# Frame4414：EID1551–3479 的 URP 还原

已将这个区间实际发生的 **182 次绘制** 配置到 `Assets/Scenes/SampleScene.unity` 中的对应物体。每个 EID 使用自己的捕获参数、纹理绑定和绘制状态。原有前一段场景与角色仍参与画面，验证截至 EID3479。

## Shader 与分类

| Unity Shader | 绘制数 | 原程序 | 作用 |
|---|---:|---|---|
| Ground | 1 | 23411 | EID1600，复用地面，关闭此变体没有的屏幕高光 |
| SceneLit | 137 | 17041、7527 | 场景表面、贴片等；133 个普通变体，4 个 Alpha Clip 变体 |
| SceneTint | 9 | 17046 | 纹理乘颜色与游戏指定的染色强度，不计算法线照明 |
| GeneralVFX | 24 | 31699、7836、23419、7831、11025 | 通用透明特效，合并为五种明确的编译变体 |
| ParticleVFX | 8 | 7667 | 粒子颜色、透明度、序列帧、单轴视差 |
| FlowFire | 1 | 31718 | EID3176，顶点采样 Flowmap 控制 UV，溶解与火焰加色 |
| FogOfWar | 2 | 29912、29915 | EID3356 深度阴影与 EID3369 云层 |

这是 **13 个 GPU 程序、7 个功能类别**。Ground 和 SceneLit 复用已有实现，本次新增/重写后五类。Shader 均在 `Assets/LastZ/Shader/`；材质仍使用 `Assets/RdocMeshes/eid_N/eid_N.mat`。完整逐 EID 对照见 [material_assignments.md](material_assignments.md)。

另外有一个 `Hidden/LastZ/FogDepthSnapshot`，由 Renderer Feature 执行深度复制。它不绑定场景物体，不会多画一个可见物体。

## 阅读源码

代码根据 VS/FS 的实际运算重写为有语义的函数，保留原属性拼写以对应 CB，并用注释解释特殊行为。没有给 CB 中未被当前编译程序使用的字段虚构功能。

原始 VS/FS 的便于阅读副本在 `Assets/LastZ/GLSL/Pass6/`，`source_mapping.json` 记录原程序、代表 EID 和源码 SHA。原始完整数据仍在 `Reconstruction/Raw/Shaders/` 与 `Reconstruction/Raw/Frame_4414/Draws/e<EID>.json`。本目录的 [source.json](source.json) 汇总全部 182 次绘制的材质参数、资源、顶点属性和对象矩阵。

### GeneralVFX

`_Variant` 显式选择捕获中的五个静态变体，避免把其中一个程序没有的操作强行加到其他程序上：

| Variant | 原程序 | 核心区别 |
|---:|---:|---|
| 0 | 31699 | 基础路径，主 UV 可绕原点旋转 |
| 1 | 7836 | 基础路径，无主 UV 旋转 |
| 2 | 23419 | 双纹理、Mask、Fresnel，输出真实世界位置与法线 |
| 3 | 7831 | 读取噪声 G 通道，同时扰动 UV 的两个方向 |
| 4 | 11025 | 溶解纹理、方向溶解、自定义阈值与边缘颜色 |

UV 流动公式保留为 `(uv * ST.xy + ST.zw - 0.5) * centerScale + 0.5 + frac(time * speed)`；原程序旋转绕原点，不擅自改为绕贴图中心。

双层变体按原式在乘法与加法之间混合。其他变体即使 CB 有第二层参数，也不会凭空采样第二张纹理。MaskType 为 0 或 3 时使用 `min(mask.r, mask.a)`。Fresnel 保留原程序对插值法线的处理，不能随意加一次归一化来改变结果。

只有 Variant2 的位置 varying 有真实值；其余变体原 VS 写零。因此它们的 HeightFade 也按零位置计算。这看似古怪，但属于捕获程序实际行为。高度淡出关闭时直接跳过除法，避免默认起止高度相同造成无意义的 0/0。

所有这组 FS 输出均预乘 RGB，之后仍需使用各自原有 Blend 状态。不能看到预乘就把所有材质统一改成 One/OneMinusSrcAlpha；某些原 draw 确实还会由 SrcAlpha 再乘一次。

`_FlyOffset` 修改的是裁剪深度：原 OpenGL 的 `clip.z -= offset` 在 D3D reversed-Z 中对应 `clip.z += offset * 0.5`，不是世界空间位移。屏幕 UV 使用偏移前的裁剪位置。

### ParticleVFX 与 FlowFire

ParticleVFX 保留序列帧和视差等动态分支。视差仅沿原 tangent 方向，不补造完整 TBN；下一帧 UV 直接来自 UV0.zw。颜色处理顺序是饱和度、对比度、截断，然后乘 HDR 颜色和强度。

FlowFire **没有顶点位移**。VS 读取 Flowmap RG 得到绝对 UV，用 UV1.y 混合；UV1.x 是旋转，UV1.z/w 分别控制溶解和火焰阈值。原火焰 softness=-0.33，属性保留 Float。Mask 影响 RGB，不额外乘 Alpha。

完整公式与属性对照见 [b_flow_notes.md](b_flow_notes.md)。

### 战争迷雾与深度

FogOfWar 是两层绘制，不是全屏 URP 距离雾。两层共用战争迷雾遮罩；3356 使用场景深度计算阴影过渡，3369 根据覆盖率混合边缘色、内部色、云纹理和顶部噪声颜色。FogMask 的 RGBA 反色通过三次 lerp 选择，不是四通道相加。

3356 先在对象空间应用 `_FogShadowOffset`，再计算世界/裁剪位置。深度项为 `saturate((sceneEyeDepth - fogClip.w + VertexOffset.x) / FallOff)`，之后应用幂函数。3369 则将裁剪深度设到远平面，并使用原 ZTest Always，由遮罩决定覆盖区域。

`Assets/LastZ/Rendering/FogDepthSnapshotFeature.cs` 已加入 `Assets/Settings/URP-HighFidelity-Renderer.asset`。它在 `BeforeRenderingTransparents` 实时复制当前深度附件，重建原 EID1550 的调度位置：

1. EID466–1523 的材质队列为 2000–2083，保持原顺序和原 Blend/ZWrite。
2. 复制深度，720×1280 时生成 360×640 的 Point/Clamp 原生深度纹理。
3. EID1600–3479 的队列为 3100–3281，按 EID 顺序执行，全部 ZWrite Off。

将前段放入不透明队列只是为了安排复制时机，其材质混合状态仍保留。没有使用固定的 8-bit 导出深度图；移动相机后快照会重新生成。这里使用独立全局 `_FogSceneDepthTexture`，避免 URP 默认深度图的生成时机差异。

当前 DX11 实测深度附件格式为 **D32_SFloat_S8_UInt**；原捕获为 D24S8，精度表示并非完全一样。细节见 [fog_implementation.md](fog_implementation.md)。

## 网格与资源修复

182 个对应 Renderer 都存在，没有发现此区间漏对象或重复 Renderer。已从原始 GPU 输入 VB/IB 重建 182 个 Mesh 资产，保留本地坐标和原模型矩阵，绑定到现有对象。新网格位于 `Assets/LastZ/Shader/Pass6Meshes/`。

- 修正索引读取：IB 绑定偏移加 `indexOffset * indexStride`，随后应用 baseVertex。
- 10 个原 CSV 的 generic vertex attribute 读错：EID1673 的法线、EID3081 的顶点色，以及 8 个 ParticleVFX 的 tangent，现按 GL 实际常量补齐。
- 原 FBX 将特效 UV 通道保存成 float2，丢失自定义数据。现保留完整 float4；原 GL 两分量输入补值为 Z=0、W=1。
- EID1912 的原矩阵含剪切；EID2297、2299 的负行列式在普通 lossyScale 分解中丢失。现通过 SVD 分为两个 Transform，保持有符号缩放。新增的 `EID_<id>_ExactMatrix` 仅是变换父节点，没有 Renderer。

上述修复后的 182 个世界矩阵最大元素误差约 0.00116，对应数千量级缩放的单精度运算；三个特殊对象误差分别约 0.000244、0.000610、0.000329。具体值记录于 [final_audit.json](final_audit.json)。

100 个唯一纹理资产位于 `Assets/LastZ/Shader/Pass6Textures/`，保留捕获的各级 mip、sRGB 解码和采样状态，没有重新生成 mip。补入此前导出绑定遗漏的顶点阶段 Flowmap Texture23488。即使某图用于 UV 或遮罩，也按捕获实际格式处理 sRGB，不能仅按用途猜测应关闭解码。

Texture29993 是动态战争迷雾覆盖图，当前保存了这一帧的内容。原 FBX/CSV 保留；本次修改前的场景、材质和 Renderer 配置备份在 [backup/](backup/)。

## 使用与复现

打开当前 SampleScene 即可查看已配置结果。新特效默认将 Shader 时间冻结在 `126.3208237` 秒。GeneralVFX、ParticleVFX、FlowFire 关闭 `_UseCaptureTime`，FogOfWar 关闭 `_UseCapturedTime` 可恢复 Shader 的时间滚动。

这只恢复 UV 等随时间变化的运算；静态截帧网格中的粒子位置、自定义数据和战争迷雾覆盖图不会自动变成游戏的粒子模拟或地图探索系统。

脚本记录用于复核/重建，当前场景已经执行过，不需要再次运行：

1. `prepare_sources.py` 从本地原始数据生成网格数据、参数与纹理清单。
2. 在 Unity Editor 执行 `setup.cs.txt` 方法体，创建资产并配置现有对象。
3. **紧接着执行 `restore_exact_matrices.cs.txt`**，修复三个特殊矩阵；不能只重跑第 2 步就结束。脚本基于当前 identity 导入根节点。
4. 使用已保存且包含 FogDepthSnapshotFeature 的 Renderer 配置。
5. 执行 `validate_and_save.cs.txt` 检查绑定并保存场景。

`capture_unity.cs.txt` 是验证方法体模板，运行前将 `LIMITS` 替换为需要的 EID 列表。它暂时禁用后处理、HDR、MSAA，按捕获分辨率与 EID 截止范围输出，最后恢复相机和 Renderer 状态。原相机姿态没有被重调。

## 双边画面验证

![RenderDoc、Unity 与 RGB 差值放大 16 倍](comparison.png)

左图是 **原始 RenderDoc 捕获执行到 EID3479 后的 Texture29999**，中图是 Unity 场景对应范围渲染，右图是绝对 RGB 差值放大 16 倍。默认参考图没有隐藏原始 draw，没有使用替换后的 Shader。范围包含此前地面、场景、角色与本次 Pass6；不是游戏最后一帧的 UI/后处理结果。

比较 720×1280、后处理前输出的 RGB8（不比较 Alpha）。整图包含背景，因此“完全相同像素百分比”不是“Shader 还原率”。最后保存状态对应 `unity_final.png`，原图为 `renderdoc_3479.png`：

| 指标 | 整图 | Pass6 改变区域 |
|---|---:|---:|
| 像素数 | 921600 | 881408 |
| RGB 平均绝对误差，0–255 | 0.018595 | 0.017786 |
| RGB 三通道全相同像素 | 98.7352% | 98.7177% |
| 任一通道差值大于 5 的像素数 | 808 | 754 |

“Pass6 改变区域”指原 RenderDoc EID3479 与 EID1523 的 RGB 不同位置，不等同于对象轮廓分割。完整指标、RMSE、最大误差和阶段结果见 [metrics.json](metrics.json)；计算程序为 [compare.py](compare.py)。个别像素最大通道差仍达 124，不能宣称逐像素完全还原。

已比较 16 个截止点：1523、1600、1912、2101、3047、3081、3106、3129、3151、3176、3213、3253、3331、3356、3369、3479。3356 阴影阶段平均误差约 0.0509/255，高于最终叠云结果；最终整图会掩盖部分前层差异，所以保留了这些中间结果。

另做三组非默认参数的双边测试：GeneralVFX 的五种变体、ParticleVFX/FlowFire 的动态分支、两层雾的覆盖/深度/时间参数。这些测试在 RenderDoc 临时替换原 VS/FS 中的参数，在 Unity 设置相同参数，再比较各自 GPU 输出；原始操作逻辑不替换成 Unity 实现。测试后恢复材质并重新打开原捕获。配置及图像均保留在本目录 `*_branches*` 文件中。

最终材质审计：182/182 绑定有效，失败项为零；相关 Shader 编译消息为空。深度精度、API 光栅化和浮点运算仍有差异，剩余边缘误差尚未逐像素全部归因。验证基于当前 Unity 2022.3.62f1、URP14.0.12、DX11 环境，不把这次固定视角匹配等同于所有平台与动画状态的验证。
