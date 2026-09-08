// Frame4414 / EID1016，Program31017，VS31015 / FS31016。
// 原 GLSL：Assets/LastZ/GLSL/HeightGradient_vs.txt、HeightGradient_fs.txt。
// 核心：以像素的世界 Y 在底部纯色与主贴图之间过渡，不计算法线光照。
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

        [Header(Game Environment Color)]
        // 与 SceneLit 相同的游戏自定义全局量，供学习时直接查看/调整。
        // 它们不是 URP 主光颜色；不能用场景平行光强度 1.3 替换。
        _LightColor1("Environment color - linear RGB", Vector) = (0.999986529,0.999987841,0.999995470,1)
        _LightIntensity1("Environment color intensity", Float) = 1.003173828
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
        Pass
        {
            Name "HeightGradientForward"
            Tags { "LightMode"="UniversalForwardOnly" }
            Cull Back
            ZTest LEqual
            ZWrite On
            Blend Off
            ColorMask RGBA

            HLSLPROGRAM
            #pragma target 3.5
            #pragma vertex HeightGradientVertex
            #pragma fragment HeightGradientFragment
            #pragma multi_compile_instancing
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float4 _GradientColor;
                float4 _LightColor1;
                float _Intensity;
                float _GradientHeightStart;
                float _GradientHeightEnd;
                float _GradientPower;
                float _LightIntensity1;
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
                float2 uv : TEXCOORD0;          // 原 vs_TEXCOORD0
                float worldHeight : TEXCOORD1;  // 原 vs_TEXCOORD2.y，其余分量未使用
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
                // 原 VS 直接传递 UV，没有 Tiling/Offset，也没有局部顶点偏移。
                output.uv = input.uv;
                return output;
            }

            float EvaluateTextureWeight(float worldHeight)
            {
                float heightSpan = _GradientHeightEnd - _GradientHeightStart;
                // 原式对 Start=End 未定义。仅为此无效区间增加硬切换保护。
                // 保留非零负区间的方向，不把分母强行改成正数。
                if (abs(heightSpan) < 1e-6) return step(_GradientHeightStart, worldHeight);
                float heightRatio = saturate((worldHeight - _GradientHeightStart) / heightSpan);
                float smoothHeight = heightRatio * heightRatio * (3.0 - 2.0 * heightRatio);
                // GLSL 的 exp2(log2(smoothHeight) * power) 就是幂运算。
                // 有效 power>0 时明确处理 0，避免不必要的 log2(0)。
                if (smoothHeight <= 0.0) return 0.0;
                return pow(smoothHeight, _GradientPower);
            }

            float4 HeightGradientFragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                // 原 texture() 没有 mip bias；抵消 URP14 宏自动附加的全局 bias。
                float4 mainSample = SAMPLE_TEXTURE2D_BIAS(_MainTex, sampler_MainTex,
                    input.uv, -_GlobalMipBias.x);
                float4 tintedSample = mainSample * (_Color * _Intensity);
                float3 texturedColor = tintedSample.rgb * _LightColor1.rgb * _LightIntensity1;
                float textureWeight = EvaluateTextureWeight(input.worldHeight);

                // 底色直接替换贴图颜色，不是乘在贴图上的暗色；底部细节因此消失。
                // GradientColor 不受 Color、Intensity 或环境色再次调制。
                float3 color = lerp(_GradientColor.rgb, texturedColor, textureWeight);
                // 高度渐变只改变 RGB，透明度仍来自主贴图 * Color.a * Intensity。
                return float4(color, tintedSample.a);
            }
            // 原 VS 的法线输出未被 FS 读取，已省略对应计算。
            // 原 CB 虽声明 _CutOff，但没有 discard/clip；不制造裁切功能。
            // 此程序没有 SH、Lambert、主光方向、Fresnel、雾或自发光。
            ENDHLSL
        }
    }
    FallBack Off
}
