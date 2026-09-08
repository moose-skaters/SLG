# EID496–1523：按 Shader 逻辑与游戏用途归类

同一帧 `D:/LastZ/Last-Z-frame4414.rdc`，严格范围 496–1523。83 次实际 draw，7 组编译后的 VS/FS 配对；去重源码为 5 份 VS、7 份 FS。为后续可读 URP 还原，建议组织为 **5 个功能 Shader 文件**；加上已完成的 Ground.shader 共 6 个。这里是还原工程的功能划分，不是声称知道原始 Unity Shader 资产数量。

| 建议文件 | 程序 / draw 数 | 功能 | 已核对的游戏对象或贴图 |
|---|---|---|---|
| SceneSimple.shader | 17050 / 11 | 主贴图乘颜色，可选平面模糊阴影 | 道路边缘、地块、局部装饰；如 496、505、1041、1453 |
| SceneLit.shader | 17041 + 7527 / 66 | 通用光照、昼夜、自发光、Fresnel、序列图；Opaque/Transparent/AlphaClip 状态与变体 | 建筑、道路、草丛、载具、部分角色、枪械、道路标线 |
| HeightGradient.shader | 31017 / 1 | 世界高度驱动的颜色渐变 | 1016，建筑纹理 |
| CharacterSpecular.shader | 7531 + 31745 / 3 | Specular/Gloss、细节、可选 Cubemap；头发裁切变体 | 1084 枪械；1255 女性角色身体；1313 头发 |
| Monster.shader | 7523 / 2 | 金属度、粗糙度、AO、反射和自发光等计算 | 1122、1137，BOSS/怪物纹理 |

这些文件名是建议命名。SceneLit 的 AlphaClip 变体与普通变体的 VS 源码完全一致；FS 对比仅增加依据 _CutOff 的 discard。CharacterSpecular 的两个程序同样共用 VS 源码，FS 存在裁切与是否采样反射 Cubemap 的差异。因此无需按 7 组程序机械拆成 7 个学习文件。

## 游戏分类如何映射

- **草与普通场景共用程序**：草丛 EID754、756、767、769、771、869、878、880 使用 Program17041。代表 draw754/767/869 的增量输出已直接查看，确实是草丛。这个范围没有单独的风摆草 Shader 程序。
- **同一游戏用途可以用不同 Shader**：枪械 EID1084 使用高光功能族；EID1282 的武器图集使用 SceneLit 的裁切变体。
- **同一 Shader 可以服务不同游戏对象**：EID1084 枪械和 EID1255 女性身体使用相同 VS/FS 程序。
- **角色并非单一功能族**：EID1169 男性角色使用 SceneLit 裁切变体；1255 身体与1313头发使用 Specular 功能族；1122/1137怪物使用 Metallic 功能族。
- **场景还要细分**：既有简单贴图程序、通用光照程序，也有 1016 的世界高度渐变程序。没有必要把所有场景效果塞入一个难读的大 Shader。

物体用途依据导出的主纹理内容和代表 draw 的画面判断，不代表恢复了游戏内部对象名称或原材质资产名。BOSS/怪物的“BOSS”身份沿用用户的游戏语境。

## 证据与注意点

- 本次 RenderDoc 实时 draw 查询返回83项，首项496，末项1523；已和原始逐 draw JSON 核对。
- 实时核查各程序代表像素 Shader：496->17049，571->17040，1016->31016，1084->7530，1122->7522，1169->7526，1313->31744。
- 全部53张唯一主纹理的预览：`all_base_textures.png`。草丛代表 draw 的局部画面：`grass_draw_context.png`。
- 七组程序的完整 EID 列表见 `shader_classification.json` 或同目录原有 `report.md`。
- Program17041 中既有不透明深度写入，也有透明混合且不写深度的 draw；17050 也如此。合并为一个 Shader 文件时仍须保留各材质的 Blend/ZWrite/Queue 配置。
- 不要把声明了 NormalMap 或 GPUSkin 参数当作本次变体真的采样了它们。例如1122/1137的 FS 实际没有 NormalMap 采样；应按可执行 GLSL 逐项翻译。

