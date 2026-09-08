# EID3356 / EID3369：战争迷雾

## 源码与实现

- EID3356：VS29910 / FS29911，源码 hash 分别为 `e0dfd33a...` / `3eef8a2e...`。
- EID3369：VS29913 / FS29914，源码 hash 分别为 `c0055bef...` / `416bc9ac...`。
- EID1550：VS4406 / FS4407，复制当前深度到 360×640 的 Texture30002。
- 可读实现：`Assets/LastZ/Shader/FogOfWar.shader`。
- 实时深度复制：`Assets/LastZ/Rendering/FogDepthSnapshotFeature.cs` 和 `FogDepthSnapshot.shader`。

## 绑定方式

两材质都使用 `LastZ/FogOfWar`，EID3356 设置 `_UseDepth=1, _ZTest=4 (LEqual)`，EID3369 设置 `_UseDepth=0, _ZTest=8 (Always)`。
原 CB 中与 shader 同名的有效参数直接赋值，颜色使用 Vector 保留线性数值。
原全局 `_Params=(-0,-0,0.00249999994412065,1)` 与 `_Timeline=1` 也作为材质属性赋值。
EID3369 的 `_MainTex_ST=(5,5,0,0)`、`_BlendNoise_ST=(8,8,0.5,0)` 不能省略。

| 属性 | EID3356 | EID3369 | 导入与采样 |
|---|---|---|---|
| `_FogMask` | Texture30516 | Texture30516 | 原 sRGB RGBA；Repeat、Bilinear + 最近 mip，保留原 mip |
| `_FogOfWar` | Texture29993 | Texture29993 | 原 sRGB；Clamp、Bilinear，无 mip |
| `_MainTex` | 不使用 | Texture5291 | 使用原导出格式/采样状态 |
| `_BlendNoise` | 不使用 | Texture5289 | 使用原导出格式/采样状态 |
| `_FogSceneDepthTexture` | Feature 实时提供 | 不使用 | D32 native device depth、Point、Clamp、无 mip |

**不要把导出的 `_CameraDepthTexture__Texture_30002.tga` 绑定为深度来源。** 它的 8-bit 导出无法保留透视深度精度，也不会随相机变化。
`_FogSceneDepthTexture` 没有写在 Properties 中，避免材质属性覆盖 Feature 设置的全局纹理。

默认 `_UseCapturedTime=1`、`_CapturedTime=126.320823669434`。云纹理用原 `_Time.x=t/20`，混合噪声用 `_Time.y=t`；设 `_UseCapturedTime=0` 可恢复实时动画。

## 网格和空间

两 draw 输入只用 POSITION 和 UV0。应保留原局部顶点、UV 与原对象矩阵。
EID3356 在对象空间先减 `_FogShadowOffset.xyz=(0,-0.1,0.01)`；原对象 scale=(180,2,180)、position=(200,0,200)，所以世界偏移是 (0,+0.2,-1.8)。若把模型提前烘焙到世界坐标，此偏移必须相应转换；不可再按 identity 对象矩阵直接做原局部偏移。

EID3369 **将裁剪深度强制放到远平面**：GL 原值 `clip.z=clip.w-1e-6`，D3D reversed-Z 使用 `clip.z=0.5e-6`。世界位置不变，只更改裁剪深度。该 draw 的 ZTest=Always，所以云层可以叠在场景上；覆盖区域由战争迷雾遮罩决定，不能误设为 LEqual 让云只画在背景。

## 深度快照配置

1. 在使用的 UniversalRendererData 中加入 `FogDepthSnapshotFeature`。
2. 将 feature 的序列化字段 `depthCopyShader` 设置为 `Hidden/LastZ/FogDepthSnapshot` 资产，确保打包时保留该 shader。
3. 前一阶段 EID466..1523 材质队列设置为 `2000+原绘制顺序`；不要改变它们原 Blend、Cull、ZWrite。
4. EID1600..3479 设置为 `3100+本阶段绘制顺序`，保持全部 ZWrite Off。
5. Feature 在 `BeforeRenderingTransparents` 读取 `renderer.cameraDepthTargetHandle` 并复制到相机输出宽高的一半。

这样保留跨材质的 EID 次序，同时给 EID1550 提供一个真实的 URP 调度位置。默认 URP 深度图可能在不合适的时机生成，不能直接把 `_CameraDepthTexture` 当成本次快照。
Feature 继承本项目固定 URP 14.0.12 的 `CopyDepthPass`，使用其 RTHandle UV 翻转和 MSAA 支持；本次 MSAA=1 时就是原始单采样深度复制。

## 与错误草稿的区别

- FogMask 通过三次连续 lerp 选择 RGBA 反色，**不是四通道求和**。
- 世界遮罩 UV 是 `((world.xz + offset) * Params.z + Params.xy) * UvScale`。
- Coverage 只线性 remap + saturate，不使用 smoothstep、高度 pow 或其他通用雾公式。
- EID3356 先算 `sceneEyeDepth - fogClip.w + VertexOffset.x`，再除 FallOff、饱和、幂运算。白天到夜晚还会把该层 alpha 衰减为零。
- EID3369 根据 coverage 混合边缘色和内部色，乘主纹理，再用独立噪声混合顶部颜色。
- 雾纹理采样没有原游戏全局 mip bias；URP 宏的自动 bias 在这些采样中被抵消。

源 CB 中 `_EdgeNoiseFlowDir`、`_ShadeOffset`、`_EdgeClamp`、`_EdgeNoise_ST`、`_EdgeNoise2_ST`、`_EdgeSpeed`、`_DepthColor`、`_NightDepthColor`、`_FogEdgeMin`、`_FogPower`、`_FogStart`、`_FogEnd`、`_EdgeContrast`、`_DepthColorOn`、`_HeightStart`、`_HeightEnd`、`_EdgeSmootMin`、`_EdgeSmootMax`、`_EdgeNoise2Blend` 在这两组有效 FS 中都未读取。没有为这些闲置量虚构功能。3369 VS 输出的 screenPosition.z 加了 `_VertexOffset.z`，但 FS 完全不读取该 varying，因此省略这项死输出；3356 则确实读取 `_VertexOffset.x`。

## 验证状态

实现基于逐行检查原 VS/FS 和 draw 参数。整体 Unity 编译与双边渲染比较由 Pass6 统一验证流程执行；本文不预先宣称像素一致率。
