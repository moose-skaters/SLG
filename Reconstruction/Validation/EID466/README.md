# EID466 地表 Shader 还原与阅读说明

实现文件：`Assets/LastZ/Shader/Ground.shader`，Shader 名称：`LastZ/Ground`。六个 EID466 实例仍使用原来的 `Assets/RdocMeshes/eid_466/eid_466.mat`，该材质已绑定新 Shader、原 CB 参数和纹理。Unity 2022.3.62f1、URP 14.0.12、DX11、Linear。

这是基于原 VS/FS 运算的可读 HLSL 翻译。没有用一张最终画面贴图代替计算，也没有将整个 GLSL 的临时变量机械改名；世界坐标、四层采样、权重、光照、法线、高光等仍实时计算。函数旁保留了中文解释及原 varying 对照。

## 按数据流阅读

1. **GroundVertex**：通过 Unity 的实例矩阵变换位置、逆转置矩阵变换法线。世界 UV 为 `(worldXZ + WorldEdge.zw) / WorldEdge.xy + (0,1)`，与网格 UV 按 `_WorldUVON` 混合。全局图和闪光图用网格 UV。切线由 `cross((0,0,1), normalOS)` 构造，原 VS 没有 tangent 属性。SH 在顶点求值后插值。
2. **HeightBlendWeights / BlendGroundLayers**：控制图 RGBA 对应四层；Splat 的 RGB 是颜色、A 是高度。开启高度混合时，先求 `h = control * heights`，再求 `control * max(h - max(h) + Weight, 0)`，除以总和加 `2^-14`。随后原 FS 仍再执行一次权重归一化。四层分别乘颜色与强度后求和。
3. **FakeNormal 分支**：偏移一次控制图采样，取指定通道与中心归一化权重之差，乘 `_EdgeColor01` 加到颜色上。它不修改法线。偏移点复用中心点的四层高度，而且不进行第二次归一化；这些不对称行为都保留了。
4. **BuildLightingNormal**：相机高度在 100~200 内用 smoothstep 使法线 XY 强度淡出。RGB 直接乘 2 减 1，基底是 `(-T, B, N)`；不重建 Z，也不归一化。法线遮罩在 `(1,1,1)` 与结果间插值。这是原 FS 的行为，不能改成常规的平面法线混合。
5. **GroundFragment**：`albedo * (lightColor * saturate(dot(N,L)) * attenuation + SH)`。灯色先按亮度与原色插值；名字叫 Desat，但值 1 实际保留原色。
6. **闪光与高光**：屏幕遮罩的 R 调制 SparkMap.a，只影响控制图的 G/B 两层；G 直接产生另一项高光。不涉及半角向量、粗糙度或 PBR。
7. **全局远景图**：按相机 Y 在 MinHeight、MaxHeight 间线性混合近景结果与全局图。当前 Min=0、Max=-5，分母为负，相机 Y=360.058868 时混合系数为 0。不能将这个负分母“修正”为正数。
8. **平面模糊阴影**：先按阴影颜色的 A 调色，再用屏幕阴影图 R 混回原颜色；白色表示完全可见。输出 alpha 来自 `_AlphaScale`。

## 当前抓帧的实际路径

- 世界 UV 开启；四层 Tiling 为 25、30、40、30。
- 高度混合、FakeNormal、平面阴影关闭，但代码完整保留。
- 相机高度超过 200，法线 XY 已完全淡出。
- 全局远景图混合为 0；屏幕高光/闪光仍参与。
- AlphaScale=0，但固定管线关闭 Blend，因此 RGB 仍不透明写入。
- Cull Back、ZTest LEqual、ZWrite Off 与 EID466 对齐。
- 没有额外添加雾、实时阴影、PBR、额外灯或后处理。
- 原 VS 的视线向量、TEXCOORD4/5 及 HeightBlendScale 的计算不被 FS 读取；FakeNormalScale、Control_TexelSize 也未使用。代码注释解释了这些死数据，没有为它们虚构效果。

## 材质与纹理为什么这样设置

当前版本直接使用 `GetMainLight()` 和顶点阶段的 `SampleSH(normalWS)`。已删除抓帧光照开关、`_CapturedLight*` 属性和硬编码 SH 函数。场景 `Assets/Scenes/SampleScene.unity` 已保存：Directional Light 旋转 (55.5,27.7,0)，白色，强度 1.3，色温关闭；Environment Lighting 使用 Flat 白色，Ambient Intensity=1，并将该灯设为 Sun Source。场景中没有 Light Probe 覆盖环境光。

捕获的 SH 约等于白色常量环境光；Flat 白色与原 SH 的微小非零高阶项之间存在数值差异。使用可直接编辑的场景设置后，当前 720×1280 地表 RGB 平均误差为 **0.00906207/255**，覆盖不同像素为 0。相机始终使用现有 Unity 相机，没有写死投影或位置。最新截图、指标及场景状态见 `SceneLighting/`；此前包含抓帧光照的 Shader 备份保存在其 `backup/`。

颜色参数使用 Vector，直接保存 GPU 常量中的线性值，避免 Color 属性重复进行 sRGB -> Linear 转换。原属性名称保留便于对照。

| 属性 | GPU 纹理 ID | 颜色空间 / 用途 |
|---|---|---|
| _Control | 5681 | Linear，RGBA 权重 |
| _BaseNormal | 4311 | Linear，普通 RGB 法线 |
| _NormalMask / _SparkMap | 4312 | sRGB 白色常量；Spark 读 A |
| _SpecMaskMap | 5627 | Linear，屏幕 RG 遮罩 |
| _Splat0 / 1 / 2 / 3 | 5620 / 5618 / 5619 / 5626 | sRGB RGB；线性 alpha 高度 |
| _Splat_Golobal | 4316 | sRGB 灰色常量 |
| _PlaneBlurShadowMap | 4322 | 原绑定为 sRGB 灰色常量 |

六张有 mip 的主要纹理保存为 `Assets/LastZ/Shader/EID466Textures/Texture_*.asset`。这些 Texture2D 资产包含从 RenderDoc 读取的完整原始 RGBA8 mip 链，没有重新压缩或生成 mip。其余四张常量纹理继续引用原 TGA。原 TGA 文件内容保留，导入设置也已校正。

最终使用 **Bilinear、anisoLevel=0**。本项目 QualitySettings 是 ForceEnable，anisoLevel=1 会被强制启用各向异性过滤，导致图案变锐、初始误差约 1.37/255。过滤组合由整幅图像对比确认；MCP 提供的 GL 管线信息没有可靠返回 sampler 状态，因此不把该组合声称为直接读取到的原 sampler 枚举。

原 `_GlobalMipBias.x=-0.584962487` 已保留为 `_TextureMipBias`。URP 14 的采样宏会自动附加全局 bias，代码先抵消它，避免重复计算。原平面阴影采样没有 bias，因此单独抵消 URP 自动添加项。

## 验证证据

参考捕获：`D:/LastZ/Last-Z-frame4414.rdc`，EID466。输出 720×1280。Unity 使用用户已还原的相机，临时仅渲染六个地表实例、关闭后处理/MSAA/HDR，再恢复所有相机和 Renderer 设置。

比较的是地表覆盖区域内的 sRGB 8-bit RGB，不计黑色背景，也不比较导出 PNG 的 alpha。Shader 实际仍输出捕获的 alpha=0；展示 PNG 为便于观看设为不透明。

| 测试 | 覆盖不同像素 | RGB 平均绝对误差 / 255 | RMSE / 255 |
|---|---:|---:|---:|
| 捕获默认参数 | 0 | 0.00825034 | 0.10729254 |
| 当前 URP 场景光照 | 0 | 0.00906207 | 0.11101090 |
| 开启高度混合 + 非零边缘颜色 | 0 | 0.00979367 | 0.13307538 |
| 法线强度 10 + 全局图混合 + 平面阴影 | 0 | 0.00316760 | 0.05961402 |

默认参数覆盖 415,983 像素，其中 **97.813% 的 RGB 三通道完全相同**。PSNR 67.52 dB。仍有少量局部采样差异，最大单通道误差 19/255；不声称逐像素全部相等。

分支测试在 RenderDoc 原 GLSL 和 Unity HLSL 中设置同样参数，然后实际渲染对比，包含原捕获默认未激活的分支。GLSL 测试文件保存在本目录。所有临时参数已恢复。RenderDoc 的 replacement 移除工具返回成功后仍保留替换缓存，因此最后重新打开原捕获，并核实源码恢复；重新打开后的地表 RGB 与测试前原参考逐像素相同。重新打开的完整 RT 背景是 (49,77,121)，展示比较沿用用户最初 Clear Before Draw 的黑色背景。

Unity Shader 编译及 Console 检查无错误/警告。表格中“当前 URP 场景光照”是最新版本的实测结果；其余行保留此前抓帧光照基准及功能分支测试记录。当前版本只使用场景光照，已无抓帧光照模式。

- `comparison.png`：原图、URP、16 倍绝对差异。
- `metrics.json`：完整指标。
- `compare.py`：复算 RGB 指标并生成对比图。
- `capture_unity.cs.txt`：在 Unity execute_code 中重拍；保存并恢复相机状态。
- `restore_material.cs.txt`：恢复原 CB 数值，不改纹理引用。
- `import_original_mips.cs.txt`、`raw_*.json`：原始 mip 资产生成记录。
- `backup/`：原 Ground.shader、材质和纹理导入设置的备份。

URP 接口核对使用本机 14.0.12 包源码，采样宏见 Core.hlsl；结构可参考 [Unity URP 14 自定义 Shader 文档](https://docs.unity.cn/Packages/com.unity.render-pipelines.universal@14.0/manual/urp-shaders/birp-urp-custom-shader-upgrade-guide.html)。
