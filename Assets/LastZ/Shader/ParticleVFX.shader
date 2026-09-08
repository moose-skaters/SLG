// Frame4414 / Program7667: EID3151, 3228, 3284, 3300, 3328-3331.
// GeneralVFX_B 的实际变体。CB 虽有噪声/溶解等字段，这组 VS/FS 没有执行它们。
// 阅读顺序：ParticleVertex -> SampleParticleSurface -> AdjustParticleColor -> ParticleFragment。
Shader "LastZ/ParticleVFX"
{
    Properties
    {
        [Header(Main Texture and Color)]
        [MainTexture] _Main_Tex("Main texture - RGB and alpha", 2D) = "white" {}
        _Main_Color("Main tint - linear HDR RGBA", Vector) = (2.99607849,2.99607849,2.99607849,1)
        _Main_UV("Main UV speed XY per second", Vector) = (0,0,0,0)
        _Main_tex_Rotator("Main UV clockwise rotation - degrees around origin", Float) = 0
        _Particle_SpeedUV("Use particle UV1 XY offset instead of timed offset", Float) = 0
        _Brightness("Brightness", Float) = 1
        _Saturation("Saturation", Float) = 1
        _Contrast("Contrast about 0.5 - clamped before HDR tint", Float) = 1

        [Header(Alpha and Flipbook)]
        _Alpha("Opacity", Float) = 1
        _AlphaSub("Subtract from texture alpha before clamp", Float) = 0
        _Alpha_NO_R("Alpha to red channel blend", Float) = 0
        [Toggle] _FlipBookBlend_On("Blend with UV0 ZW frame using UV2 X", Float) = 0
        [Toggle] _AlphaPremultiply("Premultiply output RGB by final alpha", Float) = 0

        [Header(Original One Axis Parallax)]
        [Toggle] _ParallaxOn("Enable original tangent axis parallax", Float) = 0
        [Enum(R,0,G,1,B,2,A,3)] _ParallaxChannel("Height channel after base alpha adjustment", Float) = 0
        _ParallaxScale("Parallax UV displacement scale", Float) = 1
        _ParallaxEdgeColor("Parallax edge RGB - linear", Vector) = (0,0,0,1)

        [Header(Animation Time)]
        [Toggle] _UseCaptureTime("Freeze at captured time", Float) = 1
        _CaptureTime("Captured time in seconds", Float) = 126.3208237

        // 原 VS 写出这组 UV，但 FS 未读；不误造第二张纹理或双图混合。
        [HideInInspector] _Tex_2_ST("Unused VS secondary UV transform", Vector) = (1,1,0,0)
        [HideInInspector] _Tex_2_UV("Unused VS secondary UV speed", Vector) = (0,0,0,0)

        [Header(Captured Draw State)]
        [Enum(UnityEngine.Rendering.CullMode)] _Cull("Cull", Float) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("Depth test", Float) = 4
        [Toggle] _ZWrite("Depth write", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("RGB source blend", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("RGB destination blend", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendAlpha("Alpha source blend", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendAlpha("Alpha destination blend", Float) = 1
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
        Pass
        {
            Name "ParticleVFXForward"
            Tags { "LightMode"="UniversalForwardOnly" }
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
            TEXTURE2D(_Main_Tex); SAMPLER(sampler_Main_Tex);
            CBUFFER_START(UnityPerMaterial)
                float4 _Main_Tex_ST, _Main_Color, _Main_UV, _ParallaxEdgeColor;
                float4 _Tex_2_ST, _Tex_2_UV;
                float _Main_tex_Rotator, _Particle_SpeedUV;
                float _Brightness, _Saturation, _Contrast;
                float _Alpha, _AlphaSub, _Alpha_NO_R, _FlipBookBlend_On, _AlphaPremultiply;
                float _ParallaxOn, _ParallaxChannel, _ParallaxScale;
                float _UseCaptureTime, _CaptureTime;
                float _Cull, _ZTest, _ZWrite, _SrcBlend, _DstBlend, _SrcBlendAlpha, _DstBlendAlpha;
            CBUFFER_END

            struct Attributes
            {
                float3 positionOS : POSITION;
                float4 tangentOS : TANGENT;
                float4 color : COLOR;
                float4 uv0 : TEXCOORD0; // XY 当前帧，ZW 下一帧；保留原输入的全部分量。
                float4 uv1 : TEXCOORD1; // XY 粒子自定义滚动偏移。
                float4 uv2 : TEXCOORD2; // X 两帧插值量。
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float4 color : COLOR;
                float2 mainUV : TEXCOORD0;       // 原 vs_TEXCOORD4.xy。
                float2 nextFrameUV : TEXCOORD1;  // 原 vs_TEXCOORD7.xy。
                float frameBlend : TEXCOORD2;    // 原 vs_TEXCOORD6。
                float2 parallaxView : TEXCOORD3; // 原 vs_TEXCOORD8.xy。
                float2 secondaryUV : TEXCOORD4;  // 原 vs_TEXCOORD5.zw，FS 未使用。
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings ParticleVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                float3 positionWS = TransformObjectToWorld(input.positionOS);
                output.positionCS = TransformWorldToHClip(positionWS);
                float timeSeconds = _UseCaptureTime != 0 ? _CaptureTime : _Time.y;
                float2 baseUV = input.uv0.xy * _Main_Tex_ST.xy + _Main_Tex_ST.zw;
                float2 timedUV = baseUV + timeSeconds * _Main_UV.xy;
                float2 particleUV = baseUV + input.uv1.xy;
                float2 scrollingUV = lerp(timedUV, particleUV, _Particle_SpeedUV);

                // 原 shader 绕 (0,0) 旋转，而不是纹理中心。
                float sine, cosine;
                sincos(_Main_tex_Rotator * 0.017453294, sine, cosine);
                output.mainUV = float2(dot(scrollingUV, float2(cosine, sine)),
                                       dot(scrollingUV, float2(-sine, cosine)));
                output.nextFrameUV = input.uv0.zw;
                output.frameBlend = input.uv2.x;
                output.color = input.color;
                output.secondaryUV = input.uv0.xy * _Tex_2_ST.xy + _Tex_2_ST.zw
                                   + timeSeconds * _Tex_2_UV.xy;
                if (_ParallaxOn != 0)
                {
                    // 原 VS 没读取 normal、没构造完整 TBN。
                    // 它将 dot(tangentWS,viewDirectionWS) 写入 X，Y/Z 明确为零。
                    float3 tangentWS = normalize(TransformObjectToWorldDir(input.tangentOS.xyz, false));
                    float3 viewDirectionWS = normalize(_WorldSpaceCameraPos - positionWS);
                    output.parallaxView = float2(dot(tangentWS, viewDirectionWS), 0);
                }
                return output;
            }

            float4 SampleMainTexture(float2 uv)
            {
                // 抵消 URP 采样宏的全局 mip bias，对应原 GLSL texture() 的 bias=0。
                return SAMPLE_TEXTURE2D_BIAS(_Main_Tex, sampler_Main_Tex, uv, -_GlobalMipBias.x);
            }

            float4 SampleParticleSurface(Varyings input)
            {
                float4 surface = SampleMainTexture(input.mainUV);
                float adjustedAlpha = saturate(surface.a - _AlphaSub);
                surface.a = lerp(adjustedAlpha, surface.r, _Alpha_NO_R);
                if (_ParallaxOn != 0)
                {
                    // A 高度读取处理后的 alpha。视差只替换 RGB，alpha 保留第一次采样值。
                    float height = surface[(int)_ParallaxChannel];
                    float2 displacedUV = input.mainUV + (1.0 - height) * input.parallaxView * _ParallaxScale;
                    float4 displaced = SampleMainTexture(displacedUV);
                    float edgeWeight = lerp(displaced.a, displaced.r, _Alpha_NO_R);
                    surface.rgb = lerp(_ParallaxEdgeColor.rgb, displaced.rgb, edgeWeight);
                }
                if (_FlipBookBlend_On != 0)
                {
                    // 下一帧使用原始 UV0.ZW，不重复 ST、旋转、滚动、视差。
                    // 第二帧只减 _AlphaSub，不执行 _Alpha_NO_R，这是原程序的实际行为。
                    float4 nextFrame = SampleMainTexture(input.nextFrameUV);
                    nextFrame.a = saturate(nextFrame.a - _AlphaSub);
                    surface = lerp(surface, nextFrame, input.frameBlend);
                }
                return surface;
            }

            float3 AdjustParticleColor(float3 textureColor, float3 vertexColor)
            {
                float luminance = dot(textureColor, float3(0.29899999, 0.58700001, 0.114));
                float3 saturatedColor = lerp(luminance.xxx, textureColor, _Saturation);
                float3 contrastColor = saturate((saturatedColor - 0.5) * _Contrast + 0.5);
                // clamp 在 HDR 颜色/亮度乘法之前，因此输出可以大于 1。
                return contrastColor * _Main_Color.rgb * _Brightness * vertexColor;
            }

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
