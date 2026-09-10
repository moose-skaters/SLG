Shader "LastZ/SceneSimple"
{
    Properties
    {
        [Header(Surface)]
        [MainTexture] [NoScaleOffset] _MainTex("主纹理", 2D) = "white" {}
        _Color("基础颜色", Color) = (1,1,1,1)
        _AlphaIsR("透明度来源（0=Alpha，1=调色后的 R）", Range(0,1)) = 0
        _VertexOffsetY("物体空间 Y 偏移", Float) = 0
        
        [Space(8)]
        [Header(Shadow)]
        [Toggle] _BlurPlaneShadowOn("启用屏幕空间平面阴影", Float) = 0
        [NoScaleOffset] _PlaneBlurShadowMap("平面阴影", 2D) = "white" {}

        [Space(8)]
        [Header(Render State)]
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("RGB 源混合因子", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("RGB 目标混合因子", Float) = 10
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendAlpha("Alpha 源混合因子", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendAlpha("Alpha 目标混合因子", Float) = 10
        [Enum(Off,0,On,1)] _ZWrite("写入深度", Float) = 0
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
        Pass
        {
            Name "SceneSimpleForward"
            Tags { "LightMode"="UniversalForward" }
            ZWrite [_ZWrite]
            Blend [_SrcBlend] [_DstBlend], [_SrcBlendAlpha] [_DstBlendAlpha]
            BlendOp Add, Add
            
            HLSLPROGRAM
            #pragma target 3.5
            #pragma vertex SceneSimpleVertex
            #pragma fragment SceneSimpleFragment
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
            TEXTURE2D(_PlaneBlurShadowMap); SAMPLER(sampler_PlaneBlurShadowMap);

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
                float2 uv : TEXCOORD0;             
                float4 screenPosition : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings SceneSimpleVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                
                float3 displacedPositionOS = input.positionOS + float3(0, _VertexOffsetY, 0);
                output.positionCS = TransformObjectToHClip(displacedPositionOS);
                output.uv = input.uv;
                output.screenPosition = ComputeScreenPos(output.positionCS);
                return output;
            }

            float ResolveOpacity(float4 tintedSample)
            {
                float opacityFromAlpha = tintedSample.a;
                float opacityFromRed = tintedSample.r * _Color.a;
                return lerp(opacityFromAlpha, opacityFromRed, _AlphaIsR);
            }

            float4 SceneSimpleFragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float4 tintedSample = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex,
                    input.uv) * _Color;
                float opacity = ResolveOpacity(tintedSample);
                float3 color = tintedSample.rgb;

                if (_BlurPlaneShadowOn != 0)
                {
                    float2 screenUV = input.screenPosition.xy / input.screenPosition.w;
                    float shadowVisibility = SAMPLE_TEXTURE2D(_PlaneBlurShadowMap,sampler_PlaneBlurShadowMap, screenUV).r;
                    color *= 0.5 + 0.5 * shadowVisibility;
                }

                return float4(color, opacity);
            }
            ENDHLSL
        }
    }
    FallBack Off
}
