# Frame 4414 / EID 1551–3479

This range has 182 draw calls and 13 VS/PS program combinations. The first draw is 1600; events 1551–1599 are setup, so exporting 1600–3479 gives the same mesh draws as 1551–3479. Live RenderDoc draw enumeration confirms this count. All draws have one instance.

## RenderDoc CSV exporter fields

| Field | Value |
|---|---|
| Start | 1600 (1551 also works for export; use 1600 for the debug buttons) |
| End | 3479 |
| VS CBuffer | UnityPerDraw |
| Matrix variable | hlslcc_mtx4x4unity_ObjectToWorld |
| Layout | Column-Major |
| Inst CBuffer | UnityInstancing_PerDraw0 |
| Inst template | unity_Builtins0Array[{i}].hlslcc_mtx4x4unity_ObjectToWorldArray |
| VP CBuffer | $Globals |
| VP variable | hlslcc_mtx4x4unity_MatrixVP |
| Textures / VP export | Enabled |

E1600 is a ground draw. Although numInstances is 1, its VS reads UnityInstancing_PerDraw0, not the regular UnityPerDraw model matrix. The current exporter already checks this instance buffer first for a single-instance draw. Instance 0 is at (182.5, -0.1, -45) with scale (50,1,15), verified from live shader constants. Base instance ID is 0.

## Suggested batches and limitations

- 1551–3047: 147 draws, 4 programs. Ground and ordinary scene geometry. All declared _VertexOffsetY values in this range are zero. E1912 is an exception: its M includes shear (normalized X/Z column dot product -0.46687779), so the current Unity TRS decomposition does not preserve it. Bake the full matrix into vertices, or represent the transform with a suitable hierarchy, before claiming exact restoration for E1912.
- 3048–3479: 35 draws, 9 programs. First effect draw is E3081. Includes particles, flowing UVs, dissolution, masks, and fog. Their base meshes can be exported, but a plain color-texture material does not reproduce these effects.
- Particle shaders consume vertex colors, TEXCOORD2/TEXCOORD3, and in some cases four-component UV data. The initial audit found these were lost by the old Unity converter. The later TEXCOORD upgrade now preserves channels 0–7 and per-file dimensions 1–4. For four-dimensional or sparse layouts it saves a companion Unity Mesh asset which Step 2 uses automatically, because FBX UV sets are two-dimensional.
- Some effect color textures use `_Main_Tex`, which is not currently included in the `_MainTex`/`_BaseMap` auto-assignment aliases.
- E3176 also samples `_Flowmap_Tex` in VS. The existing PS-bound texture export does not export this VS-only resource.
- E3356 subtracts `_FogShadowOffset = (0,-0.1,0.01)` from the local vertex before multiplying M. E3369 forces clip-space depth to w-1e-6. Neither operation is reproduced by applying M alone.
- The 24 draws with `_FlyOffset` currently have value 0, so that particular clip-depth offset requires no correction in this captured frame.

All 182 draws use exactly the same VP matrix as E466 in the first range. When adding this range to the current Unity scene, reuse the existing restored camera; leave Mirror world Z off and avoid creating another active camera. A separate parent group and separate CSV export directory keep the ranges easy to inspect.

This was a settings/data audit. No range export, importer modification, or Unity scene update was performed for this request. Exact program-to-EID lists are in inventory.json.
