# Shader Analysis — Frame 1526 EID 187

## 1. DrawCall Summary
- API: OpenGL; Indexed TriangleList; ForwardLit; RT0.
- Role: metallic surface with captured cubemap environment BRDF, custom diffuse lighting, emission, rim and height-distance fog.
- Indices: 1197; instances: 1.

## 2. Pipeline State
```json
{"depthEnable": true, "depthWrites": true, "depthFunction": "CompareFunction.LessEqual", "depthBounds": false, "nearBound": 0.0, "farBound": 1.0}
{"enabled": false, "logicOperationEnabled": false, "logicOperation": "LogicOperation.NoOp", "writeMask": 15, "index": 0, "colorBlend": {"source": "BlendMultiplier.One", "destination": "BlendMultiplier.InvSrcAlpha", "operation": "BlendOperation.Add"}, "alphaBlend": {"source": "BlendMultiplier.One", "destination": "BlendMultiplier.InvSrcAlpha", "operation": "BlendOperation.Add"}, "writeMaskChannels": {"r": true, "g": true, "b": true, "a": true}}
```

## 3. CB Mapping Table
Named Unity uniforms retain their source semantic stems; original names are the lookup keys. Values below are full capture precision.
| Stage | CB | GLSL Ref | Inferred Name | Snapshot Value | Confidence |
|---|---|---|---|---|---|
|vertex|UnityPerDraw|`hlslcc_mtx4x4unity_ObjectToWorld`|unityObjectToWorldSnapshot|`[[-0.9919856786727905, 0.01763264462351799, 0.8400318622589111, 0.0], [0.8227794766426086, -0.24303077161312103, 0.9767138957977295, 0.0], [0.17028889060020447, 1.2769594192504883, 0.17428871989250183, 0.0], [31.19162368774414, 5.048766136169434, 20.494853973388672, 1.0]]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`hlslcc_mtx4x4unity_WorldToObject`|unityWorldToObjectSnapshot|`[[-0.5869738459587097, 0.4868517816066742, 0.10076269507408142, 0.0], [0.010433471761643887, -0.14380519092082977, 0.7555972933769226, 0.0], [0.49706026911735535, 0.5779372453689575, 0.10312939435243607, 0.0], [8.068814277648926, -26.304397583007812, -9.07140827178955, 1.0]]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_LODFade`|unityLODFadeSnapshot|`[0.0, 0.0, "NaN", 0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_WorldTransformParams`|unityWorldTransformParamsSnapshot|`[0.0, 0.0, 0.0, 1.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_RenderingLayer`|unityRenderingLayerSnapshot|`[1.401298464324817e-45, 0.0, 0.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_LightData`|unityLightDataSnapshot|`[316.0, 1.0, 1.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_LightIndices`|unityLightIndicesSnapshot|`[[0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0]]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_ProbesOcclusion`|unityProbesOcclusionSnapshot|`[1.0, 1.0, 1.0, 1.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_SpecCube0_HDR`|unitySpecCube0HDRSnapshot|`[1.0, 1.0, 0.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_SpecCube1_HDR`|unitySpecCube1HDRSnapshot|`[1.0, 1.0, 0.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_SpecCube0_BoxMax`|unitySpecCube0BoxMaxSnapshot|`["Infinity", "Infinity", "Infinity", 0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_SpecCube0_BoxMin`|unitySpecCube0BoxMinSnapshot|`["-Infinity", "-Infinity", "-Infinity", 0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_SpecCube0_ProbePosition`|unitySpecCube0ProbePositionSnapshot|`[0.0, 0.0, 0.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_SpecCube1_BoxMax`|unitySpecCube1BoxMaxSnapshot|`["Infinity", "Infinity", "Infinity", 0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_SpecCube1_BoxMin`|unitySpecCube1BoxMinSnapshot|`["-Infinity", "-Infinity", "-Infinity", 0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_SpecCube1_ProbePosition`|unitySpecCube1ProbePositionSnapshot|`[0.0, 0.0, 0.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_LightmapST`|unityLightmapSTSnapshot|`[0.0, 0.0, 0.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_DynamicLightmapST`|unityDynamicLightmapSTSnapshot|`[0.0, 0.0, 0.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_SHAr`|unitySHArSnapshot|`[0.0, 5.424022674560547e-06, 0.0, 0.9999691843986511]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_SHAg`|unitySHAgSnapshot|`[0.0, 4.470348358154297e-06, 0.0, 0.9999756813049316]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_SHAb`|unitySHAbSnapshot|`[0.0, 3.0100345611572266e-06, 0.0, 0.9999861121177673]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_SHBr`|unitySHBrSnapshot|`[0.0, 0.0, -1.6540288925170898e-06, 0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_SHBg`|unitySHBgSnapshot|`[0.0, 0.0, -1.385807991027832e-06, 0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_SHBb`|unitySHBbSnapshot|`[0.0, 0.0, -9.611248970031738e-07, 0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_SHC`|unitySHCSnapshot|`[-1.5497207641601562e-06, -1.2814998626708984e-06, -8.717179298400879e-07, 1.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`hlslcc_mtx4x4unity_MatrixPreviousM`|unityMatrixPreviousMSnapshot|`[[0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0], [0.0, -4.591774807899561e-41, "NaN", 0.0]]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`hlslcc_mtx4x4unity_MatrixPreviousMI`|unityMatrixPreviousMISnapshot|`[[0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0]]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_MotionVectorsParams`|unityMotionVectorsParamsSnapshot|`[0.0, -4.591774807899561e-41, "NaN", 0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|$Globals|`_FogEnd`|fogEndSnapshot|`[1.0]`|HIGH: named uniform; numeric snapshot|
|vertex|$Globals|`_FogFallOff`|fogFallOffSnapshot|`[3.0]`|HIGH: named uniform; numeric snapshot|
|vertex|$Globals|`_FogGlobalDensity`|fogDensitySnapshot|`[0.09000000357627869]`|HIGH: named uniform; numeric snapshot|
|vertex|$Globals|`_FogGradientDis`|fogGradientDisSnapshot|`[50.0]`|HIGH: named uniform; numeric snapshot|
|vertex|$Globals|`_FogHeight`|fogHeightSnapshot|`[5.0]`|HIGH: named uniform; numeric snapshot|
|vertex|$Globals|`_FogStart`|fogStartSnapshot|`[0.05400000140070915]`|HIGH: named uniform; numeric snapshot|
|vertex|$Globals|`_FogStartDis`|fogStartDisSnapshot|`[25.709999084472656]`|HIGH: named uniform; numeric snapshot|
|vertex|$Globals|`_ProjectionParams`|projectionParamsSnapshot|`[0.0, 0.0, 0.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|$Globals|`_WorldSpaceCameraPos`|worldSpaceCameraPosSnapshot|`[36.02374267578125, 15.999999046325684, -8.70000171661377]`|HIGH: named uniform; numeric snapshot|
|vertex|$Globals|`hlslcc_mtx4x4unity_MatrixVP`|unityMatrixVPSnapshot|`[[4.188181400299072, 0.0, 0.0, 0.0], [0.0, 1.9935059547424316, -0.5350121855735779, -0.5328763723373413], [0.0, 1.2553778886795044, 0.849584698677063, 0.8461931347846985], [-150.87396240234375, -20.974302291870117, 13.947574615478516, 15.887903213500977]]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerDraw|`hlslcc_mtx4x4unity_ObjectToWorld`|unityObjectToWorldSnapshot|`[[-0.9919856786727905, 0.01763264462351799, 0.8400318622589111, 0.0], [0.8227794766426086, -0.24303077161312103, 0.9767138957977295, 0.0], [0.17028889060020447, 1.2769594192504883, 0.17428871989250183, 0.0], [31.19162368774414, 5.048766136169434, 20.494853973388672, 1.0]]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerDraw|`hlslcc_mtx4x4unity_WorldToObject`|unityWorldToObjectSnapshot|`[[-0.5869738459587097, 0.4868517816066742, 0.10076269507408142, 0.0], [0.010433471761643887, -0.14380519092082977, 0.7555972933769226, 0.0], [0.49706026911735535, 0.5779372453689575, 0.10312939435243607, 0.0], [8.068814277648926, -26.304397583007812, -9.07140827178955, 1.0]]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerDraw|`unity_LODFade`|unityLODFadeSnapshot|`[0.0, 0.0, "NaN", 0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerDraw|`unity_WorldTransformParams`|unityWorldTransformParamsSnapshot|`[0.0, 0.0, 0.0, 1.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerDraw|`unity_RenderingLayer`|unityRenderingLayerSnapshot|`[1.401298464324817e-45, 0.0, 0.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerDraw|`unity_LightData`|unityLightDataSnapshot|`[316.0, 1.0, 1.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerDraw|`unity_LightIndices`|unityLightIndicesSnapshot|`[[0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0]]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerDraw|`unity_ProbesOcclusion`|unityProbesOcclusionSnapshot|`[1.0, 1.0, 1.0, 1.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerDraw|`unity_SpecCube0_HDR`|unitySpecCube0HDRSnapshot|`[1.0, 1.0, 0.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerDraw|`unity_SpecCube1_HDR`|unitySpecCube1HDRSnapshot|`[1.0, 1.0, 0.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerDraw|`unity_SpecCube0_BoxMax`|unitySpecCube0BoxMaxSnapshot|`["Infinity", "Infinity", "Infinity", 0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerDraw|`unity_SpecCube0_BoxMin`|unitySpecCube0BoxMinSnapshot|`["-Infinity", "-Infinity", "-Infinity", 0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerDraw|`unity_SpecCube0_ProbePosition`|unitySpecCube0ProbePositionSnapshot|`[0.0, 0.0, 0.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerDraw|`unity_SpecCube1_BoxMax`|unitySpecCube1BoxMaxSnapshot|`["Infinity", "Infinity", "Infinity", 0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerDraw|`unity_SpecCube1_BoxMin`|unitySpecCube1BoxMinSnapshot|`["-Infinity", "-Infinity", "-Infinity", 0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerDraw|`unity_SpecCube1_ProbePosition`|unitySpecCube1ProbePositionSnapshot|`[0.0, 0.0, 0.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerDraw|`unity_LightmapST`|unityLightmapSTSnapshot|`[0.0, 0.0, 0.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerDraw|`unity_DynamicLightmapST`|unityDynamicLightmapSTSnapshot|`[0.0, 0.0, 0.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerDraw|`unity_SHAr`|unitySHArSnapshot|`[0.0, 5.424022674560547e-06, 0.0, 0.9999691843986511]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerDraw|`unity_SHAg`|unitySHAgSnapshot|`[0.0, 4.470348358154297e-06, 0.0, 0.9999756813049316]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerDraw|`unity_SHAb`|unitySHAbSnapshot|`[0.0, 3.0100345611572266e-06, 0.0, 0.9999861121177673]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerDraw|`unity_SHBr`|unitySHBrSnapshot|`[0.0, 0.0, -1.6540288925170898e-06, 0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerDraw|`unity_SHBg`|unitySHBgSnapshot|`[0.0, 0.0, -1.385807991027832e-06, 0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerDraw|`unity_SHBb`|unitySHBbSnapshot|`[0.0, 0.0, -9.611248970031738e-07, 0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerDraw|`unity_SHC`|unitySHCSnapshot|`[-1.5497207641601562e-06, -1.2814998626708984e-06, -8.717179298400879e-07, 1.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerDraw|`hlslcc_mtx4x4unity_MatrixPreviousM`|unityMatrixPreviousMSnapshot|`[[0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0], [0.0, -4.591774807899561e-41, "NaN", 0.0]]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerDraw|`hlslcc_mtx4x4unity_MatrixPreviousMI`|unityMatrixPreviousMISnapshot|`[[0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0]]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerDraw|`unity_MotionVectorsParams`|unityMotionVectorsParamsSnapshot|`[0.0, -4.591774807899561e-41, "NaN", 0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_BaseMap_ST`|baseMapSTSnapshot|`[1.0, 1.0, 0.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_BaseColor`|baseColorSnapshot|`[1.0, 1.0, 1.0, 1.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_NormalMap_ST`|normalMapSTSnapshot|`[1.0, 1.0, 0.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_MGA_ST`|mGASTSnapshot|`[1.0, 1.0, 0.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`reflectionDir`|reflectionDirSnapshot|`[-0.5899999737739563, -0.3400000035762787, 0.019999999552965164, 0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_ReflectionMap_HDR`|reflectionMapHDRSnapshot|`[34.49324417114258, 2.200000047683716, 0.0, 1.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_Fresnel_Color`|fresnelColorSnapshot|`[2.272857904434204, 1.010862946510315, 0.8662592768669128, 1.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_Fresnel_Color_Edge`|fresnelColorEdgeSnapshot|`[0.0, 0.0, 0.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_EmissiveColor`|emissiveColorSnapshot|`[1.0, 1.0, 1.0, 1.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_CustomLightDir`|customLightDirSnapshot|`[1.0199999809265137, 1.440000057220459, 0.9700000286102295, 1.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_NormalScale`|normalScaleSnapshot|`[1.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_MetallicIntensity`|metallicIntensitySnapshot|`[1.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_RoughnessIntensity`|roughnessIntensitySnapshot|`[1.1699999570846558]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_ClipThreshold`|clipThresholdSnapshot|`[0.5]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_ReflectionIntenSity`|reflectionIntenSitySnapshot|`[0.5]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_AoIntensity`|aoIntensitySnapshot|`[1.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_EmissiveIntensity`|emissiveIntensitySnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_Fresnel_Bisa`|fresnelBisaSnapshot|`[0.10000000149011612]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_Fresnel_Scale`|fresnelScaleSnapshot|`[10.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_Fresnel_Intensity`|fresnelIntensitySnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_LightIntensity`|lightIntensitySnapshot|`[1.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_AddLightIntensity`|addLightIntensitySnapshot|`[0.30000001192092896]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_HeroDayNight_ON`|heroDayNightBlendSnapshot|`[1.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_CustmLightDir_ON`|custmLightDirONSnapshot|`[1.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_CustomLightIntensity`|customLightIntensitySnapshot|`[1.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_HorizontalPlaneValue`|horizontalPlaneValueSnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_Fresnel_Scale_Edge`|fresnelScaleEdgeSnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_UV2_ON`|uV2ONSnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_EmissionMap_ON`|emissionMapONSnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_Fresnel_ON`|rimLightEnabledSnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_DayNightInfluence`|dayNightInfluenceSnapshot|`[1.0]`|HIGH: named uniform; numeric snapshot|
|pixel|$Globals|`_FogColor`|fogColorSnapshot|`[0.6901960968971252, 0.5254902243614197, 0.3333333432674408, 0.6509804129600525]`|HIGH: named uniform; numeric snapshot|
|pixel|$Globals|`_LightColor2`|secondSceneLightColorSnapshot|`[0.9999902248382568, 0.9999929666519165, 1.0, 1.0]`|HIGH: named uniform; numeric snapshot|
|pixel|$Globals|`_LightIntensity2`|lightIntensity2Snapshot|`[1.0000479221343994]`|HIGH: named uniform; numeric snapshot|
|pixel|$Globals|`_MainLightColor`|mainLightColorSnapshot|`[1.2999664545059204, 1.299973964691162, 1.2999917268753052, 1.2999999523162842]`|HIGH: named uniform; numeric snapshot|
|pixel|$Globals|`_MainLightPosition`|mainLightPositionSnapshot|`[-0.2632894814014435, 0.824126124382019, -0.5014926195144653, 0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|$Globals|`_WorldSpaceCameraPos`|worldSpaceCameraPosSnapshot|`[36.02374267578125, 15.999999046325684, -8.70000171661377]`|HIGH: named uniform; numeric snapshot|

## 4. Texture/Sampler Mapping
| Slot | GLSL name | Resource | Semantic | Usage |
|---|---|---|---|---|
|0|_BaseMap|ResourceId::6851|baseColor|.rgba / .rgb; see source branch|
|1|_MGA|ResourceId::4313|metallicRoughnessOcclusionEmissionMask|.rgba / .rgb; see source branch|
|2|_EmissionMap|ResourceId::6854|emissionTexture|.rgba / .rgb; see source branch|
|3|_ReflectionMap|ResourceId::6824|reflectionCubemap|.rgba / .rgb; see source branch|

## 5. Varying Mapping
|Source|Semantic|VS source|PS usage|
|---|---|---|---|
|vs_TEXCOORD0|packedBaseAndSecondaryUV|in_TEXCOORD0.xy and in_TEXCOORD1.xy|base/MGA/emission UV|
|vs_TEXCOORD2.xyz/w|worldNormal/worldPositionX|normal transformed by inverse-transpose / objectToWorld position.x|normal/view direction|
|vs_TEXCOORD3.xyz/w|worldTangent/worldPositionY|tangent transformed by objectToWorld / position.y|position assembly; tangent xyz not consumed|
|vs_TEXCOORD4.xyz/w|worldBitangent/worldPositionZ|cross(normal,tangent)*handedness / position.z|position assembly; bitangent xyz not consumed|
|vs_TEXCOORD5.xyz/w|ambientIrradiance/fogFactor|captured SH and height-distance fog|indirect diffuse and fog blend|
|vs_TEXCOORD6|screenPosition|GL projected position|not consumed by PS|

## 6. Vertex Input Mapping
| Input | Semantic | Format |
|---|---|---|
|in_POSITION0|POSITION0|{"compByteWidth": 4, "compCount": 3, "compType": 1, "type": 0}|
|in_NORMAL0|NORMAL0|{"compByteWidth": 2, "compCount": 4, "compType": 1, "type": 0}|
|in_TANGENT0|TANGENT0|{"compByteWidth": 2, "compCount": 4, "compType": 1, "type": 0}|
|in_TEXCOORD0|TEXCOORD0|{"compByteWidth": 2, "compCount": 2, "compType": 1, "type": 0}|
|in_TEXCOORD1|TEXCOORD1|{"compByteWidth": 2, "compCount": 2, "compType": 1, "type": 0}|

## 7. Branch Coverage

Independent E187 scope: this specification Sections 1–6 plus the co-located VS (148 lines) and PS (228 lines) were read from disk. No other EID, shader implementation, raw_data or runtime tool contributes to this analysis. `target_filter=[0]`; source line 1 is `#version 450`.

| Condition | CB Value | Active? | Inactive Path Summary |
|---|---|---|---|
| PS L123–134: `_EmissionMap_ON > 0.5` | `0.0`; `_EmissiveIntensity=0.0` | FALSE / MGA-alpha emission ACTIVE; TRUE / texture emission INACTIVE | TRUE samples `_EmissionMap.rgb` at raw primary UV and multiplies by emissive color/intensity. FALSE uses `_MGA.a` times the same color/intensity. Both yield zero for finite sampled values in this snapshot, but both algorithms remain required. |
| PS L123,197–217: `_Fresnel_ON > 0.5` | `0.0`; `_Fresnel_Intensity=0.0` | FALSE / preserve pre-rim color ACTIVE; TRUE / rim addition INACTIVE | TRUE adds a biased fifth-power broad rim and a separate third-power edge rim. Its view normalization has no max(lengthSquared,0) operation, unlike the earlier environment view-vector path. |
| VS L100–103: `unity_WorldTransformParams.w >= 0.0` | `1.0` | TRUE / transform parity +1 ACTIVE; FALSE / -1 INACTIVE | The parity multiplies input tangent.w and cross(normal,tangent) for the bitangent xyz output. Neither bitangent xyz nor tangent xyz is read by this PS, so this branch has no RT0 dependency. Position remains packed in their w channels independently. |

`_UV2_ON=0`, `_CustmLightDir_ON=1`, `_HeroDayNight_ON=1` and `_DayNightInfluence=1` are continuous arithmetic interpolation weights, not conditions. Roughness/metallic/AO clamps depend on sampled MGA data and therefore have pixel-varying results; no missing control-flow branch is implied by a clamp. There is no light loop or alpha discard. `_NormalScale`, `_NormalMap_ST`, `_ClipThreshold`, `_LightIntensity`, `_AddLightIntensity` and `_HorizontalPlaneValue` have no executable PS use. `reflectionDir.w`, `_BaseColor.a`, `_EmissiveColor.a` and rim-color alpha components are unused. NaN/Infinity values listed for unused per-draw fields do not enter RT0.

## 8. Data Flow — Panoramic AST Dependency Tree (Bottom-Up)

### 8.1 Mechanical assignment index and segmentation

The following in-memory mechanical scan covers every PS intermediate assignment, including swizzles and the self-assignment at L135. Counts include the first definition. No auxiliary file was created.

```text
[变量冲突表]
u_xlat10_6: L126 (1)
u_xlat13: L221 (1)
u_xlat16_0: L102, L103, L104, L201, L202, L203, L210, L211, L212, L214, L215, L223, L224 (13)
u_xlat16_1: L105, L106, L107, L113, L114, L115, L117, L118, L166 (9)
u_xlat16_10: L159, L162, L163, L164, L178, L190 (6)
u_xlat16_11: L209, L213 (2)
u_xlat16_16: L122, L142 (2)
u_xlat16_19: L141, L148, L149 (3)
u_xlat16_33: L120, L121, L137, L138, L145, L160, L161, L168, L169, L170, L171, L172, L173, L174, L176, L177, L183, L184, L187, L188, L192 (21)
u_xlat16_4: L116 (1)
u_xlat16_40: L139, L150 (2)
u_xlat16_42: L154, L155, L156, L157, L158 (5)
u_xlat16_5: L119, L135, L136, L146, L147, L194, L195, L196, L216 (9)
u_xlat16_7: L127, L128, L133 (3)
u_xlat16_8: L132, L140, L143, L144, L179, L181, L182 (7)
u_xlat16_9: L151, L152, L153, L165, L175, L185, L186, L189, L191, L193 (10)
u_xlat2: L108, L200, L204, L205, L206, L207, L208, L218, L219, L220, L222 (11)
u_xlat3: L110, L111, L112, L167, L180 (5)
u_xlat35: L109, L199 (2)
u_xlatb6: L123 (1)
[冲突统计]: 20 intermediate names; 16 have >=2 assignments; maximum 21.

[合成点索引]
RT0.rgb (SV_Target0.xyz): assignment L225
  u_xlat16_0.xyz -> L224 post-fog day/night multiplier, NOT earlier normal/rim
  u_xlat2.xyz -> L222 fog composition, NOT view displacement or rim power
    u_xlat2.x -> L220 before xyz overwrite
    u_xlat13.xyz -> L221 fog-minus-surface delta
    u_xlat16_5.xyz -> join of L196 and optional L216; snapshot selects L196
      L196 -> emission at L128 or L133 + lighting at L195
      L195 -> direct diffuse at L194 + AO at L150 * indirect at L182
      L182 -> vertex SH diffuse + environment specular at L181
RT0.a (SV_Target0.w): assignment L226, literal 1.0
[分段计划]: five complete contribution subtrees:
  1. cubemap lookup/HDR decode/environment BRDF and shared material/geometry inputs
  2. direct diffuse, vertex SH and indirect occlusion
  3. both emission paths and pre-rim composition
  4. optional broad/edge rim
  5. vertex fog, post-fog day/night multiplier and RT0 outputs
```

Registers below are resolved at the listed assignments and at control-flow joins, never by name alone. In particular `u_xlat16_33` successively stores input roughness, smoothness, restored roughness, mip, HDR decode, surface reduction and light attenuation. Each semantic value receives its own node. `computed node above` refers to already defined semantic nodes. Texture lookup parents include coordinate/LOD dependencies in addition to `[TEX]` sample leaves. `interpolate` denotes the default smooth perspective raster interpolation generated from the primitive's clip positions. Packed varying producer chains are expanded to vertex inputs and uniforms.

[全景依赖树 (Bottom-Up Trace)]

=== SV_Target0 (RT0 — environment-lit metallic RGB, opaque alpha) ===
