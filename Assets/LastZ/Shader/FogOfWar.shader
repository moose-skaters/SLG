Shader "LastZ/FogOfWar"
{
    Properties
    {
        [Header(Fog Layer)]
        [Enum(CloudLayer,0,DepthShadow,1)] _UseDepth("层类型（0=雾，1=雾阴影）", Float) = 0.00
        [NoScaleOffset] _FogMask("战争迷雾区域", 2D) = "white" {}
        [NoScaleOffset] _FogOfWar("已探索区域（R 通道）", 2D) = "white" {}

        _Level2("反相 R 到 G 的混合", Range(0,1)) = 1.00
        _Level3("上一结果到反相 B 的混合", Range(0,1)) = 1.00
        _Level4("上一结果到反相 A 的混合", Range(0,1)) = 0.00

        _OffsetX("世界 X 偏移", Float) = 7.50
        _OffsetY("世界 Z 偏移", Float) = 0.00
        _UvScale("最终世界地图 UV 缩放", Float) = 0.97
        _AlphaDisMin("覆盖率最小值", Float) = 0.25
        _AlphaDisMax("覆盖率最大值", Float) = 0.80

        [Space(8)]
        [Header(Cloud Layer)]
        _MainTex("云层纹理", 2D) = "white" {}
        _BlendNoise("混合噪声", 2D) = "black" {}
        _FogSpeed("云层 UV 速度 XY（_Time.x）与噪声 ZW（_Time.y）", Vector) = (0.01, 0.00, 0.00, 0.02)

        _Color("白天雾颜色", Vector) = (0.15, 0.17, 0.22, 1.00)
        _NightColor("夜晚雾颜色", Vector) = (0.03, 0.06, 0.09, 1.00)
        _EdgeColor("白天边界颜色", Vector) = (0.05, 0.07, 0.10, 1.00)
        _NightEdgeColor("夜晚边界颜色", Vector) = (0.11, 0.16, 0.21, 1.00)
        _TopColor("白天云顶颜色", Vector) = (0.18, 0.20, 0.26, 1.00)
        _NightTopColor("夜晚云顶颜色", Vector) = (0.04, 0.06, 0.09, 1.00)

        [Space(8)]
        [Header(Depth Shadow)]
        _FogShadowOffset("原始对象位置的 XYZ 偏移（相减）", Vector) = (0.00, -0.10, 0.01, 0.00)
        _VertexOffset("眼空间深度比较偏移（仅使用 X）", Vector) = (24.00, 0.00, -0.50, 0.00)
        _FogFallOff("眼空间深度淡出距离", Float) = 25.00
        _FogPowerShadow("深度淡出幂指数", Float) = 3.00
        _FogShadowColor("白天阴影颜色", Vector) = (0.02, 0.02, 0.02, 0.90)
        _FogNightShadowColor("夜晚阴影颜色", Vector) = (0.01, 0.03, 0.05, 1.00)

        [Space(8)]
        [Header(Render State)]
        [Enum(UnityEngine.Rendering.CullMode)] _Cull("剔除模式", Float) = 2.00
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("深度测试", Float) = 4.00
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
        Pass
        {
            Name "FogOfWarForward"
            Tags { "LightMode"="UniversalForwardOnly" }
            Cull [_Cull]
            ZTest [_ZTest]
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha OneMinusSrcAlpha
            BlendOp Add, Add
            ColorMask RGBA

            HLSLPROGRAM
            #pragma target 3.5
            #pragma vertex FogVertex
            #pragma fragment FogFragment
            #pragma multi_compile_instancing
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // Textures.
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_FogMask);
            SAMPLER(sampler_FogMask);
            TEXTURE2D(_FogOfWar);
            SAMPLER(sampler_FogOfWar);
            TEXTURE2D(_BlendNoise);
            SAMPLER(sampler_BlendNoise);

            // FogDepthSnapshotFeature 在 EID1523 之后、透明绘制之前写入。
            // 这里采样实时深度快照，不绑定导出的 8-bit 深度 TGA。
            TEXTURE2D_X_FLOAT(_FogSceneDepthTexture);
            SAMPLER(sampler_FogSceneDepthTexture);

            // 原 GLSL $Globals，由 LastZGlobalShaderParameters 统一设置。
            float4 _Params;
            float _Timeline;

            // Material properties.
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _BlendNoise_ST;
                float4 _FogSpeed;

                float4 _Color;
                float4 _NightColor;
                float4 _EdgeColor;
                float4 _NightEdgeColor;
                float4 _TopColor;
                float4 _NightTopColor;

                float4 _FogShadowOffset;
                float4 _VertexOffset;
                float4 _FogShadowColor;
                float4 _FogNightShadowColor;

                float _UseDepth;
                float _Level2;
                float _Level3;
                float _Level4;
                float _OffsetX;
                float _OffsetY;
                float _UvScale;
                float _AlphaDisMin;
                float _AlphaDisMax;
                float _FogFallOff;
                float _FogPowerShadow;
            CBUFFER_END

            // Vertex input from the fog mesh.
            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            // Interpolators shared by the vertex and fragment stages.
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float4 screenPosition : TEXCOORD1;
                float2 cloudUV : TEXCOORD2;
                float2 meshUV : TEXCOORD3;

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings FogVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                // EID3356：偏移发生在对象空间，先偏移再乘对象矩阵。
                // 抓帧对象缩放为 (180,2,180)，所以世界偏移实际是 (0,+0.2,-1.8)。
                float3 displacedPositionOS = input.positionOS;
                if (_UseDepth > 0.5)
                    displacedPositionOS -= _FogShadowOffset.xyz;

                output.positionWS = TransformObjectToWorld(displacedPositionOS);
                float4 originalClipPosition = TransformWorldToHClip(output.positionWS);
                output.positionCS = originalClipPosition;
                output.screenPosition = ComputeScreenPos(originalClipPosition);
                output.cloudUV = input.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                output.meshUV = input.uv;

                // EID3369 原 VS 写的是 GL clip.z = clip.w - 0.000001。
                // 把云层深度推到远平面附近；原 draw 的 ZTest=Always，
                // 所以它仍可叠在场景上，可见区域由战争迷雾遮罩决定。
                // 保留实际世界坐标和 clip.w，仅替换用于深度测试的 clip.z。
                if (_UseDepth < 0.5)
                {
                    #if UNITY_REVERSED_Z
                        output.positionCS.z = 0.0000005;
                    #elif defined(SHADER_API_GLCORE) || defined(SHADER_API_GLES) || defined(SHADER_API_GLES3)
                        output.positionCS.z = originalClipPosition.w - 0.000001;
                    #else
                        output.positionCS.z = originalClipPosition.w - 0.0000005;
                    #endif
                }
                return output;
            }

            float ReadFogCoverage(float2 meshUV, float3 positionWS)
            {
                float4 hiddenLevels = 1.0
                                     - SAMPLE_TEXTURE2D(_FogMask, sampler_FogMask, meshUV);

                // 三次连续 lerp：不是 RGBA 求和，也不是加权 dot。
                float hiddenRegion = lerp(hiddenLevels.r, hiddenLevels.g, _Level2);
                hiddenRegion = lerp(hiddenRegion, hiddenLevels.b, _Level3);
                hiddenRegion = lerp(hiddenRegion, hiddenLevels.a, _Level4);

                float2 worldMapUV = positionWS.xz + float2(_OffsetX, _OffsetY);
                worldMapUV = worldMapUV * _Params.z + _Params.xy;
                worldMapUV *= _UvScale;
                float exploredArea = SAMPLE_TEXTURE2D(
                    _FogOfWar,
                    sampler_FogOfWar,
                    worldMapUV
                ).r;
                return hiddenRegion * saturate(1.0 - exploredArea);
            }

            float RemapCoverage(float coverage)
            {
                // GLSL 只有线性重映射 + clamp，没有 smoothstep 或高度衰减。
                return saturate((coverage - _AlphaDisMin) / (_AlphaDisMax - _AlphaDisMin));
            }

            float4 EvaluateDepthShadow(Varyings input, float coverage)
            {
                float opacity = RemapCoverage(coverage);
                float2 screenUV = input.screenPosition.xy / input.screenPosition.w;
                float deviceDepth = SAMPLE_TEXTURE2D_X(
                    _FogSceneDepthTexture, sampler_FogSceneDepthTexture, screenUV).r;
                // 原 GLSL：1 / (ZBufferParams.z * depth + ZBufferParams.w)。
                // URP 当前相机参数正确处理 D3D reversed-Z，不硬编码 OpenGL 的系数。
                float sceneEyeDepth = LinearEyeDepth(deviceDepth, _ZBufferParams);
                float fogEyeDepth = input.screenPosition.w;
                float depthFade = saturate((sceneEyeDepth - fogEyeDepth + _VertexOffset.x) / _FogFallOff);
                depthFade = pow(depthFade, _FogPowerShadow);
                opacity = min(depthFade * opacity, 1.0);

                // 原 FS 先算 nightAmount，再将阴影透明度朝 0 混合。
                // 完全夜晚 Timeline=0 时该绘制消失，与云层的昼夜颜色变化不同。
                float nightAmount = 1.0 - _Timeline;
                opacity = lerp(opacity, 0.0, nightAmount);
                float4 shadowColor = lerp(_FogShadowColor, _FogNightShadowColor, nightAmount);
                return float4(shadowColor.rgb, shadowColor.a * opacity);
            }

            float4 EvaluateCloudLayer(Varyings input, float coverage)
            {
                // 云层多一次 saturate(coverage)，阴影层原 FS 没有这一项。
                float opacity = RemapCoverage(saturate(coverage));
                float3 fogColor = lerp(_NightColor.rgb, _Color.rgb, _Timeline);
                float3 edgeColor = lerp(_NightEdgeColor.rgb, _EdgeColor.rgb, _Timeline);
                float3 edgeToInterior = lerp(edgeColor, fogColor, opacity);

                float seconds = _Time.y;
                // 保留 _Time.x 与 _Time.y 的 20 倍速度差。
                float slowSeconds = _Time.x;
                float2 cloudUV = input.cloudUV + slowSeconds * _FogSpeed.xy;
                float3 cloudTexture = SAMPLE_TEXTURE2D(
                    _MainTex,
                    sampler_MainTex,
                    cloudUV
                ).rgb;
                float3 texturedCloud = edgeToInterior * cloudTexture;

                float3 cloudTop = lerp(_NightTopColor.rgb, _TopColor.rgb, _Timeline);
                float2 blendUV = input.meshUV * _BlendNoise_ST.xy + _BlendNoise_ST.zw;
                blendUV += seconds * _FogSpeed.zw;
                float topAmount = SAMPLE_TEXTURE2D(
                    _BlendNoise,
                    sampler_BlendNoise,
                    blendUV
                ).r;

                // 原 FS 实际先计算 (1-noise)，再反减一次作为 top 权重。
                float cloudAmount = 1.0 - topAmount;
                float3 finalColor = texturedCloud * cloudAmount + cloudTop * (1.0 - cloudAmount);
                // alpha 只使用 _Color.a；不读取主纹理 alpha 或 NightColor.a。
                return float4(finalColor, opacity * _Color.a);
            }

            float4 FogFragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                float coverage = ReadFogCoverage(input.meshUV, input.positionWS);
                if (_UseDepth > 0.5)
                    return EvaluateDepthShadow(input, coverage);
                return EvaluateCloudLayer(input, coverage);
            }
            ENDHLSL
        }
    }
    FallBack Off
}
