# Frame 4414：EID 468–1523 网格导出与 Shader 汇总

核查日期：2026-09-07。抓帧：`D:/LastZ/Last-Z-frame4414.rdc`，OpenGL。

核查对象：`C:/Users/admin/AppData/Roaming/qrenderdoc/extensions/rdoc_csv_exporter`。用户消息中的转义路径对应本机这个目录。

## 结论

可以通过这个插件导出该范围的 VS 输入网格和模型矩阵，并在 Unity 中恢复物体世界变换。但是当前版本不能直接保证所有顶点与抓帧精确重合：12 次绘制包含额外的顶点 Y 偏移，插件没有导出或应用该参数。

- 严格 EID 468–1523：83 次绘制，7 组 OpenGL Program / VS+PS 组合。
- 按实际 GLSL 功能归纳：5 类材质功能，两类各有两个程序变体。此分类不是原始 Unity Shader 资产名称。
- 截图首个地面 draw 实际是 EID 466；EID 468 是绑定纹理。若要包含它，范围应为 466–1523：84 次绘制、8 组程序、6 类功能。
- EID 466 为一个 6 实例地面 draw，不能只导出一份网格后全部放在同一位置。
- 绘制次数不等于独立 Mesh 资产数或原始 GameObject 数。此处统计的是抓帧实际使用的程序，不是项目全部 Shader。

## 七组程序

下面的程序编号均为本帧 ResourceId。功能名称根据 GLSL 代码归纳。

| Program | VS / PS | Draw 数 | 功能 | EID |
|---|---|---:|---|---|
| 17050 | 17048 / 17049 | 11 | 基础贴图乘颜色，可选平面模糊阴影 | 496, 505, 514, 523, 532, 541, 1041, 1050, 1453, 1460, 1467 |
| 17041 | 17039 / 17040 | 60 | 通用场景光照，包含自发光、Fresnel、昼夜及贴图序列等分支 | 571, 573, 580, 582, 584, 595, 606, 617, 623, 629, 640, 651, 663, 675, 677, 700, 702, 704, 706, 708, 732, 743, 754, 756, 767, 769, 771, 794, 818, 841, 843, 845, 869, 878, 880, 903, 905, 907, 914, 925, 936, 938, 962, 973, 984, 995, 997, 1196, 1204, 1217, 1222, 1369, 1380, 1422, 1428, 1492, 1503, 1505, 1516, 1523 |
| 7527 | 7525 / 7526 | 6 | 通用场景光照的 Alpha Clip 变体 | 1169, 1282, 1339, 1345, 1347, 1400 |
| 31017 | 31015 / 31016 | 1 | 按世界高度渐变着色 | 1016 |
| 7531 | 7529 / 7530 | 2 | Specular/Gloss 高光与细节材质，带反射 Cubemap | 1084, 1255 |
| 31745 | 31743 / 31744 | 1 | 同一高光/细节功能族的裁切变体，无反射 Cubemap 采样 | 1313 |
| 7523 | 7521 / 7522 | 2 | 法线贴图、金属度/粗糙度/AO、反射与自发光 | 1122, 1137 |

边界补充：EID 466 使用 Program 29883，VS 29881 / PS 29882；地形多层 Splat 混合、法线与高度混合，600 索引、6 实例。

计数口径：严格范围内 VS 资源 ID 有 7 个、PS 资源 ID 有 7 个；按源码哈希去重则是 5 份 VS、7 份 PS。17041 与 7527 的 VS 源码相同；7531 与 31745 的 VS 源码相同。7 个 VS 和 7 个 PS 配对成 7 组程序，不能说成 14 种材质。

17041 的 60 次绘制还使用了不同固定管线状态：51 次关闭混合并写深度，9 次启用透明混合且不写深度；17050 对应为 2 次和 9 次。复原外观时，不能仅按 Program 合并为一套固定渲染状态。

## CSV 插件的正确配置

严格范围的 83 次 draw 都是非实例化 TriangleList，均有 `UnityPerDraw` 中的 ObjectToWorld；读取的矩阵均非单位矩阵，未检出负行列式或明显剪切（基向量正交误差阈值 1e-5）。因此当前导入器的 TRS 分解适用于本次数据。

| 配置项 | 值 |
|---|---|
| EID Start / End | 468 / 1523；需要首块地面则用 466 / 1523 |
| VS CBuffer Name | `UnityPerDraw` |
| Matrix Var Path | `hlslcc_mtx4x4unity_ObjectToWorld` |
| Matrix Layout | `Column-Major` |
| Inst CBuffer（EID 466） | `UnityInstancing_PerDraw0` |
| Inst Var Template（EID 466） | `unity_Builtins0Array[{i}].hlslcc_mtx4x4unity_ObjectToWorldArray` |
| VP CBuffer Name（可选相机数据） | `$Globals` |
| VP Var Path | `hlslcc_mtx4x4unity_MatrixVP` |

EID 466 的 `unity_BaseInstanceID` 是 0。实例配置须覆盖插件默认值 `UnityInstancing_PerInstance` / `unity_ObjectToWorld[{i}]`；这些默认值不匹配本次地面 shader。应检查 6 份实际矩阵，不能把导出成功视为读取成功：插件在找不到矩阵时有回退单位矩阵的分支。

插件流程是 VS 输入数据 → 每个 draw 的 CSV + `matrices.json` → 随附 `UnityEditor/RdocImporter.cs` 的 CSV→FBX → Apply Transform。只导入 CSV/FBX，不应用 JSON 矩阵，并不能得到世界位置。

CSV 常用列是 `in_POSITION0`、`in_NORMAL0`、`in_TEXCOORD0`；1122/1137 还要保留 `in_TANGENT0` 和 `in_TEXCOORD1`。各组顶点布局不完全相同，批量导入时确认列映射。

这里的输入顶点与 ObjectToWorld 是 Unity 提交的模型/世界数据。不能仅凭抓帧 API 为 OpenGL 就额外翻转 Z。此导入器 Apply Transform 的 Flip Z 默认关闭；恢复原 Unity 数值坐标时应先保持该设置，并通过一个实际 draw 校核 FBX 往返后的轴向和比例。若主动改坐标系，顶点、矩阵和相机必须一致变换。

例如 EID 606 的模型原点是 `(155, 0, 70)`。这是物体原点，不是包围盒中心。

## 必须补偿的顶点偏移

Program 17050、17041、7527 的 VS 实际使用：

```text
worldPosition = ObjectToWorld * float4(localPosition + (0, _VertexOffsetY, 0), 1)
```

当前插件导出原始输入顶点和 M，不会额外保存 `_VertexOffsetY`。本范围中非零值如下（四舍五入）：

| 局部 Y 偏移 | EID |
|---:|---|
| +0.01 | 606, 617, 623, 629, 818, 973, 995, 997, 1339, 1345, 1347 |
| +0.02 | 1050 |

复原时可在 Unity shader 中保留偏移；也可先把它烘入局部顶点，再套 M。二者只做一次。不要直接把相同数值加到世界 Y，因为局部轴和缩放会影响结果。例如 1339 的局部 +0.01 对应世界 +0.0095 Y。

本范围 VS 没有骨骼混合或蒙皮贴图采样逻辑；`_GPUSKin_TextureSize` 的声明本身不代表该变体执行了 GPU 蒙皮。VS 输入可以恢复这一帧已提交的姿态，但这不等于恢复原始骨骼、动画和资产层级。

## 核查证据与验证边界

- 使用 RenderDoc MCP 打开同一帧并取得实时 draw 列表；与本地 `Raw/Frame_4414` 逐 draw 记录比对范围。
- 对 466、496、571、1016、1084、1122、1169、1313 实时核查 VS/PS 资源 ID，覆盖全部程序组。
- 实时读取 EID 606 的 `_VertexOffsetY = 0.009999999776482582`，与本地记录一致。
- 检查 CSV 导出和 Unity 导入器实现、全部范围内的模型矩阵、各组 VS/PS 源码。
- 本次完成的是可行性与数据审计，没有运行全量 CSV/FBX 导出和 Unity 往返视觉验证，也没有修改插件或 Unity 场景。

附加发现：当前另一个 MCP PostVS 属性建议在 EID 606 报告实际 stride 88，却按 112 字节计算属性布局，因而给出了错误的世界位置候选。不要直接采用这个自动建议。按 GLSL，606 的世界位置输出是 `vs_TEXCOORD2.xyz`、法线是 `vs_TEXCOORD1.xyz`。这不影响本次指定 CSV 插件读取 VS 输入的路线。

网格位置恢复也不等于画面恢复：纹理语义、材质参数、透明/深度状态、灯光、阴影和相机仍需匹配。该插件的纹理复制与简单赋贴图不会自动重建上述七组 shader。

完整逐 draw 数据见同目录 `inventory.json`。RenderDoc 官方 mesh 解码示例区分 VS 输入与 VS 输出，并要求依实际布局解析：[官方示例](https://github.com/baldurk/renderdoc/blob/v1.x/docs/python_api/examples/renderdoc/decode_mesh.rst)。
