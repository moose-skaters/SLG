// Program17046：主纹理乘基础色和游戏环境色的透明场景变体。
// 注意原 FS 使用的是 VS 中 SepcularGloss_ST 变换后的 UV，MainTex_ST 是未使用输出。
Shader "LastZ/SceneTint"
{
    Properties
    {
        [MainTexture][NoScaleOffset] _MainTex("Main texture - sRGB",2D)="white"{}
        _SepcularGloss_ST("Original sampled UV scale/offset",Vector)=(1,1,0,0)
        _BaseColor("Tint - linear RGBA",Vector)=(1,1,1,1)
        _LightColor1("Game environment color - linear RGB",Vector)=(1,1,1,1)
        _LightIntensity1("Game environment intensity",Float)=1
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
        Pass
        {
            Name "SceneTintForward"
            Tags { "LightMode"="UniversalForwardOnly" }
            Cull Back
            ZTest LEqual
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha OneMinusSrcAlpha
            HLSLPROGRAM
            #pragma target 3.5
            #pragma vertex SceneTintVertex
            #pragma fragment SceneTintFragment
            #pragma multi_compile_instancing
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor, _LightColor1, _SepcularGloss_ST;
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
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            Varyings SceneTintVertex(Attributes input)
            {
                Varyings output=(Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input,output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                output.positionCS=TransformObjectToHClip(input.positionOS);
                output.uv=input.uv*_SepcularGloss_ST.xy+_SepcularGloss_ST.zw;
                return output;
            }
            float4 SceneTintFragment(Varyings input):SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                // 原 texture() 无 bias，不重复叠加 URP 自动全局偏移。
                float4 tinted=SAMPLE_TEXTURE2D_BIAS(_MainTex,sampler_MainTex,input.uv,-_GlobalMipBias.x)*_BaseColor;
                // 灯色只影响 RGB，Alpha 只乘一次 BaseColor.a；没有 AlphaClip/SH。
                return float4(tinted.rgb*_LightColor1.rgb*_LightIntensity1,tinted.a);
            }
            ENDHLSL
        }
    }
    FallBack Off
}
