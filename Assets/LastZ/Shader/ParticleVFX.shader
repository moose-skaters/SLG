Shader "LastZ/ParticleVFX"
{
    Properties
    {
        [Header(Main Texture and Color)]
        [MainTexture] _Main_Tex("主纹理（RGB 和 Alpha）", 2D) = "white" {}
        _Main_Color("主颜色（线性 HDR RGBA）", Vector) = (3.00, 3.00, 3.00, 1.00)
        _Main_UV("主纹理 UV 滚动速度 XY（每秒）", Vector) = (0.00, 0.00, 0.00, 0.00)
        _Main_tex_Rotator("主纹理顺时针旋转角度（绕原点，度）", Float) = 0.00
        _Particle_SpeedUV("使用粒子 UV1 XY 偏移替代时间滚动", Float) = 0.00
        _Brightness("亮度", Float) = 1.00
        _Saturation("饱和度", Float) = 1.00
        _Contrast("对比度（围绕 0.5，先限制再乘 HDR 颜色）", Float) = 1.00

        [Space(8)]
        [Header(Alpha and Flipbook)]
        _Alpha("透明度", Float) = 1.00
        _AlphaSub("纹理 Alpha 减去的值（再限制到 0~1）", Float) = 0.00
        _Alpha_NO_R("使用纹理 R 通道混合 Alpha", Float) = 0.00
        [Toggle] _FlipBookBlend_On("使用 UV2 X 混合 UV0 ZW 下一帧", Float) = 0.00
        [Toggle] _AlphaPremultiply("使用最终 Alpha 预乘输出 RGB", Float) = 0.00

        [Space(8)]
        [Header(Original One Axis Parallax)]
        [Toggle] _ParallaxOn("启用原始切线轴视差", Float) = 0.00
        [Enum(R,0,G,1,B,2,A,3)] _ParallaxChannel("视差高度通道（处理基础 Alpha 后）", Float) = 0.00
        _ParallaxScale("视差 UV 位移强度", Float) = 1.00
        _ParallaxEdgeColor("视差边缘颜色（线性 RGB）", Vector) = (0.00, 0.00, 0.00, 1.00)

        [HideInInspector] _Tex_2_ST("未使用的顶点阶段第二组 UV 变换", Vector) = (1.00, 1.00, 0.00, 0.00)
        [HideInInspector] _Tex_2_UV("未使用的顶点阶段第二组 UV 速度", Vector) = (0.00, 0.00, 0.00, 0.00)

        [Space(8)]
        [Header(Captured Draw State)]
        [Enum(UnityEngine.Rendering.CullMode)] _Cull("剔除模式", Float) = 0.00
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("深度测试", Float) = 4.00
        [Toggle] _ZWrite("深度写入", Float) = 0.00
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("RGB 源混合因子", Float) = 5.00
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("RGB 目标混合因子", Float) = 1.00
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendAlpha("Alpha 源混合因子", Float) = 5.00
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendAlpha("Alpha 目标混合因子", Float) = 1.00
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }

        Pass
        {
            Name "ParticleVFXForward"

            Tags { "LightMode" = "UniversalForward" }

            Cull [_Cull]
            ZTest [_ZTest]
            ZWrite [_ZWrite]
            Blend [_SrcBlend] [_DstBlend], [_SrcBlendAlpha] [_DstBlendAlpha]
            ColorMask RGBA

            HLSLPROGRAM
            #pragma target 3.5
            #pragma vertex ParticleVertex
            #pragma fragment ParticleFragment
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

            TEXTURE2D(_Main_Tex);
            SAMPLER(sampler_Main_Tex);

            CBUFFER_START(UnityPerMaterial)
                float4 _Main_Tex_ST;
                float4 _Main_Color;
                float4 _Main_UV;
                float4 _ParallaxEdgeColor;
                float4 _Tex_2_ST;
                float4 _Tex_2_UV;

                float _Main_tex_Rotator;
                float _Particle_SpeedUV;
                float _Brightness;
                float _Saturation;
                float _Contrast;

                float _Alpha;
                float _AlphaSub;
                float _Alpha_NO_R;
                float _FlipBookBlend_On;
                float _AlphaPremultiply;

                float _ParallaxOn;
                float _ParallaxChannel;
                float _ParallaxScale;

                float _Cull;
                float _ZTest;
                float _ZWrite;
                float _SrcBlend;
                float _DstBlend;
                float _SrcBlendAlpha;
                float _DstBlendAlpha;
            CBUFFER_END

            struct Attributes
            {
                float3 positionOS : POSITION;
                float4 tangentOS : TANGENT;
                float4 color : COLOR;
                float4 uv0 : TEXCOORD0; // XY 当前帧，ZW 下一帧；保留完整输入。
                float4 uv1 : TEXCOORD1; // XY 粒子自定义滚动偏移。
                float4 uv2 : TEXCOORD2; // X 两帧插值量。

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float4 color : COLOR;
                float2 mainUV : TEXCOORD0;
                float2 nextFrameUV : TEXCOORD1;
                float frameBlend : TEXCOORD2;
                float2 parallaxView : TEXCOORD3;
                float2 secondaryUV : TEXCOORD4;

                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings ParticleVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float3 positionWS = TransformObjectToWorld(input.positionOS);
                output.positionCS = TransformWorldToHClip(positionWS);

                float timeSeconds = _Time.y;
                float2 baseUV = input.uv0.xy * _Main_Tex_ST.xy+ _Main_Tex_ST.zw;
                float2 timedUV = baseUV + timeSeconds * _Main_UV.xy;
                float2 particleUV = baseUV + input.uv1.xy;
                float2 scrollingUV = lerp(timedUV, particleUV, _Particle_SpeedUV);

                float sine, cosine;
                sincos(_Main_tex_Rotator * 0.017453294, sine, cosine);
                output.mainUV = float2(dot(scrollingUV, float2(cosine, sine)),dot(scrollingUV, float2(-sine, cosine)));

                output.nextFrameUV = input.uv0.zw;
                output.frameBlend = input.uv2.x;
                output.color = input.color;
                output.secondaryUV = input.uv0.xy * _Tex_2_ST.xy+ _Tex_2_ST.zw + timeSeconds * _Tex_2_UV.xy;

                if (_ParallaxOn != 0)
                {
                    float3 tangentWS = normalize(TransformObjectToWorldDir(input.tangentOS.xyz, false));
                    float3 viewDirectionWS = normalize(_WorldSpaceCameraPos - positionWS);
                    output.parallaxView = float2(dot(tangentWS, viewDirectionWS), 0);
                }

                return output;
            }

            float4 SampleMainTexture(float2 uv)
            {
                return SAMPLE_TEXTURE2D(_Main_Tex, sampler_Main_Tex, uv);
            }

            float4 SampleParticleSurface(Varyings input)
            {
                float4 surface = SampleMainTexture(input.mainUV);
                float adjustedAlpha = saturate(surface.a - _AlphaSub);
                surface.a = lerp(adjustedAlpha, surface.r, _Alpha_NO_R);

                if (_ParallaxOn != 0)
                {
                    float height = surface[(int)_ParallaxChannel];
                    float2 displacedUV = input.mainUV + (1.0 - height) * input.parallaxView * _ParallaxScale;
                    float4 displaced = SampleMainTexture(displacedUV);
                    float edgeWeight = lerp(displaced.a, displaced.r, _Alpha_NO_R);
                    surface.rgb = lerp(_ParallaxEdgeColor.rgb, displaced.rgb, edgeWeight);
                }

                if (_FlipBookBlend_On != 0)
                {
                    float4 nextFrame = SampleMainTexture(input.nextFrameUV);
                    nextFrame.a = saturate(nextFrame.a - _AlphaSub);
                    surface = lerp(surface, nextFrame, input.frameBlend);
                }

                return surface;
            }

            float3 AdjustParticleColor(float3 textureColor, float3 vertexColor)
            {
                float luminance = Luminance(textureColor);
                float3 saturatedColor = lerp(luminance.xxx, textureColor, _Saturation);
                float3 contrastColor = saturate((saturatedColor - 0.5) * _Contrast + 0.5);
                return contrastColor * _Main_Color.rgb * _Brightness * vertexColor;
            }

            // Fragment stage: resolve the final RGB and alpha.
            float4 ParticleFragment(Varyings input) : SV_Target
            {
                float4 surface = SampleParticleSurface(input);
                float3 color = AdjustParticleColor(surface.rgb, input.color.rgb);
                float alpha = saturate(surface.a * _Main_Color.a * _Alpha * input.color.a);
                if (_AlphaPremultiply != 0)
                    color *= alpha;

                return float4(color, alpha);
            }

            ENDHLSL
        }
    }

    FallBack Off
}
