Shader "LastZ/FogOfWar"
{
    Properties
    {
        [Header(Fog Layer)]
        [NoScaleOffset] _FogMask("战争迷雾区域", 2D) = "white" {}
        [NoScaleOffset] _FogOfWar("已探索区域", 2D) = "white" {}

        _Level2("区域遮罩 1 ", Range(0,1)) = 1.00
        _Level3("区域遮罩第 2 ", Range(0,1)) = 1.00
        _Level4("区域遮罩第 3 ", Range(0,1)) = 0.00

        _OffsetX("世界 X 偏移", Float) = 7.50
        _OffsetY("世界 Z 偏移", Float) = 0.00
        _UvScale("最终世界地图 UV 缩放", Float) = 0.97
        _AlphaDisMin("覆盖率最小值", Float) = 0.25
        _AlphaDisMax("覆盖率最大值", Float) = 0.80

        [Space(8)]
        [Header(Cloud Layer)]
        _MainTex("云层纹理", 2D) = "white" {}
        _BlendNoise("混合噪声", 2D) = "black" {}
        _FogSpeed("雾UV速度XY与噪声ZW", Vector) = (0.01, 0.00, 0.00, 0.02)

        _Color("白天雾颜色", Vector) = (0.15, 0.17, 0.22, 1.00)
        _NightColor("夜晚雾颜色", Vector) = (0.03, 0.06, 0.09, 1.00)
        _EdgeColor("白天边缘颜色", Vector) = (0.05, 0.07, 0.10, 1.00)
        _NightEdgeColor("白天边缘颜色", Vector) = (0.11, 0.16, 0.21, 1.00)
        _TopColor("白天顶部颜色", Vector) = (0.18, 0.20, 0.26, 1.00)
        _NightTopColor("夜晚顶部颜色", Vector) = (0.04, 0.06, 0.09, 1.00)

        [Space(8)]
        [Header(Render State)]
        [Enum(UnityEngine.Rendering.CullMode)] _Cull("剔除模式", Float) = 2.00
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("深度测试", Float) = 4.00
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
        Pass
        {
            Name "FogOfWarForward"
            Tags { "LightMode"="UniversalForward" }
            Cull [_Cull]
            ZTest [_ZTest]
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha OneMinusSrcAlpha
            BlendOp Add, Add
            ColorMask RGBA

            HLSLPROGRAM
            #pragma target 3.5
            #pragma vertex FogVertex
            #pragma fragment FogFragment
            #pragma multi_compile_instancing
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // Textures.
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_FogMask);
            SAMPLER(sampler_FogMask);
            TEXTURE2D(_FogOfWar);
            SAMPLER(sampler_FogOfWar);
            TEXTURE2D(_BlendNoise);
            SAMPLER(sampler_BlendNoise);

            float4 _Params;
            float _Timeline;

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _BlendNoise_ST;
                float4 _FogSpeed;

                float4 _Color;
                float4 _NightColor;
                float4 _EdgeColor;
                float4 _NightEdgeColor;
                float4 _TopColor;
                float4 _NightTopColor;

                float _Level2;
                float _Level3;
                float _Level4;
                float _OffsetX;
                float _OffsetY;
                float _UvScale;
                float _AlphaDisMin;
                float _AlphaDisMax;
            CBUFFER_END

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float4 screenPosition : TEXCOORD1;
                float2 cloudUV : TEXCOORD2;
                float2 meshUV : TEXCOORD3;

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings FogVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float3 displacedPositionOS = input.positionOS;

                output.positionWS = TransformObjectToWorld(displacedPositionOS);
                float4 originalClipPosition = TransformWorldToHClip(output.positionWS);
                output.positionCS = originalClipPosition;
                #if UNITY_REVERSED_Z
                output.positionCS.z = 0.0000005;
                #elif defined(SHADER_API_GLCORE) || defined(SHADER_API_GLES) || defined(SHADER_API_GLES3)
                output.positionCS.z = originalClipPosition.w - 0.000001;
                #else
                output.positionCS.z = originalClipPosition.w - 0.0000005;
                #endif
                output.screenPosition = ComputeScreenPos(originalClipPosition);
                output.cloudUV = input.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                output.meshUV = input.uv;

                return output;
            }

            float EvaluateFogCoverage(float2 meshUV, float3 positionWS)
            {
                float4 hiddenLevels = 1.0- SAMPLE_TEXTURE2D(_FogMask, sampler_FogMask, meshUV);
                float hiddenRegion = lerp(hiddenLevels.r, hiddenLevels.g, _Level2);
                hiddenRegion = lerp(hiddenRegion, hiddenLevels.b, _Level3);
                hiddenRegion = lerp(hiddenRegion, hiddenLevels.a, _Level4);

                float2 worldMapUV = positionWS.xz + float2(_OffsetX, _OffsetY);
                worldMapUV = worldMapUV * _Params.z + _Params.xy;
                worldMapUV *= _UvScale;
                float exploredArea = SAMPLE_TEXTURE2D(_FogOfWar,sampler_FogOfWar,worldMapUV).r;
                return hiddenRegion * saturate(1.0 - exploredArea);
            }

            float RemapCoverage(float coverage)
            {
                // GLSL 只有线性重映射 + clamp，没有 smoothstep 或高度衰减。
                return saturate((coverage - _AlphaDisMin) / (_AlphaDisMax - _AlphaDisMin));
            }

            float4 EvaluateCloudLayer(Varyings input, float coverage)
            {
                float opacity   = RemapCoverage(saturate(coverage));
                float3 fogColor = lerp(_NightColor.rgb, _Color.rgb, _Timeline);
                float3 edgeColor = lerp(_NightEdgeColor.rgb, _EdgeColor.rgb, _Timeline);
                float3 edgeToInterior = lerp(edgeColor, fogColor, opacity);

                float seconds = _Time.y;
                float slowSeconds = _Time.x;
                float2 cloudUV = input.cloudUV + slowSeconds * _FogSpeed.xy;
                float3 cloudTexture = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,cloudUV).rgb;
                float3 texturedCloud = edgeToInterior * cloudTexture;

                float3 cloudTop = lerp(_NightTopColor.rgb, _TopColor.rgb, _Timeline);
                float2 blendUV = input.meshUV * _BlendNoise_ST.xy + _BlendNoise_ST.zw;
                blendUV += seconds * _FogSpeed.zw;
                float topAmount = SAMPLE_TEXTURE2D(_BlendNoise,sampler_BlendNoise,blendUV).r;

                float cloudAmount = 1.0 - topAmount;
                float3 finalColor = texturedCloud * cloudAmount + cloudTop * (1.0 - cloudAmount);
           
                return float4(finalColor, opacity * _Color.a);
            }

            float4 FogFragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                float coverage = EvaluateFogCoverage(input.meshUV, input.positionWS);
                return EvaluateCloudLayer(input, coverage);
            }
            ENDHLSL
        }
    }
    FallBack Off
}
