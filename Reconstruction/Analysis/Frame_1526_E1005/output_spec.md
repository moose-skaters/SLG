# Shader Analysis — Frame 1526 EID 1005

## 1. DrawCall Summary
- API: OpenGL; Indexed TriangleList; ForwardLit; RT0.
- Role: textured character/surface shader, custom diffuse lighting, emission, rim and height-distance fog.
- Indices: 765; instances: 1.

## 2. Pipeline State
```json
{"depthEnable": true, "depthWrites": true, "depthFunction": "CompareFunction.LessEqual", "depthBounds": false, "nearBound": 0.0, "farBound": 1.0}
{"enabled": false, "logicOperationEnabled": false, "logicOperation": "LogicOperation.NoOp", "writeMask": 15, "index": 0, "colorBlend": {"source": "BlendMultiplier.One", "destination": "BlendMultiplier.InvSrcAlpha", "operation": "BlendOperation.Add"}, "alphaBlend": {"source": "BlendMultiplier.One", "destination": "BlendMultiplier.InvSrcAlpha", "operation": "BlendOperation.Add"}, "writeMaskChannels": {"r": true, "g": true, "b": true, "a": true}}
```

## 3. CB Mapping Table
Named Unity uniforms retain their source semantic stems; original names are the lookup keys. Values below are full capture precision.
| Stage | CB | GLSL Ref | Inferred Name | Snapshot Value | Confidence |
|---|---|---|---|---|---|
|vertex|UnityPerDraw|`hlslcc_mtx4x4unity_ObjectToWorld`|unityObjectToWorldSnapshot|`[[1.0, 0.0, 0.0, 0.0], [0.0, 1.0, 0.0, 0.0], [0.0, 0.0, 1.0, 0.0], [55.386566162109375, -35.13422393798828, 180.5950164794922, 1.0]]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`hlslcc_mtx4x4unity_WorldToObject`|unityWorldToObjectSnapshot|`[[1.0, 0.0, 0.0, 0.0], [0.0, 1.0, 0.0, 0.0], [0.0, 0.0, 1.0, 0.0], [-55.386566162109375, 35.13422393798828, -180.5950164794922, 1.0]]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_LODFade`|unityLODFadeSnapshot|`[0.0, 0.0, 0.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_WorldTransformParams`|unityWorldTransformParamsSnapshot|`[0.0, 0.0, 0.0, 1.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_RenderingLayer`|unityRenderingLayerSnapshot|`[1.401298464324817e-45, 0.0, 0.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_LightData`|unityLightDataSnapshot|`[157.0, 1.0, 1.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_LightIndices`|unityLightIndicesSnapshot|`[[0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0]]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_ProbesOcclusion`|unityProbesOcclusionSnapshot|`[1.0, 1.0, 1.0, 1.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_SpecCube0_HDR`|unitySpecCube0HDRSnapshot|`[1.0, 1.0, 0.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_SpecCube1_HDR`|unitySpecCube1HDRSnapshot|`[1.0, 1.0, 0.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_SpecCube0_BoxMax`|unitySpecCube0BoxMaxSnapshot|`[0.0, 0.0, 0.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_SpecCube0_BoxMin`|unitySpecCube0BoxMinSnapshot|`[0.0, 0.0, 0.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_SpecCube0_ProbePosition`|unitySpecCube0ProbePositionSnapshot|`[0.0, 0.0, 0.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_SpecCube1_BoxMax`|unitySpecCube1BoxMaxSnapshot|`[0.0, 0.0, 0.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_SpecCube1_BoxMin`|unitySpecCube1BoxMinSnapshot|`[0.0, 0.0, 0.0, 0.0]`|HIGH: named uniform; numeric snapshot|
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
|vertex|UnityPerDraw|`hlslcc_mtx4x4unity_MatrixPreviousM`|unityMatrixPreviousMSnapshot|`[[0.0, 3.0100345611572266e-06, 0.0, 0.9999861121177673], [0.0, 0.0, -1.6540288925170898e-06, 0.0], [0.0, 0.0, -1.385807991027832e-06, 0.0], [0.0, 0.0, -9.611248970031738e-07, 0.0]]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`hlslcc_mtx4x4unity_MatrixPreviousMI`|unityMatrixPreviousMISnapshot|`[[-1.5497207641601562e-06, -1.2814998626708984e-06, -8.717179298400879e-07, 1.0], [7.533886398027124e+25, 4.52002832652613e-41, 0.0, 0.0], [2.5798288095916872e+26, 4.52002832652613e-41, 3.8826317450002534e-07, 6.095648319812954e-43], [4.210901885296075e-42, 0.53125, 0.0, 0.0]]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerDraw|`unity_MotionVectorsParams`|unityMotionVectorsParamsSnapshot|`[-182.41493225097656, 24.398849487304688, 0.0, -4.591914937745993e-41]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerMaterial|`_MainTex_ST`|baseTextureScaleOffsetSnapshot|`[1.0, 1.0, 0.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerMaterial|`_EmissionColor`|emissionTintSnapshot|`[0.0, 0.0, 0.0, 1.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerMaterial|`_Color`|materialColorTintSnapshot|`[1.0, 1.0, 1.0, 1.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerMaterial|`_Fresnel_Color`|fresnelColorSnapshot|`[1.0, 1.0, 1.0, 1.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerMaterial|`_Fresnel_Color_Edge`|fresnelColorEdgeSnapshot|`[0.0, 0.0, 0.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerMaterial|`_GPUSKin_TextureSize`|skinAnimationTextureSizeSnapshot|`[0.0, 0.0, 0.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerMaterial|`_ShadowColor`|shadowColorSnapshot|`[0.07323893904685974, 0.07323893904685974, 0.07323893904685974, 1.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerMaterial|`_VertexOffsetY`|localVertexHeightOffsetSnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerMaterial|`_MainLightOn`|mainLightBlendWeightSnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerMaterial|`_MaxAddIntensity1`|maximumAdditionalLightIntensitySnapshot|`[1.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerMaterial|`_EmissionIntensity`|emissionIntensitySnapshot|`[1.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerMaterial|`_Fresnel_Bisa`|fresnelBisaSnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerMaterial|`_Fresnel_Scale`|fresnelScaleSnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerMaterial|`_Fresnel_Intensity`|fresnelIntensitySnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerMaterial|`_CutOff`|cutOffSnapshot|`[0.5]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerMaterial|`_AlphaIsR`|useRedAsOpacitySnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerMaterial|`_Intensity`|outputIntensitySnapshot|`[1.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerMaterial|`_NoMainTextureOn`|ignoreBaseTextureSnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerMaterial|`_HeroDayNight_ON`|heroDayNightBlendSnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerMaterial|`_EMISSIONMAPON_BUILDING_ON`|buildingEmissionEnabledSnapshot|`[1.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerMaterial|`_FadeY`|fadeYSnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerMaterial|`_AlphFadeY_ON`|heightAlphaFadeEnabledSnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerMaterial|`_Fresnel_Scale_Edge`|fresnelScaleEdgeSnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerMaterial|`_EMISSIONMAPON_ON`|emissionTextureEnabledSnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerMaterial|`_BlinnPhongOn`|blinnPhongEnabledSnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerMaterial|`_Fresnel_ON`|rimLightEnabledSnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerMaterial|`_SheetAnimationON`|atlasAnimationEnabledSnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerMaterial|`_MainTexSheetAnimSpeed`|mainTexSheetAnimSpeedSnapshot|`[1.0]`|HIGH: named uniform; numeric snapshot|
|vertex|UnityPerMaterial|`_MainTexSheet`|mainTexSheetSnapshot|`[1.0, 1.0, 1.0, 1.0]`|HIGH: named uniform; numeric snapshot|
|vertex|$Globals|`_FogEnd`|fogEndSnapshot|`[1.0]`|HIGH: named uniform; numeric snapshot|
|vertex|$Globals|`_FogFallOff`|fogFallOffSnapshot|`[3.0]`|HIGH: named uniform; numeric snapshot|
|vertex|$Globals|`_FogGlobalDensity`|fogDensitySnapshot|`[0.09000000357627869]`|HIGH: named uniform; numeric snapshot|
|vertex|$Globals|`_FogGradientDis`|fogGradientDisSnapshot|`[50.0]`|HIGH: named uniform; numeric snapshot|
|vertex|$Globals|`_FogHeight`|fogHeightSnapshot|`[5.0]`|HIGH: named uniform; numeric snapshot|
|vertex|$Globals|`_FogStart`|fogStartSnapshot|`[0.05400000140070915]`|HIGH: named uniform; numeric snapshot|
|vertex|$Globals|`_FogStartDis`|fogStartDisSnapshot|`[25.709999084472656]`|HIGH: named uniform; numeric snapshot|
|vertex|$Globals|`_WorldSpaceCameraPos`|worldSpaceCameraPosSnapshot|`[36.02374267578125, 15.999999046325684, -8.70000171661377]`|HIGH: named uniform; numeric snapshot|
|vertex|$Globals|`hlslcc_mtx4x4unity_MatrixVP`|unityMatrixVPSnapshot|`[[4.188181400299072, 0.0, 0.0, 0.0], [0.0, 1.9935059547424316, -0.5350121855735779, -0.5328763723373413], [0.0, 1.2553778886795044, 0.849584698677063, 0.8461931347846985], [-150.87396240234375, -20.974302291870117, 13.947574615478516, 15.887903213500977]]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_MainTex_ST`|baseTextureScaleOffsetSnapshot|`[1.0, 1.0, 0.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_EmissionColor`|emissionTintSnapshot|`[0.0, 0.0, 0.0, 1.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_Color`|materialColorTintSnapshot|`[1.0, 1.0, 1.0, 1.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_Fresnel_Color`|fresnelColorSnapshot|`[1.0, 1.0, 1.0, 1.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_Fresnel_Color_Edge`|fresnelColorEdgeSnapshot|`[0.0, 0.0, 0.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_GPUSKin_TextureSize`|skinAnimationTextureSizeSnapshot|`[0.0, 0.0, 0.0, 0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_ShadowColor`|shadowColorSnapshot|`[0.07323893904685974, 0.07323893904685974, 0.07323893904685974, 1.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_VertexOffsetY`|localVertexHeightOffsetSnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_MainLightOn`|mainLightBlendWeightSnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_MaxAddIntensity1`|maximumAdditionalLightIntensitySnapshot|`[1.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_EmissionIntensity`|emissionIntensitySnapshot|`[1.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_Fresnel_Bisa`|fresnelBisaSnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_Fresnel_Scale`|fresnelScaleSnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_Fresnel_Intensity`|fresnelIntensitySnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_CutOff`|cutOffSnapshot|`[0.5]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_AlphaIsR`|useRedAsOpacitySnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_Intensity`|outputIntensitySnapshot|`[1.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_NoMainTextureOn`|ignoreBaseTextureSnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_HeroDayNight_ON`|heroDayNightBlendSnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_EMISSIONMAPON_BUILDING_ON`|buildingEmissionEnabledSnapshot|`[1.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_FadeY`|fadeYSnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_AlphFadeY_ON`|heightAlphaFadeEnabledSnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_Fresnel_Scale_Edge`|fresnelScaleEdgeSnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_EMISSIONMAPON_ON`|emissionTextureEnabledSnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_BlinnPhongOn`|blinnPhongEnabledSnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_Fresnel_ON`|rimLightEnabledSnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_SheetAnimationON`|atlasAnimationEnabledSnapshot|`[0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_MainTexSheetAnimSpeed`|mainTexSheetAnimSpeedSnapshot|`[1.0]`|HIGH: named uniform; numeric snapshot|
|pixel|UnityPerMaterial|`_MainTexSheet`|mainTexSheetSnapshot|`[1.0, 1.0, 1.0, 1.0]`|HIGH: named uniform; numeric snapshot|
|pixel|$Globals|`_FogColor`|fogColorSnapshot|`[0.6901960968971252, 0.5254902243614197, 0.3333333432674408, 0.6509804129600525]`|HIGH: named uniform; numeric snapshot|
|pixel|$Globals|`_LightColor1`|firstSceneLightColorSnapshot|`[0.9999865293502808, 0.9999878406524658, 0.9999954700469971, 1.0]`|HIGH: named uniform; numeric snapshot|
|pixel|$Globals|`_LightColor2`|secondSceneLightColorSnapshot|`[0.9999902248382568, 0.9999929666519165, 1.0, 1.0]`|HIGH: named uniform; numeric snapshot|
|pixel|$Globals|`_LightIntensity1`|lightIntensity1Snapshot|`[1.003173828125]`|HIGH: named uniform; numeric snapshot|
|pixel|$Globals|`_LightIntensity2`|lightIntensity2Snapshot|`[1.0000479221343994]`|HIGH: named uniform; numeric snapshot|
|pixel|$Globals|`_MainLightPosition`|mainLightPositionSnapshot|`[-0.2632894814014435, 0.824126124382019, -0.5014926195144653, 0.0]`|HIGH: named uniform; numeric snapshot|
|pixel|$Globals|`_Time`|timeSnapshot|`[1.4527066946029663, 29.054134368896484, 58.10826873779297, 87.16239929199219]`|HIGH: named uniform; numeric snapshot|
|pixel|$Globals|`_Timeline`|timelineSnapshot|`[1.0]`|HIGH: named uniform; numeric snapshot|
|pixel|$Globals|`_WorldSpaceCameraPos`|worldSpaceCameraPosSnapshot|`[36.02374267578125, 15.999999046325684, -8.70000171661377]`|HIGH: named uniform; numeric snapshot|

## 4. Texture/Sampler Mapping
| Slot | GLSL name | Resource | Semantic | Usage |
|---|---|---|---|---|
|0|_MainTex|ResourceId::4313|baseColorAndOpacity|.rgba / .rgb; see source branch|
|1|_EmissionMap|ResourceId::7407|emissionTexture|.rgba / .rgb; see source branch|

## 5. Varying Mapping
| Source | Semantic | VS expression | PS usage |
|---|---|---|---|
|vs_TEXCOORD0|baseUV|in_TEXCOORD0.xy|base/atlas UV|
|vs_TEXCOORD1|worldNormal|normalize(transpose(worldToObject) * localNormal)|lighting/rim|
|vs_TEXCOORD2.xyz|worldPosition|objectToWorld * (localPosition + Y offset)|view and height fade|
|vs_TEXCOORD2.w|heightDistanceFog|density integration * distance, smoothstep|fog mix|
|vs_TEXCOORD3|ambientIrradiance|second-order SH evaluated at world normal, clamped nonnegative|ambient lighting|
|vs_TEXCOORD5/6|unusedLightingOutputs|zero|not consumed by PS|

## 6. Vertex Input Mapping
| Input | Semantic | Format |
|---|---|---|
|in_POSITION0|POSITION0|{"compByteWidth": 4, "compCount": 3, "compType": 1, "type": 0}|
|in_NORMAL0|NORMAL0|{"compByteWidth": 2, "compCount": 4, "compType": 1, "type": 0}|
|in_TEXCOORD0|TEXCOORD0|{"compByteWidth": 2, "compCount": 2, "compType": 1, "type": 0}|

## 7. Branch Coverage

Scope: independently traced only this file Sections 1–6, `vs.glsl` (150 lines), and `ps.glsl` (172 lines), all in `Frame_1526_E1005`. `target_filter=[0]`. Source line numbers below count from `#version 450` as L1. All runtime control-flow decisions occur in PS; VS has no `if`, ternary, loop, or discard.

| Condition | CB Value | Active? | Inactive Path Summary |
|---|---|---|---|
| PS L72–109: `_SheetAnimationON != 0` | `0.0` | FALSE; L109 raw-UV path ACTIVE; L75–105 atlas path INACTIVE | Atlas path computes signed fractional frame wrapping, column/row with truncation, then interpolates between cell corners. Both paths continue through `_MainTex_ST` for MainTex only. |
| PS L79–80: `trunc(sheet.x*sheet.y)*(_Time.y*speed) >= -trunc(sheet.x*sheet.y)*(_Time.y*speed)` | sheet `(1,1,1,1)`, time.y `29.054134368896484`, speed `1.0` | TRUE if atlas path were entered; whole enclosing path INACTIVE | FALSE negates the truncated sheet cell count before reciprocal/fract wrapping. TRUE retains it. |
| PS L86–87: `wrappedFrame*sheet.x >= -wrappedFrame*sheet.x` | With these constants, wrappedFrame approximately `0.054134368896484`, sheet.x `1.0` | TRUE if atlas path were entered; whole enclosing path INACTIVE | FALSE uses `-sheet.x` as the second wrap divisor; TRUE uses `sheet.x`. Both must retain signed wrap behavior for other parameter values. |
| PS L122,126: `_BlinnPhongOn > 0.5` | `0.0` | FALSE/unmodulated scene-light color ACTIVE; TRUE/Lambert path INACTIVE | TRUE multiplies by `saturate(dot(_MainLightPosition.xyz, interpolatedNormal))`. Regardless of this branch, L128 separately adds `_BlinnPhongOn * baseAlbedo * interpolatedSH`. |
| PS L122,129–147: `_Fresnel_ON > 0.5` | `0.0` | FALSE/preserve prior lighting ACTIVE; TRUE/rim path INACTIVE | TRUE adds independent cubic edge rim and biased quintic broad rim, with a normalized view direction but no PS normal renormalization. |
| PS L122,148–157: `_EMISSIONMAPON_ON > 0.5` | `0.0` | FALSE/preserve prior color ACTIVE; TRUE/emission path INACTIVE | TRUE samples emission at pre-ST atlas/raw UV, tints and scales it, applies a building/timeline blend, then adds it before fog. |
| PS L166–167: `worldPositionWS.y >= _FadeY` | `_FadeY=0.0`; vertex positions are not supplied by these three inputs | `[BRANCH_REQUIRES_RUNTIME]`; inclusive height test, both paths expanded | TRUE selects `1.0`; FALSE selects `0.0`. The step is still calculated; `_AlphFadeY_ON=0.0` makes its contribution to output alpha zero for finite values. |

The following controls are arithmetic blend weights, **not branches**, and must remain continuous/unclamped: `_NoMainTextureOn=0`, `_HeroDayNight_ON=0`, `_BlinnPhongOn=0` in the separate SH term, `_AlphaIsR=0`, `_AlphFadeY_ON=0`, and `_EMISSIONMAPON_BUILDING_ON=1`. In the inactive emission path `_Timeline=1` and building weight `1` reduce its finite emission result to zero. `_MainLightOn`, `_MaxAddIntensity1`, and `_CutOff` are declared but unused; there is no alpha clipping, additional-light loop, shadow sampling, specular term, normal map, or GPU skinning execution in these sources.

## 8. Data Flow — Panoramic AST Dependency Tree (Bottom-Up)

### 8.1 Mechanical prepass and segment plan

Mechanical assignment scan was performed in memory, without creating any auxiliary file. Each entry includes every PS assignment to the base variable, including component writes. Counts are assignment counts; the first write is included.

```text
[变量冲突表]
u_xlat0: L75, L82, L83, L84, L93, L104, L105, L109, L158, L159, L160, L162 (12)
u_xlat10_0: L150 (1)
u_xlat14: L78, L81, L88, L89, L90, L111, L132, L133 (8)
u_xlat16_1: L76, L94, L95, L96, L103, L112 (6)
u_xlat16_16: L138, L140 (2)
u_xlat16_17: L102 (1)
u_xlat16_2: L98, L113, L114, L116, L164, L165 (6)
u_xlat16_23: L117 (1)
u_xlat16_24: L123, L124 (2)
u_xlat16_3: L99, L100, L115, L118, L120, L121, L126, L128, L146, L156 (10)
u_xlat16_4: L119, L125, L127, L144, L145, L151, L154, L155 (8)
u_xlat16_6: L152 (1)
u_xlat16_9: L135, L136, L137, L139, L141, L142, L143, L153, L163, L168 (10)
u_xlat21: L167 (1)
u_xlat5: L131, L134 (2)
u_xlat7: L77, L80, L85, L87, L91, L161 (6)
u_xlatb0: L72 (1)
u_xlatb14: L79 (1)
u_xlatb21: L166 (1)
u_xlatb5: L122 (1)
u_xlatb7: L86 (1)
u_xlati0: L92, L97, L101 (3)
[冲突统计]: 12 intermediate variables have >=2 assignments; maximum 12.

[合成点索引]
RT0.a (SV_Target0.w): assignment L169
  _AlphFadeY_ON -> uniform L33
  u_xlat16_9.x -> L168 (NOT its earlier rim/emission/alpha definitions)
  u_xlat16_2.x -> L165 (depends on its pre-overwrite red albedo at L116)
RT0.rgb (SV_Target0.xyz): assignment L170
  u_xlat0.xyz -> L162 (NOT UV at L105/L109)
    u_xlat0.x -> L160 before the L162 write; y/z were irrelevant to its .xxx read
    u_xlat7.xyz -> L161
    u_xlat16_3.xyz -> control-flow join of L128, optional L146, optional L156
      current snapshot -> L128; lexical nearest L156 is inactive
[分段计划]: 5 contribution subtrees, written in dependency order:
  1. RT0 alpha, shared albedo, atlas/raw UV, world-position producer
  2. base lighting, Lambert selection, vertex SH and normal producer
  3. optional cubic/quintic rim addition
  4. optional timeline-modulated emission addition
  5. vertex height-distance fog and RT0 RGB composition
```

`computed node above` always refers to a previously defined semantic node, not to a reused register's later value. A source reference suffix such as `@L116` in prose denotes the value immediately after that assignment; the bracketed source variable remains the original spelling. Texture leaves state the sample operation; their lookup parent also expands the UV dependency. VS varying producers are expanded to vertex inputs and CB leaves. `interpolate` below means default perspective-correct smooth raster interpolation, with weights determined by the primitive and clip position; no unavailable per-pixel values are invented.

[全景依赖树 (Bottom-Up Trace)]

=== SV_Target0 (RT0 — opaque pipeline RGB plus independently computed alpha) ===

--- 子树段 1: RT0 alpha and shared surface inputs ---

- `outputOpacity` [`SV_Target0.w`] = heightFadeWeight * heightOpacityDelta + selectedOpacity; no final saturate or discard // PS L169 [INTERMEDIATE]
  - `heightFadeWeight` [`_AlphFadeY_ON`] = material UBO scalar; snapshot `0.0` // PS L33,169 [TERMINAL] [CB]
  - `heightOpacityDelta` [`u_xlat16_9.x`] = heightGate * selectedOpacity - selectedOpacity // PS L168 [INTERMEDIATE]
    - `heightGate` [`u_xlat21`] = branch(heightAboveThreshold) ? 1.0 : 0.0; both values retained // PS L167 [BRANCH_REQUIRES_RUNTIME]
      - `heightAboveThreshold` [`u_xlatb21`] = worldPositionWS.y >= fadeHeight; inclusive comparison // PS L166 [BRANCH_REQUIRES_RUNTIME]
        - `worldPositionWS` [`vs_TEXCOORD2.xyz`] = interpolate(worldVertexPosition, rasterInterpolation, clipPosition); PS has no additional displacement // PS L46,131,166; VS L119 [INTERMEDIATE]
          - `worldVertexPosition` [`u_xlat0.xyz`] = objectToWorld[0].xyz * localPosition.x + objectToWorld[1].xyz * (localPosition.y + localHeightOffset) + objectToWorld[2].xyz * localPosition.z + objectToWorld[3].xyz, evaluated in the VS L91–95 addition order // PS L46; VS L91–95,119 [INTERMEDIATE]
            - `localPosition` [`in_POSITION0`] = vertex input from VS attribute POSITION0; only xyz are used, with implicit homogeneous w=1 // VS L72,91–95 [TERMINAL] [VERTEX]
            - `localHeightOffset` [`_VertexOffsetY`] = material UBO scalar; snapshot `0.0` // VS L49,91 [TERMINAL] [CB]
            - `objectToWorld` [`hlslcc_mtx4x4unity_ObjectToWorld`] = per-draw UBO matrix represented by four vec4 columns; numeric snapshot in Section 3 // VS L12,92–95 [TERMINAL] [CB]
          - `clipPosition` [`gl_Position`] = matrixVP[0] * worldVertexPosition.x + matrixVP[1] * worldVertexPosition.y + matrixVP[2] * worldVertexPosition.z + matrixVP[3], evaluated in VS source order // VS L96–99 [INTERMEDIATE]
            - computed node above `worldVertexPosition`.
            - `matrixVP` [`hlslcc_mtx4x4unity_MatrixVP`] = scene uniform matrix represented by four vec4 columns; snapshot in Section 3 // VS L3,96–99 [TERMINAL] [CB]
          - `rasterInterpolation` [`gl_Position`] = built-in primitive rasterization and default smooth perspective interpolation using clip w; actual geometry, coverage and barycentric weights are not supplied by these inputs // VS L99; PS L44–47 [TERMINAL] [BUILTIN]
        - `fadeHeight` [`_FadeY`] = material UBO scalar; snapshot `0.0` // PS L32,166 [TERMINAL] [CB]
    - `selectedOpacity` [`u_xlat16_2.x`] = alphaChannelOpacity + redAsOpacityWeight * (redChannelOpacity - alphaChannelOpacity); L165 overwrites the albedo's red register after RGB lighting has already consumed it // PS L163–165 [INTERMEDIATE]
      - `alphaChannelOpacity` [`u_xlat16_9.x`] = textureOpacity * materialTint.a; this is the value at L163, before L168 overwrites this register // PS L163 [INTERMEDIATE]
        - `textureOpacity` [`u_xlat16_23`] = baseTexel.a * scaledMaterialTint.a // PS L117 [INTERMEDIATE]
          - `baseTexel` [`u_xlat16_1`] = mainTextureSample evaluated at mainTextureUV; all RGBA components are retained // PS L112 [INTERMEDIATE]
            - `mainTextureSample` [`_MainTex`] = texture sample `texture(_MainTex, mainTextureUV)`; implicit derivatives/LOD; sampler location 0, resource `ResourceId::4313` per Section 4 // PS L42,112 [TERMINAL] [TEX]
            - `mainTextureUV` [`u_xlat14.xy`] = surfaceUV * baseTextureScaleOffset.xy + baseTextureScaleOffset.zw // PS L111 [INTERMEDIATE]
              - `surfaceUV` [`u_xlat0.xy`] = branch(atlasEnabled) ? atlasUV : baseUV; this UV is also used directly for emission before any later fog overwrite // PS L73–110 [INTERMEDIATE]
                - `atlasEnabled` [`u_xlatb0`] = atlasAnimationSwitch != 0.0; this condition is not `>0.5` // PS L72 [BRANCH: _SheetAnimationON != 0, CB=0, INACTIVE]
                  - `atlasAnimationSwitch` [`_SheetAnimationON`] = material UBO scalar; snapshot `0.0` // PS L38,72 [TERMINAL] [CB]
                - `baseUV` [`vs_TEXCOORD0.xy`] = interpolate(vertexUV, rasterInterpolation, clipPosition); raw UV is the ACTIVE alternative // PS L109; VS L100 [BRANCH: _SheetAnimationON == 0, CB=0, ACTIVE]
                  - `vertexUV` [`in_TEXCOORD0.xy`] = vertex input from VS attribute TEXCOORD0; passed without ST in VS // VS L73,100 [TERMINAL] [VERTEX]
                  - computed node above `rasterInterpolation` and `clipPosition`.
                - `atlasUV` [`u_xlat0.xy`] = baseUV * (atlasUpperCorner - atlasLowerCorner) + atlasLowerCorner // PS L104–105 [BRANCH: _SheetAnimationON != 0, CB=0, INACTIVE]
                  - computed node above `baseUV`.
                  - `atlasUpperCorner` [`u_xlat16_17.xy * u_xlat16_2.zw`] = (float(int(wrappedColumn)+1), float(int(invertedRow)+1)) * reciprocalSheetSize.xy; original integer shuffle at L101–102 is `(row,column)+1` followed by `.yx` // PS L92,97,101–104 [INTERMEDIATE]
                    - `wrappedColumn` [`u_xlat7.x`] = fract(wrappedFrame / signedColumnDivisor) * signedColumnDivisor // PS L88–91 [INTERMEDIATE]
                      - `wrappedFrame` [`u_xlat0.x`] = fract(animationTime / signedFrameDivisor) * signedFrameDivisor; value after L84, before row division L93 // PS L81–84 [INTERMEDIATE]
                        - `animationTime` [`u_xlat0.x`] = sceneTime.y * atlasAnimationSpeed // PS L75 [INTERMEDIATE]
                          - `sceneTime` [`_Time`] = scene uniform vector; y=`29.054134368896484` // PS L3,75 [TERMINAL] [CB]
                          - `atlasAnimationSpeed` [`_MainTexSheetAnimSpeed`] = material UBO scalar; snapshot `1.0` // PS L39,75 [TERMINAL] [CB]
                        - `signedFrameDivisor` [`u_xlat7.x`] = branch(frameProductNonnegative) ? sheetCellCount : -sheetCellCount // PS L80 [BRANCH: frameProductNonnegative, CB-derived=true but enclosing atlas inactive, INACTIVE]
                          - `frameProductNonnegative` [`u_xlatb14`] = sheetCellCount * animationTime >= -(sheetCellCount * animationTime) // PS L78–79 [INTERMEDIATE]
                            - `sheetCellCount` [`u_xlat7.x`] = trunc(atlasSheet.y * atlasSheet.x); truncation toward zero // PS L76–77 [INTERMEDIATE]
                              - `atlasSheet` [`_MainTexSheet`] = material UBO vector; snapshot `(1.0,1.0,1.0,1.0)`; only xy used // PS L40,76,85–100 [TERMINAL] [CB]
                            - computed node above `animationTime`.
                          - computed node above `sheetCellCount`; FALSE path is its negation, TRUE path is itself.
                      - `signedColumnDivisor` [`u_xlat7.x`] = branch(columnProductNonnegative) ? atlasSheet.x : -atlasSheet.x // PS L87 [BRANCH: columnProductNonnegative, CB-derived=true but enclosing atlas inactive, INACTIVE]
                        - `columnProductNonnegative` [`u_xlatb7`] = wrappedFrame * atlasSheet.x >= -(wrappedFrame * atlasSheet.x) // PS L85–86 [INTERMEDIATE]
                          - computed node above `wrappedFrame` and `atlasSheet`.
                        - computed node above `atlasSheet`; FALSE path negates x, TRUE path preserves x.
                    - `invertedRow` [`u_xlat16_1.x`] = atlasSheet.y - trunc(wrappedFrame / atlasSheet.x) - 1.0 // PS L93–96 [INTERMEDIATE]
                      - computed node above `wrappedFrame` and `atlasSheet`.
                    - `reciprocalSheetSize` [`u_xlat16_2`] = 1.0 / atlasSheet.xyxy; preserve all divisions and no zero guards // PS L98 [INTERMEDIATE]
                      - computed node above `atlasSheet`.
                  - `atlasLowerCorner` [`u_xlat16_1.xy`] = (trunc(wrappedColumn), trunc(invertedRow)) * reciprocalSheetSize.xy // PS L99–100,103 [INTERMEDIATE]
                    - computed node above `wrappedColumn`, `invertedRow` and `reciprocalSheetSize`.
              - `baseTextureScaleOffset` [`_MainTex_ST`] = material UBO vector; snapshot `(1.0,1.0,0.0,0.0)` // PS L12,111 [TERMINAL] [CB]
          - `scaledMaterialTint` [`u_xlat16_3`] = materialTint * outputIntensity; all four components, including alpha // PS L115 [INTERMEDIATE]
            - `materialTint` [`_Color`] = material UBO vector; snapshot `(1.0,1.0,1.0,1.0)` // PS L14,115,163–164 [TERMINAL] [CB]
            - `outputIntensity` [`_Intensity`] = material UBO scalar; snapshot `1.0` // PS L28,115 [TERMINAL] [CB]
        - computed node above `materialTint`.
      - `redChannelOpacity` [`u_xlat16_2.x * _Color.w`] = baseAlbedo.r * materialTint.a; the first product inside L164, before subtracting alphaChannelOpacity // PS L164 [INTERMEDIATE]
        - `baseAlbedo` [`u_xlat16_2.xyz`] = textureOrWhite * scaledMaterialTint.rgb; retain this L116 value separately from the opacity overwrite at L164–165 // PS L116 [INTERMEDIATE]
          - `textureOrWhite` [`u_xlat16_2.xyz`] = baseTexel.rgb + ignoreTextureWeight * (1.0 - baseTexel.rgb) // PS L113–114 [INTERMEDIATE]
            - computed node above `baseTexel`.
            - `ignoreTextureWeight` [`_NoMainTextureOn`] = material UBO scalar, used as unclamped interpolation weight; snapshot `0.0` // PS L29,114 [TERMINAL] [CB]
          - computed node above `scaledMaterialTint`.
        - computed node above `materialTint`.
      - `redAsOpacityWeight` [`_AlphaIsR`] = material UBO scalar, used as unclamped interpolation weight; snapshot `0.0` // PS L27,165 [TERMINAL] [CB]
  - computed node above `selectedOpacity`.

Alpha audit formula, for finite inputs: `outputOpacity = lerp(MainTex.a * _Intensity * _Color.a * _Color.a, lerp(MainTex.r,1,_NoMainTextureOn) * _Intensity * _Color.r * _Color.a, _AlphaIsR) * (1 + _AlphFadeY_ON * (step(_FadeY,worldPositionWS.y)-1))`. This equivalent formula explains the duplicate color-alpha multiplication; translation should retain the source operation order for closest rounding. Current snapshot reduces alpha to the MainTex alpha sample.

<!-- SEMANTICS: outputOpacity, heightFadeWeight, heightOpacityDelta, heightGate, heightAboveThreshold, worldPositionWS, worldVertexPosition, localPosition, localHeightOffset, objectToWorld, clipPosition, matrixVP, rasterInterpolation, fadeHeight, selectedOpacity, alphaChannelOpacity, textureOpacity, baseTexel, mainTextureSample, mainTextureUV, surfaceUV, atlasEnabled, atlasAnimationSwitch, baseUV, vertexUV, atlasUV, atlasUpperCorner, wrappedColumn, wrappedFrame, animationTime, sceneTime, atlasAnimationSpeed, signedFrameDivisor, frameProductNonnegative, sheetCellCount, atlasSheet, signedColumnDivisor, columnProductNonnegative, invertedRow, reciprocalSheetSize, atlasLowerCorner, baseTextureScaleOffset, scaledMaterialTint, materialTint, outputIntensity, redChannelOpacity, baseAlbedo, textureOrWhite, ignoreTextureWeight, redAsOpacityWeight -->

--- 子树段 2: base lighting and VS normal/SH producers ---

- `diffuseLitColor` [`u_xlat16_3.xyz`] = selectedDirectColor + blinnPhongWeight * ambientDiffuseColor; value at L128, prior to rim and emission // PS L128 [INTERMEDIATE]
  - `selectedDirectColor` [`u_xlat16_3.xyz`] = branch(lambertEnabled) ? lambertColor : sceneTintedAlbedo // PS L126 [INTERMEDIATE]
    - `lambertEnabled` [`u_xlatb5.x`] = blinnPhongWeight > 0.5 // PS L122 [BRANCH: _BlinnPhongOn > 0.5, CB=0, INACTIVE]
      - `blinnPhongWeight` [`_BlinnPhongOn`] = material UBO scalar; snapshot `0.0`; also an independent raw multiplier on SH // PS L36,122,128 [TERMINAL] [CB]
    - `lambertColor` [`u_xlat16_4.xyz`] = lambertianTerm * sceneTintedAlbedo // PS L125 [BRANCH: _BlinnPhongOn > 0.5, CB=0, INACTIVE]
      - `lambertianTerm` [`u_xlat16_24`] = saturate(dot(mainLightVector.xyz, worldNormal)); mainLightVector.w is unused // PS L123–124 [INTERMEDIATE]
        - `mainLightVector` [`_MainLightPosition`] = scene uniform vector; snapshot `(-0.2632894814014435,0.824126124382019,-0.5014926195144653,0.0)`; xyz used directly, without normalization // PS L2,123 [TERMINAL] [CB]
        - `worldNormal` [`vs_TEXCOORD1.xyz`] = interpolate(worldVertexNormal, rasterInterpolation, clipPosition); **not renormalized in PS** // PS L45,123,135; VS L108 [INTERMEDIATE]
          - `worldVertexNormal` [`u_xlat1.xyz`] = transformedVertexNormal * inversesqrt(max(dot(transformedVertexNormal,transformedVertexNormal),0.0)) // VS L104–108 [INTERMEDIATE]
            - `transformedVertexNormal` [`u_xlat1.xyz`] = (dot(localNormal,worldToObject[0].xyz), dot(localNormal,worldToObject[1].xyz), dot(localNormal,worldToObject[2].xyz)) // VS L101–103 [INTERMEDIATE]
              - `localNormal` [`in_NORMAL0.xyz`] = vertex input from VS attribute NORMAL0; shader reads xyz despite wider captured attribute format // VS L74,101–103 [TERMINAL] [VERTEX]
              - `worldToObject` [`hlslcc_mtx4x4unity_WorldToObject`] = per-draw UBO matrix; inverse-transpose normal transform through the explicit three dot products; snapshot in Section 3 // VS L13,101–103 [TERMINAL] [CB]
          - computed node above `rasterInterpolation` and `clipPosition`.
      - `sceneTintedAlbedo` [`u_xlat16_3.xyz`] = baseAlbedo * sceneLightTint; evaluated before the Lambert selection regardless of its condition // PS L121 [INTERMEDIATE]
        - computed node above `baseAlbedo`.
        - `sceneLightTint` [`u_xlat16_3.xyz`] = firstSceneLight + heroDayNightWeight * (secondSceneLight - firstSceneLight) // PS L118–120 [INTERMEDIATE]
          - `firstSceneLight` [`u_xlat16_3.xyz`] = firstLightColor.rgb * firstLightIntensity // PS L118 [INTERMEDIATE]
            - `firstLightColor` [`_LightColor1`] = scene uniform vector; snapshot `(0.9999865293502808,0.9999878406524658,0.9999954700469971,1.0)` // PS L7,118 [TERMINAL] [CB]
            - `firstLightIntensity` [`_LightIntensity1`] = scene uniform scalar; snapshot `1.003173828125` // PS L9,118 [TERMINAL] [CB]
          - `secondSceneLight` [`_LightColor2.xyz * vec3(_LightIntensity2)`] = secondLightColor.rgb * secondLightIntensity; product prior to subtraction at L119 // PS L119 [INTERMEDIATE]
            - `secondLightColor` [`_LightColor2`] = scene uniform vector; snapshot `(0.9999902248382568,0.9999929666519165,1.0,1.0)` // PS L8,119 [TERMINAL] [CB]
            - `secondLightIntensity` [`_LightIntensity2`] = scene uniform scalar; snapshot `1.0000479221343994` // PS L10,119 [TERMINAL] [CB]
          - `heroDayNightWeight` [`_HeroDayNight_ON`] = material UBO scalar; snapshot `0.0`; unclamped blend weight // PS L30,120 [TERMINAL] [CB]
    - computed node above `sceneTintedAlbedo`; FALSE branch selects it unchanged [BRANCH: _BlinnPhongOn > 0.5 is false, CB=0, ACTIVE].
  - computed node above `blinnPhongWeight`.
  - `ambientDiffuseColor` [`u_xlat16_4.xyz`] = baseAlbedo * ambientIrradiance; the L127 definition replaces the earlier Lambert scratch value // PS L127 [INTERMEDIATE]
    - computed node above `baseAlbedo`.
    - `ambientIrradiance` [`vs_TEXCOORD3.xyz`] = interpolate(vertexAmbientIrradiance,rasterInterpolation,clipPosition); no second PS clamp and no normal-dependent SH reevaluation in PS // PS L47,127; VS L146 [INTERMEDIATE]
      - `vertexAmbientIrradiance` [`vs_TEXCOORD3.xyz`] = max(shQuadraticColor + shLinearColor, 0.0) per component at each vertex // VS L145–146 [INTERMEDIATE]
        - `shQuadraticColor` [`u_xlat16_3.xyz`] = shQuadraticCrossColor + shCoefficientC.rgb * shNormalDifference // VS L140 [INTERMEDIATE]
          - `shQuadraticCrossColor` [`u_xlat16_4.xyz`] = (dot(shCoefficientBr,shNormalProducts),dot(shCoefficientBg,shNormalProducts),dot(shCoefficientBb,shNormalProducts)) // VS L137–139 [INTERMEDIATE]
            - `shNormalProducts` [`u_xlat16_0`] = worldVertexNormal.yzzx * worldVertexNormal.xyzz = (Nx*Ny,Ny*Nz,Nz*Nz,Nx*Nz) // VS L136 [INTERMEDIATE]
              - computed node above `worldVertexNormal`.
            - `shCoefficientBr` [`unity_SHBr`] = per-draw UBO vector; snapshot `(0.0,0.0,-1.6540288925170898e-06,0.0)` // VS L33,137 [TERMINAL] [CB]
            - `shCoefficientBg` [`unity_SHBg`] = per-draw UBO vector; snapshot `(0.0,0.0,-1.385807991027832e-06,0.0)` // VS L34,138 [TERMINAL] [CB]
            - `shCoefficientBb` [`unity_SHBb`] = per-draw UBO vector; snapshot `(0.0,0.0,-9.611248970031738e-07,0.0)` // VS L35,139 [TERMINAL] [CB]
          - `shCoefficientC` [`unity_SHC`] = per-draw UBO vector; snapshot `(-1.5497207641601562e-06,-1.2814998626708984e-06,-8.717179298400879e-07,1.0)`; w unused // VS L36,140 [TERMINAL] [CB]
          - `shNormalDifference` [`u_xlat16_3.x`] = worldVertexNormal.x * worldVertexNormal.x - worldVertexNormal.y * worldVertexNormal.y // VS L134–135 [INTERMEDIATE]
            - computed node above `worldVertexNormal`.
        - `shLinearColor` [`u_xlat16_4.xyz`] = (dot(shCoefficientAr,float4(worldVertexNormal,1)),dot(shCoefficientAg,float4(worldVertexNormal,1)),dot(shCoefficientAb,float4(worldVertexNormal,1))) // VS L141–144 [INTERMEDIATE]
          - computed node above `worldVertexNormal`.
          - `shCoefficientAr` [`unity_SHAr`] = per-draw UBO vector; snapshot `(0.0,5.424022674560547e-06,0.0,0.9999691843986511)` // VS L30,142 [TERMINAL] [CB]
          - `shCoefficientAg` [`unity_SHAg`] = per-draw UBO vector; snapshot `(0.0,4.470348358154297e-06,0.0,0.9999756813049316)` // VS L31,143 [TERMINAL] [CB]
          - `shCoefficientAb` [`unity_SHAb`] = per-draw UBO vector; snapshot `(0.0,3.0100345611572266e-06,0.0,0.9999861121177673)` // VS L32,144 [TERMINAL] [CB]
      - computed node above `rasterInterpolation` and `clipPosition`.

Current finite-value snapshot reduces this segment to `baseAlbedo * _LightColor1.rgb * _LightIntensity1`. The directional vector and SH coefficients remain traced because their alternative behavior is part of the shader, although neither contributes with `_BlinnPhongOn=0`.

<!-- SEMANTICS: diffuseLitColor, selectedDirectColor, lambertEnabled, blinnPhongWeight, lambertColor, lambertianTerm, mainLightVector, worldNormal, worldVertexNormal, transformedVertexNormal, localNormal, worldToObject, sceneTintedAlbedo, sceneLightTint, firstSceneLight, firstLightColor, firstLightIntensity, secondSceneLight, secondLightColor, secondLightIntensity, heroDayNightWeight, ambientDiffuseColor, ambientIrradiance, vertexAmbientIrradiance, shQuadraticColor, shQuadraticCrossColor, shNormalProducts, shCoefficientBr, shCoefficientBg, shCoefficientBb, shCoefficientC, shNormalDifference, shLinearColor, shCoefficientAr, shCoefficientAg, shCoefficientAb -->

--- 子树段 3: optional independent rim addition ---

- `rimmedColor` [`u_xlat16_3.xyz`] = branch(rimEnabled) ? diffuseLitColor + rimColor : diffuseLitColor; branch join after L147 // PS L129–147 [INTERMEDIATE]
  - computed node above `diffuseLitColor`; FALSE path preserves it [BRANCH: _Fresnel_ON > 0.5 is false, CB=0, ACTIVE].
  - `rimEnabled` [`u_xlatb5.y`] = rimSwitch > 0.5 // PS L122,129 [BRANCH: _Fresnel_ON > 0.5, CB=0, INACTIVE]
    - `rimSwitch` [`_Fresnel_ON`] = material UBO scalar; snapshot `0.0` // PS L37,122 [TERMINAL] [CB]
  - `rimColor` [`u_xlat16_4.xyz`] = edgeRimTint.rgb * edgeRimWeight + broadRimTint.rgb * broadRimWeight; independent of albedo and light color // PS L144–145 [BRANCH: _Fresnel_ON > 0.5, CB=0, INACTIVE]
    - `edgeRimWeight` [`u_xlat16_9.x`] = rimCubic * edgeRimScale * rimIntensity // PS L142–143 [INTERMEDIATE]
      - `rimCubic` [`u_xlat16_9.x`] = rimBase * rimSquared // PS L139 [INTERMEDIATE]
        - `rimBase` [`u_xlat16_9.x`] = 1.0 - saturate(dot(worldNormal,viewDirectionWS)) // PS L135–137 [INTERMEDIATE]
          - computed node above `worldNormal`.
          - `viewDirectionWS` [`u_xlat5.xyw`] = surfaceToCamera * inversesqrt(dot(surfaceToCamera,surfaceToCamera)); `.xyw` stores the three spatial components, not a homogeneous coordinate // PS L132–134 [INTERMEDIATE]
            - `surfaceToCamera` [`u_xlat5.xyw`] = cameraPositionWS - worldPositionWS; vector points from the surface toward the camera // PS L131 [INTERMEDIATE]
              - `cameraPositionWS` [`_WorldSpaceCameraPos`] = scene uniform vector; snapshot `(36.02374267578125,15.999999046325684,-8.70000171661377)`; shared by VS fog // PS L4,131; VS L2,109,118 [TERMINAL] [CB]
              - computed node above `worldPositionWS`.
        - `rimSquared` [`u_xlat16_16`] = rimBase * rimBase; value at L138 before the quintic overwrite // PS L138 [INTERMEDIATE]
          - computed node above `rimBase`.
      - `edgeRimScale` [`_Fresnel_Scale_Edge`] = material UBO scalar; snapshot `0.0` // PS L34,142 [TERMINAL] [CB]
      - `rimIntensity` [`_Fresnel_Intensity`] = material UBO scalar; snapshot `0.0`; multiplies both rim weights after bias is added // PS L25,143 [TERMINAL] [CB]
    - `broadRimWeight` [`u_xlat16_9.y`] = (broadRimScale * rimQuintic + rimBias) * rimIntensity; no clamp // PS L141,143 [INTERMEDIATE]
      - `rimQuintic` [`u_xlat16_16`] = rimCubic * rimSquared; retains the r^2 * r^3 multiplication chain // PS L140 [INTERMEDIATE]
        - computed node above `rimCubic` and `rimSquared`.
      - `broadRimScale` [`_Fresnel_Scale`] = material UBO scalar; snapshot `0.0` // PS L24,141 [TERMINAL] [CB]
      - `rimBias` [`_Fresnel_Bisa`] = material UBO scalar; snapshot `0.0`; preserve original misspelled lookup key // PS L23,141 [TERMINAL] [CB]
      - computed node above `rimIntensity`.
    - `edgeRimTint` [`_Fresnel_Color_Edge`] = material UBO vector; snapshot `(0.0,0.0,0.0,0.0)`; only rgb used // PS L16,144 [TERMINAL] [CB]
    - `broadRimTint` [`_Fresnel_Color`] = material UBO vector; snapshot `(1.0,1.0,1.0,1.0)`; only rgb used // PS L15,145 [TERMINAL] [CB]

<!-- SEMANTICS: rimmedColor, rimEnabled, rimSwitch, rimColor, edgeRimWeight, rimCubic, rimBase, viewDirectionWS, surfaceToCamera, cameraPositionWS, rimSquared, edgeRimScale, rimIntensity, broadRimWeight, rimQuintic, broadRimScale, rimBias, edgeRimTint, broadRimTint -->

--- 子树段 4: optional emission before fog ---

- `preFogColor` [`u_xlat16_3.xyz`] = branch(emissionEnabled) ? rimmedColor + buildingEmission : rimmedColor; after this join all lighting additions are complete // PS L148–157 [INTERMEDIATE]
  - computed node above `rimmedColor`; FALSE path preserves it [BRANCH: _EMISSIONMAPON_ON > 0.5 is false, CB=0, ACTIVE].
  - `emissionEnabled` [`u_xlatb5.z`] = emissionSwitch > 0.5 // PS L122,148 [BRANCH: _EMISSIONMAPON_ON > 0.5, CB=0, INACTIVE]
    - `emissionSwitch` [`_EMISSIONMAPON_ON`] = material UBO scalar; snapshot `0.0` // PS L35,122 [TERMINAL] [CB]
  - `buildingEmission` [`u_xlat16_4.xyz`] = constantEmission + buildingEmissionWeight * emissionFadeDelta // PS L155 [BRANCH: _EMISSIONMAPON_ON > 0.5, CB=0, INACTIVE]
    - `constantEmission` [`u_xlat16_6.xyz`] = tintedEmission * emissionIntensity // PS L152 [INTERMEDIATE]
      - `tintedEmission` [`u_xlat16_4.xyz`] = emissionTexel * emissionTint.rgb; L151 value before reusing the same register for deltas and result // PS L151 [INTERMEDIATE]
        - `emissionTexel` [`u_xlat10_0.xyz`] = emissionTextureSample evaluated at surfaceUV; MainTex ST is deliberately absent here // PS L150 [INTERMEDIATE]
          - `emissionTextureSample` [`_EmissionMap`] = texture sample `texture(_EmissionMap, surfaceUV).xyz`; implicit derivatives/LOD; sampler location 1, resource `ResourceId::7407` per Section 4 // PS L43,150 [TERMINAL] [TEX]
          - computed node above `surfaceUV`.
        - `emissionTint` [`_EmissionColor`] = material UBO vector; snapshot `(0.0,0.0,0.0,1.0)`; only rgb used // PS L13,151 [TERMINAL] [CB]
      - `emissionIntensity` [`_EmissionIntensity`] = material UBO scalar; snapshot `1.0` // PS L22,152–153 [TERMINAL] [CB]
    - `buildingEmissionWeight` [`_EMISSIONMAPON_BUILDING_ON`] = material UBO scalar; snapshot `1.0`; continuous, unclamped blend weight // PS L31,155 [TERMINAL] [CB]
    - `emissionFadeDelta` [`u_xlat16_4.xyz`] = tintedEmission * timelineEmissionIntensity - constantEmission; value at L154 // PS L154 [INTERMEDIATE]
      - computed node above `tintedEmission` and `constantEmission`.
      - `timelineEmissionIntensity` [`u_xlat16_9.x`] = timeline * (-emissionIntensity) + emissionIntensity // PS L153 [INTERMEDIATE]
        - `timeline` [`_Timeline`] = scene uniform scalar; snapshot `1.0` // PS L6,153 [TERMINAL] [CB]
        - computed node above `emissionIntensity`.

For finite values the building blend is algebraically `emissionTexel * _EmissionColor.rgb * _EmissionIntensity * (1 - _EMISSIONMAPON_BUILDING_ON * _Timeline)`. Keep L151–155 operation order for pixel matching; do not replace the blend weight with a boolean. No emission contribution affects alpha.

<!-- SEMANTICS: preFogColor, emissionEnabled, emissionSwitch, buildingEmission, constantEmission, tintedEmission, emissionTexel, emissionTextureSample, emissionTint, emissionIntensity, buildingEmissionWeight, emissionFadeDelta, timelineEmissionIntensity, timeline -->

--- 子树段 5: VS height-distance fog and final RT0 RGB ---

- `outputColor` [`SV_Target0.xyz`] = foggedColor; assigned independently of outputOpacity, with no premultiplication // PS L170 [INTERMEDIATE]
  - `foggedColor` [`u_xlat0.xyz`] = preFogColor + fogBlendWeight * fogColorDelta; L162 overwrites all former UV/fog-scalar components simultaneously // PS L162 [INTERMEDIATE]
    - computed node above `preFogColor`.
    - `fogColorDelta` [`u_xlat7.xyz`] = fogTint.rgb - preFogColor; value at L161, unrelated to the earlier atlas scratch scalar // PS L161 [INTERMEDIATE]
      - `fogTint` [`_FogColor`] = scene uniform vector; snapshot `(0.6901960968971252,0.5254902243614197,0.3333333432674408,0.6509804129600525)`; alpha is a fog blend multiplier, not output alpha // PS L5,160–161 [TERMINAL] [CB]
      - computed node above `preFogColor`.
    - `fogBlendWeight` [`u_xlat0.x`] = saturate(interpolatedFog) * fogTint.a; no clamp after multiplication by fog alpha // PS L158–160 [INTERMEDIATE]
      - `interpolatedFog` [`vs_TEXCOORD2.w`] = interpolate(vertexFogFactor,rasterInterpolation,clipPosition); fog is integrated and smoothed in VS, not recomputed per pixel // PS L46,158; VS L133 [INTERMEDIATE]
        - `vertexFogFactor` [`vs_TEXCOORD2.w`] = fogRampSquared * fogSmoothPolynomial // VS L133 [INTERMEDIATE]
          - `fogRampSquared` [`u_xlat0.x`] = fogRamp * fogRamp; after L132, distinct from the unclamped/pre-square x values // VS L132 [INTERMEDIATE]
            - `fogRamp` [`u_xlat0.x`] = saturate(fogRangeReciprocal * (heightIntegratedDensity * distanceFogRamp - fogStart)); value at L130 // VS L126,129–130 [INTERMEDIATE]
              - `fogRangeReciprocal` [`u_xlat5`] = 1.0 / (fogEnd - fogStart) // VS L127–128 [INTERMEDIATE]
                - `fogEnd` [`_FogEnd`] = scene uniform scalar; snapshot `1.0` // VS L5,127 [TERMINAL] [CB]
                - `fogStart` [`_FogStart`] = scene uniform scalar; snapshot `0.05400000140070915` // VS L4,126–127 [TERMINAL] [CB]
              - `heightIntegratedDensity` [`u_xlat15`] = heightScaledDensity * heightIntegralQuotient; retain this unusual two-factor chain exactly // VS L117 [INTERMEDIATE]
                - `heightScaledDensity` [`u_xlat2.x`] = heightExponential * fogGlobalDensity // VS L115 [INTERMEDIATE]
                  - `heightExponential` [`u_xlat2.x`] = exp2(-heightExponent), equivalently `pow(2.0,-heightExponent)` for the real-valued formula, not `exp(-heightExponent)` // VS L113 [INTERMEDIATE]
                    - `heightExponent` [`u_xlat15`] = (worldVertexPosition.y - cameraPositionWS.y - fogHeight) * heightFalloffScale // VS L109–112 [INTERMEDIATE]
                      - computed node above `worldVertexPosition` and `cameraPositionWS`.
                      - `fogHeight` [`_FogHeight`] = scene uniform scalar; snapshot `5.0` // VS L8,110 [TERMINAL] [CB]
                      - `heightFalloffScale` [`u_xlat2.x`] = fogFalloff * 0.0099999998 // VS L111 [INTERMEDIATE]
                        - `fogFalloff` [`_FogFallOff`] = scene uniform scalar; snapshot `3.0` // VS L7,111 [TERMINAL] [CB]
                  - `fogGlobalDensity` [`_FogGlobalDensity`] = scene uniform scalar; snapshot `0.09000000357627869` // VS L6,115 [TERMINAL] [CB]
                - `heightIntegralQuotient` [`u_xlat15`] = oneMinusHeightExponential / heightExponent; no small-height branch or epsilon // VS L116 [INTERMEDIATE]
                  - `oneMinusHeightExponential` [`u_xlat7`] = 1.0 - heightExponential // VS L114 [INTERMEDIATE]
                    - computed node above `heightExponential`.
                  - computed node above `heightExponent`.
              - `distanceFogRamp` [`u_xlat0.x`] = max((cameraDistance - fogStartDistance) / fogGradientDistance,0.0); no upper clamp here // VS L123–125 [INTERMEDIATE]
                - `cameraDistance` [`u_xlat0.x`] = sqrt(max(dot(vertexToCamera,vertexToCamera),6.1035156e-05)) // VS L120–122 [INTERMEDIATE]
                  - `vertexToCamera` [`u_xlat2.xyz`] = cameraPositionWS - worldVertexPosition; differs from the interpolated PS view vector in segment 3 // VS L118 [INTERMEDIATE]
                    - computed node above `cameraPositionWS` and `worldVertexPosition`.
                - `fogStartDistance` [`_FogStartDis`] = scene uniform scalar; snapshot `25.709999084472656` // VS L9,123 [TERMINAL] [CB]
                - `fogGradientDistance` [`_FogGradientDis`] = scene uniform scalar; snapshot `50.0` // VS L10,124 [TERMINAL] [CB]
              - computed node above `fogStart`.
          - `fogSmoothPolynomial` [`u_xlat5`] = -2.0 * fogRamp + 3.0; computed from unsquared ramp before L132 overwrites it // VS L131 [INTERMEDIATE]
            - computed node above `fogRamp`.
        - computed node above `rasterInterpolation` and `clipPosition`.
      - computed node above `fogTint`.

Closed-form audit for finite nonzero denominators: let `h=(worldVertexPosition.y-cameraY-_FogHeight)*(_FogFallOff*0.0099999998)`, `e=exp2(-h)`, `d=max((sqrt(max(lengthSquared(camera-worldVertexPosition),6.1035156e-05))-_FogStartDis)/_FogGradientDis,0)`, `s=saturate(((e*_FogGlobalDensity)*((1-e)/h)*d-_FogStart)*(1/(_FogEnd-_FogStart)))`. VS writes `s*s*(-2*s+3)`, PS interpolates and clamps that value, then multiplies by `_FogColor.a`. This is the actual source's extra exponential factor; replacing it with a conventional height-fog integral changes the result.

For the current snapshot, finite RGB reduces to `lerp(MainTex.rgb * _LightColor1.rgb * _LightIntensity1, _FogColor.rgb, saturate(interpolatedFog) * _FogColor.a)`. The original geometry, sampled texels, sampler state and interpolation are still required to evaluate a pixel. No claim of pixel validation is made in this analysis phase.

<!-- SEMANTICS: outputColor, foggedColor, fogColorDelta, fogTint, fogBlendWeight, interpolatedFog, vertexFogFactor, fogRampSquared, fogRamp, fogRangeReciprocal, fogEnd, fogStart, heightIntegratedDensity, heightScaledDensity, heightExponential, heightExponent, fogHeight, heightFalloffScale, fogFalloff, fogGlobalDensity, heightIntegralQuotient, oneMinusHeightExponential, distanceFogRamp, cameraDistance, vertexToCamera, fogStartDistance, fogGradientDistance, fogSmoothPolynomial -->


### 8.2 Dependency inventory, generated from the completed tree

[依赖变量盘点池 - Post-Trace Summary]

中间节点（91）: `outputOpacity` [`SV_Target0.w`], `heightOpacityDelta` [`u_xlat16_9.x`], `heightGate` [`u_xlat21`], `heightAboveThreshold` [`u_xlatb21`], `worldPositionWS` [`vs_TEXCOORD2.xyz`], `worldVertexPosition` [`u_xlat0.xyz`], `clipPosition` [`gl_Position`], `selectedOpacity` [`u_xlat16_2.x`], `alphaChannelOpacity` [`u_xlat16_9.x`], `textureOpacity` [`u_xlat16_23`], `baseTexel` [`u_xlat16_1`], `mainTextureUV` [`u_xlat14.xy`], `surfaceUV` [`u_xlat0.xy`], `atlasEnabled` [`u_xlatb0`], `baseUV` [`vs_TEXCOORD0.xy`], `atlasUV` [`u_xlat0.xy`], `atlasUpperCorner` [`u_xlat16_17.xy * u_xlat16_2.zw`], `wrappedColumn` [`u_xlat7.x`], `wrappedFrame` [`u_xlat0.x`], `animationTime` [`u_xlat0.x`], `signedFrameDivisor` [`u_xlat7.x`], `frameProductNonnegative` [`u_xlatb14`], `sheetCellCount` [`u_xlat7.x`], `signedColumnDivisor` [`u_xlat7.x`], `columnProductNonnegative` [`u_xlatb7`], `invertedRow` [`u_xlat16_1.x`], `reciprocalSheetSize` [`u_xlat16_2`], `atlasLowerCorner` [`u_xlat16_1.xy`], `scaledMaterialTint` [`u_xlat16_3`], `redChannelOpacity` [`u_xlat16_2.x * _Color.w`], `baseAlbedo` [`u_xlat16_2.xyz`], `textureOrWhite` [`u_xlat16_2.xyz`], `diffuseLitColor` [`u_xlat16_3.xyz`], `selectedDirectColor` [`u_xlat16_3.xyz`], `lambertEnabled` [`u_xlatb5.x`], `lambertColor` [`u_xlat16_4.xyz`], `lambertianTerm` [`u_xlat16_24`], `worldNormal` [`vs_TEXCOORD1.xyz`], `worldVertexNormal` [`u_xlat1.xyz`], `transformedVertexNormal` [`u_xlat1.xyz`], `sceneTintedAlbedo` [`u_xlat16_3.xyz`], `sceneLightTint` [`u_xlat16_3.xyz`], `firstSceneLight` [`u_xlat16_3.xyz`], `secondSceneLight` [`_LightColor2.xyz * vec3(_LightIntensity2)`], `ambientDiffuseColor` [`u_xlat16_4.xyz`], `ambientIrradiance` [`vs_TEXCOORD3.xyz`], `vertexAmbientIrradiance` [`vs_TEXCOORD3.xyz`], `shQuadraticColor` [`u_xlat16_3.xyz`], `shQuadraticCrossColor` [`u_xlat16_4.xyz`], `shNormalProducts` [`u_xlat16_0`], `shNormalDifference` [`u_xlat16_3.x`], `shLinearColor` [`u_xlat16_4.xyz`], `rimmedColor` [`u_xlat16_3.xyz`], `rimEnabled` [`u_xlatb5.y`], `rimColor` [`u_xlat16_4.xyz`], `edgeRimWeight` [`u_xlat16_9.x`], `rimCubic` [`u_xlat16_9.x`], `rimBase` [`u_xlat16_9.x`], `viewDirectionWS` [`u_xlat5.xyw`], `surfaceToCamera` [`u_xlat5.xyw`], `rimSquared` [`u_xlat16_16`], `broadRimWeight` [`u_xlat16_9.y`], `rimQuintic` [`u_xlat16_16`], `preFogColor` [`u_xlat16_3.xyz`], `emissionEnabled` [`u_xlatb5.z`], `buildingEmission` [`u_xlat16_4.xyz`], `constantEmission` [`u_xlat16_6.xyz`], `tintedEmission` [`u_xlat16_4.xyz`], `emissionTexel` [`u_xlat10_0.xyz`], `emissionFadeDelta` [`u_xlat16_4.xyz`], `timelineEmissionIntensity` [`u_xlat16_9.x`], `outputColor` [`SV_Target0.xyz`], `foggedColor` [`u_xlat0.xyz`], `fogColorDelta` [`u_xlat7.xyz`], `fogBlendWeight` [`u_xlat0.x`], `interpolatedFog` [`vs_TEXCOORD2.w`], `vertexFogFactor` [`vs_TEXCOORD2.w`], `fogRampSquared` [`u_xlat0.x`], `fogRamp` [`u_xlat0.x`], `fogRangeReciprocal` [`u_xlat5`], `heightIntegratedDensity` [`u_xlat15`], `heightScaledDensity` [`u_xlat2.x`], `heightExponential` [`u_xlat2.x`], `heightExponent` [`u_xlat15`], `heightFalloffScale` [`u_xlat2.x`], `heightIntegralQuotient` [`u_xlat15`], `oneMinusHeightExponential` [`u_xlat7`], `distanceFogRamp` [`u_xlat0.x`], `cameraDistance` [`u_xlat0.x`], `vertexToCamera` [`u_xlat2.xyz`], `fogSmoothPolynomial` [`u_xlat5`].

终端节点（56）: `heightFadeWeight` [`_AlphFadeY_ON`] [CB], `localPosition` [`in_POSITION0`] [VERTEX], `localHeightOffset` [`_VertexOffsetY`] [CB], `objectToWorld` [`hlslcc_mtx4x4unity_ObjectToWorld`] [CB], `matrixVP` [`hlslcc_mtx4x4unity_MatrixVP`] [CB], `rasterInterpolation` [`gl_Position`] [BUILTIN], `fadeHeight` [`_FadeY`] [CB], `mainTextureSample` [`_MainTex`] [TEX], `atlasAnimationSwitch` [`_SheetAnimationON`] [CB], `vertexUV` [`in_TEXCOORD0.xy`] [VERTEX], `sceneTime` [`_Time`] [CB], `atlasAnimationSpeed` [`_MainTexSheetAnimSpeed`] [CB], `atlasSheet` [`_MainTexSheet`] [CB], `baseTextureScaleOffset` [`_MainTex_ST`] [CB], `materialTint` [`_Color`] [CB], `outputIntensity` [`_Intensity`] [CB], `ignoreTextureWeight` [`_NoMainTextureOn`] [CB], `redAsOpacityWeight` [`_AlphaIsR`] [CB], `blinnPhongWeight` [`_BlinnPhongOn`] [CB], `mainLightVector` [`_MainLightPosition`] [CB], `localNormal` [`in_NORMAL0.xyz`] [VERTEX], `worldToObject` [`hlslcc_mtx4x4unity_WorldToObject`] [CB], `firstLightColor` [`_LightColor1`] [CB], `firstLightIntensity` [`_LightIntensity1`] [CB], `secondLightColor` [`_LightColor2`] [CB], `secondLightIntensity` [`_LightIntensity2`] [CB], `heroDayNightWeight` [`_HeroDayNight_ON`] [CB], `shCoefficientBr` [`unity_SHBr`] [CB], `shCoefficientBg` [`unity_SHBg`] [CB], `shCoefficientBb` [`unity_SHBb`] [CB], `shCoefficientC` [`unity_SHC`] [CB], `shCoefficientAr` [`unity_SHAr`] [CB], `shCoefficientAg` [`unity_SHAg`] [CB], `shCoefficientAb` [`unity_SHAb`] [CB], `rimSwitch` [`_Fresnel_ON`] [CB], `cameraPositionWS` [`_WorldSpaceCameraPos`] [CB], `edgeRimScale` [`_Fresnel_Scale_Edge`] [CB], `rimIntensity` [`_Fresnel_Intensity`] [CB], `broadRimScale` [`_Fresnel_Scale`] [CB], `rimBias` [`_Fresnel_Bisa`] [CB], `edgeRimTint` [`_Fresnel_Color_Edge`] [CB], `broadRimTint` [`_Fresnel_Color`] [CB], `emissionSwitch` [`_EMISSIONMAPON_ON`] [CB], `emissionTextureSample` [`_EmissionMap`] [TEX], `emissionTint` [`_EmissionColor`] [CB], `emissionIntensity` [`_EmissionIntensity`] [CB], `buildingEmissionWeight` [`_EMISSIONMAPON_BUILDING_ON`] [CB], `timeline` [`_Timeline`] [CB], `fogTint` [`_FogColor`] [CB], `fogEnd` [`_FogEnd`] [CB], `fogStart` [`_FogStart`] [CB], `fogHeight` [`_FogHeight`] [CB], `fogFalloff` [`_FogFallOff`] [CB], `fogGlobalDensity` [`_FogGlobalDensity`] [CB], `fogStartDistance` [`_FogStartDis`] [CB], `fogGradientDistance` [`_FogGradientDis`] [CB].

[盘点总数]: 147 unique semantic nodes = 91 intermediate nodes + 56 terminal nodes. Every pool entry is extracted from one actual tree definition; computed-node references are not additional nodes. Varying producers have been expanded to VS inputs, uniforms and rasterization, so there are no remaining varying-only leaves.


## 9. Translation Notes

### 9.1 Must Preserve Exactly

| Source | Category | Required translation behavior |
|---|---|---|
| VS L91–99 | Transform order | Offset **object-space Y** before object-to-world. Source explicitly uses homogeneous position w=1 regardless of input position.w. Preserve matrix column conventions and match the captured VP transform; shader contains no extra OpenGL-to-D3D depth remap itself. |
| VS L101–108; PS L123,135 | Normal handling | Use the inverse-transpose dot products and VS inverse-square-root normalization, with `max(lengthSquared,0.0)` only. Do not add an epsilon or renormalize the interpolated PS normal. |
| VS L109–117 | Custom height integration | Preserve `h=(worldY-cameraY-FogHeight)*(FogFallOff*0.0099999998)`, `e=exp2(-h)`, and `(e*FogGlobalDensity)*((1-e)/h)`. The leading e is present. There is no small-h limiting case in the source. `exp2(x)=pow(2.0,x)` is the relevant identity; natural exponential requires a base conversion. |
| VS L120–133; PS L158–160 | Nonlinear fog and constants | Preserve `6.1035156e-05`, square-root-before-distance-offset, distance lower clamp, reciprocal of `(FogEnd-FogStart)`, and clamped cubic `s*s*(-2*s+3)`. Evaluate this cubic per vertex, interpolate it, clamp again in PS, then multiply by FogColor.a without a second clamp. |
| VS L134–146 | SH polynomial | Preserve all A/B/C coefficients from Section 3, basis `(Nx*Ny,Ny*Nz,Nz*Nz,Nx*Nz)` and `(Nx*Nx-Ny*Ny)`, source addition order, and **per-vertex** nonnegative clamp. A URP per-pixel SH helper can change both interpolation and clamping. |
| PS L72,122 | Different switch conventions | Atlas switch uses `!=0.0`; Lambert, rim and emission use `>0.5`. Do not unify all controls into one boolean convention. |
| PS L75–105 | Signed atlas indexing | Keep both signed-divisor selections, `trunc` versus `fract`, integer casts, row inversion, `+1` integer corner calculation and `.yx` reorder. `fract(x)=x-floor(x)`, whereas integer conversion and truncation use toward-zero behavior. Replacing the sequence with `%`, a floor-based frame index, or unsigned modulo changes negative-time/speed behavior. Keep divisions and overflow/undefined domains unchanged. |
| PS L98–111,150 | Texture lookup coordinates | Build atlas corner interpolation before MainTex ST. MainTex samples `surfaceUV*ST.xy+ST.zw`; emission samples `surfaceUV`. The distinction is hidden by the captured identity ST but matters for other materials. Both samples use implicit derivatives/LOD, and no explicit bias or LOD exists. |
| PS L113–120 | Unclamped arithmetic interpolation | Preserve raw `_NoMainTextureOn` and `_HeroDayNight_ON` weights. Preserve tint and intensity multiplication on all RGBA components at L115. These uniforms are not branches and may extrapolate. |
| PS L122–128 | Custom lighting composition | The direct branch chooses either sceneTintedAlbedo or its clamped NdotL product. SH is separately multiplied by the **raw** `_BlinnPhongOn` scalar and added, including when its value is <=0.5. Despite its name this switch does not enable a Blinn–Phong specular calculation. |
| PS L135–145 | Custom Fresnel/rim polynomial | Preserve `r=1-saturate(dot(N,V))`, `r2=r*r`, `r3=r*r2`, `r5=r3*r2`; edge weight=`r3*ScaleEdge*Intensity`, broad weight=`(Scale*r5+Bisa)*Intensity`. Two different RGB colors are summed. Do not substitute a single Fresnel helper, exponent parameter, or material/albedo modulation. |
| PS L151–155 | Custom emission blend | Preserve the two emission intensities and delta blend. The readable factor `(1-buildingWeight*Timeline)` is algebraically equivalent for finite values, but refactoring multiplication order may alter float rounding. Color/weight alpha channels are unused here. |
| PS L161–162 | RGB composition | All lighting, rim and emission precede fog. Fog is `color+weight*(fogRGB-color)`, independent of output alpha. No output saturate, gamma transform or tone mapper occurs in this shader. |
| PS L117,163–165 | Nonstandard opacity | The texture-alpha path multiplies `_Color.a` **twice** in total. The red path uses already tinted/intensity-scaled albedo.r and one `_Color.a`. `_AlphaIsR` is an unclamped lerp weight. Neither path uses fog, emission, rim or scene-light RGB to calculate alpha. |
| PS L166–170 | Height gate/output state | Gate is inclusive `worldY>=FadeY`. Fade weight interpolates to zero below the threshold without discard. `_CutOff` has no executable use. Output RGB is not premultiplied; Section 2 says blending is disabled, depth writes enabled and comparison LessEqual. |

### 9.2 Allowed Stubs

- None for RT0: every active and inactive source path has a complete formula and terminal dependencies in Section 8. Missing runtime values are data acquisition/validation gaps, not permission to replace the math with constants or to drop inactive functionality.
- VS L147–148 write constant zero to `vs_TEXCOORD5/6`, which PS does not declare or consume. Omitting these unused interface outputs in the reconstructed shader does not remove an RT0 dependency. The unused declared uniforms listed in Section 7 need no invented implementation.

### 9.3 Rendering Technique Notes

- Forward material shader with base texture, tint/intensity, a continuous blend between two scene colors, optional Lambert diffuse plus vertex SH, optional independent cubic/quintic rim, optional texture emission, and custom vertex height-distance fog.
- No evidence of physically based metallic/roughness shading, Blinn–Phong specular, shadow attenuation, normal mapping, matcap, parallax, alpha testing, additional-light loops, motion deformation or GPU skinning in this variant. Names such as `_ShadowColor`, `_BlinnPhongOn` and `_GPUSKin_TextureSize` do not imply executable features beyond the traced statements.
- Current frame uses the raw UV path, first scene-light tint, no Lambert/SH addition, no rim and no emission. Its finite alpha is MainTex.a. Fog remains active mathematically; its actual amount is vertex-dependent and cannot be inferred numerically without mesh data.

### 9.4 Special Warnings

- Resolve reused registers by component and control-flow join. `u_xlat16_3.w` from L115 remains tint/intensity alpha while xyz are repurposed at L118 onward. `u_xlat16_2.x` at L116 is albedo red; L164 overwrites it with an opacity delta. `u_xlat16_9.x` successively holds rim, emission-intensity, alpha-channel-opacity and height-opacity-delta values. `u_xlat0.xy` holds sample UV through L150, but x becomes fog weight at L158–160 and xyz become RGB at L162. `u_xlat16_3.xyz` after L157 selects the executed path, not necessarily the lexically latest assignment at L156.
- Source prefixes `u_xlat16_` and `u_xlat10_` are names, not GLSL precision declarations. This source declares ordinary `vec*`/`float`; preserve float precision initially instead of assuming HLSL `half` from the prefix.
- Avoid protective modifications during faithful reconstruction: normal length zero, view-vector length zero, atlas zero divisors, integer conversion overflow, `_FogGradientDis=0`, `_FogEnd=_FogStart`, and height exponent zero have no source safeguards. At `h=0` the fog quotient evaluates a 0/0 chain; a smooth mathematical limit would be a deliberate behavior change. Validate whether captured geometry reaches problematic domains before changing them.
- The reconstruction must account for actual OpenGL texture addressing/filtering/mips, texture format and sRGB decode, render-target color space, viewport and coordinate conventions. No manual gamma conversion or texture Y flip is present in the shader. Do not add either without API/resource evidence.
- `layout(location=0/1)` on a GLSL sampler establishes a **uniform location**, not its texture-unit binding. Section 4's resource associations are used here as the supplied mapping contract. These three inputs do not independently show sampler uniform integer values or bound texture units, so verify those in the acquisition/validation phase before treating the resource mapping as proven by the layout text alone.
- `_MainLightPosition.xyz` is used directly in a dot product; w is unused. Its snapshot w=0 is consistent with a directional vector, but there is no light-type branch or loop. There is no permission to substitute URP's current main-light color for the two explicit captured light colors.
- Only RT0 is tracked. Pipeline blend-factor fields in Section 2 are inactive because blend enable is false. Alpha may still matter to later consumers of the target, but it does not cause blending or clipping in this draw.

### 9.5 API Syntax Reference

- Source API: desktop OpenGL GLSL `#version 450`; `layout(std140,binding=0/1)` uniform blocks, standalone scene uniforms, combined `sampler2D` values, implicit `texture()` sampling, VS `gl_Position`, PS `layout(location=0) out vec4 SV_Target0`.
- Readable HLSL equivalents: `vecN -> floatN`, `ivecN -> intN`, `bvecN -> boolN`, `inversesqrt -> rsqrt`, `fract -> frac`, `clamp(x,0,1) -> saturate(x)`, and `texture(sampler2D,uv) -> SAMPLE_TEXTURE2D(texture,sampler,uv)` with matching texture/sampler binding. Preserve `trunc`, dot products, comparisons and source scalar-versus-vector behavior.
- GLSL vector `!=` at L72 produces a scalar inequality result for the entire vector; all four components compare the same switch, so the exact scalar equivalent is `_SheetAnimationON != 0.0`. `lessThan` at L122 is component-wise and its xyz encode the three independent `>0.5` tests. GLSL ternary/component assignments must evaluate their right-hand side before overwriting shared components, especially integer shuffle L101 and UV/RGB overwrite L162.
- Matrix arrays are consumed as columns by explicit weighted sums. HLSL matrix storage qualifiers and `mul` argument order must recreate these sums rather than blindly transposing the captured array. VS source has no varying `layout(location=...)`; the TEXCOORD names in Section 5 describe its logical interface, not independently observed linked numeric locations.
- Return value semantics map to `SV_Target0`; use source material alpha as calculated, with no automatic URP alpha clipping/fog/lighting replacement. Any URP helper is acceptable only if its generated operations and coordinate/color conventions are verified equivalent to this tree.

## 10. Self-Check

- **Confidence HIGH — executable data flow:** all PS assignments L72–170 and all RT0-relevant VS assignments L91–146 are represented; alpha, RGB and all alternative branches are closed to textures, vertex inputs, uniforms or rasterization. Variable conflict scan found 22 intermediate base names, 12 of them multiply assigned, maximum 12 writes. Three explicit `if` statements plus four ternary decisions are covered by the seven Section 7 rows.
- **Confidence HIGH — formulas:** source-preserving signed atlas math, two alpha-color multiplications, distinct MainTex/emission UVs, non-renormalized PS normal, exact SH basis, cubic/quintic rim and custom fog integral were separately checked. This is source analysis, not a numerical render comparison.
- **Confidence MEDIUM — scene interpretation:** source proves the custom diffuse/rim/emission/fog operations. The visual object role comes from Section 1; supplied light vectors and texture associations are consumed as that mapping contract, without inventing names for an unobserved engine implementation.
- **UNRESOLVED variable list:** none in the algorithm. `[DATA MISSING: actual mesh vertex/index values, raster coverage and interpolated per-pixel values]` prevent evaluating the height gate/fog and output numerically. `[DATA MISSING: texture texels, dimensions, formats/sRGB, sampler filter/address/mip states and sampler uniform integer bindings]` prevent independent sample/binding validation. `[DATA MISSING: complete raster/viewport/render-target color-space state and reference pixel results]` prevent a pixel-equivalence claim. These are external values, not breaks in the dependency tree.
- **MCP FAIL list:** none; no RenderDoc/Unity/MCP data operation was called for this analysis. Any original mapping acquisition uncertainty is outside this three-file boundary and is not silently repaired here.
- **Contradiction checks:** `_CutOff` does not imply discard; `_MainLightOn` has no effect here; `_BlinnPhongOn` does not implement specular; `_ShadowColor` is unused. Alpha is not premultiplied into RGB and blend enable is false. Emission has pre-ST UV while MainTex has post-ST UV. Snapshot-disabled branches are preserved rather than treated as absent. No assumption that GLSL sampler `location` equals texture `binding` is used to derive new associations.
- **Source coverage ledger:** PS L72–110 atlas/raw UV; L111–117 lookup/material; L118–128 scene tint/Lambert/SH; L129–147 rim; L148–157 emission; L158–162 fog composition; L163–169 alpha; L170 RGB write. VS L91–99 world/clip position; L100 raw UV; L101–108 normal; L109–133 height-distance fog and world-position varying; L134–146 SH. VS L147–148 only write unused outputs; declaration sections and return statements carry no additional RT0 math.
- **Mechanical tree audit:** 147 unique semantic definitions = 91 intermediate + 56 terminal nodes. The post-trace inventory was generated directly from the tree, with no duplicate semantic definitions, no unresolved/forward `computed node above` references, no untyped terminal and no node lacking PS/VS source-line references. Terminal varying producers are expanded rather than left implicit.
- **MD self-contained completeness:** a translation agent can implement every source algorithm from this MD plus the supplied VS/PS, using explicit semantic formulas and original source line references. No hidden reasoning context, external shader, raw_data file or other EID was used. The missing runtime assets/state listed above are still required for reconstruction and pixel validation; this analysis neither stubs them nor claims validation was completed.

<!-- Sections 10.1-10.3 and Section 11 are populated by Phase A-Validate.
     Analyze-Tree does NOT write these. -->

## 10.1 Spec Audit

Audit boundary: the complete current `output_spec.md`, `vs.glsl` and `ps.glsl` were re-read from this E1005 directory. `target_filter=[0]`. No raw_data, other EID, RenderDoc/Unity operation or visual asset was used. Sections 1–10 were left unchanged by this audit.

- **V0-1 CB Offset: WARNING.** Section 3 contains 104 stage-specific mapping rows and named GLSL fields; no duplicate `(stage,CB,source)` key, no source-to-semantic conflict and no differing cross-stage snapshot for shared names was found. VS/PS `UnityPerMaterial` declaration order and member types are identical. `[SPEC WARNING: CB UnityPerDraw/UnityPerMaterial offset issue: Section 3 has no byte-offset or array-stride column, so captured buffer offset continuity and non-overlap cannot be certified from this specification.]` These named GLSL sources do not use `_m0/_m1` numbering; absence of that numbering is not itself a gap. `$Globals` values are standalone uniforms, not one demonstrated packed buffer. This does not prevent name-based HLSL translation.
- **V0-2 Terminal Coverage: PASS.** All 56 Section 8 terminal definitions resolve: 50 `[CB]` entries to Section 3 original lookup names, 2 `[TEX]` entries to Section 4, 3 `[VERTEX]` entries to Section 6, and 1 `[BUILTIN]` entry to its explicit rasterization explanation. Varying producers are expanded beyond the interface rather than left as unresolved varying leaves. Texture sample-node aliases (`mainTextureSample`, `emissionTextureSample`) resolve through `_MainTex`/`_EmissionMap` to the table's resource semantics; they are not additional texture bindings.
- **V0-3 Varying Consistency: PASS.** Every PS input has a same-name/type VS output: `vs_TEXCOORD0:vec2`, `vs_TEXCOORD1:vec3`, `vs_TEXCOORD2:vec4`, `vs_TEXCOORD3:vec3`. Section 5's world-position xyz and fog w occupy disjoint components of one vec4. Producers exist at VS L100,108,119,133,146; consumers exist at PS L105/109,123/135,131/166,158,127 respectively. VS L147–148 zero outputs 5/6 are correctly identified as unconsumed. There are no explicit linked numeric varying locations in these sources or Section 5, so consistency is established by GLSL interface names/types/components. The wider captured NORMAL0 attribute format does not contradict the VS reading only xyz.
- **V0-4 Texture Binding: WARNING.** The two Section 4 rows are unique, match the two PS sampler names and cover both sample terminals. MainTex RGBA is used at PS L112–117 and in the subsequent alpha path; emission consumes RGB only at PS L150. `[SPEC WARNING: Texture binding issue: Section 4 labels rows as Slot 0/1, but sampler uniform integer values and actual texture-unit bindings are absent; GLSL layout(location=0/1) establishes uniform locations, not sampler unit bindings.]` `[SPEC WARNING: Texture binding issue: sampler filter/address/mip state and format/sRGB data are absent, and the emission row's generic .rgba/.rgb wording is broader than the actual RGB-only consumption.]` Use the recorded ResourceIds as supplied associations until acquisition/validation confirms them; this is a binding-evidence warning, not a missing symbolic input for Build.
- **V0-5 Dependency Self-Containment: PASS.** All 91 nonterminal definitions have indented children or valid `computed node above` references. All such references resolve earlier in the tree. There are 147 unique definitions, no duplicate semantic name, and the generated inventory matches them exactly. No placeholder replaces a dependency subtree. No algorithmic `[UNRESOLVED]` node is present; Section 10 centrally records missing external runtime values.
- **V0-6 Raw Data Completeness: SKIPPED.** raw_data was outside the authorized input boundary and was not read. This is not a detected COLLECT failure. The absence of raw_data in this audit must not be described as an empty or failed acquisition.
- **Overall: WARN.** The symbolic interfaces and complete source algorithms support Phase B. Byte-offset evidence and texture binding/sampling evidence remain non-blocking audit warnings and must be resolved before a pixel-equivalence claim.

## 10.2 Source Coverage Audit

- **Target RT Coverage: PASS.** PS L48 declares only `layout(location=0) out vec4 SV_Target0`; the target filter selects RT0. Section 8 has its independent RT0 tree, split into five explicit contribution subtrees. No other RT is silently mixed into this audit.
- **Output Root Coverage: PASS.** Alpha write PS L169 is rooted at `outputOpacity` and closes through selected opacity plus the height gate. RGB write PS L170 is rooted at `outputColor` and closes through `foggedColor` at L162, its pre-fog color join and fog weight. The index correctly resolves `u_xlat0.x` before its xyz overwrite and `u_xlat16_3.xyz` according to executed control flow rather than the nearest lexical assignment.
- **Leaf Trace Coverage: PASS.** All source output dependencies reach the 50 uniform, 2 texture, 3 vertex and 1 builtin terminals audited above. UV lookup parents additionally trace all coordinate math. Current snapshot-disabled atlas, Lambert, rim and emission paths remain represented. Three explicit if statements and four ternary decisions match the seven Section 7 coverage rows; no light loop or discard is omitted.
- **Source Line Coverage: PASS.** A mechanical scan found 87 PS assignment lines, all represented by the Section 8 node source references. It found 58 VS assignment lines: all 56 RT0-relevant assignments are represented; the two excluded assignments are VS L147–148, which write outputs absent from the PS interface and are explicitly documented in Section 9.2. No cited source line is out of range. Manual checks of the alpha-channel reuse, signed atlas corner shuffle, per-vertex SH, two rim powers, timeline emission and custom exponential fog agree with the corresponding source chains. This confirms coverage, not execution equivalence.
- **Translation Notes Coverage: PASS.** Section 9 provides all required categories: exact math and constants, an explicit no-stub policy for RT0, technique notes, API/type/precision warnings, coordinate conventions and source-order requirements. It correctly preserves `_Color.a` twice on the texture-alpha path; distinct MainTex/emission UVs; SH's raw `_BlinnPhongOn` multiplier; absence of PS normal renormalization; cubic edge plus quintic broad rim; and the extra exponential factor in vertex fog.
- **Precision clarification for Build:** `wrappedFrame` and `wrappedColumn` use readable `a/b` notation in the tree. The actual PS L81–82 and L88–89 compute a reciprocal first and then multiply before `fract`; preserve those two-step operations, following Section 9's source-order rule. Likewise, interpret compact lerp/closed-form audit expressions as algebraic explanations and translate the referenced source multiplication/addition order when pursuing closest float rounding. This clarification requires no missing dependency or Analyze-Tree rerun.
- **Overall: PASS.** No source-coverage failure requiring return to Analyze-Tree was found. Build may proceed while retaining the Spec Audit warnings. Compilation, GPU execution and numerical pixel comparison were not performed by this audit.

## 10.3 Optional Visual Audit

- **Status: SKIPPED.**
- **Blocking: false.**
- **Inputs:** no RenderDoc reference, Unity candidate, diff or heatmap was included in this three-file audit. RenderDoc and Unity were not called. **逐像素尚未验证 / pixel equivalence has not been validated.**
- **Spec-derived checkpoints:** `outputColor` and `outputOpacity` are defined, but no observed pixels are available for comparison. There is therefore no PASS/WARN/FAIL visual judgment or numerical error metric.
- **Suggested next debug captures:** after Build, compare matched RT0 RGBA output using identical camera, geometry, viewport, texture formats and sampling state. If the final output differs materially, inspect `baseTexel`/`baseAlbedo` first for binding or color-space errors and `interpolatedFog`/`fogBlendWeight` for the vertex fog contribution; compare alpha separately through `selectedOpacity`. These are optional diagnostic suggestions, not evidence already obtained.

## 11. Human Verification Notes

- [ ] Verify the captured sampler uniform integer values and actual texture-unit associations for `_MainTex` and `_EmissionMap`; do not infer them only from `layout(location=...)`. Confirm the Section 4 ResourceIds, texture contents, RGB/alpha roles, filter/address/mip settings and sRGB/linear interpretation.
- [ ] Add or verify CB byte offsets and array strides if raw buffer replay or snapshot decoding is required. Name-based shader translation is supported now; the existing table does not independently prove byte-level layout/value acquisition.
- [ ] Provide the actual mesh and matching camera/viewport/raster/target state to the reconstruction. Confirm object-space Y offset, matrix convention, inverse-transpose vertex normals and captured vertex attribute decoding.
- [ ] Compile and run the completed human-readable Unity URP shader, then compare final RT0 RGB **and alpha** with the matching RenderDoc reference. Record numerical pixel metrics and a diff/heatmap before claiming equivalence. No visual or pixel validation has occurred in this audit.
- [ ] If the final comparison differs, use the Section 10.3 source-derived checkpoints; preserve vertex-evaluated fog and SH instead of silently substituting URP fog/lighting helpers.
- [ ] Exercise material controls beyond the current disabled snapshots: signed-time atlas indexing, raw arithmetic blend weights, Lambert plus independently weighted SH, cubic/quintic rim, building/timeline emission, red-channel opacity and inclusive world-height fade. Preserve the source's distinct switch thresholds and operation order.
- [x] No LOW-confidence algorithm node or unresolved source variable was found. External runtime evidence gaps remain documented above; no substitute shader logic or stub has been approved for RT0.
- **Build handoff:** supported with warnings. No mandatory return to Analyze-Tree is recommended. Supplement Analyze-Map/acquisition evidence for CB byte layouts and texture bindings when available; this evidence work is required for validating the reconstructed render, not for generating the already specified shader algorithm.

VALIDATE_RESULT: WARN
FAIL_CATEGORY: NONE