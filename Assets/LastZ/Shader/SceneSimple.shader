// Frame4414：Program17050，VS17048 / FS17049。
// 对应 EID：496,505,514,523,532,541,1041,1050,1453,1460,1467。
// 阅读顺序：SceneSimpleVertex -> ResolveOpacity -> SceneSimpleFragment。
// 这是原始 GLSL 的 Unlit 路径，不计算主光、SH、Fresnel、自发光或雾。
// 本场景材质队列为 3000 + 完整 EID 序列中的 draw 索引，与 SceneLit 交错提交。
// 其中 1041/1050 仍是 One/Zero + ZWrite On；队列位置与混合方式是两件事。
Shader "LastZ/SceneSimple"
{
    Properties
    {
        [Header(Surface)]
        [MainTexture] [NoScaleOffset] _MainTex("Main texture - sRGB RGB and linear alpha", 2D) = "white" {}
        // 原 CB 是已经转换后的线性 RGBA。用 Vector 避免 Color 属性重复转换。
        _Color("Tint - linear RGBA", Vector) = (1,1,1,1)
        _AlphaIsR("Opacity source - 0 alpha 1 tinted red", Range(0,1)) = 0
        _VertexOffsetY("Local Y offset before object transform", Float) = 0

        [Header(Blurred Plane Shadow)]
        [Toggle] _BlurPlaneShadowOn("Enable screen space plane shadow", Float) = 0
        [NoScaleOffset] _PlaneBlurShadowMap("Plane shadow R - white is fully lit", 2D) = "white" {}

        [Header(Render State)]
        // 同一个程序被两种状态使用，不能把所有材质固定成同一种透明模式。
        // 透明：RGB/Alpha 都是 SrcAlpha, OneMinusSrcAlpha，ZWrite=0。
        // 不透明（1041/1050）：One, Zero，ZWrite=1；等价于原 Blend Off。
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("Source RGB blend", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("Destination RGB blend", Float) = 10
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendAlpha("Source alpha blend", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendAlpha("Destination alpha blend", Float) = 10
        [Toggle] _ZWrite("Write depth", Float) = 0
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
        Pass
        {
            Name "SceneSimpleForward"
            Tags { "LightMode"="UniversalForwardOnly" }
            Cull Back
            ZTest LEqual
            ZWrite [_ZWrite]
            Blend [_SrcBlend] [_DstBlend], [_SrcBlendAlpha] [_DstBlendAlpha]
            BlendOp Add, Add
            ColorMask RGBA

            HLSLPROGRAM
            #pragma target 3.5
            #pragma vertex SceneSimpleVertex
            #pragma fragment SceneSimpleFragment
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_PlaneBlurShadowMap);
            SAMPLER(sampler_PlaneBlurShadowMap);

            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float _AlphaIsR;
                float _VertexOffsetY;
                float _BlurPlaneShadowOn;
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
                float2 uv : TEXCOORD0;             // 原 vs_TEXCOORD0
                float4 screenPosition : TEXCOORD1; // 原 vs_TEXCOORD5
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings SceneSimpleVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                // 偏移发生在物体空间，之后才乘 ObjectToWorld 和 VP。
                // EID1050 为 +0.02；不能直接加到世界 Y，也不能再烘入网格重复偏移。
                float3 displacedPositionOS = input.positionOS + float3(0, _VertexOffsetY, 0);
                output.positionCS = TransformObjectToHClip(displacedPositionOS);
                // 原 VS 原样传 UV，没有 _MainTex_ST 的缩放或偏移。
                output.uv = input.uv;
                output.screenPosition = ComputeScreenPos(output.positionCS);
                return output;
            }

            float ResolveOpacity(float4 tintedSample)
            {
                // tintedSample = texture * _Color。
                // 常规透明度 = texture.a * _Color.a。
                // 红通道透明度 = texture.r * _Color.r * _Color.a。
                // 注意红通道也受 tint.r 影响；不能直接用原 texture.r 代替。
                float opacityFromAlpha = tintedSample.a;
                float opacityFromRed = tintedSample.r * _Color.a;
                return lerp(opacityFromAlpha, opacityFromRed, _AlphaIsR);
            }

            float4 SceneSimpleFragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                // 原 texture() 没有显式 mip bias。
                // URP14 的采样宏会自动叠加 _GlobalMipBias.x，因此先抵消它。
                float4 tintedSample = SAMPLE_TEXTURE2D_BIAS(_MainTex, sampler_MainTex,
                    input.uv, -_GlobalMipBias.x) * _Color;
                float opacity = ResolveOpacity(tintedSample);
                float3 color = tintedSample.rgb;

                if (_BlurPlaneShadowOn != 0)
                {
                    float2 screenUV = input.screenPosition.xy / input.screenPosition.w;
                    float shadowVisibility = SAMPLE_TEXTURE2D_BIAS(_PlaneBlurShadowMap,
                        sampler_PlaneBlurShadowMap, screenUV, -_GlobalMipBias.x).r;
                    // 原式：color * 0.5 + shadowR * color * 0.5。
                    // 黑色遮罩减半亮度，白色保持原色；只改 RGB，不改 Alpha。
                    color *= 0.5 + 0.5 * shadowVisibility;
                }
                // 保留 straight alpha：预乘颜色会改变原 SrcAlpha 混合结果。
                // 这里也没有 clip()，不要把透明贴片误改成 Alpha Clip。
                return float4(color, opacity);
            }
            // 原 VS 的法线、世界位置、零值光照输出均未被此 FS 读取，可删除。
            // CB 中 _MainLightOn、_Emission*、_Fresnel*、_FogON、_CutOff、
            // _Color1、_GPUSKin_TextureSize 等未参与本程序，故不伪造相应功能。
            ENDHLSL
        }
    }
    FallBack Off
}
