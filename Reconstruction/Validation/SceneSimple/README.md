# SceneSimple 还原与学习说明

实现：`Assets/LastZ/Shader/SceneSimple.shader`，名称 `LastZ/SceneSimple`。Unity 2022.3.62f1、URP 14.0.12、DX11、Linear。

源抓帧：Frame4414，Program17050，VS17048 / FS17049。原始 GLSL 已复制到 `Assets/LastZ/GLSL/SceneSimple_vs.txt` 和 `SceneSimple_fs.txt`，便于与 HLSL 对照。原始逐 draw 完整 CB/状态在 `Reconstruction/Raw/Frame_4414/Draws/e*.json`；本目录 `source_materials.json` 汇总了实际参与计算的参数与纹理绑定。

## 对象和材质

11 个 EID：
496、505、514、523、532、541、1041、1050、1453、1460、1467。

每个对象使用各自已有的 `Assets/RdocMeshes/eid_N/eid_N.mat`，没有把不同参数硬塞到同一共享材质。场景中对应的 11 个 MeshRenderer 都已绑定、启用，SampleScene 已保存。Ground 和已经匹配的场景灯光保留。

| EID | 主纹理 ID | Blend | ZWrite | 局部 Y 偏移 | Color.a | Render Queue |
|---|---:|---|---|---:|---:|---:|
| 496 | 30554 | SrcAlpha / OneMinusSrcAlpha | Off | 0 | 1 | 3000 |
| 505 | 30551 | 同上 | Off | 0 | 1 | 3001 |
| 514 | 30556 | 同上 | Off | 0 | 1 | 3002 |
| 523 | 30555 | 同上 | Off | 0 | 1 | 3003 |
| 532 | 30547 | 同上 | Off | 0 | 1 | 3004 |
| 541 | 30553 | 同上 | Off | 0 | 1 | 3005 |
| 1041 | 31096 | One / Zero | On | 0 | 1 | 3054 |
| 1050 | 30713 | One / Zero | On | 0.02 | 1 | 3055 |
| 1453 | 5543 | SrcAlpha / OneMinusSrcAlpha | Off | 0 | 0 | 3075 |
| 1460 | 5543 | 同上 | Off | 0 | 0 | 3076 |
| 1467 | 5543 | 同上 | Off | 0 | 0 | 3077 |

最后三项 RGB Tint 均为 (0.839622617,0.839622617,0.839622617)，其余为白色。AlphaIsR 与 BlurPlaneShadowOn 在捕获中均为 0。最后三项在原帧不贡献颜色是正确结果，不是贴图丢失。

原 pass 交错提交透明和不透明 draw。接入 SceneLit 后，为匹配跨 Shader 的顺序，材质都放在同一个 URP 透明阶段内，用 3000+完整 draw 索引固定次序；1041/1050 仍采用不透明覆盖和深度写入。Render Queue 不等于 Blend 模式。后续加入其他 Shader 类别时，应统一安排整个 EID 序列，而不是机械地将所有写深度材质移到不透明阶段。

## GLSL 翻译要点

1. `SceneSimpleVertex` 先在 **物体空间** 添加 (0,VertexOffsetY,0)，再执行对象和相机变换。1050 的 0.02 不能改加到世界 Y，也不能同时烘进 Mesh。
2. 主纹理使用原网格 UV；原源码没有 MainTex_ST，所以材质隐藏了 Tiling/Offset。
3. 主色为 `tinted = texture * Color`。Color 使用 Vector 保存 GPU 的线性 RGBA，避免 Color Inspector 的额外 sRGB 转换。
4. `ResolveOpacity` 等价于：
   - 常规 Alpha：`texture.a * Color.a`；
   - R 作为 Alpha：`texture.r * Color.r * Color.a`；
   - 按 AlphaIsR 在两者间插值。原算法的 R 已被 Tint.r 调制，不能忽略这一点。
5. 平面模糊阴影用屏幕 UV 采样遮罩 R，将 RGB 乘 `0.5 + 0.5 * shadowR`；只改颜色，不改透明度。原本是全局开关，这里提供同名材质控制供学习，捕获默认关闭。
6. 返回 straight alpha 颜色；没有预乘，也没有 clip。原透明状态的 RGB 与 Alpha 两套因子都是 SrcAlpha / OneMinusSrcAlpha，这与一些常见透明 Shader 的 Alpha 因子不同。
7. 不使用 URP 主光或 SH：这个程序本身就是 Unlit。CB 中声明的 MainLightOn、Emission、Fresnel、Fog、CutOff、GPUSkin 等没有参与这份可执行 GLSL，不为它们制造功能。
8. 原纹理采样没有全局 mip bias。URP 14 的采样宏会自动添加 `_GlobalMipBias.x`，Shader 将其抵消，以保留原 texture() 行为。

## 纹理

主纹理与平面阴影纹理均为 sRGB RGBA8；Alpha 不作 sRGB 转换。使用 Bilinear、Repeat、无额外压缩，anisoLevel=0，防止当前项目 ForceEnable 将各向异性过滤强行启用。实际使用的采样状态可在原逐 draw 的 `stages.pixel.used_resources[].sampler` 查看；仅看初始化阶段的 glTexParameteri 记录可能与 draw 时实际状态不一致。

除1050外，相关输入纹理只有 mip0，已关闭 Unity 自动生成 mip。1050 的主纹理30713保留原始10级 mip，存为 `Assets/LastZ/Shader/SceneSimpleTextures/Texture_30713.asset`；数据来自原抓帧导出目录的10张 PNG，转换为 Unity Texture2D 时保留 RGBA8 和正确行方向，不重新生成 mip。

## 验证

对比的是 **Ground + SceneSimple**，不是尚未完成的整个游戏画面。在 RenderDoc 中仅将其余六组 FS 临时改为 discard，保留原 SceneSimple VS/FS、输入、Blend、深度状态及提交顺序；逐个 EID 导出累积图像。之后重新打开原捕获并核实原 Shader 恢复，避免 replacement 移除缓存问题。

Unity 使用用户已匹配的相机，720×1280、临时关闭后处理/HDR/MSAA，并匹配参考 RT 的清屏背景。验证后恢复相机全部设置。PNG 展示统一设为不透明；下列指标比较 RGB，未宣称 alpha render-target 通道逐像素验证。

- SceneSimple 默认实际影响区域：50,069 像素。
- RGB MAE：**0.00095868/255**；RMSE：0.03201955/255。
- 99.740% 的区域像素 RGB 完全一致；最大单通道误差 2/255。
- 包含 Ground 和背景的完整图像 MAE：0.00347584/255。
- 541、1050 在原相机下没有改变参考 RGB，所以不纳入可见像素精度结论。它们仍完成了材质、纹理、矩阵、网格边界及偏移检查。
- 1453、1460、1467 的零 Alpha 行为已验证：原参考与 Unity 均不产生 RGB 变化。
- 11 个对象的模型矩阵最大差异约 1.2e-7，局部包围盒最大差异约 3.9e-6；1050 的输入网格未重复烘入偏移，材质偏移为0.02。
- 额外在原 GLSL 和 HLSL 中同时设置 AlphaIsR=1、Color=(0.65,0.8,0.9,0.7)、BlurPlaneShadowOn=1。分支测试影响135,932像素，MAE **0.00667736/255**，最大误差3/255。
- Shader 编译及 Unity Console 无错误、无警告。测试开关和材质值全部恢复为捕获数值，场景已保存。

文件：
- `comparison.png`、`difference_x16.png`：对比与16倍差异。
- `metrics.json`、`compare.py`：完整逐 draw 指标与复算脚本。
- `geometry_validation.json`：对象变换与网格边界核对。
- `setup_materials.cs.txt`：配置材质、原始 mip 与对象的执行记录。
- `capture_unity.cs.txt`：累积渲染验证代码，默认截止1467。
- `branch_alpha_shadow.glsl`：默认未激活分支的 GLSL 测试源。
- `backup/`：修改前材质、导入设置及场景备份。

