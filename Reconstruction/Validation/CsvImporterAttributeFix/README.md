# CSV importer attribute validation

The 84-file scan/ParseCsv/BuildMesh checks in `validate_meshes.cs.txt` verify per-file attribute retention before FBX import. The current importer retains that behavior and does not synthesize missing normals or tangents while building the source mesh.

The user subsequently requested that Unity's FBX import settings remain untouched. `ConfigureFbxImport` and its call were removed from both copies of RdocImporter.cs. New FBX assets use the normal Unity defaults; existing FBX assets keep their existing import settings.

`validate_fbx_roundtrip.cs.txt`, the FBX portion of `results.json`, and the five FBX files under `Assets/LastZ/Validation/CsvImporterAttributeFix` are historical evidence from the earlier version that explicitly disabled attribute generation. That historical script references the removed helper and is not a test of the current version. Its post-import attribute-presence guarantees do not apply to the default Unity importer requested by the user.
