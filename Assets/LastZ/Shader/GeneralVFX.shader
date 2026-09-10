Shader "LastZ/GeneralVFX"
{
    Properties
    {
        [Header(Feature Keywords)]
        // 原始五套程序中的功能拆成可独立组合的开关；全部关闭时为基础路径。
        [Toggle(_GENERALVFX_MAIN_ROTATED)] _MainRotated("启用主纹理旋转", Float) = 0.00
        [Toggle(_GENERALVFX_DUAL_MASK_FRESNEL)] _DualMaskFresnel("启用双层遮罩与菲涅尔", Float) = 0.00
        [Toggle(_GENERALVFX_NOISE)] _Noise("启用噪声扰动", Float) = 0.00
        [Toggle(_GENERALVFX_DISSOLVE)] _Dissolve("启用溶解", Float) = 0.00

        [Space(8)]
        [Header(Main and Second Layers)]
        _MainTex("主纹理", 2D) = "white" {}
        _MainColor("主颜色（线性 RGBA）", Vector) = (1.40, 1.01, 0.93, 1.00)
        _MainColorIntensity("主颜色强度", Float) = 0.91
        _MainTex02("第二层纹理", 2D) = "white" {}
        _Main02Color("第二层颜色（线性 RGBA）", Vector) = (1.00, 1.00, 1.00, 0.13)
        _Main02ColorIntensity("第二层颜色强度", Float) = 0.52
        [Toggle] _MNBlendMode("使用图层相加混合（关闭=相乘）", Float) = 0.00
        [Toggle] _BlackOff("使用纹理 R 通道控制透明度", Float) = 0.00
        [Range(0, 1)] _Desaturate("去饱和度（0=原色，1=灰度）", Float) = 1.00

        [Space(8)]
        [Header(UV Mapping)]
        [Toggle] _UVChannel("使用限制后的 UV1（关闭=UV0）", Float) = 0.00
        _mainUVMove("主纹理 UV 滚动 XY 与中心缩放 Z", Vector) = (0.05, 0.10, 1.00, 0.00)
        _MainAngle("主纹理旋转角度（绕原点）", Float) = 90.00
        _main02UVMove("第二层 UV 滚动 XY 与中心缩放 Z", Vector) = (0.00, 0.00, 1.00, 1.00)
        _Main02Angle("第二层旋转角度（绕原点）", Float) = 90.00
        [Toggle] _particleUV("使用自定义 TEXCOORD2 XY 偏移", Float) = 0.00
        [Toggle] _ScreenSpaceUV_ON("使用屏幕 UV（关闭=网格 UV）", Float) = 0.00
        [Toggle] _MWarpMode("限制主纹理 UV 到 0~1", Float) = 0.00
        [Toggle] _M02WarpMode("限制第二层 UV 到 0~1", Float) = 0.00

        [Space(8)]
        [Header(Mask and Fresnel)]
        _MaskTex("遮罩纹理（R 与 A 通道）", 2D) = "white" {}
        _maskUVMove("遮罩 UV 滚动 XY 与中心缩放 Z", Vector) = (0.00, 0.00, 1.00, 1.00)
        [Toggle] _MaskTexUV("使用自定义 TEXCOORD3 XY 偏移", Float) = 0.00
        [Toggle] _MKWarpMode("限制遮罩 UV 到 0~1", Float) = 0.00
        _MaskType("遮罩类型（0/3 使用 R 与 A 的最小值）", Float) = 0.00
        _FresnelColor("菲涅尔颜色（线性 RGBA）", Vector) = (1.00, 0.97, 0.95, 1.00)
        _FresnelColorIntensity("菲涅尔颜色强度", Float) = 1.45
        _FresnelPower("菲涅尔指数", Float) = 0.42
        [Toggle] _FalseFresnel("使用替代世界视线方向", Float) = 0.00
        _FalseViewDir("替代世界视线方向 XYZ", Vector) = (0.00, -1.00, 0.00, 0.00)
        [Toggle] _BlendMode("使用菲涅尔相加混合（关闭=相乘）", Float) = 0.00
        [Toggle] _InvertMode("启用反转边缘光与边缘光 Alpha 混合", Float) = 1.00

        [Space(8)]
        [Header(Noise Distortion)]
        _NoiseTex("扰动噪声（G 通道）", 2D) = "gray" {}
        _noiseUVMove("噪声 UV 滚动 XY 与中心缩放 Z", Vector) = (0.00, 0.00, 1.00, 1.00)
        [Toggle] _NWarpMode("限制噪声 UV 到 0~1", Float) = 0.00
        _DistortIntensity("固定 UV 扰动强度", Float) = 0.00
        [Toggle] _DistortMod("使用自定义 TEXCOORD2 W 扰动强度", Float) = 0.00

        [Space(8)]
        [Header(Dissolve)]
        _DissolveTex("溶解遮罩（R 通道）", 2D) = "white" {}
        _dissolveUVMove("溶解 UV 滚动 XY 与中心缩放 Z", Vector) = (0.00, 0.00, 1.00, 1.00)
        _depc("溶解阈值 X、柔和度 Y、边缘宽度 W", Vector) = (0.50, 0.50, 1.00, 0.00)
        [Toggle] _dissolveMode("使用自定义 TEXCOORD2 Z 溶解阈值", Float) = 1.00
        [Toggle] _DissolveDirToggle("启用方向性溶解", Float) = 0.00
        [Toggle] _DissolveDir("使用 Y 方向溶解（关闭=X 方向）", Float) = 0.00
        [Toggle] _InvertDissolveDir("反转溶解方向", Float) = 0.00
        _EdgeColor("溶解边缘颜色（线性 RGB）", Vector) = (1.00, 1.00, 1.00, 1.00)
        _EdgeColorIntensity("边缘颜色强度", Float) = 1.00

        [Space(8)]
        [Header(Height Fade)]
        _HeightFadeParam("高度淡出起始 X 与结束 Y", Vector) = (0.00, 0.00, 0.00, 0.00)
        [Range(0, 1)] _HeightFade("高度淡出强度", Float) = 0.00

        [Space(8)]
        [Header(Captured Draw State)]
        [Enum(UnityEngine.Rendering.CullMode)] _Cull("剔除模式", Float) = 2.00
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("深度测试", Float) = 4.00
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("RGB 源混合因子", Float) = 5.00
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("RGB 目标混合因子", Float) = 1.00
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendAlpha("Alpha 源混合因子", Float) = 5.00
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendAlpha("Alpha 目标混合因子", Float) = 1.00
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
        Pass
        {
            Name "GeneralVFXForward"
            Tags { "LightMode"="UniversalForward" }
            Cull [_Cull]
            ZTest [_ZTest]
            ZWrite Off
            Blend [_SrcBlend] [_DstBlend], [_SrcBlendAlpha] [_DstBlendAlpha]

            HLSLPROGRAM
            #pragma target 3.5
            #pragma vertex EffectVertex
            #pragma fragment EffectFragment
            #pragma shader_feature_local _GENERALVFX_MAIN_ROTATED
            #pragma shader_feature_local _GENERALVFX_DUAL_MASK_FRESNEL
            #pragma shader_feature_local _GENERALVFX_NOISE
            #pragma shader_feature_local _GENERALVFX_DISSOLVE
            #pragma multi_compile_instancing
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_MainTex02);
            SAMPLER(sampler_MainTex02);
            TEXTURE2D(_MaskTex);
            SAMPLER(sampler_MaskTex);
            TEXTURE2D(_NoiseTex);
            SAMPLER(sampler_NoiseTex);
            TEXTURE2D(_DissolveTex);
            SAMPLER(sampler_DissolveTex);

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
            CBUFFER_END

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 vertexColor : COLOR;
                float4 baseUV : TEXCOORD0;
                float4 auxiliaryUV : TEXCOORD1;
                float4 particleData : TEXCOORD2;
                float4 maskData : TEXCOORD3;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float4 mainUV : TEXCOORD0; // XY=main, ZW=second layer.
                float4 noiseAndMaskUV : TEXCOORD1; // XY=noise, ZW=mask.
                float4 dissolveUV : TEXCOORD2; // XY=dissolve, ZW=direction.
                float4 vertexColor : TEXCOORD3;
                float3 normalWS : TEXCOORD4;
                float3 positionWS : TEXCOORD5;
                float4 particleData : TEXCOORD6;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            float2 RotateUVAboutOrigin(float2 uv, float degrees)
            {
                float s;
                float c;
                sincos(radians(degrees), s, c);
                return float2(uv.x * c - uv.y * s, uv.x * s + uv.y * c);
            }

            float2 TransformAnimatedUV(float2 uv, float4 st, float4 move, float time)
            {
                return (uv * st.xy + st.zw - 0.5) * move.z + 0.5 + frac(time * move.xy);
            }

            float2 ResolveWarpedUV(float2 uv, float clampWeight)
            {
                return lerp(uv, saturate(uv), clampWeight);
            }

            Varyings EffectVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                float time = _Time.y;
                float3 positionWS = TransformObjectToWorld(input.positionOS);
                float4 clipPosition = TransformWorldToHClip(positionWS);
                output.positionCS = clipPosition;

                #if UNITY_REVERSED_Z
                    output.positionCS.z += 0.5 * _FlyOffset;
                #elif defined(SHADER_API_GLCORE) || defined(SHADER_API_GLES3)
                    output.positionCS.z -= _FlyOffset;
                #else
                    output.positionCS.z -= 0.5 * _FlyOffset;
                #endif

                float4 screenPosition = ComputeScreenPos(clipPosition);
                float2 sourceUV = lerp(input.baseUV.xy, saturate(input.auxiliaryUV.xy), _UVChannel);

                #if defined(_GENERALVFX_MAIN_ROTATED)
                sourceUV = RotateUVAboutOrigin(sourceUV, _MainAngle);
                #endif

                float2 meshUV = TransformAnimatedUV(sourceUV, _MainTex_ST, _mainUVMove, time) + _particleUV * input.particleData.xy;
                float2 screenUV = TransformAnimatedUV(screenPosition.xy / screenPosition.w, _MainTex_ST, _mainUVMove, time)
                                + _particleUV * input.particleData.xy;
                output.mainUV.xy = lerp(meshUV, screenUV, _ScreenSpaceUV_ON);
                output.vertexColor = input.vertexColor;
                output.particleData = input.particleData;
                #if defined(_GENERALVFX_DUAL_MASK_FRESNEL)
                {
                    output.mainUV.zw = TransformAnimatedUV(
                        RotateUVAboutOrigin(input.baseUV.xy, _Main02Angle),
                        _MainTex02_ST,
                        _main02UVMove,
                        time);
                    output.noiseAndMaskUV.zw = TransformAnimatedUV(
                        input.baseUV.xy,
                        _MaskTex_ST,
                        _maskUVMove,
                        time) + _MaskTexUV * input.maskData.xy;
                    output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                    output.positionWS = positionWS;
                }
                #endif

                #if defined(_GENERALVFX_NOISE)
                output.noiseAndMaskUV.xy = TransformAnimatedUV(input.baseUV.xy, _NoiseTex_ST, _noiseUVMove, time);
                #endif

                #if defined(_GENERALVFX_DISSOLVE)
                {
                    output.dissolveUV.xy = TransformAnimatedUV(input.baseUV.xy, _DissolveTex_ST, _dissolveUVMove, time);
                    output.dissolveUV.zw = saturate(input.auxiliaryUV.xy);
                }
                #endif

                return output;
            }

            float4 BlendMainLayers(float4 mainSample, float4 secondSample)
            {
                float4 mainColor = mainSample * _MainColor * _MainColorIntensity;
                float4 secondColor = secondSample * _Main02Color * _Main02ColorIntensity;
                float4 multiply = mainSample * secondSample * _MainColor * _MainColorIntensity;
                return lerp(multiply, mainColor + secondColor, _MNBlendMode);
            }

            float EvaluateHeightFade(float y)
            {
                float heightRange = _HeightFadeParam.y - _HeightFadeParam.x;
                float heightRangeRcp = rcp(heightRange);
                float t = Remap01(y, heightRangeRcp, _HeightFadeParam.x * heightRangeRcp);
                return lerp(1.0, t, _HeightFade);
            }

            float4 FinishPremultiplied(float4 color, float opacity, Varyings input)
            {
                float alpha = saturate(opacity) * EvaluateHeightFade(input.positionWS.y) * input.vertexColor.a;
                float luminance = Luminance(color.rgb);
                float3 rgb = lerp(color.rgb, luminance, _Desaturate) * input.vertexColor.rgb;
                return float4(rgb * alpha, alpha);
            }

            float2 ApplyNoiseDistortion(Varyings input, float2 uv)
            {
                #if defined(_GENERALVFX_NOISE)
                float noise = SAMPLE_TEXTURE2D(_NoiseTex,sampler_NoiseTex,ResolveWarpedUV(input.noiseAndMaskUV.xy, _NWarpMode)).g - 0.5;
                float intensity = lerp(_DistortIntensity, input.particleData.w, _DistortMod);
                uv += noise * intensity;
                #endif
                return uv;
            }

            void EvaluateMaskedDual(Varyings input, out float4 color, out float opacity)
            {
                float4 mask = SAMPLE_TEXTURE2D(_MaskTex,sampler_MaskTex,ResolveWarpedUV(input.noiseAndMaskUV.zw, _MKWarpMode));
                float maskAlpha = (_MaskType == 0 || _MaskType == 3) ? min(mask.r, mask.a) : 1.0;

                float3 viewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
                viewDirection = lerp(viewDirection, normalize(_FalseViewDir.xyz), _FalseFresnel);
                float edge = saturate(1.0 - dot(input.normalWS, viewDirection));
                float rim = pow(edge, _FresnelPower);
                rim = lerp(rim, 1.0 - rim, _InvertMode);
                float4 fresnel = rim * _FresnelColor * _FresnelColorIntensity;

                float2 mainUV = ApplyNoiseDistortion(input, input.mainUV.xy);
                float4 mainSample = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,ResolveWarpedUV(mainUV, _MWarpMode));
                float4 secondSample = SAMPLE_TEXTURE2D(_MainTex02,sampler_MainTex02,ResolveWarpedUV(input.mainUV.zw, _M02WarpMode));
                float4 layers = BlendMainLayers(mainSample, secondSample);
                float4 multiplied = fresnel * layers;
                float4 added = fresnel + layers;
                float4 normalBlend = lerp(multiplied, added, _BlendMode);
                float4 invertedBlend = lerp(multiplied, added * fresnel.a, _BlendMode);
                color = lerp(normalBlend, invertedBlend, _InvertMode);
                float redMask = lerp(mainSample.r * secondSample.r, saturate(mainSample.r + secondSample.r), _MNBlendMode);
                opacity = lerp(color.a, color.a * redMask, _BlackOff) * maskAlpha;
            }

            float2 DissolveCoverage(Varyings input)
            {
                float noise = SAMPLE_TEXTURE2D(_DissolveTex,sampler_DissolveTex,input.dissolveUV.xy).r;
                float2 direction = lerp(input.dissolveUV.zw, 1.0 - input.dissolveUV.zw, _InvertDissolveDir);
                float directionValue = lerp(direction.x, direction.y, _DissolveDir);
                float shape = lerp(noise + 1.0, noise * directionValue + 1.0, _DissolveDirToggle);
                float threshold = lerp(_depc.x, input.particleData.z, _dissolveMode);
                float2 wideAndTight = saturate(shape - 2.0 * float2(threshold - _depc.w, threshold));
                float remapStart = (1.0 - _depc.y) * 0.5;
                float softnessRcp = rcp(_depc.y);
                return Remap01(
                    wideAndTight,
                    softnessRcp.xx,
                    (remapStart * softnessRcp).xx);
            }

            float4 EffectFragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float4 color;
                float opacity;

                #if defined(_GENERALVFX_DUAL_MASK_FRESNEL)
                EvaluateMaskedDual(input, color, opacity);
                #else
                float2 uv = ApplyNoiseDistortion(input, input.mainUV.xy);
                float4 mainSample = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,ResolveWarpedUV(uv, _MWarpMode));
                color = BlendMainLayers(mainSample, (1.0 - _MNBlendMode));
                opacity = lerp(color.a, color.a * mainSample.r, _BlackOff);
                #endif

                #if defined(_GENERALVFX_DISSOLVE)
                {
                    float2 coverage = DissolveCoverage(input);
                    opacity *= coverage.x;
                    color.rgb = lerp(_EdgeColor.rgb * _EdgeColorIntensity, color.rgb, coverage.y);
                }
                #endif

                return FinishPremultiplied(color, opacity, input);
            }
            ENDHLSL
        }
    }
    FallBack Off
}


