Shader "Unlit/GlitchShader" {
    Properties {
        [PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
        _Color("Tint", Color) = (1,1,1,1)
        [MaterialToggle] PixelSnap("Pixel snap", Float) = 0
        
        _Elapsed("Elapsed Seconds", Range(0, 1)) = 0.0
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
            
            float rand2(float2 seed) {
                return frac(sin(dot(seed, float2(12.9898, 78.233))) * 43758.5453);
            }
            
            float rand3(float3 seed) {
                return frac(sin(dot(seed, float3(12.9898, 78.233, 45.5432))) * 43758.5453);
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
                float2 texcoord = IN.texcoord;
                
                // horizontal chunk displacement
                float chunk = rand3(float3(0.0, interval(IN.texcoord[1], _Elapsed), _Elapsed)) * 0.04 + 0.01;
                float check = rand3(float3(0.1, interval(IN.texcoord[1], chunk), _Elapsed));
                if (check < 0.1) {
                    texcoord[0] += rand3(float3(0.2, interval(IN.texcoord[1], chunk), _Elapsed)) * 0.02;
                }
                
                fixed4 c = SampleSpriteTexture (texcoord) * IN.color;
				c.rgb *= c.a;
				return c;
			}
		ENDCG
		}
	}
}
