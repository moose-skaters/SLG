# Frame4414：EID1551–3479 Pass 分析

## 结论

这段仍在同一相机下绘制场景，但主要承担**透明场景补充、特效和战争迷雾**。不是把前段完整重画，也不是一个单独的材质Shader。RenderDoc显示的Colour Pass #6涵盖多个程序及状态组合。

- 范围内182次实际draw，13组编译后VS/PS程序配对。
- 第一条实际draw是EID1600；1551–1599是资源绑定、状态和常量设置。
- 182次draw的VP矩阵均与EID466完全相同。
- 都输出到Color29999、Depth30001，范围内没有Clear。
- 全部关闭深度写入。181次启用混合，只有1600关闭混合。
- 155次SrcAlpha/OneMinusSrcAlpha，16次SrcAlpha/One，10次One/OneMinusSrcAlpha。
- 177次使用LEqual，5次使用Always（对应部分特效和上层雾）。
- 前面的Pass #5本身也有透明draw，所以不能把两段机械等同于“纯不透明/纯透明”。

## EID1550：范围前的CopyDepth

截图当前选中的1550属于Depth-only Pass #1，不属于后面的Colour Pass #6。

其VS绘制全屏三角形列表，FS只做：
```glsl
gl_FragDepth = texture(_CameraDepthAttachment, screenUV, _GlobalMipBias.x).x;
```

输入Depth30001为720×1280，输出Depth30002为360×640，深度比较Always、写深度开启，没有颜色输出。这是半分辨率场景深度复制，不是再次绘制场景模型或生成光源阴影图。

EID3356直接把30002绑定为_CameraDepthTexture，线性化后与雾几何的深度相减，控制雾阴影/交界处的Alpha。因此后续还原雾时，除了Shader，还需在正确时机准备这张深度快照和FogOfWar遮罩。

## 建议按7个功能组组织

此表是为了可读还原而做的功能归类，不声称知道原始Unity Shader资产数。

| 功能组 | draw数 | 程序 | 内容 / 复用关系 |
|---|---:|---|---|
| Ground基础变体 | 1 | 23411 | EID1600，VS与466相同；FS没有SparkMap/SpecMaskMap采样，使用另一组控制图和地表贴图，补上此前蓝色背景区域 |
| SceneLit透明场景 | 137 | 17041 / 7527 | 133个常规 + 4个AlphaClip；与已还原SceneLit的VS/FS资源一致，可以复用程序并配置新材质与Blend/ZWrite |
| SceneTint简单环境色 | 9 | 17046 | 2101,2147,2149,2204,2206,2252,2297,2299,2357；主贴图×BaseColor×LightColor1×LightIntensity1，Alpha为贴图A×BaseColor.a |
| GeneralVFX_A | 24 | 31699 / 7836 / 23419 / 7831 / 11025 | 共5个程序变体：单图、高度淡出、双图/Mask/Fresnel、噪声扰动、溶解等；常见加法或预乘混合 |
| GeneralVFX_B | 8 | 7667 | 3151,3228,3284,3300,3328,3329,3330,3331；另一套特效逻辑，支持Parallax、Flipbook帧间混合、饱和度/对比度、预乘开关 |
| FlowFire | 1 | 31718 | EID3176；VS采样Flowmap，FS包含火焰、Mask和溶解纹理 |
| FogOfWar | 2 | 29912 / 29915 | EID3356为读取深度的雾阴影，3369为带流动纹理/噪声的雾层，两者都使用FogOfWar遮罩 |

GeneralVFX_A与B拥有不同的参数布局和计算方式，按学习可读性先分开。不能因为CB声明了大量功能就认为本次变体都执行了它们；例如GeneralVFX_B本次只声明了Main_Tex采样器，但FS的动态分支确实包含视差与帧间混合。

GeneralVFX_A变体明细：
- 31699：3081。
- 7836：3106,3190,3201,3202,3239,3240,3265,3266,3267,3310,3311,3312,3390,3391,3411,3469。
- 23419：3128,3129。
- 7831：3213,3479。
- 11025：3251,3252,3253。

SceneLit的AlphaClip四次为1863、1912、2078、2084。这里的133+4次全部开启透明混合并关闭深度写入；其中122个材质Color.a为1，但仍可能通过贴图Alpha产生透明区域。不能仅看是否开启Blend就判断每个像素都半透明。

## 和前段的实际关系

stage_1523.png、stage_1600.png、stage_3047.png、stage_3479.png均直接导自当前原捕获，没有替换Shader。

- 截至1523：之前已还原的场景骨架、角色与局部地块。
- 截至1600：另一张Ground补上大片地面。
- 截至3047：透明场景绘制补入帐篷、建筑、载具、场景贴片等内容。
- 截至3479：增加特效和明显的战争迷雾覆盖。

本段继续使用前段深度做遮挡，但自己不写深度；Depth30002快照也不会包含本段后来新增的透明几何。绘制顺序和深度复制时机是效果的一部分。

## 后续还原注意点

1. SceneLit共137次可以复用已还原Shader；Ground需要核对这个无屏幕高光变体与新材质。无需根据13个GPU程序就创建13个独立Shader文件。
2. SceneTint的透明度只有一次BaseColor.a，与SceneLit常规透明度乘两次Color.a不同，不能只凭外观相近直接换材质。
3. VFX的VS读取顶点色、多个TEXCOORD/粒子自定义数据，部分有相机偏移或时间相关变换。只导POSITION与UV0不足以完整还原。
4. 要分别保留普通Alpha、加法、预乘等混合，以及少数Always深度测试。
5. FogOfWar需要半分辨率深度快照及两张雾遮罩；不能用单个普通Unlit材质替代。
6. 当前第一段为了验证逐draw次序使用了自定义队列。进入第二段时，需要一起安排两段队列与CopyDepth边界，不能只追加Mesh后期待URP自动在相同时机生成深度。

## 证据文件

- classification.json：全部182个EID、13个程序与固定状态。
- eid_groups.md：逐组完整EID清单。
- pass_progression.png：四个阶段的可视对比。
- 原始逐draw记录：Reconstruction/Raw/Frame_4414/Draws/。
- 原始GLSL：Reconstruction/Raw/Shaders/。

本次为只读分析与证据导出，没有修改Unity场景或Shader。

