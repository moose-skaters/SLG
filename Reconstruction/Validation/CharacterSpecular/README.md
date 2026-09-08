# CharacterSpecular 还原与学习说明

实现：`Assets/LastZ/Shader/CharacterSpecular.shader`，Shader 名称 `LastZ/CharacterSpecular`。原 GLSL 在 `Assets/LastZ/GLSL/CharacterSpecular_vs.txt`、`CharacterSpecular_fs.txt`、`CharacterSpecular_Hair_fs.txt`。

| EID | 对象 | 变体 | 队列 |
|---|---|---|---:|
| 1084 | 枪械 | 普通：高光 + Cubemap | 3056 |
| 1255 | 女性角色身体 | 普通：高光 + Cubemap | 3064 |
| 1313 | 头发 | 最终 Alpha 裁切，不采样 Cubemap | 3066 |

三个对象均已启用并绑定原目录中各自的 eid_N.mat，SampleScene 已保存。Cull Back、ZTest LEqual、ZWrite On、Blend Off 与原捕获一致，队列沿用完整EID顺序。

## 核心算法

**基础色**：MainTex × BaseColor × LightColor2 × LightIntensity2，RGBA四通道都相乘。LightColor2/Intensity2 是游戏自定义角色灯色，与 SceneLit 的同名量一致，不是 URP 主灯颜色。

**高光 EvaluateSpecular**：
```text
L = lerp(URP主灯方向, CustomSpecLightDir, CustomSpecLightDir_ON)
H = normalize(V + L)
highlight = pow(max(dot(N,H),0), Shininess*128)
strength = packed.r*Smoothness0
         + packed.g*Detail.r*Leather*DetailIntensity
         + packed.b*Cloth
         + packed.a*Skin
specular = saturate(strength * LightColor2.rgb * SpecColor.rgb
                    * LightIntensity2 * highlight)
```
先混合灯方向，再与视线相加归一化，不能先把自定义灯方向归一化。原 FS 对最终高光 RGB 单独限幅。法线在 VS 和 FS 都归一化；本帧三个对象的自定义灯方向开关都为1。

**主灯影响标记**：基础色加高光后乘 lerp(ShadowColor,1,unity_LightData.z)。这里使用 URP GetMainLight().distanceAttenuation，当前前向路径对应同一个内置量。它是灯光是否影响对象的标记，不是实时阴影贴图。原 VS 输出阴影坐标和 SH，但两个 FS 都未读取，故删除无效运算。

**反射 EvaluateReflection，仅普通变体**：
```text
smoothness = packed.r * Smoothness0
roughness = 1 - smoothness
mip = roughness * (1.7 - 0.7*roughness) * 6
sampleDirection = reflect(-V,N) + ReflectionDir.xyz
grazing = saturate(packed.b*Reflectivity + smoothness)
reflectionTint = lerp(baseColor, grazing, (1-dot(N,V))^4)
reflection = packed.r * reflectionTint * decodedCubemap
```
反射方向直接加偏移，不把偏移误当作旋转。这里的四次幂使用未饱和的 NdotV。反射加在主灯影响遮罩之后。Reflectivity 只是 grazing 中的一项，不是全部反射的单一开关。

**HDR 解码 DecodeReflection**：
```text
scaledRGB = cube.rgb * ReflectionIntenSity
scaledAlpha = cube.a * ReflectionIntenSity
alphaForDecode = max(1 + hdr.w*(scaledAlpha-1),0)
decoded = scaledRGB * hdr.x * pow(alphaForDecode,hdr.y)
```
反射强度先影响 RGB 和 Alpha，再解码；不能改成先调用通用 DecodeHDREnvironment 然后乘强度。

原 CB 名称 **_ReflectionMap_HDR** 会被 Unity 根据新建 Cubemap 的元数据自动改成 (1,1,0,0)。因此最终 Shader 使用 **_ReflectionDecodeParams** 保存捕获值，并明确注释名称映射。三个材质的捕获值为 (34.493244,2.2,0,1)。这是有意的唯一名称兼容调整，不能改回后忽略 Unity 的自动覆盖。

**可选 Fresnel 染色**：使用 (1-saturate(NdotV))^5，结合 Bias/Scale/Intensity 得到系数，向 Fresnel_Color 插值，系数不额外限幅。与 SceneLit 的“添加 Fresnel 颜色”不同。

**头发变体**：不计算反射；基础透明度为 MainTex.a × BaseColor.a × LightColor2.a × LightIntensity2。先按世界Y执行可选的Alpha门控，再 clip(finalAlpha-CutValue)。它与 SceneLit 的“直接对原纹理Alpha裁切”不同。普通变体不执行此高度门控与裁切。

原代码中的 Dump_ST、CustomLightDir、AmbientSky/Equator/Ground 未被使用。不额外添加法线贴图、Lambert漫反射、实时阴影、自发光或GPU蒙皮。这里恢复的是捕获时的网格姿态和着色，不代表恢复骨骼动画系统。

## 纹理与 Cubemap

8个唯一纹理资产位于 `Assets/LastZ/Shader/CharacterSpecularTextures/`，均保留原始RGBA8数据和全部mip：
- 主纹理12469、31270、31271：sRGB。
- 高光权重12468、31269：Linear；头发权重31275在原捕获中却是 **sRGB**，不能因其用途而擅自统一改成Linear。
- Detail4312：sRGB白色常量。
- Reflection6824：128×128、6面、8级mip、sRGB，Alpha用于HDR解码。

2D采用Bilinear/Repeat，Cube采用Trilinear/Clamp，anisoLevel=0，避免项目ForceEnable改变采样。PNG到像素数组按Unity底部起始行序转换，参照 [Unity 2022.3 Cubemap.SetPixels说明](https://docs.unity3d.com/kr/2022.3/ScriptReference/Cubemap.SetPixels.html)。六个方向的固定LOD采样测试也与RenderDoc一致，未在最终 Shader 中补偿翻转方向。

## 实际验证

比较的是 RenderDoc 原捕获与 Unity 真实渲染，720×1280、后处理前。参考重放临时屏蔽尚未还原的 CharacterMetallic，其他已还原组保留原代码。逐个EID比较其绘制前后变化的区域，不用背景放大“还原率”。完成后重新打开原捕获清除所有临时替换。

| EID | 实际影响像素 | RGB完全一致 | RGB MAE / 255 | 最大单通道差异 |
|---|---:|---:|---:|---:|
| 1084 | 36 | 100% | 0 | 0 |
| 1255 | 838 | 98.329% | 0.215593 | 99 |
| 1313 | 79 | 97.468% | 0.675105 | 44 |

身体只有4个像素、头发只有2个像素的某通道差异超过5/255，集中在轮廓/重叠附近；不宣称所有像素完全一致。三个对象的矩阵最大差异约1.8e-7、网格局部包围盒最大差异约2.4e-7，残余边界差异尚未逐点归因。

额外验证：
- 关闭反射，枪械RGB逐像素一致，用于隔离基础色与高光。
- 6个不同朝向、LOD=2.35的Cubemap采样探针：打包Cube R、Alpha、B到输出RGB，两边完全一致。探针代码已从最终 Shader 删除。
- 修改主灯/自定义灯混合、Fresnel插值、反射强度、HDR解码、光滑度、Tint及头发高度门控：枪械仍完全一致；身体MAE约0.1917/255，头发约1.0101/255（只剩33个可见像素，其中1个边界像素差异超过5）。
- 恢复参数后，最终截图与测试前默认截图逐像素相同。
- 所有已使用CB参数检查通过；Shader支持正常，当前编译消息为空，Unity Console无错误/警告。三个材质和场景均已保存。

PNG展示的Alpha统一设为255，上述指标是RGB验证，不冒充RT Alpha通道的逐像素比较。

文件：
- comparison.png：完整组合画面；character_crop_comparison.png：三个对象的最近邻放大对比。
- metrics.json / compare.py：完整指标与复算。
- source_materials.json / source_textures.json：原CB、绑定与实际采样状态。
- material_setup.json / final_status.json：材质对应、参数恢复、几何与保存检查。
- branch_values.json / branch_standard.glsl / branch_hair.glsl：扩展参数测试。
- setup_materials.cs.txt / capture_unity.cs.txt / capture_branch.cs.txt / validate_scene.cs.txt：执行记录。
- backup/：修改前的三个材质及场景。

