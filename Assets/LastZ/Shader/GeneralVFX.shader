
// Frame4414 五个已编译程序的可读合并：_Variant 对应原始静态分支。
// 0=31699(主UV旋转)，1=7836(基本)，2=23419(双图/Mask/Fresnel)，
// 3=7831(Noise.g UV扰动)，4=11025(溶解)。各材质仍保留独立Blend/Cull/ZTest。
Shader "LastZ/GeneralVFX"
{
    Properties
    {
        [Header(Variant and Playback)]
        // Legacy numeric selector retained for material migration only. Runtime selection uses static keywords.
        [HideInInspector] [Enum(MainRotated,0,Basic,1,DualMaskFresnel,2,Noise,3,Dissolve,4)] _Variant("Original compiled variant",Float)=1
        [Toggle] _UseCaptureTime("Freeze at captured time",Float)=1
        _CaptureTime("Captured seconds",Float)=126.3208237
        _TextureMipBias("Original total texture mip bias",Float)=-0.584962487

        [Header(Main and Second Layers)]
        _MainTex("Main texture",2D)="white"{}
        _MainColor("Main tint - linear RGBA",Vector)=(1.39771998,1.01241767,0.92937398,1)
        _MainColorIntensity("Main RGBA intensity",Float)=0.910000026
        _MainTex02("Second texture",2D)="white"{}
        _Main02Color("Second tint - linear RGBA",Vector)=(1,1,1,0.13333334)
        _Main02ColorIntensity("Second RGBA intensity",Float)=0.519999981
        _MNBlendMode("Layers multiplication to addition blend",Float)=0
        _BlackOff("Multiply opacity by texture red",Float)=0
        _Desaturate("Desaturation - 0 color 1 gray",Float)=1

        [Header(UV Mapping)]
        _UVChannel("Mesh UV0 to clamped UV1 blend",Float)=0
        _mainUVMove("Main scroll XY and center scale Z",Vector)=(0.0500000007,0.100000001,1,0)
        _MainAngle("Variant0 main rotation in degrees around origin",Float)=90
        _main02UVMove("Second scroll XY and center scale Z",Vector)=(0,0,1,1)
        _Main02Angle("Second rotation in degrees around origin",Float)=90
        _particleUV("Add custom TEXCOORD2 XY to main UV",Float)=0
        _ScreenSpaceUV_ON("Mesh UV to screen UV blend",Float)=0
        _MWarpMode("Main UV clamp blend",Float)=0
        _M02WarpMode("Second UV clamp blend",Float)=0

        [Header(Mask and Fresnel)]
        _MaskTex("Mask R and A",2D)="white"{}
        _maskUVMove("Mask scroll XY and center scale Z",Vector)=(0,0,1,1)
        _MaskTexUV("Add custom TEXCOORD3 XY to mask UV",Float)=0
        _MKWarpMode("Mask UV clamp blend",Float)=0
        _MaskType("Mask type - 0 and 3 use min of R and A",Float)=0
        _FresnelColor("Fresnel tint - linear RGBA",Vector)=(1,0.974056602,0.948113203,1)
        _FresnelColorIntensity("Fresnel RGBA intensity",Float)=1.45000005
        _FresnelPower("Fresnel exponent",Float)=0.419999987
        _FalseFresnel("Use alternative view direction",Float)=0
        _FalseViewDir("Alternative world view direction XYZ",Vector)=(0,-1,0,0)
        _BlendMode("Fresnel multiply to addition blend",Float)=0
        _InvertMode("Invert rim and use rim alpha blend",Float)=1

        [Header(Noise Distortion)]
        _NoiseTex("Distortion noise G",2D)="gray"{}
        _noiseUVMove("Noise scroll XY and center scale Z",Vector)=(0,0,1,1)
        _NWarpMode("Noise UV clamp blend",Float)=0
        _DistortIntensity("Constant UV distortion strength",Float)=0
        _DistortMod("Constant to custom TEXCOORD2 W distortion",Float)=0

        [Header(Dissolve)]
        _DissolveTex("Dissolve mask R",2D)="white"{}
        _dissolveUVMove("Dissolve scroll XY and center scale Z",Vector)=(0,0,1,1)
        _depc("Dissolve threshold X softness Y edge width W",Vector)=(0.5,0.5,1,0)
        _dissolveMode("Constant to custom TEXCOORD2 Z dissolve",Float)=1
        _DissolveDirToggle("Use directional dissolve",Float)=0
        _DissolveDir("Dissolve direction X to Y blend",Float)=0
        _InvertDissolveDir("Reverse dissolve direction",Float)=0
        _EdgeColor("Dissolve edge tint - linear RGB",Vector)=(1,1,1,1)
        _EdgeColorIntensity("Edge RGB intensity",Float)=1

        [Header(Height Fade)]
        _HeightFadeParam("Height fade start X and end Y",Vector)=(0,0,0,0)
        _HeightFade("Height fade strength",Float)=0

        [Header(Captured Draw State)]
        [Enum(UnityEngine.Rendering.CullMode)] _Cull("Cull",Float)=2
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("Depth test",Float)=4
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("RGB source",Float)=5
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("RGB destination",Float)=1
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendAlpha("Alpha source",Float)=5
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendAlpha("Alpha destination",Float)=1

    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
        Pass
        {
            Name "GeneralVFXForward"
            Tags { "LightMode"="UniversalForwardOnly" }
            Cull [_Cull] ZTest [_ZTest] ZWrite Off
            Blend [_SrcBlend] [_DstBlend], [_SrcBlendAlpha] [_DstBlendAlpha]
            HLSLPROGRAM
            #pragma target 3.5
            #pragma vertex EffectVertex
            #pragma fragment EffectFragment
            #pragma shader_feature_local _GENERALVFX_VARIANT0 _GENERALVFX_VARIANT1 _GENERALVFX_VARIANT2 _GENERALVFX_VARIANT3 _GENERALVFX_VARIANT4
            #pragma multi_compile_instancing
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
            TEXTURE2D(_MainTex02); SAMPLER(sampler_MainTex02);
            TEXTURE2D(_MaskTex); SAMPLER(sampler_MaskTex);
            TEXTURE2D(_NoiseTex); SAMPLER(sampler_NoiseTex);
            TEXTURE2D(_DissolveTex); SAMPLER(sampler_DissolveTex);
            // 原 GLSL $Globals，由 LastZGlobalShaderParameters 统一设置。
            float _FlyOffset;
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _MainColor;
                float4 _Main02Color;
                float4 _MainTex02_ST;
                float4 _mainUVMove;
                float4 _main02UVMove;
                float4 _NoiseTex_ST;
                float4 _noiseUVMove;
                float4 _DissolveTex_ST;
                float4 _EdgeColor;
                float4 _depc;
                float4 _dissolveUVMove;
                float4 _MaskTex_ST;
                float4 _maskUVMove;
                float4 _FresnelColor;
                float4 _FalseViewDir;
                float4 _HeightFadeParam;
                float _MaskType;
                float _HeightFade;
                float _MWarpMode;
                float _M02WarpMode;
                float _UVChannel;
                float _BlackOff;
                float _NWarpMode;
                float _DistortIntensity;
                float _DissolveDirToggle;
                float _DissolveDir;
                float _InvertDissolveDir;
                float _particleUV;
                float _dissolveMode;
                float _DistortMod;
                float _MaskTexUV;
                float _MKWarpMode;
                float _BlendMode;
                float _InvertMode;
                float _FalseFresnel;
                float _FresnelPower;
                float _Desaturate;
                float _MainColorIntensity;
                float _Main02ColorIntensity;
                float _EdgeColorIntensity;
                float _FresnelColorIntensity;
                float _MainAngle;
                float _Main02Angle;
                float _ScreenSpaceUV_ON;
                float _MNBlendMode;
                float _Variant;
                float _TextureMipBias;
                float _CaptureTime;
                float _UseCaptureTime;
            CBUFFER_END
            #define READ_EFFECT(tex, uv) SAMPLE_TEXTURE2D_BIAS(tex, sampler##tex, uv, _TextureMipBias - _GlobalMipBias.x)
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 color : COLOR;
                float4 uv0 : TEXCOORD0;
                float4 uv1 : TEXCOORD1;
                float4 custom : TEXCOORD2;
                float4 maskCustom : TEXCOORD3;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float4 mainUV : TEXCOORD0;
                float4 noiseMaskUV : TEXCOORD1;
                float4 dissolveUV : TEXCOORD2;
                float4 color : TEXCOORD3;
                float3 normalWS : TEXCOORD4;
                float3 effectPositionWS : TEXCOORD5;
                float4 custom : TEXCOORD6;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            float2 RotateUV(float2 uv, float degrees)
            {
                float s,c; sincos(radians(degrees),s,c);
                return float2(uv.x*c-uv.y*s,uv.x*s+uv.y*c);
            }
            float2 TransformFlowUV(float2 uv,float4 st,float4 move,float time)
            {
                return (uv*st.xy+st.zw-0.5)*move.z+0.5+frac(time*move.xy);
            }
            float2 WrapChoice(float2 uv,float clampWeight)
            {
                return lerp(uv,saturate(uv),clampWeight);
            }
            Varyings EffectVertex(Attributes input)
            {
                Varyings output=(Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input,output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                float time=lerp(_Time.y,_CaptureTime,_UseCaptureTime);
                float3 world=TransformObjectToWorld(input.positionOS);
                float4 clipPosition=TransformWorldToHClip(world);
                output.positionCS=clipPosition;
                // 原GL z -= FlyOffset；GL[-w,w]到D3D reversed-Z的差量为+FlyOffset/2。
                #if UNITY_REVERSED_Z
                    output.positionCS.z+=0.5*_FlyOffset;
                #elif defined(SHADER_API_GLCORE) || defined(SHADER_API_GLES3)
                    output.positionCS.z-=_FlyOffset;
                #else
                    output.positionCS.z-=0.5*_FlyOffset;
                #endif
                float4 screen=ComputeScreenPos(clipPosition); // 偏移前的clip
                // GLSL variant 0 temporarily uses YX, then reverses the components
                // in its rotation expression. The net input to RotateUV is XY.
                float2 sourceUV=lerp(input.uv0.xy,saturate(input.uv1.xy),_UVChannel);
#if defined(_GENERALVFX_VARIANT0)
                sourceUV=RotateUV(sourceUV,_MainAngle);
#endif
                float2 meshUV=TransformFlowUV(sourceUV,_MainTex_ST,_mainUVMove,time)+_particleUV*input.custom.xy;
                float2 screenUV=TransformFlowUV(screen.xy/screen.w,_MainTex_ST,_mainUVMove,time)+_particleUV*input.custom.xy;
                output.mainUV.xy=lerp(meshUV,screenUV,_ScreenSpaceUV_ON);
                output.color=input.color;
                output.custom=input.custom;
#if defined(_GENERALVFX_VARIANT2)
                {
                    output.mainUV.zw=TransformFlowUV(RotateUV(input.uv0.xy,_Main02Angle),_MainTex02_ST,_main02UVMove,time);
                    output.noiseMaskUV.zw=TransformFlowUV(input.uv0.xy,_MaskTex_ST,_maskUVMove,time)+_MaskTexUV*input.maskCustom.xy;
                    output.normalWS=TransformObjectToWorldNormal(input.normalOS);
                    output.effectPositionWS=world;
                }
#endif
#if defined(_GENERALVFX_VARIANT3)
                    output.noiseMaskUV.xy=TransformFlowUV(input.uv0.xy,_NoiseTex_ST,_noiseUVMove,time);
#endif
#if defined(_GENERALVFX_VARIANT4)
                {
                    output.dissolveUV.xy=TransformFlowUV(input.uv0.xy,_DissolveTex_ST,_dissolveUVMove,time);
                    output.dissolveUV.zw=saturate(input.uv1.xy);
                }
#endif
                // 原0/1/3/4变体将位置varying写成0；HeightFade不能泛化成真实世界高度。
                return output;
            }
            float4 BlendMainLayers(float4 mainSample,float4 secondSample)
            {
                float4 mainColor=mainSample*_MainColor*_MainColorIntensity;
                float4 secondColor=secondSample*_Main02Color*_Main02ColorIntensity;
                float4 multiply=mainSample*secondSample*_MainColor*_MainColorIntensity;
                return lerp(multiply,mainColor+secondColor,_MNBlendMode);
            }
            float HeightVisibility(float y)
            {
                // 本帧关闭此功能时起止高度都为0；避免无效的0/0污染结果。
                if (_HeightFade==0.0) return 1.0;
                float t=saturate((y-_HeightFadeParam.x)/(_HeightFadeParam.y-_HeightFadeParam.x));
                return lerp(1.0,t,_HeightFade);
            }
            float4 FinishPremultiplied(float4 color,float opacity,Varyings input)
            {
                // 先饱和材质Alpha，再乘高度和顶点Alpha。三个步骤不可调换。
                float alpha=saturate(opacity)*HeightVisibility(input.effectPositionWS.y)*input.color.a;
                float luminance=dot(color.rgb,float3(0.22,0.707,0.071));
                float3 rgb=lerp(color.rgb,luminance.xxx,_Desaturate)*input.color.rgb;
                // 原FS全部预乘Alpha。部分draw还用SrcAlpha混合，照原状态保留。
                return float4(rgb*alpha,alpha);
            }
            float4 EvaluateMaskedDual(Varyings input)
            {
                float4 mask=READ_EFFECT(_MaskTex,WrapChoice(input.noiseMaskUV.zw,_MKWarpMode));
                float maskAlpha=(_MaskType==0 || _MaskType==3)?min(mask.r,mask.a):1.0;
                float3 viewDirection=normalize(_WorldSpaceCameraPos-input.effectPositionWS);
                viewDirection=lerp(viewDirection,normalize(_FalseViewDir.xyz),_FalseFresnel);
                float edge=saturate(1.0-dot(input.normalWS,viewDirection)); // 不额外归一化插值法线
                float rim=pow(edge,_FresnelPower);
                rim=lerp(rim,1.0-rim,_InvertMode);
                float4 fresnel=rim*_FresnelColor*_FresnelColorIntensity;
                float4 a=READ_EFFECT(_MainTex,WrapChoice(input.mainUV.xy,_MWarpMode));
                float4 b=READ_EFFECT(_MainTex02,WrapChoice(input.mainUV.zw,_M02WarpMode));
                float4 layers=BlendMainLayers(a,b);
                float4 multiplied=fresnel*layers;
                float4 added=fresnel+layers;
                float4 normalBlend=lerp(multiplied,added,_BlendMode);
                float4 invertedBlend=lerp(multiplied,added*fresnel.a,_BlendMode);
                float4 color=lerp(normalBlend,invertedBlend,_InvertMode);
                float redMask=lerp(a.r*b.r,saturate(a.r+b.r),_MNBlendMode);
                float opacity=lerp(color.a,color.a*redMask,_BlackOff)*maskAlpha;
                return FinishPremultiplied(color,opacity,input);
            }
            float2 DissolveCoverage(Varyings input)
            {
                float noise=READ_EFFECT(_DissolveTex,input.dissolveUV.xy).r;
                float2 direction=lerp(input.dissolveUV.zw,1.0-input.dissolveUV.zw,_InvertDissolveDir);
                float directionValue=lerp(direction.x,direction.y,_DissolveDir);
                float shape=lerp(noise+1.0,noise*directionValue+1.0,_DissolveDirToggle);
                float threshold=lerp(_depc.x,input.custom.z,_dissolveMode);
                float2 wideAndTight=saturate(shape-2.0*float2(threshold-_depc.w,threshold));
                // 原soft remap：lower=(1-softness)/2，width=softness。
                float lower=1.0-(_depc.y+1.0)*0.5;
                return saturate((wideAndTight-lower)/_depc.y);
            }
            float4 EffectFragment(Varyings input):SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
#if defined(_GENERALVFX_VARIANT2)
                return EvaluateMaskedDual(input);
#endif
                float2 uv=input.mainUV.xy;
#if defined(_GENERALVFX_VARIANT3)
                {
                    float noise=READ_EFFECT(_NoiseTex,WrapChoice(input.noiseMaskUV.xy,_NWarpMode)).g-0.5;
                    float intensity=lerp(_DistortIntensity,input.custom.w,_DistortMod);
                    uv+=noise*intensity; // 同一个G通道偏移X和Y，不是RG向量
                }
#endif
                float4 mainSample=READ_EFFECT(_MainTex,WrapChoice(uv,_MWarpMode));
                // 原无第二纹理的静态变体仍以(1-MNBlendMode)作为第二层样本。
                float4 color=BlendMainLayers(mainSample,(1.0-_MNBlendMode).xxxx);
                float opacity=lerp(color.a,color.a*mainSample.r,_BlackOff);
#if defined(_GENERALVFX_VARIANT4)
                {
                    float2 coverage=DissolveCoverage(input);
                    opacity*=coverage.x;
                    color.rgb=lerp(_EdgeColor.rgb*_EdgeColorIntensity,color.rgb,coverage.y);
                }
#endif
                return FinishPremultiplied(color,opacity,input);
            }
            ENDHLSL
        }
    }
    FallBack Off
}


