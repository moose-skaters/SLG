// EID1550 only samples _CameraDepthAttachment and writes the sampled device depth.
// URP14's copy implementation supplies platform UV handling and MSAA variants.
// At the captured MSAA=1 it is the same single depth sample as the original GLSL.
Shader "Hidden/LastZ/FogDepthSnapshot"
{
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" }
        Pass
        {
            Name "FogDepthSnapshot"
            ZTest Always
            ZWrite On
            Cull Off
            ColorMask R

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment frag
            #pragma multi_compile _ _DEPTH_MSAA_2 _DEPTH_MSAA_4 _DEPTH_MSAA_8
            #pragma multi_compile _ _OUTPUT_DEPTH
            #include "Packages/com.unity.render-pipelines.universal/Shaders/Utils/CopyDepthPass.hlsl"
            ENDHLSL
        }
    }
    FallBack Off
}
