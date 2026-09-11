Shader "LastZ/SceneLit"
{
    Properties
    {
        [Header(Surface)]
        [MainTexture] _MainTex("主纹理", 2D) = "white" {}
        _Color("基础颜色", Vector) = (1,1,1,1)
        _Intensity("颜色强度", Float) = 1
        [Toggle] _NoMainTextureOn("开启没有主纹理", Float) = 0
        _VertexOffsetY("物体空间 Y 偏移", Float) = 0

        [Toggle(_ALPHATEST_ON)] _AlphaClip("启用 Alpha 裁切", Float) = 0
        _CutOff("裁切阈值", Range(0,1)) = 0.5
        _AlphaIsR("透明度来源（0=Alpha，1=调色后的 R）", Range(0,1)) = 0
        [Toggle] _AlphFadeY_ON("世界高度 Alpha 控制", Float) = 0
        _FadeY("世界 Y 可见阈值", Float) = 0

        [Space(8)]
        [Header(Lighting)]
        [Toggle] _HeroDayNight_ON("启用角色昼夜光照", Float) = 0
        _BlinnPhongOn("BlinnPhongOn", Range(0,1)) = 0

        [Space(8)]
        [Header(Fresnel)]
        [Toggle] _Fresnel_ON("启用菲涅尔", Float) = 0
        _Fresnel_Color("菲涅尔颜色", Vector) = (1,1,1,1)
        _Fresnel_Color_Edge("边缘菲涅尔颜色", Vector) = (0,0,0,0)
        _Fresnel_Bisa("菲涅尔偏移", Float) = 0
        _Fresnel_Scale("菲涅尔强度", Float) = 0
        _Fresnel_Scale_Edge("边缘菲涅尔强度", Float) = 0
        _Fresnel_Intensity("菲涅尔总强度", Float) = 0

        [Space(8)]
        [Header(Emission)]
        [Toggle] _EMISSIONMAPON_ON("启用自发光纹理", Float) = 0

        [NoScaleOffset] _EmissionMap("自发光纹理", 2D) = "black" {}
        _EmissionColor("自发光颜色", Vector) = (1,1,1,1)
        _EmissionIntensity("自发光强度", Float) = 1
        [Toggle] _EMISSIONMAPON_BUILDING_ON("建筑自发光开启", Float) = 0

        [Space(8)]
        [Header(Animation)]
        [Toggle] _SheetAnimationON("启用纹理序列帧动画", Float) = 0
        _MainTexSheet("序列帧列数 X、行数 Y", Vector) = (1,1,1,1)
        _MainTexSheetAnimSpeed("序列帧播放速度", Float) = 1

        [Space(8)]
        [Header(Render State)]
        [Enum(UnityEngine.Rendering.CullMode)] _Cull("面剔除", Float) = 2
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("RGB 源混合因子", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("RGB 目标混合因子", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendAlpha("Alpha 源混合因子", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendAlpha("Alpha 目标混合因子", Float) = 0
        [Enum(Off,0,On,1)] _ZWrite("写入深度", Float) = 1
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Transparent" }
        Pass
        {
            Name "SceneLitForward"
            Tags { "LightMode"="UniversalForward" }
            Cull [_Cull]
            ZWrite [_ZWrite]
            Blend [_SrcBlend] [_DstBlend], [_SrcBlendAlpha] [_DstBlendAlpha]
            BlendOp Add, Add
            
            HLSLPROGRAM
            #pragma target 3.5
            #pragma vertex SceneLitVertex
            #pragma fragment SceneLitFragment
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma multi_compile_instancing
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
            TEXTURE2D(_EmissionMap); SAMPLER(sampler_EmissionMap);

            float4 _LightColor1;
            float _LightIntensity1;
            float4 _LightColor2;
            float _LightIntensity2;
            float _Timeline;

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _Color;
                float4 _MainTexSheet;
                // 菲涅耳与自发光颜色
                float4 _Fresnel_Color;
                float4 _Fresnel_Color_Edge;
                float4 _EmissionColor;
                // 基础表面参数
                float _Intensity;
                float _NoMainTextureOn;
                float _VertexOffsetY;
                float _CutOff;
                float _AlphaClip;
                float _AlphaIsR;
                float _AlphFadeY_ON;
                float _FadeY;
                // 材质参数：角色昼夜光照权重
                float _HeroDayNight_ON;
                float _BlinnPhongOn;
                // 菲涅耳参数
                float _Fresnel_ON;
                float _Fresnel_Bisa;
                float _Fresnel_Scale;
                float _Fresnel_Scale_Edge;
                float _Fresnel_Intensity;
                // 自发光参数
                float _EMISSIONMAPON_ON;
                float _EmissionIntensity;
                float _EMISSIONMAPON_BUILDING_ON;
                // 序列帧参数
                float _SheetAnimationON;
                float _MainTexSheetAnimSpeed;
            CBUFFER_END

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
                float3 ambientSH : TEXCOORD3;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings SceneLitVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                float3 displacedPositionOS = input.positionOS + float3(0, _VertexOffsetY, 0);
                output.positionWS = TransformObjectToWorld(displacedPositionOS);
                output.positionCS = TransformWorldToHClip(output.positionWS);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                output.ambientSH = SampleSH(output.normalWS);
                output.uv = input.uv;
                return output;
            }

            float2 GetAnimatedUV(float2 meshUV)
            {
                if (_SheetAnimationON == 0) return meshUV;
                float2 grid = _MainTexSheet.xy;
                float frameCount = trunc(grid.x * grid.y);
                float timeInFrames = _Time.y * _MainTexSheetAnimSpeed;
                float wrappedFrame = fmod(timeInFrames, frameCount);
                float column = trunc(fmod(wrappedFrame, grid.x));
                float rowFromTop = trunc(wrappedFrame / grid.x);
                float row = trunc(grid.y - rowFromTop - 1.0);
                return (meshUV + float2(column, row)) / grid;
            }

            float3 EvaluateSceneLighting(float3 albedo, Varyings input)
            {
                float3 environmentLight = _LightColor1.rgb * _LightIntensity1;
                float3 heroLight = _LightColor2.rgb * _LightIntensity2;
                float3 sceneLightColor = lerp(environmentLight, heroLight, _HeroDayNight_ON);
                float3 directColor = albedo * sceneLightColor;
                Light mainLight = GetMainLight();
                if (_BlinnPhongOn > 0.5)
                    directColor *= saturate(dot(mainLight.direction, input.normalWS));
                return directColor + albedo * input.ambientSH * _BlinnPhongOn;
            }

            float3 EvaluateFresnel(Varyings input)
            {
                float3 viewDirection = normalize(GetWorldSpaceViewDir(input.positionWS));
                float edgeFactor = 1.0 - saturate(dot(input.normalWS, viewDirection));
                float edgePower3 = pow(edgeFactor, 3.0);
                float edgePower5 = pow(edgeFactor, 5.0);
                return _Fresnel_Color.rgb * (_Fresnel_Bisa + _Fresnel_Scale * edgePower5) * _Fresnel_Intensity
                     + _Fresnel_Color_Edge.rgb * (edgePower3 * _Fresnel_Scale_Edge) * _Fresnel_Intensity;
            }

            float3 EvaluateEmission(float2 animatedUV)
            {
                float3 emissionSample = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap,
                    animatedUV).rgb * _EmissionColor.rgb;
                float3 normalEmission = emissionSample * _EmissionIntensity;
                float buildingIntensity = _EmissionIntensity * (1.0 - _Timeline);
                float3 buildingEmission = emissionSample * buildingIntensity;
                return lerp(normalEmission, buildingEmission, _EMISSIONMAPON_BUILDING_ON);
            }

            float ResolveOpacity(float rawTextureAlpha, float3 albedo, float worldY)
            {
                float opacityFromAlpha = rawTextureAlpha * _Color.a * _Intensity * _Color.a;
                float opacityFromRed = albedo.r * _Color.a;
                float opacity = lerp(opacityFromAlpha, opacityFromRed, _AlphaIsR);
                float heightVisibility = step(_FadeY, worldY);
                return lerp(opacity, opacity * heightVisibility, _AlphFadeY_ON);
            }

            float4 SceneLitFragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                
                float2 animatedUV = GetAnimatedUV(input.uv);
                float2 mainUV = animatedUV * _MainTex_ST.xy + _MainTex_ST.zw;
                float4 mainSample = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex,
                    mainUV);
                
                #if defined(_ALPHATEST_ON)
                    clip(mainSample.a - _CutOff);
                #endif
                float3 textureColor = lerp(mainSample.rgb, float3(1,1,1), _NoMainTextureOn);
                float3 albedo = textureColor * _Color.rgb * _Intensity;
                float3 color = EvaluateSceneLighting(albedo, input);
                
                if (_Fresnel_ON > 0.5) color += EvaluateFresnel(input);
                if (_EMISSIONMAPON_ON > 0.5) color += EvaluateEmission(animatedUV);
                
                float opacity = ResolveOpacity(mainSample.a, albedo, input.positionWS.y);
                return float4(color, opacity);
            }
            ENDHLSL
        }
    }
    FallBack Off
}
