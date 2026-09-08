# Last-Z RDC reconstruction

Target: all 13 captures in `D:/LastZ`, one editable Unity scene per frame, readable URP HLSL, pixel comparisons against original capture outputs.

Environment: Unity 2022.3.62f1, Universal RP 14.0.12. Capture API: OpenGL (confirmed frame 1526).

## Layout

- `Raw/`: original draw state and GLSL, never used as executable Unity shader code.
- `References/`: original capture outputs and pass references; comparison only.
- `Reports/`: completeness, shader provenance and image differences.
- `Tools/`: reproducible extraction, conversion and validation scripts.
- `../Assets/LastZ/`: reconstructed scenes and organized runtime assets.

## Acceptance

Completion requires all draws classified, geometry and resources recovered, every active shader path translated into readable HLSL, Unity compilation, rendered frames and numerical/image differences for every frame. A reference image displayed on a quad does not count as scene reconstruction. Export success does not count as visual validation.

## Current status

Inventory: 13 captures. Frame 1526: 738 draws, 54 clears, 185 textures, 623 buffers; capture contains two similar draw sequences and emulator/window composition. No reconstructed frame has passed validation yet.

Official URP reference: https://docs.unity.cn/Packages/com.unity.render-pipelines.universal@14.0/manual/urp-shaders/birp-urp-custom-shader-upgrade-guide.html
