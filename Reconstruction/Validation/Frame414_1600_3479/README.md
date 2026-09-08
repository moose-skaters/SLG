# Frame 4414 EID 1600–3479 world-position repair

The active scene `Assets/Scenes/SampleScene.unity` now contains 182 draw objects under `RdocImport_1600_3479`. The existing `RdocImport` group remains at 89 EID instances plus its captured camera.

The exported matrices were compared draw-by-draw with the stored RenderDoc capture data: all 182 matrices match. Thirty-two effect draws use identity ObjectToWorld matrices because their input POSITION data already contains world coordinates. Shared transforms are also intentional for EIDs 1629/1641, 1734/2581, and 3356/3369.

Repairs applied:

- EID 3300: Unity CSV parsing now accepts RenderDoc's lowercase `nan` spelling. Its previously missing FBX was generated. Four tangent vectors contain captured NaN components; the position data is finite and valid.
- EID 1912: the model matrix contains shear and cannot be represented by a Unity Transform. The full matrix is baked into `eid_1912_verts.world.mesh.asset`; the object Transform is identity. Re-running Apply preserves this route.
- EID 3356: the vertex shader subtracts `_FogShadowOffset = (0,-0.1,0.01)` before ObjectToWorld. The corresponding local `(0,+0.1,-0.01)` adjustment is baked into `eid_3356_verts.position.mesh.asset`; re-running Apply preserves it.
- `_Main_Tex` is accepted as another color-texture alias.
- Captured draw state has blending enabled for 181/182 draws. Their preview materials now use the captured source/destination blend factors, disable depth writes, and follow capture draw order through render queues. The single blended draw without a color texture is transparent instead of an opaque white screen cover. These settings improve inspection but do not recreate the full original shaders.

Validation checks all 182 scene meshes against their captured CSV vertices and model matrices, including the E3356 pre-transform offset. Maximum world AABB error is `0.0000305175781` Unity units. There are no failures. The retained old range still has 89 EID instances.

`world_position_validation.json` contains the machine-readable result. `corrected_positions_blend_preview.png` is a captured-camera preview. Remaining white ground areas come from terrain/effect materials whose original multi-texture shader logic is not reconstructed; they are not position errors.

The pre-import scene backup is `Assets/LastZ/Validation/Frame414_1600_3479/BeforeCorrectedImport_20260908_122828.unity`.
