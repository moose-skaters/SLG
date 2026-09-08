# CSV material and camera repair

Scope: the 84 draws / 89 instances exported from Frame 4414, EID 466–1523. Updated the current RdocImport group and both C-drive plugin scripts. The prior scene is copied to `D:/Last-Z/Assets/LastZ/Validation/CsvMaterialCameraFix/Before.unity`.

## Materials

- Create a separate external `eid_N.mat` for every draw, remap the FBX embedded material, and assign it to existing imported renderers.
- Resolve source color textures from `_BaseMap` (2 draws) or `_MainTex` (81 draws), using actual shader binding indices. Added binding manifests to the old resource-only export folders from the existing capture records. Future RenderDoc exports write this manifest directly.
- The new-material shader defaults to URP Unlit for color preview; users can select a shader for new materials. It is not a recreation of the original captured shader.
- EID 466 has no `_MainTex`/`_BaseMap`: it needs terrain Splat blending. No arbitrary texture is assigned to it.
- Normals, tangents, UV generation and texture import settings remain untouched. Only the requested FBX material remap changes importer metadata.

## Camera

- Fix the old code's disabled camera and incorrect clip-space flip.
- Derive perspective camera origin directly from the inverse VP instead of intersecting near-parallel small-FOV rays. Retain the recovered projection in a serialized `RdocCameraSettings` component.
- Enable RdocCamera; preserve 720×1280 aspect ratio with viewport fitting. Preview Captured Camera renders at the original resolution independently of Scene View navigation.
- For these Unity captures Mirror world Z is OFF. Repeated Apply / Update Scene updates existing EID objects and the camera rather than adding duplicates.
- Source VP is OpenGL clip-space depth [-1,1]. Other clip-space conventions need explicit conversion before using this reconstruction.

## Validation

The results JSON verifies 84 external FBX material bindings and 83 correctly selected color textures. All 89 sampled world points project to the captured VP with maximum error 0.0007671 pixels at 720×1280. This measures camera geometry, not full-frame image equivalence. The camera projection survives a Unity domain reload.

`restored_720x1280.png` is the actual camera render. It still shows differences from the capture because terrain Splat blending, shader tint/alpha rules, lighting and the 12 known vertex Y offsets are not reproduced by a plain color-texture material.

Run the body in `validate.cs.txt` through the Unity execute-code tool to repeat the checks. It reads captured manifests and does not reconstruct or overwrite shaders.
