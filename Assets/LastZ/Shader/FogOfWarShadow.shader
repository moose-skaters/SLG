Shader "LastZ/FogOfWarShadow"
{
    Properties
    {
        [Header(Fog Layer)]
        [NoScaleOffset] _FogMask("战争迷雾区域", 2D) = "white" {}
        [NoScaleOffset] _FogOfWar("已探索区域", 2D)  = "white" {}

        _Level2("区域遮罩 1 ", Range(0,1)) = 1.00
        _Level3("区域遮罩第 2 ", Range(0,1)) = 1.00
        _Level4("区域遮罩第 3 ", Range(0,1)) = 0.00

        _OffsetX("世界 X 偏移", Float) = 7.50
        _OffsetY("世界 Z 偏移", Float) = 0.00
        _UvScale(" UV 缩放", Float) = 0.97
        _AlphaDisMin("覆盖率最小值", Float) = 0.25
        _AlphaDisMax("覆盖率最大值", Float) = 0.80

        [Space(8)]
        [Header(Depth Shadow)]
        _FogShadowOffset("阴影位置偏移", Vector) = (0.00, -0.10, 0.01, 0.00)
        _VertexOffset("场景深度偏移", Vector) = (24.00, 0.00, -0.50, 0.00)
        _FogFallOff("阴影衰减距离", Float) = 25.00
        _FogPowerShadow("阴影深度衰减速率", Float) = 3.00
        _FogShadowColor("白天战争迷雾阴影颜色", Vector) = (0.02, 0.02, 0.02, 0.90)
        _FogNightShadowColor("夜晚战争迷雾阴影颜色", Vector) = (0.01, 0.03, 0.05, 1.00)

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
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            TEXTURE2D(_FogMask);
            SAMPLER(sampler_FogMask);
            TEXTURE2D(_FogOfWar);
            SAMPLER(sampler_FogOfWar);

            float4 _Params;
            float _Timeline;

            CBUFFER_START(UnityPerMaterial)
                float4 _FogShadowOffset;
                float4 _VertexOffset;
                float4 _FogShadowColor;
                float4 _FogNightShadowColor;

                float _Level2;
                float _Level3;
                float _Level4;
                float _OffsetX;
                float _OffsetY;
                float _UvScale;
                float _AlphaDisMin;
                float _AlphaDisMax;
                float _FogFallOff;
                float _FogPowerShadow;
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
                float2 meshUV : TEXCOORD2;

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings FogVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float3 displacedPositionOS = input.positionOS - _FogShadowOffset.xyz;

                output.positionWS = TransformObjectToWorld(displacedPositionOS);
                output.positionCS = TransformWorldToHClip(output.positionWS);
                output.screenPosition = ComputeScreenPos(output.positionCS);
                output.meshUV = input.uv;

                return output;
            }

            float EvaluateFogCoverage(float2 meshUV, float3 positionWS)
            {
                float4 hiddenLevels = 1.0 - SAMPLE_TEXTURE2D(_FogMask, sampler_FogMask, meshUV);
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
                return saturate((coverage - _AlphaDisMin) / (_AlphaDisMax - _AlphaDisMin));
            }

            float4 EvaluateFogShadow(Varyings input, float coverage)
            {
                float opacity = RemapCoverage(coverage);
                float2 screenUV = input.screenPosition.xy / input.screenPosition.w;
                float deviceDepth = SampleSceneDepth(screenUV);

                float sceneEyeDepth = LinearEyeDepth(deviceDepth, _ZBufferParams);
                float fogEyeDepth = input.screenPosition.w;
                float depthFade = saturate((sceneEyeDepth - fogEyeDepth + _VertexOffset.x) / _FogFallOff);
                depthFade = pow(depthFade, _FogPowerShadow);
                opacity = min(depthFade * opacity, 1.0);

                float nightAmount = 1.0 - _Timeline;
                opacity = lerp(opacity, 0.0, nightAmount);
                float4 shadowColor = lerp(_FogShadowColor, _FogNightShadowColor, nightAmount);
                return float4(shadowColor.rgb, shadowColor.a * opacity);
            }

            float4 FogFragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                float coverage = EvaluateFogCoverage(input.meshUV, input.positionWS);
                return EvaluateFogShadow(input, coverage);
            }
            ENDHLSL
        }
    }
    FallBack Off
}
