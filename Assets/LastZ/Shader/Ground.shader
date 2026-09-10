Shader "LastZ/Ground"
{
    Properties
    {
        [Header(Coordinates and Layer Weights)]
        [Toggle] _WorldUVON("使用世界坐标UV", Float) = 1
        _WorldEdge("世界 UV 尺寸 XY 与偏移 ZW", Vector) = (512,512,67.5,122)
        _Control("控制纹理", 2D) = "red" {}
        [Toggle] _HeightBlendOn("使用各层 Alpha 高度混合", Float) = 0
        _Weight("高度混合过渡权重", Range(0.001,1)) = 0.2

        [Space(8)]
        [Header(Four Ground Layers)]
        _Splat0("地表层 0（RGB 颜色，A 高度）", 2D) = "white" {}
        _Splat1("地表层 1（RGB 颜色，A 高度）", 2D) = "white" {}
        _Splat2("地表层 2（RGB 颜色，A 高度）", 2D) = "white" {}
        _Splat3("地表层 3（RGB 颜色，A 高度）", 2D) = "white" {}

        _Color_Splat1("地表层 0 颜色", Vector) = (0.88,0.75,0.63,0)
        _Color_Splat2("地表层 1 颜色", Vector) = (0.71,0.71,0.71,0)
        _Color_Splat3("地表层 2 颜色", Vector) = (0.50,0.49,0.34,0)
        _Color_Splat4("地表层 3 颜色", Vector) = (0.78,0.70,0.47,0)
        _Color_Splat1_Intensity("地表层 0 强度", Float) = 1
        _Color_Splat2_Intensity("地表层 1 强度", Float) = 1
        _Color_Splat3_Intensity("地表层 2 强度", Float) = 1
        _Color_Splat4_Intensity("地表层 3 强度", Float) = 1

        [Space(8)]
        [Header(Normal and Camera Height)]
        _BaseNormal("法线纹理 ", 2D) = "bump" {}
        _NormalMask("法线遮罩 R", 2D) = "white" {}
        _BaseNormalScale("法线强度", Float) = 1
        _NormalMinHeight("法线淡出起始相机高度", Float) = 100
        _NormalMaxHeight("法线淡出结束相机高度", Float) = 200
        _Splat_Golobal("远景颜色纹理（网格 UV）", 2D) = "gray" {}
        _Color_Golobal("远景颜色乘数", Vector) = (1,1,1,1)
        _MinHeight("远景混合起始相机高度", Float) = 0
        _MaxHeight("远景混合结束相机高度", Float) = -5

        [Space(8)]
        [Header(Control Edge Color)]
        [Toggle] _FakeNormalOn("启用控制纹理边缘颜色", Float) = 0
        _FakeNormalDir("控制纹理采样 UV 偏移 XY", Vector) = (0.00,0,0,0)
        [Enum(R,0,G,1,B,2,A,3)] _FakeNormalChannel("控制纹理边缘通道", Float) = 0
        _EdgeColor01("边缘颜色", Vector) = (0,0,0,0)

        [Space(8)]
        [Header(Screen Masks and Spark)]
        [Toggle(_SCREENSPECON_ON)] _ScreenSpecOn("启用屏幕闪光与高光", Float) = 1
        _SparkMap("闪光遮罩 A（网格 UV）", 2D) = "white" {}
        _SparkColor("闪光颜色", Vector) = (1,0.91,0.54,1)
        _SparkColorIntensity("闪光强度", Float) = 0.05
        [NoScaleOffset] _SpecMaskMap("屏幕遮罩（R 闪光，G 高光）", 2D) = "black" {}
        _specColor("高光颜色", Vector) = (1,0.85,0.35,1)
        _specScale("高光强度", Float) = 0.05
        [Toggle] _BlurPlaneShadowOn("启用模糊平面阴影", Float) = 0
        [NoScaleOffset] _PlaneBlurShadowMap("平面阴影图", 2D) = "white" {}
        _BlurPlaneShadowColor("阴影颜色", Vector) = (0,0,0,0.5)

        [Space(8)]
        [Header(Lighting)]
        _LightColorDesat("主光去饱和度", Range(0,1)) = 1
        _AlphaScale("输出Alpha", Range(0,1)) = 0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" "RenderPipeline"="UniversalPipeline" }
        Pass
        {
            Name "GroundForward"
            Tags { "LightMode"="UniversalForward" }
            ZWrite Off

            HLSLPROGRAM
            #pragma target 3.5
            #pragma vertex GroundVertex
            #pragma fragment GroundFragment
            #pragma shader_feature_local_fragment _ _SCREENSPECON_ON
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            TEXTURE2D(_Control);            SAMPLER(sampler_Control);
            TEXTURE2D(_Splat0);             SAMPLER(sampler_Splat0);
            TEXTURE2D(_Splat1);             SAMPLER(sampler_Splat1);
            TEXTURE2D(_Splat2);             SAMPLER(sampler_Splat2);
            TEXTURE2D(_Splat3);             SAMPLER(sampler_Splat3);
            TEXTURE2D(_BaseNormal);         SAMPLER(sampler_BaseNormal);
            TEXTURE2D(_NormalMask);         SAMPLER(sampler_NormalMask);
            TEXTURE2D(_Splat_Golobal);      SAMPLER(sampler_Splat_Golobal);
            TEXTURE2D(_SparkMap);           SAMPLER(sampler_SparkMap);
            TEXTURE2D(_SpecMaskMap);        SAMPLER(sampler_SpecMaskMap);
            TEXTURE2D(_PlaneBlurShadowMap); SAMPLER(sampler_PlaneBlurShadowMap);

            CBUFFER_START(UnityPerMaterial)
                float4 _WorldEdge;
                float4 _Control_ST;
                float4 _Splat0_ST;
                float4 _Splat1_ST;
                float4 _Splat2_ST;
                float4 _Splat3_ST;
                float4 _Color_Splat1;
                float4 _Color_Splat2;
                float4 _Color_Splat3;
                float4 _Color_Splat4;
                float4 _BaseNormal_ST;
                float4 _NormalMask_ST;
                float4 _Splat_Golobal_ST;
                float4 _Color_Golobal;
                float4 _FakeNormalDir;
                float4 _EdgeColor01;
                float4 _SparkMap_ST;
                float4 _SparkColor;
                float4 _specColor;
                float4 _BlurPlaneShadowColor;
                float _WorldUVON;
                float _HeightBlendOn;
                float _Weight;
                float _BaseNormalScale;
                float _Color_Splat1_Intensity;
                float _Color_Splat2_Intensity;
                float _Color_Splat3_Intensity;
                float _Color_Splat4_Intensity;
                float _NormalMinHeight;
                float _NormalMaxHeight;
                float _MinHeight;
                float _MaxHeight;
                float _FakeNormalOn;
                float _FakeNormalChannel;
                float _SparkColorIntensity;
                float _specScale;
                float _BlurPlaneShadowOn;
                float _LightColorDesat;
                float _AlphaScale;
            CBUFFER_END

            static const float kWeightEpsilon = 0.00006103515625;

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
                float2 groundUV : TEXCOORD0;
                float4 globalAndSparkUV : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                float3 tangentWS : TEXCOORD3;
                float3 bitangentWS : TEXCOORD4;
                float3 ambientSH : TEXCOORD5;
                float4 screenPosition : TEXCOORD6;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            float CameraHeightRatio(float startHeight, float endHeight)
            {
                float span = endHeight - startHeight;
                return saturate((_WorldSpaceCameraPos.y - startHeight) / span);
            }

            Varyings GroundVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float3 positionWS = TransformObjectToWorld(input.positionOS);
                output.positionCS = TransformWorldToHClip(positionWS);
                float2 worldUV = (positionWS.xz + _WorldEdge.zw) / _WorldEdge.xy + float2(0,1);
                output.groundUV = lerp(input.uv, worldUV, _WorldUVON);
                output.globalAndSparkUV.xy = input.uv * _Splat_Golobal_ST.xy + _Splat_Golobal_ST.zw;
                output.globalAndSparkUV.zw = input.uv * _SparkMap_ST.xy + _SparkMap_ST.zw;

                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                float3 tangentOS = float3(-input.normalOS.y, input.normalOS.x, 0);
                output.tangentWS = TransformObjectToWorldDir(tangentOS);
                output.bitangentWS = cross(output.normalWS, output.tangentWS) * GetOddNegativeScale();

                output.ambientSH = SampleSH(output.normalWS);
                output.screenPosition = ComputeScreenPos(output.positionCS);
                return output;
            }

            float4 HeightBlendWeights(float4 control, float4 heights)
            {
                float4 weightedHeights = control * heights;
                float highest = max(max(weightedHeights.r, weightedHeights.g), max(weightedHeights.b, weightedHeights.a));
                float4 survivingHeights = max(weightedHeights - highest + _Weight, 0.0);
                float4 weightedControl = control * survivingHeights;
                return weightedControl / (dot(weightedControl, float4(1,1,1,1)) + kWeightEpsilon);
            }

            struct GroundLayers
            {
                float3 albedo;
                float4 weights;
            };

            GroundLayers BlendGroundLayers(float2 uv)
            {
                GroundLayers layers;
                float2 controlUV = uv * _Control_ST.xy;
                float4 control = SAMPLE_TEXTURE2D(_Control, sampler_Control, controlUV);
                float4 neighborControl = control;
                if (_FakeNormalOn != 0)
                    neighborControl = SAMPLE_TEXTURE2D(_Control, sampler_Control, controlUV + _FakeNormalDir.xy);

                float4 layer0 = SAMPLE_TEXTURE2D(_Splat0, sampler_Splat0, uv * _Splat0_ST.xy + _Splat0_ST.zw);
                float4 layer1 = SAMPLE_TEXTURE2D(_Splat1, sampler_Splat1, uv * _Splat1_ST.xy + _Splat1_ST.zw);
                float4 layer2 = SAMPLE_TEXTURE2D(_Splat2, sampler_Splat2, uv * _Splat2_ST.xy + _Splat2_ST.zw);
                float4 layer3 = SAMPLE_TEXTURE2D(_Splat3, sampler_Splat3, uv * _Splat3_ST.xy + _Splat3_ST.zw);

                if (_HeightBlendOn != 0)
                {
                    float4 heights = float4(layer0.a, layer1.a, layer2.a, layer3.a);
                    control = HeightBlendWeights(control, heights);
                    // 复用中心点的层高度，不偏移四张 Splat 的采样。
                    neighborControl = HeightBlendWeights(neighborControl, heights);
                }
                // 高度混合之后仍再次归一化，保持当前计算顺序。
                layers.weights = control / (dot(control, float4(1,1,1,1)) + kWeightEpsilon);
                layers.albedo = layers.weights.r * layer0.rgb * _Color_Splat1.rgb * _Color_Splat1_Intensity
                              + layers.weights.g * layer1.rgb * _Color_Splat2.rgb * _Color_Splat2_Intensity
                              + layers.weights.b * layer2.rgb * _Color_Splat3.rgb * _Color_Splat3_Intensity
                              + layers.weights.a * layer3.rgb * _Color_Splat4.rgb * _Color_Splat4_Intensity;
                if (_FakeNormalOn != 0)
                {
                    uint channel = (uint)clamp(_FakeNormalChannel, 0.0, 3.0);
                    // 虽名为 FakeNormal，实际只加颜色；邻点不做第二次归一化。
                    float4 edgeDelta = neighborControl - layers.weights;
                    layers.albedo += _EdgeColor01.rgb * edgeDelta[channel];
                }
                return layers;
            }

            float3 BuildLightingNormal(Varyings input)
            {
                float heightRatio = CameraHeightRatio(_NormalMinHeight, _NormalMaxHeight);
                float smoothFade = heightRatio * heightRatio * (3.0 - 2.0 * heightRatio);
                float normalStrength = _BaseNormalScale * (1.0 - smoothFade);
                float3 normalTS = SAMPLE_TEXTURE2D(_BaseNormal, sampler_BaseNormal,input.groundUV * _BaseNormal_ST.xy).rgb * 2.0 - 1.0;
                normalTS.xy *= normalStrength;

                float3 mappedNormal = -input.tangentWS * normalTS.x + input.bitangentWS * normalTS.y + input.normalWS * normalTS.z;
                float normalMask = SAMPLE_TEXTURE2D(_NormalMask, sampler_NormalMask,input.groundUV * _NormalMask_ST.xy).r;
                return lerp(float3(1,1,1), mappedNormal, normalMask);
            }

            float4 GroundFragment(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                GroundLayers layers = BlendGroundLayers(input.groundUV);
                float3 lightingNormal = BuildLightingNormal(input);

                Light mainLight = GetMainLight();
                float3 lightColor = mainLight.color;
                float lightLuminance = Luminance(lightColor);
                lightColor = lerp(lightLuminance, lightColor, _LightColorDesat);
                float diffuse = saturate(dot(lightingNormal, mainLight.direction));
                float3 color = layers.albedo * (lightColor * diffuse * mainLight.distanceAttenuation + input.ambientSH);

                float2 screenUV = input.screenPosition.xy / input.screenPosition.w;
                #if defined(_SCREENSPECON_ON)
                {
                    float sparkMask = SAMPLE_TEXTURE2D(_SparkMap, sampler_SparkMap, input.globalAndSparkUV.zw).a;
                    float2 screenSpecMask = SAMPLE_TEXTURE2D(_SpecMaskMap, sampler_SpecMaskMap, screenUV).rg;
                    float3 spark = sparkMask * _SparkColor.rgb * _SparkColorIntensity * screenSpecMask.r;
                    color += spark * (layers.weights.g + layers.weights.b);
                    color += screenSpecMask.g * _specColor.rgb * _specScale;
                }
                #endif

                float3 globalAlbedo = SAMPLE_TEXTURE2D(_Splat_Golobal, sampler_Splat_Golobal,input.globalAndSparkUV.xy).rgb;
                float3 globalColor  = globalAlbedo * lightColor * _Color_Golobal.rgb;
                color = lerp(color, globalColor, CameraHeightRatio(_MinHeight, _MaxHeight));

                if (_BlurPlaneShadowOn != 0)
                {
                    float visibility = SAMPLE_TEXTURE2D(_PlaneBlurShadowMap, sampler_PlaneBlurShadowMap, screenUV).r;
                    float3 shadowedColor = lerp(color, _BlurPlaneShadowColor.rgb, _BlurPlaneShadowColor.a);
                    color = lerp(shadowedColor, color, visibility);
                }

                return float4(color, _AlphaScale);
            }
            ENDHLSL
        }
    }
    FallBack Off
}
