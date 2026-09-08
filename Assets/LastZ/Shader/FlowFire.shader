// Frame4414 / Program31718 / EID3176.
// VS 采样 Flowmap 的 RG 作为绝对 UV，供主图与溶解图混合；没有顶点位移。
// 阅读顺序：FlowVertex -> EvaluateSoftThreshold -> FlowFragment。
Shader "LastZ/FlowFire"
{
    Properties
    {
        [Header(Main Surface)]
        [MainTexture] _Main_Tex("Main texture - RGB and alpha", 2D) = "white" {}
        _Color("Main tint - linear HDR RGBA", Vector) = (3.95294118,3.95294118,3.95294118,1)
        _Alpha("Final opacity", Float) = 1
        _A_R_ON("Main alpha to red channel blend", Float) = 0

        [Header(Vertex Flow UV)]
        _Flowmap_Tex("Flowmap - absolute UV in RG sampled in VS at mip 1", 2D) = "gray" {}
        _Flowmap_UV("Flowmap scroll XY per second", Vector) = (0,0,0,0)

        [Header(Light Mask)]
        _Mask_Tex("Mask R - affects RGB only", 2D) = "white" {}
        _LightAngle("Mask clockwise rotation - radians", Float) = 0.639999986
        _Mask_Power("Mask exponent", Float) = 2.329999924

        [Header(Fire Addition)]
        [NoScaleOffset] _Fire_Tex("Fire shape R - uses main UV", 2D) = "white" {}
        _Fire_Color("Added fire RGB - linear HDR", Vector) = (2.99607849,0.564705908,0.141176477,1)
        _Fire_ON("Fire color contribution", Float) = 1
        _Fire_Tex_Soft_Value("Fire threshold softness - may be negative", Float) = -0.330000013

        [Header(Dissolve Alpha)]
        _Diss_Tex("Dissolve R - affects alpha only", 2D) = "white" {}
        _Diss_UV("Dissolve scroll XY per second", Vector) = (0,0,0,0)
        _Diss_Tex_Soft_Value("Dissolve threshold softness", Float) = 0

        [Header(Animation Time)]
        [Toggle] _UseCaptureTime("Freeze at captured time", Float) = 1
        _CaptureTime("Captured time in seconds", Float) = 126.3208237

        [Header(Captured Draw State)]
        [Enum(UnityEngine.Rendering.CullMode)] _Cull("Cull", Float) = 2
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("Depth test", Float) = 4
        [Toggle] _ZWrite("Depth write", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("RGB source blend", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("RGB destination blend", Float) = 10
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendAlpha("Alpha source blend", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendAlpha("Alpha destination blend", Float) = 10
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
        Pass
        {
            Name "FlowFireForward"
            Tags { "LightMode"="UniversalForwardOnly" }
            Cull [_Cull]
            ZTest [_ZTest]
            ZWrite [_ZWrite]
            Blend [_SrcBlend] [_DstBlend], [_SrcBlendAlpha] [_DstBlendAlpha]
            ColorMask RGBA
            HLSLPROGRAM
            #pragma target 3.5
            #pragma vertex FlowVertex
            #pragma fragment FlowFragment
            #pragma multi_compile_instancing
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            TEXTURE2D(_Main_Tex); SAMPLER(sampler_Main_Tex);
            TEXTURE2D(_Mask_Tex); SAMPLER(sampler_Mask_Tex);
            TEXTURE2D(_Fire_Tex); SAMPLER(sampler_Fire_Tex);
            TEXTURE2D(_Diss_Tex); SAMPLER(sampler_Diss_Tex);
            TEXTURE2D(_Flowmap_Tex); SAMPLER(sampler_Flowmap_Tex);
            CBUFFER_START(UnityPerMaterial)
                float4 _Main_Tex_ST, _Flowmap_Tex_ST, _Mask_Tex_ST, _Diss_Tex_ST;
                float4 _Fire_Color, _Color, _Flowmap_UV, _Diss_UV;
                float _LightAngle, _Mask_Power, _Fire_Tex_Soft_Value, _Fire_ON;
                float _A_R_ON, _Diss_Tex_Soft_Value, _Alpha;
                float _UseCaptureTime, _CaptureTime;
                float _Cull, _ZTest, _ZWrite, _SrcBlend, _DstBlend, _SrcBlendAlpha, _DstBlendAlpha;
            CBUFFER_END

            struct Attributes
            {
                float3 positionOS : POSITION;
                float4 color : COLOR;
                float4 uv0 : TEXCOORD0;
                // 原 in_TEXCOORD1: X=旋转弧度，Y=流动UV权重，Z=溶解量，W=火焰阈值。
                // 必须导入完整 float4 的 UV1，不能误用 UV2 或丢弃 ZW。
                float4 particleControls : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
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

            float CaptureOrGameTime()
            {
                return _UseCaptureTime != 0 ? _CaptureTime : _Time.y;
            }

            float2 RotateUVAboutCenter(float2 uv, float angleRadians)
            {
                float sine, cosine;
                sincos(angleRadians, sine, cosine);
                float2 centeredUV = uv - 0.5;
                return float2(dot(centeredUV, float2(cosine, sine)),
                              dot(centeredUV, float2(-sine, cosine))) + 0.5;
            }

            Varyings FlowVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                output.positionCS = TransformObjectToHClip(input.positionOS);
                output.color = input.color;
                output.baseUV = input.uv0.xy;
                output.particleControls = input.particleControls;
                float2 flowSampleUV = input.uv0.xy * _Flowmap_Tex_ST.xy + _Flowmap_Tex_ST.zw
                                    + CaptureOrGameTime() * _Flowmap_UV.xy;
                // 原 textureLod(...,1.0)：保留顶点阶段与 mip 等级。
                // RG 不解码到 [-1,1]，不作为位置偏移，也不是 fragment flowmap。
                float2 flowUV = SAMPLE_TEXTURE2D_LOD(_Flowmap_Tex, sampler_Flowmap_Tex, flowSampleUV, 1.0).rg;
                float2 mainUV = input.uv0.xy * _Main_Tex_ST.xy + _Main_Tex_ST.zw;
                mainUV = lerp(mainUV, flowUV, input.particleControls.y);
                output.mainAndFlowUV.xy = RotateUVAboutCenter(mainUV, abs(input.particleControls.x));
                output.mainAndFlowUV.zw = flowUV;
                float2 maskUV = input.uv0.xy * _Mask_Tex_ST.xy + _Mask_Tex_ST.zw;
                output.maskUV = RotateUVAboutCenter(maskUV, _LightAngle);
                return output;
            }

            float EvaluateSoftThreshold(float noiseValue, float particleThreshold, float softness)
            {
                // 原式: t=saturate((noise+1-threshold*(2-softness)-softness)/(1-softness))。
                // 随后是 cubic Hermite，不能写成 smoothstep(softness,1,noise)，
                // 阈值来自每顶点自定义通道，而且本帧火焰 softness 为负数。
                float ramp = noiseValue + 1.0 - particleThreshold * (2.0 - softness) - softness;
                ramp = saturate(ramp * (1.0 / (1.0 - softness)));
                return ramp * ramp * (3.0 - 2.0 * ramp);
            }

            float4 FlowFragment(Varyings input) : SV_Target
            {
                float2 dissolveUV = input.baseUV * _Diss_Tex_ST.xy + _Diss_Tex_ST.zw;
                dissolveUV = lerp(dissolveUV, input.mainAndFlowUV.zw, input.particleControls.y);
                dissolveUV += CaptureOrGameTime() * _Diss_UV.xy;
                float dissolveNoise = SAMPLE_TEXTURE2D_BIAS(_Diss_Tex, sampler_Diss_Tex, dissolveUV, -_GlobalMipBias.x).r;
                float dissolve = EvaluateSoftThreshold(dissolveNoise, input.particleControls.z, _Diss_Tex_Soft_Value);

                float4 mainSample = SAMPLE_TEXTURE2D_BIAS(_Main_Tex, sampler_Main_Tex, input.mainAndFlowUV.xy, -_GlobalMipBias.x);
                float4 vertexTint = input.color * _Color;
                float3 baseColor = mainSample.rgb * vertexTint.rgb;
                float mainAlpha = lerp(mainSample.a, mainSample.r, _A_R_ON);
                float alpha = saturate(dissolve * (mainAlpha * vertexTint.a) * _Alpha);

                float fireNoise = SAMPLE_TEXTURE2D_BIAS(_Fire_Tex, sampler_Fire_Tex, input.mainAndFlowUV.xy, -_GlobalMipBias.x).r;
                float fire = min(EvaluateSoftThreshold(fireNoise, input.particleControls.w, _Fire_Tex_Soft_Value), 1.0);
                float3 fireColor = baseColor + _Fire_Color.rgb * fire;

                float mask = SAMPLE_TEXTURE2D_BIAS(_Mask_Tex, sampler_Mask_Tex, input.maskUV, -_GlobalMipBias.x).r;
                float shapedMask = min(exp2(log2(mask) * _Mask_Power), 1.0);
                float3 maskedBaseColor = shapedMask * baseColor;
                float3 color = lerp(maskedBaseColor, fireColor * shapedMask, _Fire_ON);
                // Mask 只调制 RGB，溶解只调制 Alpha。火焰项不再乘顶点色或 _Color。
                return float4(color, alpha);
            }
            ENDHLSL
        }
    }
    FallBack Off
}
