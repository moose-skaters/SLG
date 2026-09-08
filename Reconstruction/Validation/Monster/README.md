# Monster 还原与学习说明

实现：`Assets/LastZ/Shader/Monster.shader`，Shader 名称 `LastZ/Monster`。按用户要求，将此前功能分类中的 CharacterMetallic 命名为 Monster；没有再保留一个重复的 CharacterMetallic.shader。

覆盖 Frame4414 的 Program7523，EID1122 / 1137。两个对象均已绑定各自原目录中的 eid_N.mat 并启用，SampleScene 已保存。原 GLSL 在 `Assets/LastZ/GLSL/Monster_vs.txt` 和 `Monster_fs.txt`，代码按表面参数、间接光、直接光、自发光和Fresnel拆成可读函数。

## 数据流

**MonsterVertex**：变换世界位置、法线，原样传UV0/UV1，使用URP SampleSH在顶点计算SH。原 VS 把世界XYZ分装进三个varying的W，现在使用明确的positionWS。原切线、副切线及屏幕坐标没有被此FS使用。

**ReadSurface**：
- BaseMap 使用 lerp(UV0,UV1,UV2_ON)，然后执行BaseMap_ST。
- MGA固定使用UV0及自己的ST；R为金属度、G为粗糙度、B为AO、A为备用自发光遮罩。
- metallic=saturate(MGA.r×MetallicIntensity)。
- 输入粗糙度先限制在[0.001,1]，再转换到smoothness并限制smoothness至少0.001，之后转回perceptualRoughness。这个次序让最粗糙端为0.999，不能简化得丢失边界。
- roughness=max(perceptualRoughness², 0.0078125)。
- oneMinusReflectivity=0.96×(1-metallic)。
- diffuseColor=albedo×oneMinusReflectivity，specularColor=lerp(0.04,albedo,metallic)。
- grazingReflectance=min(smoothness+1-oneMinusReflectivity,1)。
- AO=min(MGA.b×AoIntensity,1)，原式没有额外的下界钳制。

**EvaluateIndirectLighting**：
```text
mip = perceptualRoughness * (1.7 - 0.7*perceptualRoughness) * 6
reflectionDirection = reflect(-V,N) + reflectionDir.xyz
edge4 = (1-saturate(dot(N,V)))^4
reflectionTint = lerp(specularColor, grazingReflectance, edge4)
surfaceReduction = 1 / (roughness² + 1)
indirectSpecular = decodedCubemap * reflectionTint * surfaceReduction
indirectDiffuse = vertexSH * diffuseColor
indirect = (indirectSpecular + indirectDiffuse) * AO
```
AO只影响这两项，不影响直接漫反射、自发光或之后添加的Fresnel。

**DecodeReflection**：先令scale=pow(ReflectionIntenSity,0.44)，用它乘Cubemap的RGB和Alpha，再按捕获HDR参数解码。它与CharacterSpecular直接使用Intensity不同，不能省略0.44次幂，也不能把强度移到解码之后。

原 _ReflectionMap_HDR 会被Unity根据Cubemap元数据自动覆盖，因此映射为独立的 **_ReflectionDecodeParams**，保留捕获值 (34.493244,2.2,0,1)。

**EvaluateDirectLighting**：主光方向、颜色、影响标记均从URP GetMainLight读取。自定义方向按 **完整float4归一化后取XYZ**，不是normalize(xyz)。W=1时XYZ长度小于1，直接影响Lambert亮度。主方向与自定义方向混合后也不再次归一化。
```text
L = lerp(mainDirection, normalize(CustomLightDir.xyzw).xyz, CustmLightDir_ON)
lightColor = lerp(mainColor*CustomLightIntensity,
                  LightColor2*LightIntensity2, HeroDayNight_ON)
direct = diffuseColor * lightColor * saturate(dot(N,L)) * unity_LightData.z
```
本程序没有直接光的微表面高光项；金属高光主要来自环境反射。不要为了“更像标准PBR”额外添加一项改变捕获结果。

**EvaluateEmission**：开关>0.5时使用EmissionMap.rgb×EmissiveColor×Intensity，否则使用MGA.a作为遮罩。EmissionMap固定用原UV0，没有BaseMap的UV选择或ST。

**EvaluateFresnel**：第五次幂项与三次幂边缘项分别乘颜色后相加。最后MonsterFragment把直接光、间接光、自发光、Fresnel的总和乘 lerp(1,LightColor2×LightIntensity2,DayNightInfluence)，Alpha固定为1。

## 两个材质的关键差异

| 设置 | EID1122 | EID1137 |
|---|---:|---:|
| AoIntensity | 0.85 | 1 |
| HeroDayNight_ON | 1 | 0 |
| CustmLightDir_ON | 0 | 1 |
| CustomLightDir | (-0.08,0.71,-0.15,1) | (0,0.54,0.13,1) |
| 队列 | 3057 | 3058 |

默认均为MetallicIntensity=1、RoughnessIntensity=1、ReflectionIntenSity=1、DayNightInfluence=1。BaseColor=(0.95,0.8854,0.8132,1)，自发光强度0、Fresnel关闭、UV2_ON=0。

没有采样NormalMap。NormalScale/NormalMap_ST、ClipThreshold、HorizontalPlaneValue、LightIntensity、AddLightIntensity虽在原CB声明但未参与本变体；没有伪造法线贴图、AlphaClip、额外灯或GPU蒙皮。这次还原的是捕获姿态的网格与着色，不是动画系统。

## 纹理和渲染状态

4个唯一纹理保留完整原RGBA8与mip，位于 `Assets/LastZ/Shader/MonsterTextures/`：
- 6887：1024² sRGB BaseMap，11级mip。
- 6885：512² Linear MGA，10级mip。
- 4313：4² sRGB黑色EmissionMap，仅mip0。
- 6911：256² sRGB Cubemap，6面、9级mip。

2D为Bilinear/Repeat。原6911的mip过滤是最近级，因此Cube使用 **Bilinear/Clamp**，不是CharacterSpecular的Trilinear；anisoLevel=0防止项目ForceEnable改变过滤。HDR解码向量使用独立名称，避免前一阶段已查明的Unity自动覆盖问题。

Cull Back、ZTest LEqual、ZWrite On、Blend Off。两个材质采用完整EID索引对应的队列3057/3058，与其它Shader按原次序交错。

## RenderDoc / Unity 验证

720×1280、后处理之前，用实际相机渲染并恢复全部相机设置。**默认参考图直接来自原RenderDoc捕获截至EID1523的RT，没有禁用任何draw或shader。** 该范围六个功能Shader现已全部还原；这不包括之后的UI、特效或后处理事件。

| EID | 实际影响像素 | RGB完全相同 | MAE / 255 | 最大单通道差异 |
|---|---:|---:|---:|---:|
| 1122 | 818 | 99.389% | 0.099430 | 54 |
| 1137 | 32,672 | 98.779% | 0.046339 | 62 |

超过5/255的像素分别为3个和55个，仍存在少量轮廓/重叠差异，不声称逐像素全部一致。矩阵最大差异约3.3e-7、局部网格包围盒差异小于1e-6，残余差异未逐点归因。

完整截至1523的画面：RGB MAE **0.01586155/255**，99.093%像素RGB完全一致。该整图数字包含背景与此前已还原对象，不应当作Monster单独精度。

额外GPU双边测试：
1. metal_reflection_rim：改变金属度、粗糙度、AO、反射强度/HDR解码、自定义方向混合、昼夜染色、双Fresnel及MGA Alpha自发光；两对象MAE约0.1634/0.01790。
2. uv1_emission_map：UV1选择、独立ST、自发光采样路径。由于原EmissionMap全黑，测试时两边均临时将它指向BaseMap，以实际验证UV0采样与BaseMap_ST的区别；两对象MAE约0.08517/0.03813。测试后的贴图与参数均已恢复。

最终默认截图与恢复后的截图逐像素相同；参数、纹理引用、UV设置核对通过。Shader当前无编译消息，Console无错误/警告，两个对象和场景已保存。原RenderDoc捕获在分支测试后重新打开，临时替换已清除。

PNG展示统一设Alpha为255，上述指标是RGB验证，不把它描述为RT Alpha通道的逐像素核对。

## 文件

- comparison.png：完整范围三栏对比；monster_crop_comparison.png：两个怪物局部放大。
- metrics.json / compare.py：指标与复算。
- source_materials.json / source_textures.json / source_geometry.json：原参数、纹理、几何证据。
- material_setup.json / final_status.json：绑定、参数恢复与保存检查。
- 两组同名json/glsl：分支测试配置和原GLSL替换源。
- setup_materials.cs.txt / capture_unity.cs.txt / capture_branch.cs.txt / validate_scene.cs.txt：执行记录。
- backup/：修改前材质与场景。

当前Shader文件只有：Ground、SceneSimple、SceneLit、HeightGradient、CharacterSpecular、Monster，共6个。

