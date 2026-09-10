Shader "LastZ/HeightGradient"
{
    Properties
    {
        [Header(Surface)]
        [MainTexture] [NoScaleOffset] _MainTex("主纹理", 2D) = "white" {}
        _Color("基础颜色", Vector) = (1,1,1,1)
        _Intensity("颜色强度", Float) = 1

        [Space(8)]
        [Header(Height Gradient)]
        _GradientColor("底部颜色", Vector) = (0.05,0.05,0.06,1)
        _GradientHeightStart("渐变起始高度", Float) = 0
        _GradientHeightEnd("渐变结束高度", Float) = 10
        _GradientPower("渐变对比度", Range(0.01,8)) = 0.2
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
        Pass
        {
            Name "HeightGradientForward"
            Tags { "LightMode"="UniversalForward" }
        

            HLSLPROGRAM
            #pragma target 3.5
            #pragma vertex HeightGradientVertex
            #pragma fragment HeightGradientFragment
            #pragma multi_compile_instancing
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            float4 _LightColor1;
            float _LightIntensity1;

            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float4 _GradientColor;
                float _Intensity;
                float _GradientHeightStart;
                float _GradientHeightEnd;
                float _GradientPower;
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
                float2 uv : TEXCOORD0;         
                float worldHeight : TEXCOORD1;  
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings HeightGradientVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                float3 positionWS = TransformObjectToWorld(input.positionOS);
                output.positionCS = TransformWorldToHClip(positionWS);
                output.worldHeight = positionWS.y;
             
                output.uv = input.uv;
                return output;
            }

            float EvaluateHeightBlendWeight(float worldHeight)
            {
                float heightSpan = _GradientHeightEnd - _GradientHeightStart;
                float heightRatio = saturate((worldHeight - _GradientHeightStart) / heightSpan);
                float smoothHeight = heightRatio * heightRatio * (3.0 - 2.0 * heightRatio);
                return pow(smoothHeight, _GradientPower);
            }

            float4 HeightGradientFragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                
                float4 mainSample = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex,
                    input.uv);
                float4 tintedSample = mainSample * (_Color * _Intensity);
                float3 texturedColor = tintedSample.rgb * _LightColor1.rgb * _LightIntensity1;
                
                float weight = EvaluateHeightBlendWeight(input.worldHeight);
                float3 color = lerp(_GradientColor.rgb, texturedColor, weight);
                
                return float4(color, tintedSample.a);
            }
            ENDHLSL
        }
    }
    FallBack Off
}
