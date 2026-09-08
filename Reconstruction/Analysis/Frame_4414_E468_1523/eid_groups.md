# EID496–1523 完整分类

按可读 URP 还原的五个 Shader 功能类别组织。共 83 次绘制，以下 EID 不重复、无遗漏；区间内没有列出的 EID 是绑定资源或设置状态等非 draw 事件。文件名为建议的还原名称。

## SceneSimple — 基础贴图 / 11 次

Program 17050

```text
496, 505, 514, 523, 532, 541, 1041, 1050, 1453, 1460, 1467
```

## SceneLit — 常规变体，非草丛 / 52 次

Program 17041

```text
571, 573, 580, 582, 584, 595, 606, 617, 623, 629, 640, 651
663, 675, 677, 700, 702, 704, 706, 708, 732, 743, 794, 818
841, 843, 845, 903, 905, 907, 914, 925, 936, 938, 962, 973
984, 995, 997, 1196, 1204, 1217, 1222, 1369, 1380, 1422, 1428, 1492
1503, 1505, 1516, 1523
```

## SceneLit — 常规变体，草丛 / 8 次

Program 17041

```text
754, 756, 767, 769, 771, 869, 878, 880
```

## SceneLit — Alpha Clip 裁切变体 / 6 次

Program 7527

```text
1169, 1282, 1339, 1345, 1347, 1400
```

## HeightGradient — 世界高度渐变 / 1 次

Program 31017

```text
1016
```

## CharacterSpecular — 高光与反射 / 2 次

Program 7531

```text
1084, 1255
```

## CharacterSpecular — 头发裁切，无 Cubemap 采样 / 1 次

Program 31745

```text
1313
```

## Monster — BOSS / 怪物 / 2 次

Program 7523

```text
1122, 1137
```

## 已确认的特殊对象

| EID | 内容 | Shader 类别 |
|---|---|---|
| 1169 | 男性角色 | SceneLit |
| 1282 | 武器图集 | SceneLit |
| 1339 | 道路数字标线 | SceneLit |
| 1345 | 道路箭头标线 | SceneLit |
| 1347 | 道路箭头标线 | SceneLit |
| 1400 | 电线杆贴片 | SceneLit |
| 1016 | 建筑纹理 | HeightGradient |
| 1084 | 枪械 | CharacterSpecular |
| 1255 | 女性角色身体 | CharacterSpecular |
| 1313 | 头发 | CharacterSpecular |
| 1122 | BOSS/怪物 | Monster |
| 1137 | BOSS/怪物 | Monster |

草丛与 SceneLit 常规变体使用相同的程序，单独列出只为方便按游戏用途阅读。Alpha Clip 不代表 Blend 透明混合；同一程序内的 Blend、ZWrite、Queue 仍需逐材质恢复。Ground 的 EID466 不在本次范围。
