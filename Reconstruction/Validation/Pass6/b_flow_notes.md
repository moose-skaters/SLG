# GeneralVFX_B / FlowFire 还原说明

本记录对应 `ParticleVFX.shader`（原分类 GeneralVFX_B，Program7667）和 `FlowFire.shader`（Program31718）。代码保留原参数拼写并拆成有语义的函数；没有将 GLSL 临时寄存器机械改名。场景、材质、网格、纹理导入由主配置流程统一处理。

## 源码依据

- Particle VS: `Reconstruction/Raw/Shaders/580c7d2c8635fb76a717919725b3065f668aef9ec9aa603f4d00d3dbd2d7adb9.vertex.glsl`
- Particle FS: `Reconstruction/Raw/Shaders/b2720701b9cd23b474642071e056ea5c2d39838c1183d13f238ebf76405cca37.pixel.glsl`
- Flow VS: `Reconstruction/Raw/Shaders/c41c9f4077e959625ee176d173b8acc6b9fd03ec66a6a7d91e6c537e594c3770.vertex.glsl`
- Flow FS: `Reconstruction/Raw/Shaders/ee59c09dfd21982cfac2981e4e6fc0021aad90088847ffabfc3687cff49ff7ae.pixel.glsl`
- CB、顶点绑定、纹理绑定、固定功能状态：`Reconstruction/Raw/Frame_4414/Draws/e{EID}.json`。

## ParticleVFX 的执行逻辑

1. 顶点 UV0.xy 做主图 ST；时间滚动与粒子 UV1.xy 偏移以 `_Particle_SpeedUV` 混合。
2. UV 以 `_Main_tex_Rotator` 角度制绕 (0,0) 旋转。原程序没有减/加 0.5。
3. 主图 A 先减 `_AlphaSub` 再 saturate，以 `_Alpha_NO_R` 混入 R。
4. 可选视差：高度读取上述 RGBA 的 `_ParallaxChannel`；以 `(1-height)*_ParallaxScale*viewTangent` 移动 UV。原 VS 没有法线和完整 TBN，`viewTangent=(dot(tangentWS,viewDirectionWS),0,0)`，只允许单轴偏移。第二次采样用 A/R 与 `_ParallaxEdgeColor` 插值 RGB，但不改第一次的 Alpha。
5. 可选序列帧：下一帧来自原始 UV0.zw，插值系数 UV2.x。下一帧不再做 ST/旋转/滚动/视差，Alpha 仅减 `_AlphaSub`，不执行 `_Alpha_NO_R`。
6. RGB 按 Rec.601 权重 (0.299,0.587,0.114) 调饱和度，再围绕 0.5 调对比度并 saturate；最后乘 `_Main_Color.rgb`、亮度、顶点色，因此 HDR 颜色仍可大于 1。
7. Alpha = saturate(处理后Alpha * `_Main_Color.a` * `_Alpha` * vertexColor.a)。可选 `_AlphaPremultiply` 将最终 Alpha 乘进 RGB。

捕获的 8 次绘制均未开启 Parallax、FlipBook、AlphaPremultiply，但源码里的动态分支完整保留。原 CB 中的噪声、Mask、溶解、Fresnel、顶点偏移字段在这组编译程序里没有执行，因此不伪造这些效果。VS 原来写出的 `_Tex_2_ST/_Tex_2_UV` 结果也保留为注释明确的无消费者 varying；原 FS 实际只使用 `_Main_Tex` 一个纹理。

| EID | 主图 | RGB与Alpha混合 | Cull | ZTest |
|---|---|---|---|---|
|3151|6955|SrcAlpha, One|Off|LEqual|
|3228|31276|SrcAlpha, OneMinusSrcAlpha|Back|LEqual|
|3284|5729|SrcAlpha, One|Back|LEqual|
|3300|31279|SrcAlpha, OneMinusSrcAlpha|Back|LEqual|
|3328,3329,3330,3331|7498|SrcAlpha, OneMinusSrcAlpha|Off|Always|

上述绘制 ZWrite 全部关闭；主图均启用真实捕获的 sRGB 解码。每个 EID 的 CB 必须各自设置，尤其颜色分别可能为约 3、8、16 倍，不能沿用同一默认材质。

## FlowFire 的执行逻辑

旧草稿把 Flowmap 当成位置偏移，已完整替换。原程序没有移动顶点。实际流程为：

1. VS 对 UV0.xy 做 Flowmap ST 和时间滚动，以显式 mip 1 采样 RG。RG 是绝对 UV，不是 [-1,1] 的方向。
2. 主图 ST UV 与 flow RG 以 UV1.y 混合，以 `abs(UV1.x)` 弧度绕 (0.5,0.5) 旋转。
3. Mask 独立 ST 后以 `_LightAngle` 弧度绕中心旋转；Flowmap 采样结果插值给 FS。
4. 溶解 UV 独立 ST，与插值后的 Flowmap RG 以 UV1.y 混合，再加 `_Diss_UV*time`。
5. 溶解和火焰均使用同一原始阈值函数：`t=saturate((noise+1-threshold*(2-softness)-softness)/(1-softness)); result=t*t*(3-2*t)`。
6. 溶解阈值来自 UV1.z，火焰阈值来自 UV1.w。当前火焰 softness 为 **-0.33**，不能使用 Range(0,1) 限制或改为普通 smoothstep。
7. Alpha 来自主图 A/R、顶点 A、`_Color.a`、溶解、`_Alpha`。Mask 只影响 RGB，不能额外乘到 Alpha。
8. RGB 基色是主图*顶点色*`_Color`；火焰加色 `_Fire_Color.rgb*fire` 不再乘顶点色或 `_Color`；Mask 经 `min(pow(maskR,_Mask_Power),1)` 处理，同时作用于基色和火焰。`_Fire_ON` 控制两者之间的插值。

| 属性 | Resource ID | sRGB decode | Wrap | Mips |
|---|---|---|---|---|
|_Main_Tex|23500|true|Clamp|1|
|_Fire_Tex|23500|true|Clamp|1|
|_Mask_Tex|6921|true|Repeat|9|
|_Diss_Tex|7171|true|Repeat|1|
|_Flowmap_Tex|23488|true|Repeat|1|

Flowmap 即便用于 UV，也必须保留抓帧中实际的 sRGB 解码。VS 请求 mip 1，而该纹理只有一个 mip，原硬件按可用范围限制到 mip 0；请不要给这张图生成额外 mip 改变采样结果。

EID3176 的 RGB/Alpha 均为 SrcAlpha, OneMinusSrcAlpha；Cull Back、ZTest LEqual、ZWrite Off。公开属性 `_Cull/_ZTest/_ZWrite/_SrcBlend/_DstBlend/_SrcBlendAlpha/_DstBlendAlpha` 均供统一材质配置器写入。

## 顶点数据绑定

- Particle: POSITION、TANGENT float4、COLOR float4、UV0 float4、UV1 float4、UV2 float4。GL 若输入只有2个 UV 分量，读 vec4 时默认 Z=0、W=1；不能一律补 ZW=(0,0)。EID3151 的 tangent 是 GL generic (1,0,0,1)。
- Flow: POSITION、COLOR、UV0 float4、UV1 float4。UV1 四通道承载旋转/flow/溶解/火焰控制，不可压缩成 float2，也不可错绑 UV2。
- COLOR 原始为 UNorm8，必须按字节/255 保留；网格颜色不是需要手工 sRGB 转线性的颜色属性。
- 每次绘制的 POSITION/object matrix 应与导出空间一致；源码使用标准 ObjectToWorld，不能在已经世界化的网格上重复应用原物体矩阵。

## 时间与精度

两个 Shader 使用 `_UseCaptureTime=1`、`_CaptureTime=126.3208237` 作为当前帧固定时间；关闭时使用 Unity 内置 `_Time.y`。此开关仅改变 Shader 内时间，不能回放原粒子模拟/UV 自定义数据的生命周期。

全路径使用 float，与桌面 GLSL 浮点执行精度相匹配。片元采样抵消 URP 全局 mip bias，以恢复原纹理采样 bias=0；显式 VS LOD 保留原值。

## 验证状态

已经逐项核对本文件所列 4 个 VS/FS 的实际执行语句、采样器绑定、9 次绘制状态和动态分支。Unity 编译与整场景 RenderDoc/Unity 像素对比由主验证流程执行，本记录不将源码对照等同于画面验证。
