Shader "Unlit/GlitchShader" {
    Properties {
        [PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
        _Color("Tint", Color) = (1,1,1,1)
        [MaterialToggle] PixelSnap("Pixel snap", Float) = 0
        
        _Elapsed("Elapsed Seconds", Range(0, 1)) = 1.0
        
        [MaterialToggle] _HDispEnabled(" === HDisp Enabled === ", Float) = 1.0
        [MaterialToggle] _HDispSloppyPower("HDisp Sloppy Power", Float) = 0
        _HDispChance("HDisp Chance", Range(0, 1)) = 0.5
        _HDispPower("HDisp Power", Range(0, 1)) = 0.5
        _HDispPowerVariance("HDisp Power Variance", Range(0, 1)) = 0.5
        _HDispChunking("HDisp Chunk Size", Range(0, 1)) = 0.5
        _HDispChunkingVariance("HDisp Chunking Variance", Range(0, 1)) = 0.5
        
        [MaterialToggle] _HBleedEnabled(" === HBleed Enabled === ", Float) = 0
        [MaterialToggle] _HBleedAlphaRestrict("HBleed Alpha Restricted", Float) = 0
        _HBleedChance("HBleed Chance", Range(0, 1)) = 0.5
        _HBleedPower("HBleed Power", Range(-1, 1)) = 0.5
        _HBleedPowerVariance("HBleed Power Variance", Range(0, 1)) = 0.5
        _HBleedChunking("HBleed Chunk Size", Range(0, 1)) = 0.5
        _HBleedChunkingVariance("HBleed Chunking Variance", Range(0, 1)) = 0.5
        _HBleedTailing("HBleed Tail Size", Range(0, 1)) = 0.5
        _HBleedTailingVariance("HBleed Tail Variance", Range(0, 1)) = 0.5
    }
    
	SubShader {
		Tags { 
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}

		Cull Off
		Lighting Off
		ZWrite Off
		Blend One OneMinusSrcAlpha

		Pass {
            CGPROGRAM
            
            float _Elapsed;
            
            float _HDispEnabled;
            float _HDispChance;
            float _HDispPower;
            float _HDispPowerVariance;
            float _HDispChunking;
            float _HDispChunkingVariance;
            float _HDispSloppyPower;
            
            float _HBleedEnabled;
            float _HBleedChance;
            float _HBleedPower;
            float _HBleedPowerVariance;
            float _HBleedChunking;
            float _HBleedChunkingVariance;
            float _HBleedTailing;
            float _HBleedTailingVariance;
            float _HBleedAlphaRestrict;
            
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			#pragma multi_compile _ PIXELSNAP_ON
			#pragma multi_compile _ ETC1_EXTERNAL_ALPHA
			#include "UnityCG.cginc"
			
			struct appdata_t {
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f {
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				float2 texcoord  : TEXCOORD0;
				UNITY_VERTEX_OUTPUT_STEREO
			};
			
			fixed4 _Color;

			v2f vert(appdata_t IN) {
				v2f OUT;
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.texcoord = IN.texcoord;
				OUT.color = IN.color * _Color;
#ifdef PIXELSNAP_ON
				OUT.vertex = UnityPixelSnap (OUT.vertex);
#endif

				return OUT;
			}

			sampler2D _MainTex;
			sampler2D _AlphaTex;
            
            // for when 0.0001 and 0.1 are equally valid
            // source is from a slider, usually 0-1
            float cubicEase(float source,  float newMax) {
                return (source * source * source) * newMax;
            }
            
            // simple remap from source to a new max scale
            float ease(float source, float newMax) {
                return source * newMax;
            }
            
            float rand2(float2 seed) {
                return frac(sin(dot(seed, float2(12.9898, 78.233))) * 43758.5453);
            }
            
            float rand3(float3 seed) {
                return frac(sin(dot(seed, float3(45.5432, 12.9898, 78.233))) * 43758.5453);
            }
            
            float lerp(float a, float b, float r) {
                return r * a + (1.0 - r) * b;
            }
            
            // varies the source value by a percentage
            // seed: seed value to pass to rand
            // source: the value to modify
            // variance: from 0-1 how much variance is allowed (from slider)
            // varianceRange: at max variance, the percent that source varies
            float variance3(float source, float variance, float varianceRange, float3 seed) {
                float v = variance * varianceRange;
                float v2 = v * rand3(seed);
                return source + (source * v2);
            }
            
            // argument is in range 0-1
            // but we need to clamp it to say, 0.0, 0.2, 0.4 etc for 1/5 chunks
            float interval(float source, float interval) {
                return ((float)((int)(source * (1.0/interval)))) * interval;
            }

			fixed4 SampleSpriteTexture (float2 uv) {
				fixed4 color = tex2D (_MainTex, uv);

#if ETC1_EXTERNAL_ALPHA
				// get the color from an external texture (usecase: Alpha support for ETC1 on android)
				color.a = tex2D (_AlphaTex, uv).r;
#endif //ETC1_EXTERNAL_ALPHA

				return color;
			}

			fixed4 frag(v2f IN) : SV_Target {
                float2 xy = IN.texcoord;
                float t = _Elapsed + 500.0;
                
                // horizontal chunk displacement
                if (_HDispEnabled > 0.0) {
                    float hdispChunkSize = variance3(cubicEase(_HDispChunking, 0.2), _HDispChunkingVariance, 1.0, float3(0.0, 0.0, t));
                    float hdispChance = cubicEase(_HDispChance, 0.05);
                    float hdispRoll = rand3(float3(0.1, interval(xy[1], hdispChunkSize), t));
                    if (hdispRoll > 1.0 - hdispChance) {
                        float powerSeed = _HDispSloppyPower < 1.0 ? interval(xy[1], hdispChunkSize) : xy[1];
                        xy[0] += variance3(cubicEase(_HDispPower, 0.15), _HDispPowerVariance, 1.0, float3(0.2, powerSeed, t));
                    }
                }
                
                fixed4 c = SampleSpriteTexture(xy) * IN.color;
				c.rgb *= c.a;
                
                // horizontal color bleed
                if (_HBleedEnabled > 0.0) {
                    float hbleedTailSize = variance3(cubicEase(_HBleedTailing, 0.5), _HBleedTailingVariance, 1.0, float3(0.0, 0.0, t));
                    float hbleedChunkSize = variance3(cubicEase(_HBleedChunking, 0.2), _HBleedChunkingVariance, 1.0, float3(0.0, 0.0, t));
                    float hbleedChance = cubicEase(_HBleedChance, 1.0);
                    float hbleedXInterval = interval(xy[0], abs(hbleedTailSize));
                    float hbleedYInterval = interval(xy[1], hbleedChunkSize);
                    float hbleedRoll = rand3(float3(hbleedXInterval, hbleedYInterval, t));
                    if (hbleedRoll > 1.0 - hbleedChance) {
                        float r = (xy[0] - hbleedXInterval) / abs(hbleedTailSize);
                        fixed4 c2 = SampleSpriteTexture(float2(hbleedXInterval, xy[1])) * IN.color;
                        c2.rgb *= c2.a;
                        
                        fixed4 smear;
                        smear.r = lerp(c.r, c2.r, r);
                        smear.g = lerp(c.g, c2.g, r);
                        smear.b = lerp(c.b, c2.b, r);
                        if (c.a == 0.0 || _HBleedAlphaRestrict < 1.0) {
                            c.r = (smear.r > c.r) ? smear.r : c.r;
                            c.g = (smear.g > c.g) ? smear.g : c.g;
                            c.b = (smear.b > c.b) ? smear.b : c.b;
                        }
                    }
                }
                
				return c;
			}
		ENDCG
		}
	}
}
