// Frame4414：SceneLit，Program17041 / 7527（后者只多一次 Alpha Clip）。
// VS：17039 / 7525，源码相同。FS：17040 / 7526。
// 完整 EID 与参数见 Reconstruction/Validation/SceneLit/source_materials.json。
// 阅读顺序：SceneLitVertex -> GetAnimatedUV -> EvaluateSceneLighting -> SceneLitFragment。
// 使用 URP 的对象/相机变换、主光方向、SH；游戏自定义昼夜参数单独保留。
Shader "LastZ/SceneLit"
{
    Properties
    {
        [Header(Base Surface)]
        [MainTexture] _MainTex("Main texture - sRGB RGB and linear alpha", 2D) = "white" {}
        // Vector 直接存放捕获的线性 RGBA，避免 Color 属性重复进行 gamma 转换。
        _Color("Tint - linear RGBA", Vector) = (1,1,1,1)
        _Intensity("Tint intensity - affects RGB and alpha", Float) = 1
        _NoMainTextureOn("Replace texture RGB with white", Range(0,1)) = 0
        _VertexOffsetY("Local Y offset before object transform", Float) = 0
        [Toggle(_ALPHATEST_ON)] _AlphaClip("Enable raw texture alpha clipping", Float) = 0
        _CutOff("Raw texture alpha cutoff", Range(0,1)) = 0.5
        _AlphaIsR("Opacity source - 0 alpha 1 tinted red", Range(0,1)) = 0
        _AlphFadeY_ON("World height alpha gate strength", Range(0,1)) = 0
        _FadeY("Visible at or above world Y", Float) = 0

        [Header(Scene Lighting)]
        // 原游戏全局量在这里作为材质参数呈现，便于查看/调整捕获值。
        // 这两组颜色不是 URP _MainLightColor，不能用主灯的 1.3 强度替换。
        _LightColor1("Environment color - linear RGB", Vector) = (0.999986529,0.999987841,0.999995470,1)
        _LightIntensity1("Environment color intensity", Float) = 1.003173828
        _LightColor2("Hero color - linear RGB", Vector) = (0.999990225,0.999992967,1,1)
        _LightIntensity2("Hero color intensity", Float) = 1.000047922
        _HeroDayNight_ON("Environment to hero lighting blend", Range(0,1)) = 0
        _BlinnPhongOn("Lambert plus SH - original BlinnPhongOn", Range(0,1)) = 0

        [Header(Fresnel)]
        [Toggle] _Fresnel_ON("Enable two Fresnel color terms", Float) = 0
        _Fresnel_Color("Fifth power Fresnel - linear RGB", Vector) = (1,1,1,1)
        _Fresnel_Color_Edge("Cubic edge Fresnel - linear RGB", Vector) = (0,0,0,0)
        _Fresnel_Bisa("Fifth power Fresnel bias", Float) = 0
        _Fresnel_Scale("Fifth power Fresnel scale", Float) = 0
        _Fresnel_Scale_Edge("Cubic edge Fresnel scale", Float) = 0
        _Fresnel_Intensity("Both Fresnel terms intensity", Float) = 0

        [Header(Emission)]
        [Toggle] _EMISSIONMAPON_ON("Enable emission texture", Float) = 0
        [NoScaleOffset] _EmissionMap("Emission RGB - animated UV before main ST", 2D) = "black" {}
        _EmissionColor("Emission tint - linear HDR RGB", Vector) = (1,1,1,1)
        _EmissionIntensity("Emission intensity", Float) = 1
        _EMISSIONMAPON_BUILDING_ON("Building daylight attenuation", Range(0,1)) = 0
        _Timeline("Daylight amount - 1 suppresses building emission", Range(0,1)) = 1

        [Header(Texture Sheet Animation)]
        [Toggle] _SheetAnimationON("Enable texture sheet animation", Float) = 0
        _MainTexSheet("Sheet columns X rows Y - ZW unused", Vector) = (1,1,1,1)
        _MainTexSheetAnimSpeed("Sheet playback - frames per second", Float) = 1

        [Header(Render State)]
        [Enum(UnityEngine.Rendering.CullMode)] _Cull("Face culling", Float) = 2
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("Source RGB blend", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("Destination RGB blend", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendAlpha("Source alpha blend", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendAlpha("Destination alpha blend", Float) = 0
        [Toggle] _ZWrite("Write depth", Float) = 1
    }

    SubShader
    {
        // 此次还原按 EID 给材质分配队列，使 SceneLit 与 SceneSimple 按捕获次序交错提交。
        // Queue 控制次序；Blend/ZWrite/Cull 仍由每个 draw 的原状态决定。
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Transparent" }
        Pass
        {
            Name "SceneLitForward"
            Tags { "LightMode"="UniversalForwardOnly" }
            Cull [_Cull]
            ZTest LEqual
            ZWrite [_ZWrite]
            Blend [_SrcBlend] [_DstBlend], [_SrcBlendAlpha] [_DstBlendAlpha]
            BlendOp Add, Add
            ColorMask RGBA

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

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST, _Color, _MainTexSheet;
                float4 _LightColor1, _LightColor2;
                float4 _Fresnel_Color, _Fresnel_Color_Edge, _EmissionColor;
                float _Intensity, _NoMainTextureOn, _VertexOffsetY, _CutOff;
                float _AlphaClip, _AlphaIsR, _AlphFadeY_ON, _FadeY;
                float _LightIntensity1, _LightIntensity2, _HeroDayNight_ON, _BlinnPhongOn;
                float _Fresnel_ON, _Fresnel_Bisa, _Fresnel_Scale, _Fresnel_Scale_Edge, _Fresnel_Intensity;
                float _EMISSIONMAPON_ON, _EmissionIntensity, _EMISSIONMAPON_BUILDING_ON, _Timeline;
                float _SheetAnimationON, _MainTexSheetAnimSpeed;
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
                float2 uv : TEXCOORD0;          // 原 vs_TEXCOORD0
                float3 normalWS : TEXCOORD1;    // 原 vs_TEXCOORD1
                float3 positionWS : TEXCOORD2;  // 原 vs_TEXCOORD2.xyz
                float3 ambientSH : TEXCOORD3;   // 原 vs_TEXCOORD3
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
                // 原式在网格为零时未定义。只为这种无效输入增加保护。
                if (grid.x <= 0 || grid.y <= 0 || frameCount < 1) return meshUV;
                float timeInFrames = _Time.y * _MainTexSheetAnimSpeed;
                // GLSL 的符号判断 + fract 重构了 HLSL fmod（负数保留被除数符号）。
                // 不先 floor 时间：原式是先取余，再对列/行向零截断。
                float wrappedFrame = fmod(timeInFrames, frameCount);
                float column = trunc(fmod(wrappedFrame, grid.x));
                float rowFromTop = trunc(wrappedFrame / grid.x);
                float row = trunc(grid.y - rowFromTop - 1.0);
                // 第一帧位于左上角；UV 的纵轴仍按纹理坐标向上。
                return (meshUV + float2(column, row)) / grid;
            }

            float3 EvaluateSceneLighting(float3 albedo, Varyings input)
            {
                float3 environmentLight = _LightColor1.rgb * _LightIntensity1;
                float3 heroLight = _LightColor2.rgb * _LightIntensity2;
                float3 sceneLightColor = lerp(environmentLight, heroLight, _HeroDayNight_ON);
                float3 directColor = albedo * sceneLightColor;
                // 名称虽是 BlinnPhongOn，原 FS 没有半角向量或高光项。
                // 原法线只在 VS 归一化；这里保持插值结果，不额外 normalize。
                Light mainLight = GetMainLight();
                if (_BlinnPhongOn > 0.5)
                    directColor *= saturate(dot(mainLight.direction, input.normalWS));
                // 注意：SH 始终按这个浮点值相乘；不是只在 >0.5 时添加。
                return directColor + albedo * input.ambientSH * _BlinnPhongOn;
            }

            float3 EvaluateFresnel(Varyings input)
            {
                float3 viewDirection = normalize(_WorldSpaceCameraPos - input.positionWS);
                float edge = 1.0 - saturate(dot(input.normalWS, viewDirection));
                float edgeSquared = edge * edge;
                float edgeCubed = edgeSquared * edge;
                float edgeFifth = edgeCubed * edgeSquared;
                float broadRim = (_Fresnel_Bisa + _Fresnel_Scale * edgeFifth) * _Fresnel_Intensity;
                float edgeRim = edgeCubed * _Fresnel_Scale_Edge * _Fresnel_Intensity;
                return _Fresnel_Color.rgb * broadRim + _Fresnel_Color_Edge.rgb * edgeRim;
            }

            float3 EvaluateEmission(float2 animatedUV)
            {
                // 自发光使用动画后的 UV，但不使用 _MainTex_ST。
                float3 emissionSample = SAMPLE_TEXTURE2D_BIAS(_EmissionMap, sampler_EmissionMap,
                    animatedUV, -_GlobalMipBias.x).rgb;
                float3 tintedEmission = emissionSample * _EmissionColor.rgb;
                float3 normalEmission = tintedEmission * _EmissionIntensity;
                float buildingIntensity = _EmissionIntensity * (1.0 - _Timeline);
                float3 buildingEmission = tintedEmission * buildingIntensity;
                return lerp(normalEmission, buildingEmission, _EMISSIONMAPON_BUILDING_ON);
            }

            float ResolveOpacity(float rawTextureAlpha, float3 albedo, float worldY)
            {
                // 原式中常规 Alpha 有两次 _Color.a：这与 SceneSimple 不同。
                float opacityFromAlpha = rawTextureAlpha * _Color.a * _Intensity * _Color.a;
                // R 来自已执行 NoMainTexture、Tint 和 Intensity 的 albedo，尚未加光照。
                float opacityFromRed = albedo.r * _Color.a;
                float opacity = lerp(opacityFromAlpha, opacityFromRed, _AlphaIsR);
                // 名为 Fade，实际上是世界 Y 的硬阈值；等于阈值时保留。
                float heightVisibility = step(_FadeY, worldY);
                return lerp(opacity, opacity * heightVisibility, _AlphFadeY_ON);
            }

            float4 SceneLitFragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                float2 animatedUV = GetAnimatedUV(input.uv);
                float2 mainUV = animatedUV * _MainTex_ST.xy + _MainTex_ST.zw;
                // 原 texture() 无全局 bias，抵消 URP14 宏自动叠加的 _GlobalMipBias。
                float4 mainSample = SAMPLE_TEXTURE2D_BIAS(_MainTex, sampler_MainTex, mainUV, -_GlobalMipBias.x);
                #if defined(_ALPHATEST_ON)
                    // 7527 变体只在这里多一次裁切：比较原纹理 A，不比较最终透明度。
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
            // 未使用的原 CB 项：_MainLightOn、_MaxAddIntensity1、_GPUSKin_TextureSize、
            // _ShadowColor。原 VS 的 TEXCOORD2.w、TEXCOORD5/6 也未被 FS 读取。
            // 不添加原 FS 没有的实时阴影、雾、高光、法线贴图或 GPU 蒙皮。
            ENDHLSL
        }
    }
    FallBack Off
}
