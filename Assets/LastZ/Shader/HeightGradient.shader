Shader "LastZ/HeightGradient"
{
    Properties
    {
        [Header(Textured Surface)]
        [MainTexture] [NoScaleOffset] _MainTex("Main texture - sRGB RGB and linear alpha", 2D) = "white" {}
        // Vector 保存 GPU CB 中的线性值，避免 Color 属性重复转换。
        _Color("Texture tint - linear RGBA", Vector) = (1,1,1,1)
        _Intensity("Texture intensity - RGB and alpha", Float) = 1

        [Header(World Height Gradient)]
        _GradientColor("Bottom replacement color - linear RGB", Vector) = (0.051269464,0.054480284,0.064803280,1)
        _GradientHeightStart("Bottom color at world Y", Float) = 0
        _GradientHeightEnd("Full texture at world Y", Float) = 10
        _GradientPower("Power after smoothstep - below 1 reveals texture earlier", Range(0.01,8)) = 0.2

    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
        Pass
        {
            Name "HeightGradientForward"
            Tags { "LightMode"="UniversalForwardOnly" }
        

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
                // 原式对 Start=End 未定义。仅为此无效区间增加硬切换保护。
                // 保留非零负区间的方向，不把分母强行改成正数。
                if (abs(heightSpan) < 0) return step(_GradientHeightStart, worldHeight);
                float heightRatio = saturate((worldHeight - _GradientHeightStart) / heightSpan);
                float smoothHeight = heightRatio * heightRatio * (3.0 - 2.0 * heightRatio);
                if (smoothHeight <= 0.0) return 0.0;
                return pow(smoothHeight, _GradientPower);
            }

            float4 HeightGradientFragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                
                float4 mainSample = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex,input.uv);
                float4 tintedSample = mainSample * (_Color * _Intensity);
                float3 texturedColor = tintedSample.rgb * _LightColor1.rgb * _LightIntensity1;
                
                float  Weight = EvaluateHeightBlendWeight(input.worldHeight);
                float3 color = lerp(_GradientColor.rgb, texturedColor, Weight);
                
                return float4(color, tintedSample.a);
            }
            ENDHLSL
        }
    }
    FallBack Off
}
