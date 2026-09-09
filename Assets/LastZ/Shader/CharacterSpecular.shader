// Frame4414：CharacterSpecular，EID1084（枪械）、1255（身体）、1313（头发）。
// 普通 Program7531：高光 + Cubemap；头发 Program31745：高度 Alpha 裁切，无 Cubemap。
// 保留原属性名（包括 Sepcular / IntenSity 等拼写），便于与 GLSL 和 CB 对照。
// 阅读顺序：CharacterVertex -> EvaluateSpecular -> EvaluateReflection -> CharacterFragment。
Shader "LastZ/CharacterSpecular"
{
    Properties
    {
        [Header(Surface and Variant)]
        [MainTexture] _MainTex("Main texture - RGB and alpha", 2D) = "white" {}
        _BaseColor("Base tint - linear RGBA", Vector) = (1,1,1,1)
        [Toggle(_ALPHATEST_ON)] _AlphaClip("Hair variant - alpha clip and no reflection", Float) = 0
        _CutValue("Hair final alpha cutoff", Range(0,1)) = 0.5
        _FadeY("Hair visible at or above world Y", Float) = 0
        _AlphFadeY_ON("Hair height alpha gate strength", Range(0,1)) = 0

        [Header(Packed Specular and Detail)]
        _SepcularGloss("Packed R smooth G leather B cloth A skin", 2D) = "white" {}
        _DetailTex("Detail mask R", 2D) = "white" {}
        _SpecColor("Specular tint - linear RGB", Vector) = (1,1,1,1)
        _Shininess("Specular exponent divided by 128", Range(0.001,4)) = 0.2
        _Smoothness0("Packed R strength and reflection smoothness", Float) = 0.84
        _Leather("Packed G specular strength", Float) = 2.5
        _Cloth("Packed B specular strength", Float) = 1
        _Skin("Packed A specular strength", Float) = 1
        _DetailIntensity("Leather detail intensity", Float) = 0.7
        _CustomSpecLightDir_ON("Main to custom specular direction blend", Range(0,1)) = 1
        _CustomSpecLightDir("Custom specular direction - XYZ is not normalized", Vector) = (-0.2,2.96,-2.3,1)

        [Header(Cubemap Reflection)]
        [NoScaleOffset] _ReflectionMap("Original six face reflection cubemap", Cube) = "" {}
        // 原 CB 名为 _ReflectionMap_HDR；Unity 会自动覆盖该名称，故用独立参数保存捕获值。
        _ReflectionDecodeParams("HDR decode - multiplier X exponent Y alpha flag W", Vector) = (34.493244,2.2,0,1)
        ReflectionDir("Additive reflection direction offset XYZ", Vector) = (0.94,4.2,-0.4,0)
        _ReflectionIntenSity("Intensity before RGB and alpha HDR decoding", Float) = 1
        _Reflectivity("Packed B contribution to grazing reflectance", Float) = 1

        [Header(Fresnel Color Replacement)]
        [Toggle] _Fresnel_ON("Enable Fresnel color replacement", Float) = 0
        _Fresnel_Color("Fresnel target color - linear RGB", Vector) = (1,1,1,1)
        _Fresnel_Bisa("Fresnel bias", Float) = 0
        _Fresnel_Scale("Fresnel fifth power scale", Float) = 0
        _Fresnel_Intensity("Fresnel interpolation intensity", Float) = 0

        _ShadowColor("Tint when unity LightData Z is zero - linear RGB", Vector) = (0.120026499,0.120026499,0.120026499,1)
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
        Pass
        {
            Name "CharacterSpecularForward"
            Tags { "LightMode"="UniversalForwardOnly" }
            Cull Back
            ZTest LEqual
            ZWrite On
            Blend Off
            ColorMask RGBA

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

            // 原 GLSL $Globals，由 LastZGlobalShaderParameters 统一设置。
            float4 _LightColor2;
            float _LightIntensity2;

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST, _SepcularGloss_ST, _DetailTex_ST;
                float4 _BaseColor, _SpecColor, _CustomSpecLightDir, _ShadowColor;
                float4 _ReflectionDecodeParams, ReflectionDir, _Fresnel_Color;
                float _AlphaClip, _CutValue, _FadeY, _AlphFadeY_ON;
                float _Shininess, _Smoothness0, _Leather, _Cloth, _Skin, _DetailIntensity;
                float _CustomSpecLightDir_ON, _ReflectionIntenSity, _Reflectivity;
                float _Fresnel_ON, _Fresnel_Bisa, _Fresnel_Scale, _Fresnel_Intensity;
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
                float3 positionWS : TEXCOORD0; // 原 vs_TEXCOORD0.xyz
                float2 uv : TEXCOORD1;         // 原 vs_TEXCOORD3.xy
                float3 normalWS : TEXCOORD2;   // 原 vs_TEXCOORD4
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

            float3 EvaluateSpecular(float4 packed, float detail, float3 normalWS,
                                    float3 viewDirection, float3 mainLightDirection)
            {
                // 先插值灯方向，再与视线相加；不能先 normalize 自定义灯方向。
                float3 specularDirection = lerp(mainLightDirection, _CustomSpecLightDir.xyz, _CustomSpecLightDir_ON);
                float3 halfDirection = normalize(viewDirection + specularDirection);
                float nDotH = max(dot(normalWS, halfDirection), 0.0);
                float highlight = pow(nDotH, _Shininess * 128.0);
                float3 highlightColor = _LightColor2.rgb * _SpecColor.rgb * _LightIntensity2 * highlight;

                // RGBA 是四个权重通道，只有 G 的贡献经过 Detail.r 调制。
                float smoothSpecular = packed.r * _Smoothness0;
                float leatherSpecular = packed.g * detail * _Leather * _DetailIntensity;
                float clothSpecular = packed.b * _Cloth;
                float skinSpecular = packed.a * _Skin;
                float strength = smoothSpecular + leatherSpecular + clothSpecular + skinSpecular;
                // 原 FS 对高光的最终 RGB 单独限幅，不裁切基础色或最终合成色。
                return saturate(strength * highlightColor);
            }

            float3 DecodeReflection(float4 encodedSample)
            {
                // 原顺序：强度先乘到 Cubemap 的 RGBA，再执行 HDR 解码。
                // 直接 DecodeHDREnvironment(sample) * intensity 会改变 alpha 解码结果。
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
                // 原公式没有先 saturate roughness；GPU sampler 自行限制 mip 范围。
                float mipLevel = perceptualRoughness * (1.7 - 0.7 * perceptualRoughness) * 6.0;
                float3 reflectionDirection = reflect(-viewDirection, normalWS) + ReflectionDir.xyz;
                float4 encodedReflection = SAMPLE_TEXTURECUBE_LOD(_ReflectionMap, sampler_ReflectionMap,
                                                                 reflectionDirection, mipLevel);
                float3 reflection = DecodeReflection(encodedReflection);

                // 反射用四次幂，且 dot 不饱和；与下方可选的五次幂染色不同。
                float edge = 1.0 - dot(normalWS, viewDirection);
                float edgeSquared = edge * edge;
                float reflectionFresnel = edgeSquared * edgeSquared;
                float grazingReflectance = saturate(packed.b * _Reflectivity + smoothness);
                float3 reflectionTint = lerp(baseColor, grazingReflectance.xxx, reflectionFresnel);
                // packed.r 还会作为最终反射遮罩，不等同于单独的 Reflectivity 参数。
                return packed.r * reflectionTint * reflection;
            }

            float3 ApplyFresnelColor(float3 color, float3 normalWS, float3 viewDirection)
            {
                float edge = 1.0 - saturate(dot(normalWS, viewDirection));
                float edgeSquared = edge * edge;
                float edgeFifth = edgeSquared * edgeSquared * edge;
                float blend = (_Fresnel_Bisa + _Fresnel_Scale * edgeFifth) * _Fresnel_Intensity;
                // 此处是向目标颜色插值，不像 SceneLit 那样直接添加 Fresnel 颜色。
                // 原式不限制 blend，允许大于1时外插。
                return lerp(color, _Fresnel_Color.rgb, blend);
            }

            float4 CharacterFragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                // 与 SceneLit 不同，这两个 FS 都在像素阶段重新归一化法线。
                float3 normalWS = normalize(input.normalWS);
                float3 viewDirection = normalize(_WorldSpaceCameraPos - input.positionWS);
                Light mainLight = GetMainLight();

                // 原 2D texture() 没有 bias，抵消 URP14 采样宏自动附加的 GlobalMipBias。
                float4 packed = SAMPLE_TEXTURE2D_BIAS(_SepcularGloss, sampler_SepcularGloss,
                    input.uv * _SepcularGloss_ST.xy + _SepcularGloss_ST.zw, -_GlobalMipBias.x);
                float4 mainSample = SAMPLE_TEXTURE2D_BIAS(_MainTex, sampler_MainTex,
                    input.uv * _MainTex_ST.xy + _MainTex_ST.zw, -_GlobalMipBias.x);
                float detail = SAMPLE_TEXTURE2D_BIAS(_DetailTex, sampler_DetailTex,
                    input.uv * _DetailTex_ST.xy + _DetailTex_ST.zw, -_GlobalMipBias.x).r;
                float4 tintedSample = mainSample * (_LightColor2 * _BaseColor * _LightIntensity2);
                float3 specular = EvaluateSpecular(packed, detail, normalWS, viewDirection, mainLight.direction);

                // 原 unity_LightData.z 是主灯是否影响此物体的标记，不是阴影贴图采样。
                // 原 VS 生成了 shadowCoord，但 FS 未读取，因此不额外添加实时阴影。
                float3 lightMask = lerp(_ShadowColor.rgb, float3(1,1,1), mainLight.distanceAttenuation);
                float3 color = (tintedSample.rgb + specular) * lightMask;
                #if !defined(_ALPHATEST_ON)
                    // 普通变体的反射加在 lightMask 之后，不受这个遮罩再次调制。
                    color += EvaluateReflection(packed, tintedSample.rgb, normalWS, viewDirection);
                #endif
                if (_Fresnel_ON > 0.5) color = ApplyFresnelColor(color, normalWS, viewDirection);

                float opacity = tintedSample.a;
                #if defined(_ALPHATEST_ON)
                    // 只有头发变体使用高度 Alpha 门控；裁切比较的是最终 Alpha。
                    // 因此它不同于 SceneLit 的“先对原纹理 A 裁切”。
                    opacity *= lerp(1.0, step(_FadeY, input.positionWS.y), _AlphFadeY_ON);
                    clip(opacity - _CutValue);
                #endif
                return float4(color, opacity);
            }
            // 原 VS 的 SH、阴影坐标未被 FS 读取；_Dump_ST、_CustomLightDir、
            // _AmbientSky/Equator/Ground 未使用，均不伪造相应功能。
            // 两个程序都没有法线贴图、漫反射 NdotL、额外灯、自发光或 GPU 蒙皮。
            ENDHLSL
        }
    }
    FallBack Off
}
