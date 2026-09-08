# HeightGradient：EID1016 还原与区别

实现：`Assets/LastZ/Shader/HeightGradient.shader`，Shader 名称 `LastZ/HeightGradient`。原 GLSL 为 `Assets/LastZ/GLSL/HeightGradient_vs.txt`、`HeightGradient_fs.txt`。

EID1016 的对象 `EID_1016_inst0` 已启用，绑定原有的 `Assets/RdocMeshes/eid_1016/eid_1016.mat`。SampleScene 已保存。原蓝色相机背景 #314D79、场景光照和其它已还原材质保留。

## 核心计算

设 y 为当前像素的世界坐标 Y：
```text
t = saturate((y - HeightStart) / (HeightEnd - HeightStart))
weight = pow(t*t*(3-2*t), GradientPower)
tinted = texture(MainTex, meshUV) * Color * Intensity
texturedColor = tinted.rgb * LightColor1.rgb * LightIntensity1
RGB = lerp(GradientColor.rgb, texturedColor, weight)
Alpha = tinted.a
```

因此它是**按物体世界高度替换颜色**，而不是光照阴影：
- 低于起始高度时，直接输出 GradientColor.rgb，底部纹理细节完全被覆盖。
- 高于结束高度时，显示调色并乘游戏环境色后的贴图。
- 中间先 smoothstep，再做幂运算。Power 小于1会较早恢复贴图，大于1会延后。
- GradientColor 不再乘贴图、Color、Intensity或环境色。若把它改成乘暗贴图，效果就不同了。
- 高度渐变只改 RGB；GradientColor.a 没有参与，Alpha 始终来自主贴图 × Color.a × Intensity。
- 读取的是世界 Y。把物体上下移动会改变渐变位置；调整相机高度不会直接改变渐变。

当前捕获：
| 参数 | 值 |
|---|---|
| HeightStart / HeightEnd | 0 / 10 |
| GradientPower | 0.2 |
| GradientColor（线性 RGB） | (0.051269464, 0.054480284, 0.064803280) |
| Color / Intensity | 白色 / 1 |
| LightColor1 | 约白色，保留捕获线性数值 |
| LightIntensity1 | 1.003173828 |

## 与其它场景 Shader 的区别

| Shader | 空间依据与主要用途 | 光照与其它功能 |
|---|---|---|
| Ground | 世界 XZ UV、控制图驱动的四层地表混合；部分变化由相机 Y 控制 | 地表法线、主光+SH、屏幕高光/阴影等 |
| SceneSimple | 网格 UV 的单张贴图乘颜色 | Unlit，可选屏幕平面阴影和R透明度；没有高度染色 |
| SceneLit | 网格 UV、常规/裁切变体，通用场景材质 | 自定义昼夜色，可选 Lambert/SH、Fresnel、自发光、序列图；高度功能只门控Alpha |
| HeightGradient | 像素世界 Y 控制底部纯色与贴图的 RGB 渐变 | 不使用主光方向、法线、SH、高光或Fresnel；只使用游戏环境颜色乘数 |

尤其不要混淆：
- Ground 的相机高度控制远景混合；HeightGradient 的物体世界高度控制颜色渐变。
- SceneLit 的 FadeY 是 Alpha 硬阈值；HeightGradient 是 RGB 平滑过渡加幂曲线。
- HeightGradient 不会因为平行光转向而改变物体阴面；底部深色是美术指定的高度染色。

LightColor1、LightIntensity1 是与 SceneLit 一样的游戏自定义参数，并非 URP MainLightColor；不能直接用当前主灯的1.3强度替换。

## 忠实翻译及资源设置

- VS 原样传递 UV，没有 MainTex_ST，也没有局部顶点偏移。
- 原 VS 虽计算法线，但 FS 没有读取，已删除无效插值。
- 原 CB 的 CutOff 没有被使用，FS 没有 discard/clip，因此没有添加 Alpha Clip。
- 原 log2→乘Power→exp2 重写为可读 pow。有效Power>0时对权重0明确返回0；仅为原本未定义的起止同高区间增加硬切换保护。
- 材质设置 Power 范围为正数；非零的反向高度区间仍按原公式保留。
- GPU纹理30578为512×512 sRGB RGBA8，原始10级mip保存在 `Assets/LastZ/Shader/HeightGradientTextures/Texture_30578.asset`。Bilinear、Repeat、anisoLevel=0，不重新生成或压缩。
- 原采样无 mip bias，抵消URP14宏自动添加的GlobalMipBias。
- Cull Back、ZTest LEqual、ZWrite On、Blend Off，与原状态相同。材质队列3053使其处于完整EID提交顺序中的正确位置。

## 验证

RenderDoc 与 Unity 实际渲染画面对比，720×1280、后处理之前。参考重放保留 Ground、SceneSimple、SceneLit、HeightGradient，仅暂时屏蔽尚未还原的 Specular 两个变体和 Metallic。对照绘制前EID997与绘制后EID1016，统计1016实际改变的区域，避免用大量背景夸大精度。

- EID1016实际影响7,467个像素。
- 默认参数：99.9866% 的区域像素RGB完全相同；只有1个像素的1个通道相差1/255。
- 区域RGB MAE：0.0000446409/255，最大差异1/255。
- 改为反向区间 Start=2、End=0.5、Power=2，并修改底色、Tint、Intensity后，额外GPU双边测试的该区域RGB完全一致。
- 模型矩阵与原数据最大差异0；局部网格包围盒差异约2.4e-7。
- Shader编译与Unity Console无错误/警告。测试材质参数和相机设置已恢复，原RenderDoc捕获已重新打开清除替换，场景已保存。

对比PNG统一将Alpha设为不透明便于查看，上述指标比较RGB。完整组合图仍含此前SceneLit的少量轮廓/重叠差异，不将本次EID1016的高一致性冒充整张游戏画面完全一致。

文件：
- comparison.png：完整已还原组合的两侧图与16倍差异。
- gradient_crop_comparison.png：1016局部放大。
- metrics.json / compare.py：指标与复算。
- source_data.json / source_geometry.json / final_status.json：原数据与保存检查。
- setup_material.cs.txt / capture_unity.cs.txt / reversed_gradient.glsl：配置、渲染和曲线测试记录。
- backup/：修改前材质、场景与原纹理导入设置。

