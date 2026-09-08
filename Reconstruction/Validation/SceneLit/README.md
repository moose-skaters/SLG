# SceneLit 还原与学习说明

实现文件：`Assets/LastZ/Shader/SceneLit.shader`，Shader 名称 `LastZ/SceneLit`。Unity 2022.3.62f1、URP14.0.12、DX11、Linear。

覆盖 Program17041 的60次常规绘制，以及 Program7527 的6次 Alpha Clip 绘制。66个对象已绑定各自已有的 `Assets/RdocMeshes/eid_N/eid_N.mat` 并启用，SampleScene 已保存。对应 EID、材质、队列、裁切、剔除状态见 `material_setup.json`。

原 GLSL 保存在 `Assets/LastZ/GLSL/SceneLit_vs.txt`、`SceneLit_fs.txt`、`SceneLit_AlphaClip_fs.txt`。内部临时变量已按数学含义重写，保留原属性名称以便对照 CB；没有将反编译变量机械改名后堆放在一个函数中。

## 按函数阅读

**SceneLitVertex**：物体空间加 VertexOffsetY，再变换世界位置和裁剪坐标。法线按逆转置变换并在顶点归一化；完整 SH 通过 URP SampleSH 在顶点计算后插值。原程序的零值额外输出不参与 FS，已删除。当前11个 draw 使用 +0.01 的局部 Y 偏移。

**GetAnimatedUV**：序列图网格来自 MainTexSheet.xy，帧时间来自 Unity 内置 Time.y × MainTexSheetAnimSpeed。原 GLSL 的符号判断和 fract 是有符号 fmod 的展开：先循环帧号，再向零截断列、行，第一帧在左上角。速度单位是帧/秒。主纹理随后使用 MainTex_ST；自发光使用序列图 UV，但不使用 MainTex_ST。这两个 UV 不能合并为同一个采样坐标。

**EvaluateSceneLighting**：先对两组游戏自定义灯色强度插值：
```text
sceneLight = lerp(LightColor1 * LightIntensity1,
                  LightColor2 * LightIntensity2, HeroDayNight_ON)
direct = albedo * sceneLight
if BlinnPhongOn > 0.5:
    direct *= saturate(dot(mainLight.direction, interpolatedNormal))
result = direct + albedo * vertexSH * BlinnPhongOn
```
BlinnPhongOn 名称具有误导性：原 FS 没有半角向量或高光计算，而且 SH 的系数始终取这个浮点值，不受 >0.5 条件限制。像素阶段不再次归一化插值法线，以保留原行为。

**EvaluateFresnel**：viewDirection 为 normalize(cameraPosition - worldPosition)，edge=1-saturate(dot(N,V))。第五次幂项是 (Bias + Scale × edge^5) × Intensity；另一个 edge^3 × Scale_Edge × Intensity 项使用独立颜色。两项直接相加，不混入透明度。

**EvaluateEmission**：EmissionMap.rgb × EmissionColor。常规项乘 EmissionIntensity；建筑项再乘 (1-Timeline)，按 EMISSIONMAPON_BUILDING_ON 插值。Timeline=1 时建筑自发光被抑制。本帧仅3次 draw 开启自发光；建筑标志在61个材质上为1，不代表61个 draw 都采样自发光。

**ResolveOpacity**：
```text
alphaFromA = texture.a * Color.a * Intensity * Color.a
alphaFromR = albedo.r * Color.a
alpha = lerp(alphaFromA, alphaFromR, AlphaIsR)
alpha *= lerp(1, step(FadeY, worldY), AlphFadeY_ON)
```
常规 Alpha 有两次 Color.a，与 SceneSimple 不同。alphaFromR 的 albedo 已经过 NoMainTexture、Tint 和 Intensity，尚未加光照、自发光或 Fresnel。高度 Fade 实际是硬阈值，不是平滑淡出；世界 Y 等于 FadeY 时保留。

**SceneLitFragment**：先采样主纹理。Alpha Clip 变体在任何颜色/强度/透明度处理之前，对原纹理 alpha 执行 clip(alpha-CutOff)。然后顺序计算 NoMainTexture→Tint→光照→Fresnel→自发光→最终透明度。两份原 FS 只在这次裁切上不同，因此用一个本地关键词 _ALPHATEST_ON 表示。

## 光照来源与当前参数

主灯方向通过 GetMainLight() 读取，环境 SH 通过 SampleSH() 读取；继续使用已经配置好的场景平行光和 Flat 白色环境光。

LightColor1/2、LightIntensity1/2、Timeline 则是原游戏的自定义全局量，**不是 URP MainLightColor**。为了方便查看实际捕获值，这个还原版本将它们暴露为同名材质参数：
- LightColor1 ≈ 白色，LightIntensity1=1.003173828。
- LightColor2 ≈ 白色，LightIntensity2=1.000047922。
- Timeline=1。
不能把这两组强度直接替换成场景平行光的1.3，否则会改变亮度。

本帧全部66个材质的 BlinnPhongOn、Fresnel_ON、SheetAnimationON 都为0，意味着默认路径主要显示带游戏灯色调制的贴图，不能据画面存在明暗就推断程序执行了实时 PBR。完整关闭分支仍已翻译和测试。MainLightOn、MaxAddIntensity1、GPUSKin_TextureSize、ShadowColor 没有参与本变体，未为其伪造功能。

## 材质状态、纹理和顺序

- 60个常规材质、6个 Alpha Clip 材质：1169、1282、1339、1345、1347、1400。
- 17次双面绘制，49次背面剔除。
- 9次透明混合且不写深度，57次不透明覆盖并写深度。
- 透明 RGB 和 Alpha 均采用 SrcAlpha / OneMinusSrcAlpha；不透明用 One / Zero 等效 Blend Off。
- SceneLit 与 SceneSimple 都按完整83次 draw 的索引分配 Render Queue=3000+index，保留跨 Shader 的原提交顺序。Ground 保持先绘制。后续功能族加入时可继续使用 draw_order.json 的预留位置。
- 43张唯一纹理均按原 sRGB 标记导入，使用实际 draw 的 Bilinear、Repeat 采样，anisoLevel=0 避免项目 ForceEnable 覆盖。
- 其中30张纹理保存完整原始 mip 链到 `Assets/LastZ/Shader/SceneLitTextures/`，不重新生成或压缩。其余13张仅 mip0，引用已校正导入设置的原 TGA。多个材质共享相同资源。
- 原 texture() 没有全局 mip bias。采样时抵消 URP14 宏隐式叠加的 GlobalMipBias。

## 验证及剩余差异

在原 RenderDoc 捕获中临时将尚未还原的 HeightGradient、Specular 两个变体及 Metallic 共4组程序设为 discard，保留 Ground、SceneSimple、SceneLit 原代码和固定管线状态。按EID导出78张累积参考图，Unity 用同一相机和提交顺序逐步渲染。完成后重新打开原捕获，清除全部临时替换。

验证分辨率720×1280，关闭后处理/HDR/MSAA，匹配参考背景；完成后恢复相机设置。展示 PNG 的 alpha 统一设为255；指标比较RGB，未声称RT alpha通道逐像素验证。

默认参数结果：
- 完整图像 RGB MAE **0.01409361/255**；99.116% 的像素 RGB 完全相同。
- SceneLit 各次 draw 改变区域的并集341,524像素，最终图在该区域的 MAE **0.03213049/255**；98.928% 的像素 RGB 完全相同。
- 最大单通道差异152/255。整图有220个像素至少一个通道差异超过20，主要位于细轮廓或重叠处。不能把很低的平均误差解释成所有像素都一致。
- 原相机下1422没有产生参考RGB变化，像素指标不为它单独宣称外观精度。
- 66个模型矩阵与捕获的最大元素差异0.000244140625，局部Mesh包围盒差异最多约3.9e-6。残余画面差异可能涉及这些微小变换差异及OpenGL/DX11光栅/深度差异，尚未逐点归因；没有为掩盖误差修改模型或相机。

额外 GPU 双边分支测试：
| 测试 | 开启内容 | 完整图像 MAE / 255 |
|---|---|---:|
| lighting_fresnel_emission | Lambert/SH、双 Fresnel、自发光、建筑自发光衰减、两组灯色混合 | 0.01745768 |
| sheet_alpha_height | 3×2序列图、主纹理ST、自发光UV、R透明度、Tint/Intensity、世界高度阈值 | 0.02377206 |

序列图测试在两边暂时将 Time.y 固定为2.75；临时宏已经从最终 Shader 删除，正常使用 Unity 时间。两组测试都覆盖常规和裁切变体。参数配置和替换 GLSL 留在本目录。

所有材质测试值均已恢复，恢复后的最终截图与测试前默认截图逐像素相同。当前绑定66/66、裁切6、双面17；Shader支持正常、编译消息为空、Unity Console无错误/警告。场景已保存。

- comparison.png / difference_x16.png：最终图和16倍差异。
- metrics.json / compare.py：逐draw、区域并集、整图、分支指标与复算。
- material_setup.json / source_materials.json / draw_order.json：材质对应、原参数、提交顺序。
- source_textures.json / mip_data/：原始纹理元数据与完整RGBA8 mip数据。
- geometry_validation.json / final_status.json：变换、绑定、恢复与保存检查。
- setup_materials.cs.txt / capture_unity.cs.txt / capture_branch.cs.txt：可查看的执行代码。
- backup/：修改前66个材质、相关纹理设置、SceneSimple材质及场景。

