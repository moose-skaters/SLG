// Frame4414：EID1122 / 1137，Program7523。原分类 CharacterMetallic，命名为 Monster。
// 原 GLSL：Assets/LastZ/GLSL/Monster_vs.txt、Monster_fs.txt。
// 阅读顺序：MonsterVertex -> ReadSurface -> EvaluateIndirectLighting / EvaluateDirectLighting -> MonsterFragment。
// 保留可执行 GLSL 的运算与特殊细节，不替换成通用 URP Lit/PBR。
Shader "LastZ/Monster"
{
    Properties
    {
        [Header(Surface)]
        [MainTexture] _BaseMap("Base color RGB - alpha unused", 2D) = "white" {}
        _BaseColor("Base tint - linear RGB", Vector) = (0.95,0.8854,0.8132,1)
        _UV2_ON("Base UV blend - 0 UV0 1 UV1", Range(0,1)) = 0
        _MGA("Packed R metallic G roughness B AO A emission", 2D) = "white" {}
        _MetallicIntensity("Metallic multiplier", Float) = 1
        _RoughnessIntensity("Roughness multiplier", Float) = 1
        _AoIntensity("Indirect lighting AO multiplier", Float) = 1

        [Header(Reflection)]
        [NoScaleOffset] _ReflectionMap("Original six face reflection cubemap", Cube) = "" {}
        // 原 CB 为 _ReflectionMap_HDR；这个保留名称会被 Unity 的纹理元数据自动覆盖。
        _ReflectionDecodeParams("Original HDR decode - X multiplier Y exponent W alpha flag", Vector) = (34.493244,2.2,0,1)
        reflectionDir("Additive reflection direction offset XYZ", Vector) = (1,1,1,0)
        _ReflectionIntenSity("Reflection strength - raised to power 0.44 before decoding", Range(0,8)) = 1

        [Header(Direct and Game Lighting)]
        _CustmLightDir_ON("Main to custom light direction blend", Range(0,1)) = 0
        _CustomLightDir("Custom light direction - normalized as XYZW", Vector) = (0,0.54,0.13,1)
        _CustomLightIntensity("URP main light color multiplier", Float) = 1
        _HeroDayNight_ON("Main light to game hero color blend", Range(0,1)) = 1
        _DayNightInfluence("Final RGB influence of game hero color", Range(0,1)) = 1

        [Header(Emission)]
        [Toggle] _EmissionMap_ON("Use emission texture - otherwise use MGA alpha", Float) = 0
        [NoScaleOffset] _EmissionMap("Emission RGB - raw UV0", 2D) = "black" {}
        _EmissiveColor("Emission color - linear HDR RGB", Vector) = (1,1,1,1)
        _EmissiveIntensity("Emission intensity", Float) = 0

        [Header(Fresnel)]
        [Toggle] _Fresnel_ON("Enable additive Fresnel", Float) = 0
        _Fresnel_Color("Fifth power Fresnel color - linear RGB", Vector) = (1.41176474,0,0,1)
        _Fresnel_Color_Edge("Cubic edge color - linear RGB", Vector) = (0,0,0,0)
        _Fresnel_Bisa("Fifth power Fresnel bias", Float) = 0.1
        _Fresnel_Scale("Fifth power Fresnel scale", Float) = 1
        _Fresnel_Scale_Edge("Cubic edge scale", Float) = 0
        _Fresnel_Intensity("Both Fresnel terms intensity", Float) = 1
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
        Pass
        {
            Name "MonsterForward"
            Tags { "LightMode"="UniversalForwardOnly" }
            Cull Back
            ZTest LEqual
            ZWrite On
            Blend Off
            ColorMask RGBA

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

            // 原 GLSL $Globals，由 LastZGlobalShaderParameters 统一设置。
            float4 _LightColor2;
            float _LightIntensity2;

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST, _MGA_ST, _BaseColor;
                float4 reflectionDir, _ReflectionDecodeParams;
                float4 _CustomLightDir, _EmissiveColor;
                float4 _Fresnel_Color, _Fresnel_Color_Edge;
                float _UV2_ON, _MetallicIntensity, _RoughnessIntensity, _AoIntensity;
                float _ReflectionIntenSity, _CustmLightDir_ON, _CustomLightIntensity, _HeroDayNight_ON;
                float _DayNightInfluence, _EmissionMap_ON, _EmissiveIntensity;
                float _Fresnel_ON, _Fresnel_Bisa, _Fresnel_Scale, _Fresnel_Scale_Edge, _Fresnel_Intensity;
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
                float4 uv : TEXCOORD0;       // 原 vs_TEXCOORD0：UV0.xy、UV1.zw
                float3 normalWS : TEXCOORD1; // 原 vs_TEXCOORD2.xyz
                float3 positionWS : TEXCOORD2; // 原 TEXCOORD2/3/4.w 分别保存世界 XYZ
                float3 ambientSH : TEXCOORD3; // 原 vs_TEXCOORD5.xyz
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

            MonsterSurface ReadSurface(float4 uv)
            {
                MonsterSurface surface = (MonsterSurface)0;
                float2 baseUV = lerp(uv.xy, uv.zw, _UV2_ON);
                baseUV = baseUV * _BaseMap_ST.xy + _BaseMap_ST.zw;
                // 原 texture() 无 bias；抵消 URP14 自动附加的全局 bias。
                float3 baseSample = SAMPLE_TEXTURE2D_BIAS(_BaseMap, sampler_BaseMap, baseUV, -_GlobalMipBias.x).rgb;
                float2 materialUV = uv.xy * _MGA_ST.xy + _MGA_ST.zw;
                float4 packed = SAMPLE_TEXTURE2D_BIAS(_MGA, sampler_MGA, materialUV, -_GlobalMipBias.x);
                float3 albedo = baseSample * _BaseColor.rgb;
                float metallic = saturate(packed.r * _MetallicIntensity);

                // 保留原先“粗糙度 -> 光滑度 -> 粗糙度”的截断次序。
                // 输入为1时 smoothness 仍至少0.001，最终 perceptualRoughness 为0.999。
                float inputRoughness = clamp(packed.g * _RoughnessIntensity, 0.001, 1.0);
                float smoothness = max(1.0 - inputRoughness, 0.001);
                surface.perceptualRoughness = 1.0 - smoothness;
                surface.roughness = max(surface.perceptualRoughness * surface.perceptualRoughness, 0.0078125);

                float oneMinusReflectivity = 0.96 * (1.0 - metallic);
                surface.diffuseColor = albedo * oneMinusReflectivity;
                surface.specularColor = lerp(float3(0.04,0.04,0.04), albedo, metallic);
                surface.grazingReflectance = min(smoothness + 1.0 - oneMinusReflectivity, 1.0);
                // 原式只限制上界，不额外加 saturate 的下界限制。
                surface.occlusion = min(packed.b * _AoIntensity, 1.0);
                surface.emissionMask = packed.a;
                return surface;
            }

            float3 DecodeReflection(float4 encoded)
            {
                // Monster 与 CharacterSpecular 不同：先对强度取0.44次幂。
                // 有效强度非负；只对脚本传入的无效负值增加保护。
                float reflectionScale = pow(max(_ReflectionIntenSity, 0.0), 0.44);
                float3 scaledRGB = encoded.rgb * reflectionScale;
                float scaledAlpha = encoded.a * reflectionScale;
                float alphaForDecode = max(1.0 + _ReflectionDecodeParams.w * (scaledAlpha - 1.0), 0.0);
                float decodeScale = _ReflectionDecodeParams.x * pow(alphaForDecode, _ReflectionDecodeParams.y);
                return scaledRGB * decodeScale;
            }

            float3 EvaluateIndirectLighting(MonsterSurface surface, Varyings input,
                                             float3 normalWS, float3 viewDirection)
            {
                float3 reflectedDirection = reflect(-viewDirection, normalWS) + reflectionDir.xyz;
                float roughness = surface.perceptualRoughness;
                float mipLevel = roughness * (1.7 - 0.7 * roughness) * 6.0;
                float4 encodedReflection = SAMPLE_TEXTURECUBE_LOD(_ReflectionMap, sampler_ReflectionMap,
                                                                 reflectedDirection, mipLevel);
                float3 reflection = DecodeReflection(encodedReflection);

                float edge = 1.0 - saturate(dot(normalWS, viewDirection));
                float edgeSquared = edge * edge;
                float reflectionFresnel = edgeSquared * edgeSquared;
                float3 reflectionTint = lerp(surface.specularColor,
                    surface.grazingReflectance.xxx, reflectionFresnel);
                float surfaceReduction = 1.0 / (surface.roughness * surface.roughness + 1.0);
                float3 indirectSpecular = surfaceReduction * reflectionTint * reflection;
                float3 indirectDiffuse = input.ambientSH * surface.diffuseColor;
                // AO 仅影响 SH 和反射；不会压暗下面的直接光或自发光。
                return (indirectDiffuse + indirectSpecular) * surface.occlusion;
            }

            float3 EvaluateDirectLighting(MonsterSurface surface, float3 normalWS)
            {
                Light mainLight = GetMainLight();
                // 原 dot 使用完整 XYZW；W=1 会使 XYZ 长度小于1，不能改为 normalize(xyz)。
                float3 customDirection = normalize(_CustomLightDir).xyz;
                float3 lightDirection = lerp(mainLight.direction, customDirection, _CustmLightDir_ON);
                // 混合后同样不再次归一化。
                float lambert = saturate(dot(normalWS, lightDirection)) * mainLight.distanceAttenuation;
                float3 sceneLightColor = mainLight.color * _CustomLightIntensity;
                float3 heroLightColor = _LightColor2.rgb * _LightIntensity2;
                float3 lightColor = lerp(sceneLightColor, heroLightColor, _HeroDayNight_ON);
                // 原程序只有直接漫反射，没有额外计算直接光的微表面高光。
                return surface.diffuseColor * lightColor * lambert;
            }

            float3 EvaluateEmission(MonsterSurface surface, float2 uv0)
            {
                float3 emissionColor = _EmissiveColor.rgb * _EmissiveIntensity;
                float3 emissionMask = surface.emissionMask.xxx;
                if (_EmissionMap_ON > 0.5)
                {
                    // 自发光贴图始终用原 UV0，不用 BaseMap 的 UV选择或 ST。
                    emissionMask = SAMPLE_TEXTURE2D_BIAS(_EmissionMap, sampler_EmissionMap,
                                                        uv0, -_GlobalMipBias.x).rgb;
                }
                return emissionMask * emissionColor;
            }

            float3 EvaluateFresnel(float3 normalWS, float3 viewDirection)
            {
                float edge = 1.0 - saturate(dot(normalWS, viewDirection));
                float edgeSquared = edge * edge;
                float edgeCubed = edgeSquared * edge;
                float edgeFifth = edgeCubed * edgeSquared;
                float broadRim = (_Fresnel_Bisa + _Fresnel_Scale * edgeFifth) * _Fresnel_Intensity;
                float edgeRim = edgeCubed * _Fresnel_Scale_Edge * _Fresnel_Intensity;
                // 与 SceneLit 一样是加色；不同于 CharacterSpecular 的颜色替换插值。
                return _Fresnel_Color.rgb * broadRim + _Fresnel_Color_Edge.rgb * edgeRim;
            }

            float4 MonsterFragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                float3 normalWS = normalize(input.normalWS);
                float3 viewDirection = normalize(_WorldSpaceCameraPos - input.positionWS);
                MonsterSurface surface = ReadSurface(input.uv);
                float3 color = EvaluateIndirectLighting(surface, input, normalWS, viewDirection)
                             + EvaluateDirectLighting(surface, normalWS)
                             + EvaluateEmission(surface, input.uv.xy);
                if (_Fresnel_ON > 0.5) color += EvaluateFresnel(normalWS, viewDirection);
                // 最后这一次昼夜染色作用于总颜色，包括反射、自发光和 Fresnel。
                float3 dayNightColor = lerp(float3(1,1,1), _LightColor2.rgb * _LightIntensity2, _DayNightInfluence);
                return float4(color * dayNightColor, 1.0);
            }
            // 本捕获变体没有采样 _NormalMap：NormalScale/NormalMap_ST、VS切线/副切线均无效。
            // ClipThreshold、HorizontalPlaneValue、LightIntensity、AddLightIntensity也未使用。
            // 不伪造法线贴图、Alpha Clip、额外灯或GPU蒙皮；最终Alpha固定为1。
            ENDHLSL
        }
    }
    FallBack Off
}
