// Frame4414: EID3356 (depth shadow) and EID3369 (cloud layer).
// 原 GLSL：VS29910/FS29911、VS29913/FS29914。
// 两次绘制共用战争迷雾遮罩，却使用不同的顶点深度和颜色公式。
// 阅读顺序：FogVertex -> ReadFogCoverage -> EvaluateDepthShadow / EvaluateCloudLayer。
Shader "LastZ/FogOfWar"
{
    Properties
    {
        [Header(Fog Layer)]
        [Enum(CloudLayer,0,DepthShadow,1)] _UseDepth("Layer - EID3369 cloud or EID3356 shadow", Float) = 0
        [NoScaleOffset] _FogMask("Region levels - RGBA", 2D) = "white" {}
        [NoScaleOffset] _FogOfWar("Explored world area - R", 2D) = "white" {}
        _Level2("Blend inverted R to G", Range(0,1)) = 1
        _Level3("Blend previous result to inverted B", Range(0,1)) = 1
        _Level4("Blend previous result to inverted A", Range(0,1)) = 0
        _OffsetX("World X offset before map scale", Float) = 7.5
        _OffsetY("World Z offset before map scale", Float) = 0
        _UvScale("Final world map UV scale", Float) = 0.97
        _AlphaDisMin("Coverage remap minimum", Float) = 0.25
        _AlphaDisMax("Coverage remap maximum", Float) = 0.8

        [Header(Cloud Layer)]
        _MainTex("Cloud RGB", 2D) = "white" {}
        _BlendNoise("Top color blend - R", 2D) = "black" {}
        _FogSpeed("Cloud UV speed XY at t over 20 - noise ZW at t", Vector) = (0.01,0,0,0.02)
        // Vector 保存原 CB 的线性颜色；不用 Color，避免再次进行 sRGB 转换。
        _Color("Day fog - linear RGBA", Vector) = (0.15131709,0.16770419,0.22287723,1)
        _NightColor("Night fog - linear RGB", Vector) = (0.03493075,0.055096,0.09065469,1)
        _EdgeColor("Day boundary - linear RGB", Vector) = (0.05032558,0.06940866,0.09992069,1)
        _NightEdgeColor("Night boundary - linear RGB", Vector) = (0.11298516,0.15522255,0.21404114,1)
        _TopColor("Day cloud top - linear RGB", Vector) = (0.17624077,0.20499742,0.26032731,1)
        _NightTopColor("Night cloud top - linear RGB", Vector) = (0.03954583,0.06217053,0.08908622,1)

        [Header(Depth Shadow)]
        _FogShadowOffset("Subtract from original object position - XYZ", Vector) = (0,-0.1,0.01,0)
        _VertexOffset("Depth comparison bias in eye units - X only", Vector) = (24,0,-0.5,0)
        _FogFallOff("Depth fade distance in eye units", Float) = 25
        _FogPowerShadow("Depth fade exponent", Float) = 3
        _FogShadowColor("Day shadow - linear RGBA", Vector) = (0.02207366,0.02207366,0.02207366,0.90196079)
        _FogNightShadowColor("Night shadow - linear RGBA", Vector) = (0.01456365,0.02522493,0.0490081,1)

        [Header(Animation)]
        [Toggle] _UseCapturedTime("Freeze animation at captured time", Float) = 1
        _CapturedTime("Captured seconds - original Time.y", Float) = 126.320823669434

        [Header(Render State)]
        [Enum(UnityEngine.Rendering.CullMode)] _Cull("Face culling", Float) = 2
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("Depth comparison", Float) = 4
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

            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
            TEXTURE2D(_FogMask); SAMPLER(sampler_FogMask);
            TEXTURE2D(_FogOfWar); SAMPLER(sampler_FogOfWar);
            TEXTURE2D(_BlendNoise); SAMPLER(sampler_BlendNoise);
            // FogDepthSnapshotFeature 在 EID1523 之后、透明绘制之前写入。
            // 这里采样实时深度快照，不绑定导出的 8-bit 深度 TGA。
            TEXTURE2D_X_FLOAT(_FogSceneDepthTexture);
            SAMPLER(sampler_FogSceneDepthTexture);

            // 原 GLSL $Globals，由 LastZGlobalShaderParameters 统一设置。
            float4 _Params;
            float _Timeline;

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST, _BlendNoise_ST, _FogSpeed;
                float4 _Color, _NightColor, _EdgeColor, _NightEdgeColor;
                float4 _TopColor, _NightTopColor;
                float4 _FogShadowOffset, _VertexOffset;
                float4 _FogShadowColor, _FogNightShadowColor;
                float _UseDepth, _Level2, _Level3, _Level4;
                float _OffsetX, _OffsetY, _UvScale, _AlphaDisMin, _AlphaDisMax;
                float _FogFallOff, _FogPowerShadow;
                float _UseCapturedTime, _CapturedTime;
            CBUFFER_END

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

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
                // 原 GLSL 的这四张雾贴图都用 texture(tex,uv)，没有全局 mip bias。
                // URP 的 SAMPLE_TEXTURE2D 会自动增加 _GlobalMipBias，故在这里抵消。
                float4 hiddenLevels = 1.0 - SAMPLE_TEXTURE2D_BIAS(
                    _FogMask, sampler_FogMask, meshUV, -_GlobalMipBias.x);

                // 三次连续 lerp：不是 RGBA 求和，也不是加权 dot。
                float hiddenRegion = lerp(hiddenLevels.r, hiddenLevels.g, _Level2);
                hiddenRegion = lerp(hiddenRegion, hiddenLevels.b, _Level3);
                hiddenRegion = lerp(hiddenRegion, hiddenLevels.a, _Level4);

                float2 worldMapUV = positionWS.xz + float2(_OffsetX, _OffsetY);
                worldMapUV = worldMapUV * _Params.z + _Params.xy;
                worldMapUV *= _UvScale;
                float exploredArea = SAMPLE_TEXTURE2D_BIAS(
                    _FogOfWar, sampler_FogOfWar, worldMapUV, -_GlobalMipBias.x).r;
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

                float seconds = _UseCapturedTime > 0.5 ? _CapturedTime : _Time.y;
                // 保留 _Time.x 与 _Time.y 的 20 倍速度差，不能统一使用 t。
                float slowSeconds = _UseCapturedTime > 0.5 ? seconds * 0.05 : _Time.x;
                float2 cloudUV = input.cloudUV + slowSeconds * _FogSpeed.xy;
                float3 cloudTexture = SAMPLE_TEXTURE2D_BIAS(
                    _MainTex, sampler_MainTex, cloudUV, -_GlobalMipBias.x).rgb;
                float3 texturedCloud = edgeToInterior * cloudTexture;

                float3 cloudTop = lerp(_NightTopColor.rgb, _TopColor.rgb, _Timeline);
                float2 blendUV = input.meshUV * _BlendNoise_ST.xy + _BlendNoise_ST.zw;
                blendUV += seconds * _FogSpeed.zw;
                float topAmount = SAMPLE_TEXTURE2D_BIAS(
                    _BlendNoise, sampler_BlendNoise, blendUV, -_GlobalMipBias.x).r;

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
