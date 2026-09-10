// Frame4414 / Program31718 / EID3176.
// VS 采样 Flowmap 的 RG 作为绝对 UV，供主图与溶解图混合；没有顶点位移。
// 阅读顺序：FlowVertex -> EvaluateSoftThreshold -> FlowFragment。
Shader "LastZ/FlowFire"
{
    Properties
    {
        [Header(Main Surface)]
        [MainTexture] _Main_Tex("主纹理（RGB 和 Alpha）", 2D) = "white" {}
        _Color("主颜色", Vector) = (3.95, 3.95, 3.95, 1.00)
        _Alpha("最终透明度", Float) = 1.00
        [Toggle] _A_R_ON("使用主纹理 R 通道混合 Alpha", Float) = 0.00

        [Space(8)]
        [Header(Vertex Flow UV)]
        _Flowmap_Tex("流动图（RG 为绝对 UV，顶点阶段使用 MIP 1）", 2D) = "gray" {}
        _Flowmap_UV("流动图滚动速度 XY（每秒）", Vector) = (0.00, 0.00, 0.00, 0.00)

        [Space(8)]
        [Header(Light Mask)]
        _Mask_Tex("遮罩纹理（R 通道，仅影响 RGB）", 2D) = "white" {}
        _LightAngle("遮罩顺时针旋转角度（弧度）", Float) = 0.64
        _Mask_Power("遮罩幂指数", Float) = 2.33

        [Space(8)]
        [Header(Fire Addition)]
        [NoScaleOffset] _Fire_Tex("火焰形状纹理（R 通道，使用主 UV）", 2D) = "white" {}
        _Fire_Color("叠加火焰颜色", Vector) = (3.00, 0.56, 0.14, 1.00)
        [Toggle] _Fire_ON("启用火焰颜色", Float) = 1.00
        _Fire_Tex_Soft_Value("火焰阈值柔和度（可为负数）", Float) = -0.33

        [Space(8)]
        [Header(Dissolve Alpha)]
        _Diss_Tex("溶解纹理（R 通道，仅影响 Alpha）", 2D) = "white" {}
        _Diss_UV("溶解纹理滚动速度 XY（每秒）", Vector) = (0.00, 0.00, 0.00, 0.00)
        _Diss_Tex_Soft_Value("溶解阈值柔和度", Float) = 0.00

        [Space(8)]
        [Header(Captured Draw State)]
        [Enum(UnityEngine.Rendering.CullMode)] _Cull("剔除模式", Float) = 2.00
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("深度测试", Float) = 4.00
        [Toggle] _ZWrite("深度写入", Float) = 0.00
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("RGB 源混合因子", Float) = 5.00
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("RGB 目标混合因子", Float) = 10.00
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendAlpha("Alpha 源混合因子", Float) = 5.00
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendAlpha("Alpha 目标混合因子", Float) = 10.00
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
            Name "FlowFireForward"

            Tags { "LightMode" = "UniversalForward" }

            Cull [_Cull]
            ZTest [_ZTest]
            ZWrite [_ZWrite]
            Blend [_SrcBlend] [_DstBlend], [_SrcBlendAlpha] [_DstBlendAlpha]

            HLSLPROGRAM
            #pragma target 4.0
            #pragma vertex FlowVertex
            #pragma fragment FlowFragment
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // Textures.
            TEXTURE2D(_Main_Tex);
            SAMPLER(sampler_Main_Tex);
            TEXTURE2D(_Mask_Tex);
            SAMPLER(sampler_Mask_Tex);
            TEXTURE2D(_Fire_Tex);
            SAMPLER(sampler_Fire_Tex);
            TEXTURE2D(_Diss_Tex);
            SAMPLER(sampler_Diss_Tex);
            TEXTURE2D(_Flowmap_Tex);
            SAMPLER(sampler_Flowmap_Tex);

            // Material properties.
            CBUFFER_START(UnityPerMaterial)
                float4 _Main_Tex_ST;
                float4 _Flowmap_Tex_ST;
                float4 _Mask_Tex_ST;
                float4 _Diss_Tex_ST;

                float4 _Fire_Color;
                float4 _Color;
                float4 _Flowmap_UV;
                float4 _Diss_UV;

                float _LightAngle;
                float _Mask_Power;
                float _Fire_Tex_Soft_Value;
                float _Fire_ON;
                float _A_R_ON;
                float _Diss_Tex_Soft_Value;
                float _Alpha;

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
                float4 color : COLOR;
                float4 uv0 : TEXCOORD0;
                // X=旋转弧度，Y=流动UV权重，Z=溶解量，W=火焰阈值。
                float4 particleControls : TEXCOORD1;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            // Interpolators shared by the vertex and fragment stages.
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float4 color : COLOR;
                float2 baseUV : TEXCOORD0;
                float4 particleControls : TEXCOORD1;
                float4 mainAndFlowUV : TEXCOORD2; // XY=旋转后主UV，ZW=VS Flowmap采样值。
                float2 maskUV : TEXCOORD3;

                UNITY_VERTEX_OUTPUT_STEREO
            };

            // Rotate UVs around their center without changing their scale.
            float2 RotateUVAboutCenter(float2 uv, float angleRadians)
            {
                float sine, cosine;
                sincos(angleRadians, sine, cosine);

                float2 centeredUV = uv - 0.5;
                return float2(dot(centeredUV, float2(cosine, sine)),
                              dot(centeredUV, float2(-sine, cosine)))
                       + 0.5;
            }

            // Vertex stage: sample the flowmap at mip 1 and pass its RG to the fragment stage.
            Varyings FlowVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.positionCS = TransformObjectToHClip(input.positionOS);
                output.color = input.color;
                output.baseUV = input.uv0.xy;
                output.particleControls = input.particleControls;

                float time = _Time.y;
                float flowWeight = input.particleControls.y;

                float2 flowSampleUV =
                    input.uv0.xy * _Flowmap_Tex_ST.xy
                    + _Flowmap_Tex_ST.zw
                    + time * _Flowmap_UV.xy;

                // 顶点阶段没有隐式导数，必须显式指定 Flowmap 的 MIP 等级。
                float2 flowUV = SAMPLE_TEXTURE2D_LOD(
                    _Flowmap_Tex,
                    sampler_Flowmap_Tex,
                    flowSampleUV,
                    1.0
                ).rg;

                float2 mainUV = input.uv0.xy * _Main_Tex_ST.xy + _Main_Tex_ST.zw;
                mainUV = lerp(mainUV, flowUV, flowWeight);
                output.mainAndFlowUV.xy = RotateUVAboutCenter(mainUV, abs(input.particleControls.x));
                output.mainAndFlowUV.zw = flowUV;

                float2 maskUV = input.uv0.xy * _Mask_Tex_ST.xy
                              + _Mask_Tex_ST.zw;
                output.maskUV = RotateUVAboutCenter(maskUV, _LightAngle);

                return output;
            }

            float EvaluateSoftThreshold(float noiseValue, float particleThreshold, float softness)
            {
                // 将噪声按粒子阈值和柔和度映射到边缘区间，再执行 cubic Hermite。
                // 等价于原来的 saturate + ramp * ramp * (3.0 - 2.0 * ramp)。
                float edge0 = particleThreshold * (2.0 - softness) + softness - 1.0;
                float edge1 = particleThreshold * (2.0 - softness);
                return smoothstep(edge0, edge1, noiseValue);
            }

            float4 FlowFragment(Varyings input) : SV_Target
            {
                float time = _Time.y;
                float flowWeight = input.particleControls.y;

                // Dissolve controls alpha only.
                float2 dissolveUV = input.baseUV * _Diss_Tex_ST.xy
                                  + _Diss_Tex_ST.zw;
                dissolveUV = lerp(dissolveUV, input.mainAndFlowUV.zw, flowWeight);
                dissolveUV += time * _Diss_UV.xy;

                float dissolveNoise = SAMPLE_TEXTURE2D(_Diss_Tex,sampler_Diss_Tex,dissolveUV).r;
                float dissolve = EvaluateSoftThreshold(dissolveNoise,input.particleControls.z,_Diss_Tex_Soft_Value);

                float4 mainSample = SAMPLE_TEXTURE2D(_Main_Tex,sampler_Main_Tex,input.mainAndFlowUV.xy);
                float4 vertexTint = input.color * _Color;
                float3 baseColor = mainSample.rgb * vertexTint.rgb;
                float mainAlpha = lerp(mainSample.a, mainSample.r, _A_R_ON);
                float alpha = saturate(dissolve * (mainAlpha * vertexTint.a) * _Alpha);

                float fireNoise = SAMPLE_TEXTURE2D(_Fire_Tex,sampler_Fire_Tex,input.mainAndFlowUV.xy).r;
                float fire = min(EvaluateSoftThreshold(fireNoise,input.particleControls.w,_Fire_Tex_Soft_Value),1.0);
                float3 fireColor = baseColor + _Fire_Color.rgb * fire;

                float mask = SAMPLE_TEXTURE2D(_Mask_Tex,sampler_Mask_Tex,input.maskUV).r;
                float shapedMask = min(pow(max(mask, 0.0), _Mask_Power), 1.0);
                float3 maskedBaseColor = shapedMask * baseColor;
                float3 color = lerp(maskedBaseColor, fireColor * shapedMask, _Fire_ON);

                return float4(color, alpha);
            }

            ENDHLSL
        }
    }

    FallBack Off
}
