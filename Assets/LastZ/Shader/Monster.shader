Shader "LastZ/Monster"
{
    Properties
    {
        [Header(Surface)]
        [MainTexture] _BaseMap("主纹理", 2D) = "white" {}
        _BaseColor("基础颜色", Vector) = (0.95,0.89,0.81,1)
        [Toggle] _UV2_ON("启用第二套 UV（关闭=UV0，开启=UV1）", Float) = 0
        _MGA("Mask纹理（R 金属度、G 粗糙度、B AO、A 自发光）", 2D) = "white" {}
        _MetallicIntensity("金属度", Float) = 1
        _RoughnessIntensity("粗糙度", Float) = 1
        _AoIntensity("AO强度", Float) = 1
        
        [Space(8)]
        [Header(Reflection)]
        [NoScaleOffset]_ReflectionMap("反射球", Cube) = "" {}
        _ReflectionDecodeParams("HDR 解码参数（X 倍率、Y 指数、W Alpha）", Vector) = (34.49,2.2,0,1)
        reflectionDir("反射方向附加偏移 XYZ", Vector) = (1,1,1,0)
        _ReflectionIntenSity("反射强度", Range(0,8)) = 1

        [Space(8)]
        [Header(Lighting)]
        [Toggle] _CustmLightDir_ON("启用自定义光方向", Float) = 0
        _CustomLightDir("自定义光方向", Vector) = (0,0.54,0.13,1)
        _CustomLightIntensity("自定义光强度", Float) = 1
        [Toggle] _HeroDayNight_ON("启用角色昼夜光照", Float) = 1
        _DayNightInfluence("游戏角色光对最终 RGB 的影响", Range(0,1)) = 1

        [Space(8)]
        [Header(Emission)]
        [Toggle] _EmissionMap_ON("使用自发光纹理（关闭时使用 MGA Alpha）", Float) = 0
        [NoScaleOffset] _EmissionMap("自发光纹理（RGB）", 2D) = "black" {}
        _EmissiveColor("自发光颜色", Vector) = (1,1,1,1)
        _EmissiveIntensity("自发光强度", Float) = 0

        [Space(8)]
        [Header(Fresnel)]
        [Toggle] _Fresnel_ON("启用菲涅尔", Float) = 0
        _Fresnel_Color("菲涅尔颜色", Vector) = (1.41,0,0,1)
        _Fresnel_Color_Edge("边缘菲涅尔颜色", Vector) = (0,0,0,0)
        _Fresnel_Bisa("菲涅尔偏移", Float) = 0.1
        _Fresnel_Scale("菲涅尔强度", Float) = 1
        _Fresnel_Scale_Edge("边缘菲涅尔强度", Float) = 0
        _Fresnel_Intensity("菲涅尔总强度", Float) = 1
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
        Pass
        {
            Name "MonsterForward"
            Tags { "LightMode"="UniversalForward" }
            HLSLPROGRAM
            #pragma target 3.5
            #pragma vertex MonsterVertex
            #pragma fragment MonsterFragment
            #pragma multi_compile_instancing
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
            TEXTURE2D(_MGA); SAMPLER(sampler_MGA);
            TEXTURE2D(_EmissionMap); SAMPLER(sampler_EmissionMap);
            TEXTURECUBE(_ReflectionMap); SAMPLER(sampler_ReflectionMap);

            float4 _LightColor2;
            float _LightIntensity2;

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                float4 _MGA_ST;
                float4 _BaseColor;
                float4 reflectionDir;
                float4 _ReflectionDecodeParams;
                float4 _CustomLightDir;
                float4 _EmissiveColor;
                float4 _Fresnel_Color;
                float4 _Fresnel_Color_Edge;
                float _UV2_ON;
                float _MetallicIntensity;
                float _RoughnessIntensity;
                float _AoIntensity;
                float _ReflectionIntenSity;
                float _CustmLightDir_ON;
                float _CustomLightIntensity;
                float _HeroDayNight_ON;
                float _DayNightInfluence;
                float _EmissionMap_ON;
                float _EmissiveIntensity;
                float _Fresnel_ON;
                float _Fresnel_Bisa;
                float _Fresnel_Scale;
                float _Fresnel_Scale_Edge;
                float _Fresnel_Intensity;
            CBUFFER_END

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
                float3 ambientSH : TEXCOORD3;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            struct MonsterSurface
            {
                float3 diffuseColor;
                float3 specularColor;
                float perceptualRoughness;
                float roughness;
                float grazingReflectance;
                float occlusion;
                float emissionMask;
            };
            
            Varyings MonsterVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                output.positionWS = TransformObjectToWorld(input.positionOS);
                output.positionCS = TransformWorldToHClip(output.positionWS);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                output.ambientSH = SampleSH(output.normalWS);
                output.uv = float4(input.uv0, input.uv1);
                return output;
            }

            MonsterSurface InitializeSurfaceData(float4 uv)
            {
                MonsterSurface surface = (MonsterSurface)0;
                float2 baseUV = lerp(uv.xy, uv.zw, _UV2_ON);
                baseUV = baseUV * _BaseMap_ST.xy + _BaseMap_ST.zw;
                float3 baseSample = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, baseUV).rgb;
                float2 materialUV = uv.xy * _MGA_ST.xy + _MGA_ST.zw;
                
                float4 packed = SAMPLE_TEXTURE2D(_MGA, sampler_MGA, materialUV);
                float3 albedo = baseSample * _BaseColor.rgb;
                float metallic = saturate(packed.r * _MetallicIntensity);

                float inputRoughness = clamp(packed.g * _RoughnessIntensity, 0.001, 1.0);
                float smoothness = max(1.0 - inputRoughness, 0.001);
                surface.perceptualRoughness = 1.0 - smoothness;
                surface.roughness = max(surface.perceptualRoughness * surface.perceptualRoughness, 0.0078125);

                float oneMinusReflectivity = 0.96 * (1.0 - metallic);
                surface.diffuseColor = albedo * oneMinusReflectivity;
                surface.specularColor = lerp(float3(0.04,0.04,0.04), albedo, metallic);
                surface.grazingReflectance = min(smoothness + 1.0 - oneMinusReflectivity, 1.0);

                surface.occlusion = min(packed.b * _AoIntensity, 1.0);
                surface.emissionMask = packed.a;
                return surface;
            }

            float3 DecodeReflection(float4 encoded)
            {
                float reflectionScale = pow(max(_ReflectionIntenSity, 0.0), 0.44);
                float3 scaledRGB = encoded.rgb * reflectionScale;
                float scaledAlpha = encoded.a * reflectionScale;
                float alphaForDecode = max(1.0 + _ReflectionDecodeParams.w * (scaledAlpha - 1.0), 0.0);
                float decodeScale = _ReflectionDecodeParams.x * pow(alphaForDecode, _ReflectionDecodeParams.y);
                return scaledRGB * decodeScale;
            }

            float3 EvaluateIndirectLighting(MonsterSurface surface, Varyings input,float3 normalWS, float3 viewDirection)
            {
                float3 reflectedDirection = reflect(-viewDirection, normalWS) + reflectionDir.xyz;
                float roughness = surface.perceptualRoughness;
                float mipLevel = roughness * (1.7 - 0.7 * roughness) * 6.0;
                float4 encodedReflection = SAMPLE_TEXTURECUBE_LOD(_ReflectionMap, sampler_ReflectionMap,reflectedDirection, mipLevel);
                float3 reflection = DecodeReflection(encodedReflection);

                float  edge = 1.0 - saturate(dot(normalWS, viewDirection));
                float  reflectionFresnel = pow(edge, 4.0);
                float3 reflectionTint = lerp(surface.specularColor,surface.grazingReflectance.r, reflectionFresnel);
                float  surfaceReduction = 1.0 / (surface.roughness * surface.roughness + 1.0);
                float3 indirectSpecular = surfaceReduction * reflectionTint * reflection;
                float3 indirectDiffuse = input.ambientSH * surface.diffuseColor;

                return (indirectDiffuse + indirectSpecular) * surface.occlusion;
            }

            float3 EvaluateDirectLighting(MonsterSurface surface, float3 normalWS)
            {
                Light mainLight = GetMainLight();

                float3 customDirection = normalize(_CustomLightDir).xyz;
                float3 lightDirection = lerp(mainLight.direction, customDirection, _CustmLightDir_ON);
                float lambert = saturate(dot(normalWS, lightDirection)) * mainLight.distanceAttenuation;
                float3 sceneLightColor = mainLight.color * _CustomLightIntensity;
                float3 heroLightColor = _LightColor2.rgb * _LightIntensity2;
                float3 lightColor = lerp(sceneLightColor, heroLightColor, _HeroDayNight_ON);
                
                return surface.diffuseColor * lightColor * lambert;
            }

            float3 EvaluateEmission(MonsterSurface surface, float2 uv0)
            {
                float3 emissionColor = _EmissiveColor.rgb * _EmissiveIntensity;
                float3 emissionMask  = surface.emissionMask.xxx;
                if (_EmissionMap_ON > 0.5)
                {
                    emissionMask = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, uv0).rgb;
                }
                return emissionMask * emissionColor;
            }

            float3 EvaluateFresnel(float3 normalWS, float3 viewDirection)
            {
                float edgeFactor = 1.0 - saturate(dot(normalWS, viewDirection));
                float edgePower3 = pow(edgeFactor, 3.0);
                float edgePower5 = pow(edgeFactor, 5.0);
                float broadRim = (_Fresnel_Bisa + _Fresnel_Scale * edgePower5) * _Fresnel_Intensity;
                float edgeRim = edgePower3 * _Fresnel_Scale_Edge * _Fresnel_Intensity;
                return _Fresnel_Color.rgb * broadRim + _Fresnel_Color_Edge.rgb * edgeRim;
            }

            float4 MonsterFragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                float3 normalWS = normalize(input.normalWS);
                float3 viewDirection = normalize(GetWorldSpaceViewDir(input.positionWS));
                MonsterSurface surface = InitializeSurfaceData(input.uv);
                float3 color = EvaluateIndirectLighting(surface, input, normalWS, viewDirection)
                             + EvaluateDirectLighting(surface, normalWS)
                             + EvaluateEmission(surface, input.uv.xy);
                if (_Fresnel_ON > 0.5) color += EvaluateFresnel(normalWS, viewDirection);
                float3 dayNightColor = lerp(float3(1,1,1), _LightColor2.rgb * _LightIntensity2, _DayNightInfluence);
                return float4(color * dayNightColor, 1.0);
            }
            ENDHLSL
        }
    }
    FallBack Off
}
