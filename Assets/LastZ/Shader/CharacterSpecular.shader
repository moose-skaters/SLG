Shader "LastZ/CharacterSpecular"
{
    Properties
    {
        [Header(Surface)]
        [MainTexture] _MainTex("主纹理", 2D) = "white" {}
        _BaseColor("基础颜色", Vector) = (1,1,1,1)
        [Toggle(_ALPHATEST_ON)] _AlphaClip("启用 Alpha 裁切", Float) = 0
        _CutValue("头发最终 Alpha 裁切阈值", Range(0,1)) = 0.5
        _FadeY("世界 Y 可见阈值", Float) = 0
        _AlphFadeY_ON("世界高度 Alpha 控制", Range(0,1)) = 0

        [Space(8)]
        [Header(Specular)]
        _SepcularGloss("遮罩纹理（R 光滑度、G 皮革、B 布料、A 皮肤）", 2D) = "white" {}
        _DetailTex("细节遮罩（R 通道）", 2D) = "white" {}
        _SpecColor("高光颜色", Vector) = (1,1,1,1)
        _Shininess("高光指数", Range(0.001,4)) = 0.2
        _Smoothness0("光滑度", Float) = 0.84
        _Leather("皮革高光强度", Float) = 2.5
        _Cloth("布料高光强度", Float) = 1
        _Skin("皮肤高光强度", Float) = 1
        _DetailIntensity("皮革细节强度", Float) = 0.7
        _CustomSpecLightDir_ON("开启自定义高光方向", Range(0,1)) = 1
        _CustomSpecLightDir("自定义高光方向", Vector) = (-0.2,2.96,-2.3,1)

        [Space(8)]
        [Header(Reflection)]
        [NoScaleOffset] _ReflectionMap("反射球", Cube) = "" {}
        _ReflectionDecodeParams("HDR 解码参数（X 倍率、Y 指数、W Alpha 标志）", Vector) = (34.49,2.2,0,1)
        ReflectionDir("反射方向附加偏移 XYZ", Vector) = (0.94,4.2,-0.4,0)
        _ReflectionIntenSity("反射强度", Float) = 1
        _Reflectivity("B 通道对掠射反射的贡献", Float) = 1

        [Space(8)]
        [Header(Fresnel)]
        [Toggle] _Fresnel_ON("启用菲涅尔", Float) = 0
        _Fresnel_Color("菲涅尔颜色", Vector) = (1,1,1,1)
        _Fresnel_Bisa("菲涅尔偏移", Float) = 0
        _Fresnel_Scale("菲涅尔强度", Float) = 0
        _Fresnel_Intensity("菲涅尔总强度", Float) = 0

        _ShadowColor("阴影颜色", Vector) = (0.12,0.12,0.12,1)
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
        Pass
        {
            Name "CharacterSpecularForward"
            Tags { "LightMode"="UniversalForward" }
            HLSLPROGRAM
            #pragma target 3.5
            #pragma vertex CharacterVertex
            #pragma fragment CharacterFragment
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma multi_compile_instancing
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
            TEXTURE2D(_SepcularGloss); SAMPLER(sampler_SepcularGloss);
            TEXTURE2D(_DetailTex); SAMPLER(sampler_DetailTex);
            TEXTURECUBE(_ReflectionMap); SAMPLER(sampler_ReflectionMap);

            float4 _LightColor2;
            float _LightIntensity2;

            CBUFFER_START(UnityPerMaterial)
                // 纹理 UV 变换
                float4 _MainTex_ST;
                float4 _SepcularGloss_ST;
                float4 _DetailTex_ST;

                // 基础颜色与高光颜色
                float4 _BaseColor;
                float4 _SpecColor;
                float4 _CustomSpecLightDir;
                float4 _ShadowColor;

                // 反射与菲涅耳颜色
                float4 _ReflectionDecodeParams;
                float4 ReflectionDir;
                float4 _Fresnel_Color;

                // 变体与 Alpha
                float _AlphaClip;
                float _CutValue;
                float _FadeY;
                float _AlphFadeY_ON;

                // 高光参数
                float _Shininess;
                float _Smoothness0;
                float _Leather;
                float _Cloth;
                float _Skin;
                float _DetailIntensity;

                // 自定义高光方向与反射强度
                float _CustomSpecLightDir_ON;
                float _ReflectionIntenSity;
                float _Reflectivity;

                // 菲涅耳参数
                float _Fresnel_ON;
                float _Fresnel_Bisa;
                float _Fresnel_Scale;
                float _Fresnel_Intensity;
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
                float3 positionWS : TEXCOORD0; 
                float2 uv : TEXCOORD1;         
                float3 normalWS : TEXCOORD2;   
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings CharacterVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                output.positionWS = TransformObjectToWorld(input.positionOS);
                output.positionCS = TransformWorldToHClip(output.positionWS);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                output.uv = input.uv;
                return output;
            }

            float3 EvaluateSpecular(float4 packed, float detail, float3 normalWS,float3 viewDirection, float3 mainLightDirection)
            {
                float3 specularDirection = lerp(mainLightDirection, _CustomSpecLightDir.xyz, _CustomSpecLightDir_ON);
                float3 halfDirection = normalize(viewDirection + specularDirection);
                float highlight = pow(max(dot(normalWS, halfDirection), 0.0), _Shininess * 128.0);
                float3 highlightColor = _LightColor2.rgb * _SpecColor.rgb * _LightIntensity2 * highlight;

                // Mask纹理 RGBA 分别提供光滑度、皮革、布料和皮肤权重。
                float strength = packed.g * detail * _Leather * _DetailIntensity;
                strength += packed.r * _Smoothness0;
                strength += packed.b * _Cloth;
                strength += packed.a * _Skin;

                return saturate(strength * highlightColor);
            }

            float3 DecodeReflection(float4 encodedSample)
            {
                float3 scaledRGB = encodedSample.rgb * _ReflectionIntenSity;
                float scaledAlpha = encodedSample.a * _ReflectionIntenSity;
                float alphaForDecode = max(1.0 + _ReflectionDecodeParams.w * (scaledAlpha - 1.0), 0.0);
                float decodeScale = _ReflectionDecodeParams.x * pow(alphaForDecode, _ReflectionDecodeParams.y);
                return scaledRGB * decodeScale;
            }

            float3 EvaluateReflection(float4 packed, float3 baseColor,
                                      float3 normalWS, float3 viewDirection)
            {
                float smoothness = packed.r * _Smoothness0;
                float perceptualRoughness = 1.0 - smoothness;
                float mipLevel = perceptualRoughness * (1.7 - 0.7 * perceptualRoughness) * 6.0;
                float3 reflectionDirection = reflect(-viewDirection, normalWS) + ReflectionDir.xyz;
                float4 encodedReflection = SAMPLE_TEXTURECUBE_LOD(_ReflectionMap, sampler_ReflectionMap,
                                                                 reflectionDirection, mipLevel);
                float3 reflection = DecodeReflection(encodedReflection);

                float edge = 1.0 - dot(normalWS, viewDirection);
                float reflectionFresnel = pow(edge, 4.0);
                float grazingReflectance = saturate(packed.b * _Reflectivity + smoothness);
                float3 reflectionTint = lerp(baseColor, grazingReflectance.xxx, reflectionFresnel);
                return packed.r * reflectionTint * reflection;
            }

            float3 ApplyFresnelColor(float3 color, float3 normalWS, float3 viewDirection)
            {
                float edge = 1.0 - saturate(dot(normalWS, viewDirection));
                float edgeFifth = pow(edge, 5.0);
                float blend = (_Fresnel_Bisa + _Fresnel_Scale * edgeFifth) * _Fresnel_Intensity;
                return lerp(color, _Fresnel_Color.rgb, blend);
            }

            float4 CharacterFragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float3 normalWS = normalize(input.normalWS);
                float3 viewDirection = normalize(GetWorldSpaceViewDir(input.positionWS));
                Light  mainLight = GetMainLight();
                
                float4 packed = SAMPLE_TEXTURE2D(_SepcularGloss, sampler_SepcularGloss,
                    input.uv * _SepcularGloss_ST.xy + _SepcularGloss_ST.zw);
                float4 mainSample = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex,
                    input.uv * _MainTex_ST.xy + _MainTex_ST.zw);
                float detail = SAMPLE_TEXTURE2D(_DetailTex, sampler_DetailTex,
                    input.uv * _DetailTex_ST.xy + _DetailTex_ST.zw).r;
                float4 tintedSample = mainSample * (_LightColor2 * _BaseColor * _LightIntensity2);
                float3 specular = EvaluateSpecular(packed, detail, normalWS, viewDirection, mainLight.direction);
                
                float3 shadowColor = lerp(_ShadowColor.rgb, float3(1,1,1), mainLight.distanceAttenuation);
                float3 color = (tintedSample.rgb + specular) * shadowColor;
                
                #if !defined(_ALPHATEST_ON)
                    color += EvaluateReflection(packed, tintedSample.rgb, normalWS, viewDirection);
                #endif
                #if !defined(_ALPHATEST_ON)
                    if (_Fresnel_ON > 0.5)
                        color = ApplyFresnelColor(color, normalWS, viewDirection);
                #endif

                float opacity = tintedSample.a;
                #if defined(_ALPHATEST_ON)
                    opacity *= lerp(1.0, step(_FadeY, input.positionWS.y), _AlphFadeY_ON);
                    clip(opacity - _CutValue);
                #endif
                return float4(color, opacity);
            }
            ENDHLSL
        }
    }
    FallBack Off
}
