# TEXCOORD preservation upgrade

The importer now auto-detects TEXCOORD0–7 from every CSV and preserves each channel's 1–4 component dimension using Mesh.SetUVs. Missing channels are not created. A header with missing intermediate components or a vertex row with missing UV values fails explicitly rather than fabricating data. The old two-channel XY manual mapping remains available when automatic preservation is disabled.

Unity FBX Exporter 4.2.1's ExportUVs reads List<Vector2> and compacts UV layers. Contiguous 2D channels still use ordinary FBX. Non-2D or sparse layouts additionally save `*_verts.mesh.asset`; Apply / Update Scene replaces the instance MeshFilter's mesh with this asset. Re-export updates it in place, keeping its GUID and replacing removed channels. FBX importer settings are not changed. A standalone FBX cannot represent the extra z/w values; keep the companion mesh asset for those draws.

## Evidence

- Reconstructed focused CSV fixtures from the stored Frame 4414 vertex/index buffers for all 33 draws identified in E1551–3479. Fixtures contain actual POSITION and TEXCOORD values; unrelated attributes were omitted to verify they are not invented.
- Checked 13,364 UV component values through mesh construction and native asset serialization/reload: maximum error 0.
- Exactly five captured layouts required native companions: E3176, E3190, E3265, E3266, E3267.
- Eight synthetic edge cases cover no UV, scalar/2D/3D/4D UVs, sparse channel numbers, UV7, all eight channels, and malformed component sequences. All passed.
- All original 84 CSV files retain their UV dimensions and normal/tangent presence. None requires an unnecessary companion mesh.
- Three representative FBX export/import tests passed, including automatic full-mesh selection for four-dimensional data. Importer settings were unchanged.
- UV-to-triangle-corner associations were checked for two 2D multi-channel FBX files. UV values were exact; normal FBX position round-trip error was at most 0.00001574 units. Exact rounded-position string comparisons were replaced with a positional tolerance to avoid false mismatches at rounding boundaries.
- Temporary assets under Assets/__RdocTexCoordUpgradeCheck were removed via Unity's asset tool after validation. All retained diagnostics and fixtures are outside Assets, in this directory.

The three `.cs.txt` files are method bodies for the Unity execute-code tool; run captured-data, regression, and FBX-corner checks in that order. They create the isolated test asset folder; remove that folder through Unity after verifying the results.

This change concerns vertex UV data. It does not reconstruct special shader logic, vertex shader offsets, or shear transforms.
