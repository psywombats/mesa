Shader "Unlit/GlitchShader" {
    Properties {
        [PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
        _Color("Tint", Color) = (1,1,1,1)
        [MaterialToggle] PixelSnap("Pixel snap", Float) = 0
        
        _Elapsed("Elapsed Seconds", Float) = 1.0
        
        [Space(25)][MaterialToggle] _HDispEnabled(" === Horizontal Disp Enabled === ", Float) = 1.0
        [MaterialToggle] _HDispSloppyPower("HDisp Sloppy Power", Float) = 0
        _HDispChance("HDisp Chance", Range(0, 1)) = 0.5
        _HDispPower("HDisp Power", Range(0, 1)) = 0.5
        _HDispPowerVariance("HDisp Power Variance", Range(0, 1)) = 0.5
        _HDispChunking("HDisp Chunk Size", Range(0, 1)) = 0.5
        _HDispChunkingVariance("HDisp Chunking Variance", Range(0, 1)) = 0.5
        
        [Space(25)][MaterialToggle] _HBleedEnabled(" === Horizontal Bleed Enabled === ", Float) = 0
        [MaterialToggle] _HBleedAlphaRestrict("HBleed Alpha Restricted", Float) = 0
        _HBleedChance("HBleed Chance", Range(0, 1)) = 0.5
        _HBleedChunking("HBleed Chunk Size", Range(0, 1)) = 0.5
        _HBleedChunkingVariance("HBleed Chunking Variance", Range(0, 1)) = 0.5
        _HBleedTailing("HBleed Tail Size", Range(0, 1)) = 0.5
        _HBleedTailingVariance("HBleed Tail Variance", Range(0, 1)) = 0.5
        
        [Space(25)][MaterialToggle] _SFrameEnabled(" === Static Frames Enabled === ", Float) = 0
        [MaterialToggle] _SFrameAlphaIncluded("HBleed Alpha Included", Float) = 0
        _SFrameChance("SFrame Chance", Range(0, 1)) = 0.5
        _SFrameChunking("SFrame Chunk Size", Range(0, 1)) = 0.5
        _SFrameChunkingVariance("SFrame Chunking Variance", Range(0, 1)) = 0.5
        
        [Space(25)][MaterialToggle] _PDistEnabled(" === Palette Distortion Enabled === ", Float) = 0
        [MaterialToggle] _PDistAlphaIncluded("PDist Alpha Included", Float) = 0
        [MaterialToggle] _PDistSimultaneousInvert("Simultaneous Invert", Float) = 0
        _PDistInvertR("R Inversion Chance", Range(0, 1)) = 0.0
        _PDistInvertG("G Inversion Chance", Range(0, 1)) = 0.0
        _PDistInvertB("B Inversion Chance", Range(0, 1)) = 0.0
        _PDistMaxR("R Max Chance", Range(0, 1)) = 0.0
        _PDistMaxG("G Max Chance", Range(0, 1)) = 0.0
        _PDistMaxB("B Max Chance", Range(0, 1)) = 0.0
        _PDistMonocolorChance("Monocolor Chance", Range(0, 1)) = 0.0
        _PDistMonocolor("Monocolor", Color) = (1.0, 1.0, 1.0, 1.0)
        
        [Space(25)][MaterialToggle] _RDispEnabled(" === Rectangular Displacement Enabled === ", Float) = 0.0
        [MaterialToggle] _RDispCopyOnly("RDisp Non-destructive Swatch Moving", Range(0, 1)) = 0.0
        _RDispTex("Background Texture", 2D) = "black" {}
        _RDispChance("RDisp Chance", Range(0, 1)) = 0.5
        [MaterialToggle] _RDispSquareChunk("RDisp Only Square Chunking", Range(0, 1)) = 0.0
        _RDispChunkXSize("RDisp Chunk X Size", Range(0, 1)) = 0.5
        _RDispChunkYSize("RDisp Chunk Y Size", Range(0, 1)) = 0.5
        _RDispChunkVariance("RDisp Chunking Variance", Range(0, 1)) = 0.5
        [MaterialToggle] _RDispSquareDisp("RDisp Only Square Displacement", Range(0, 1)) = 0.0
        _RDispMinPowerX("RDisp Displacement Min Power X", Range(-1, 1)) = -0.5
        _RDispMaxPowerX("RDisp Displacement Max Power X", Range(-1, 1)) = 0.5
        _RDispMinPowerY("RDisp Displacement Min Power Y", Range(-1, 1)) = -0.5
        _RDispMaxPowerY("RDisp Displacement Max Power Y", Range(-1, 1)) = 0.5
        
        [Space(25)][MaterialToggle] _VSyncEnabled(" === VSync Enabled === ", Float) = 0.0
        _VSyncPowerMin("VSync Min Jitter Power", Range(-1, 1)) = -0.5
        _VSyncPowerMax("VSync Max Jitter Power", Range(-1, 1)) = 0.5
        _VSyncJitterChance("VSync Jitter Chance", Range(0, 1)) = 0.5
        _VSyncJitterDuration("VSync Jitter Duration", Range(0, 1)) = 0.5
        _VSyncChance("VSync Loop Chance", Range(0, 1)) = 0.5
        _VSyncDuration("VSync Loop Duration", Range(0, 1)) = 0.5
        
        [Space(25)][MaterialToggle] _SShiftEnabled(" === Scanline Shift Enabled == ", Float) = 0.0
        _SShiftChance("SShift Chance", Range(0, 1)) = .5
        _SShiftPowerMin("SShift Power Min", Range(0, 1)) = 0.25
        _SShiftPowerMax("SShift Power Max", Range(0, 1)) = 0.5
        
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
            float _HBleedChunking;
            float _HBleedChunkingVariance;
            float _HBleedTailing;
            float _HBleedTailingVariance;
            float _HBleedAlphaRestrict;
            
            float _SFrameEnabled;
            float _SFrameAlphaIncluded;
            float _SFrameChance;
            float _SFrameChunking;
            float _SFrameChunkingVariance;
            
            float _PDistEnabled;
            float _PDistAlphaIncluded;
            float _PDistInvertR;
            float _PDistInvertG;
            float _PDistInvertB;
            float _PDistSimultaneousInvert;
            float _PDistMaxR;
            float _PDistMaxG;
            float _PDistMaxB;
            float _PDistMonocolorChance;
            float4 _PDistMonocolor;
            
            float _RDispEnabled;
            sampler2D _RDispTex;
            float _RDispSquareChunk;
            float _RDispChunkXSize;
            float _RDispChunkYSize;
            float _RDispChunkVariance;
            float _RDispSquareDisp;
            float _RDispMinPowerX;
            float _RDispMaxPowerX;
            float _RDispMinPowerY;
            float _RDispMaxPowerY;
            float _RDispChance;
            float _RDispCopyOnly;
            
            float _VSyncEnabled;
            float _VSyncPowerMin;
            float _VSyncPowerMax;
            float _VSyncChance;
            float _VSyncDuration;
            float _VSyncJitterChance;
            float _VSyncJitterDuration;
            
            float _SShiftEnabled;
            float _SShiftChance;
            float _SShiftPowerMin;
            float _SShiftPowerMax;
            
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
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
            
            float rand2(float seed1, float seed2) {
                return frac(sin(dot(float2(seed1, seed2), float2(12.9898, 78.233))) * 43758.5453);
            }
            
            float rand3(float seed1, float seed2, float seed3) {
                return frac(sin(dot(float3(seed1, seed2, seed3), float3(45.5432, 12.9898, 78.233))) * 43758.5453);
            }
            
            float lerp(float a, float b, float r) {
                return r * a + (1.0 - r) * b;
            }
            
            // returns a result between rangeMin and rangeMax, eased
            float randRange(float rangeMin, float rangeMax, float easedMax, float3 seed) {
                float base = rangeMin;
                base = base + (rangeMax - rangeMin) * rand3(seed[0], seed[1], seed[2]);
                return cubicEase(base, easedMax);
            }
            
            // varies the source value by a percentage
            // seed: seed value to pass to rand
            // source: the value to modify
            // variance: from 0-1 how much variance is allowed (from slider)
            // varianceRange: at max variance, the percent that source varies
            float variance3(float source, float variance, float varianceRange, float3 seed) {
                float v = variance * varianceRange;
                float v2 = v * rand3(seed[0], seed[1], seed[2]);
                return source + (source * v2);
            }
            
            // same as interval but no covariance and not clamped (for time)
            float intervalT(float interval) {
                return ((float)((int)(_Elapsed * (1.0/interval)))) * interval;
            }
            
            // same as interval, except it should covary based on a given seed
            float intervalR(float source, float interval, float seed) {
                float stagger = rand2(seed, _Elapsed);
                float result = ((float)((int)((source + stagger) * (1.0/interval)))) * interval - stagger;
                return clamp(result, 0.0, 1.0);
            }
            
            // argument is in range 0-1
            // but we need to clamp it to say, 0.0, 0.2, 0.4 etc for 1/5 chunks
            float interval(float source, float interval) {
                return intervalR(source, interval, 12.34);
            }
            
            // inverts a given color channel
            // source: this is the source color that will be inverted
            // channelIndex: the index to flip (r/g/b 0/1/2)
            // chance: will be cubicly eased to 0-1 range
            // seed: covariant
            fixed4 invertChannel(fixed4 source, int channelIndex, float chance, float seed) {
                fixed4 result = source;
                float roll = rand2(_Elapsed, seed);
                float invertChance = cubicEase(chance, 1.0);
                if ((roll > 1.0 - invertChance) && (source.a > 0.02 || _PDistAlphaIncluded > 0.0)) {
                    result[channelIndex] = 1.0 - result[channelIndex];
                }
                return result;
            }
            fixed4 maxChannel(fixed4 source, int channelIndex, float chance, float seed) {
                fixed4 result = source;
                float roll = rand2(_Elapsed, seed);
                float invertChance = cubicEase(chance, 1.0);
                if ((roll > 1.0 - invertChance) && (source.a > 0.02 || _PDistAlphaIncluded > 0.0)) {
                    result[channelIndex] = 1.0;
                }
                return result;
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
                float2 pxXY = IN.vertex;
                float t = _Elapsed + 500.0;
                
                // horizontal chunk displacement
                if (_HDispEnabled > 0.0) {
                    float hdispChunkSize = variance3(cubicEase(_HDispChunking, 0.2), _HDispChunkingVariance, 1.0, float3(0.0, 0.0, t));
                    float hdispChance = cubicEase(_HDispChance, 0.05);
                    float hdispRoll = rand3(0.1, interval(xy[1], hdispChunkSize), t);
                    if (hdispRoll > 1.0 - hdispChance) {
                        float powerSeed = _HDispSloppyPower < 1.0 ? interval(xy[1], hdispChunkSize) : xy[1];
                        xy[0] += variance3(cubicEase(_HDispPower, 0.15), _HDispPowerVariance, 1.0, float3(0.2, powerSeed, t));
                    }
                }
                
                // v-sync
                if (_VSyncEnabled > 0.0 ) {
                    float syncDuration = cubicEase(_VSyncDuration, 0.5);
                    float syncChunk = intervalT(syncDuration);
                    float syncChance = cubicEase(_VSyncChance, 1.0);
                    float syncRoll = rand2(syncChunk, 20.0);
                    if (syncRoll > 1.0 - syncChance) {
                        float syncElapsed = (_Elapsed - syncChunk) / syncDuration;
                        xy[1] -= syncElapsed;
                    } else {
                        float jitterDuration = cubicEase(_VSyncJitterDuration, 0.4);
                        float jitterChunk = intervalT(jitterDuration);
                        float jitterChance = cubicEase(_VSyncJitterChance, 1.0);
                        float jitterRoll = rand2(jitterChunk, 21.0);
                        if (jitterRoll > 1.0 - jitterChance) {
                            float jitterElapsed = (_Elapsed - jitterChunk) / jitterDuration;
                            float power = randRange(_VSyncPowerMin, _VSyncPowerMax, 0.4, float3(jitterChunk, 22.0, 22.0));
                            if (jitterElapsed < 0.5) {
                                power *= (jitterElapsed * 2.0);
                            } else {
                                power *= (1.0 - ((jitterElapsed - 0.5) * 2.0));
                            }
                            xy[1] += power;
                        }
                    }
                    if (xy[1] < 0.0) {
                        xy[1] += 1.0;
                    }
                    if (xy[1] > 1.0) {
                        xy[1] -= 1.0;
                    }
                }
                
                // scanline shift
                if (_SShiftEnabled > 0.0) {
                    float chance = cubicEase(_SShiftChance, 1.0);
                    float roll = rand2(23.0, t);
                    if (roll > 1.0 - chance) {
                        int remain = 0;
                        if (rand2(t, 24.0) > 0.5) {
                            remain = 1;
                        }
                        int mod = pxXY[1] % 2;
                        if (mod == remain) {
                            float power = randRange(_SShiftPowerMin, _SShiftPowerMax, 0.2, float3(24.0, t, 0.0));
                            if (rand2(t, 25.0) > 0.5) {
                                power *= -1;
                            }
                            xy[0] += power;
                        }
                    }
                }
                
                fixed4 c = SampleSpriteTexture(xy) * IN.color;
				c.rgb *= c.a;
                
                // rectangular displacement
                if (_RDispEnabled > 0.0) {
                    float chunkSizeX = variance3(cubicEase(_RDispChunkXSize, 0.3), _RDispChunkVariance, 1.0, float3(11.0, 0.0, t));
                    float chunkSizeY = variance3(cubicEase(_RDispChunkYSize, 0.3), _RDispChunkVariance, 1.0, float3(13.0, 0.0, t));
                    float chance = cubicEase(_RDispChance, 1.0);
                    
                    // source (we are the source coords)
                    if (_RDispCopyOnly == 0.0) {
                        float sourceChunkX = intervalR(xy[0], chunkSizeX, 12.0);
                        float sourceChunkY = intervalR(xy[1], chunkSizeY, 14.0);
                        float sourceRoll = rand3(t, sourceChunkX, sourceChunkY);
                        if (sourceRoll > 1.0 - chance) {
                            c = tex2D(_RDispTex, xy);
                            c.rgb *= c.a;
                        }
                    }

                    // destination (we are the destination coords)
                    float offX = randRange(_RDispMinPowerX, _RDispMaxPowerX, 0.2, float3(15.0, 0.0, t));
                    float offY = randRange(_RDispMinPowerY, _RDispMaxPowerY, 0.2, float3(16.0, 0.0, t));
                    float sourceX = xy[0] + offX;
                    float sourceY = xy[1] + offY;
                    float sourceChunkX = intervalR(sourceX, chunkSizeX, 12.0);
                    float sourceChunkY = intervalR(sourceY, chunkSizeY, 14.0);
                    float sourceRoll = rand3(t, sourceChunkX, sourceChunkY);
                    if (sourceRoll > 1.0 - chance) {
                        c = tex2D(_MainTex, float2(sourceX, sourceY));
                        c.rgb *= c.a;
                    }
                }
                
                // horizontal color bleed
                if (_HBleedEnabled > 0.0) {
                    float hbleedTailSize = variance3(cubicEase(_HBleedTailing, 0.5), _HBleedTailingVariance, 1.0, float3(0.0, 0.0, t));
                    float hbleedChunkSize = variance3(cubicEase(_HBleedChunking, 0.2), _HBleedChunkingVariance, 1.0, float3(0.0, 0.0, t));
                    float hbleedChance = cubicEase(_HBleedChance, 1.0);
                    float hbleedYInterval = interval(xy[1], 0.1);
                    float hbleedXInterval = intervalR(xy[0], abs(hbleedTailSize), hbleedChance * 100);
                    float hbleedRoll = rand3(hbleedXInterval * 100, hbleedYInterval * 200, t);
                    if (hbleedRoll > 1.0 - hbleedChance) {
                        float r = (xy[0] - hbleedXInterval) / abs(hbleedTailSize);
                        fixed4 c2 = SampleSpriteTexture(float2(hbleedXInterval, xy[1])) * IN.color;
                        c2.rgb *= c2.a;
                        
                        fixed4 smear;
                        smear.r = lerp(c.r, c2.r, r);
                        smear.g = lerp(c.g, c2.g, r);
                        smear.b = lerp(c.b, c2.b, r);
                        if (c.a < 0.02 || _HBleedAlphaRestrict < 1.0) {
                            c.r = (smear.r > c.r) ? smear.r : c.r;
                            c.g = (smear.g > c.g) ? smear.g : c.g;
                            c.b = (smear.b > c.b) ? smear.b : c.b;
                        }
                    }
                }
                
                // static frames
                if (_SFrameEnabled > 0.0) {
                    float sframeChance = cubicEase(_SFrameChance, 1.0) + 0.01;
                    float sframeRoll = rand2(0.6, t);
                    if ((_SFrameAlphaIncluded || c.a >= 0.02) && (sframeRoll > 1.0 - sframeChance)) {
                        float sframeChunkSize = variance3(cubicEase(_SFrameChunking, 0.2), _SFrameChunkingVariance, 1.0, float3(0.0, 0.0, t));
                        if (sframeChunkSize < 0.001) {
                            sframeChunkSize = 0.001;
                        }
                        float sframeInterval = intervalR(xy[0], sframeChunkSize, t);
                        float sframeSubroll = rand3(sframeInterval * 200.0, xy[1] * 1000.0, t);
                        if (sframeSubroll > 0.5) {
                            c = float4(0.0, 0.0, 0.0, 1.0);
                        } else {
                            c = float4(1.0, 1.0, 1.0, 1.0);
                        }
                    }
                }
                
                // palette distorions
                if (_PDistEnabled > 0.0) {
                    float covariant = 5.0;
                    c = invertChannel(c, 0, _PDistInvertR, covariant);
                    if (_PDistSimultaneousInvert != 0.0) covariant += 1.0;
                    c = invertChannel(c, 1, _PDistInvertG, covariant);
                    if (_PDistSimultaneousInvert != 0.0) covariant += 1.0;
                    c = invertChannel(c, 2, _PDistInvertB, covariant);
                    
                    c = maxChannel(c, 0, _PDistMaxR, 8.0);
                    c = maxChannel(c, 1, _PDistMaxG, 9.0);
                    c = maxChannel(c, 2, _PDistMaxB, 10.0);
                    
                    float monoRoll = rand2(t, 11.0);
                    float monoChance = cubicEase(_PDistMonocolorChance, 1.0);
                    if (monoRoll > 1.0 - monoChance) {
                        float bright = (c[0] + c[1] + c[2]) / 3.0;
                        c[0] = _PDistMonocolor[0] * bright;
                        c[1] = _PDistMonocolor[1] * bright;
                        c[2] = _PDistMonocolor[2] * bright;
                    }
                }
                
				return c;
			}
		ENDCG
		}
	}
}
