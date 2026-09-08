"""Mechanical snapshot tables used as input to human semantic and flow analysis."""
import json
import pathlib
import re
import sys

ROOT = pathlib.Path('D:/Last-Z/Reconstruction')
frame, eid = (sys.argv[1], int(sys.argv[2])) if len(sys.argv) > 2 else ('1526', 1005)
d = json.loads((ROOT / 'Raw' / ('Frame_' + frame) / 'Draws' / ('e%d.json' % eid)).read_text())
out = ROOT / 'Analysis' / ('Frame_%s_E%d' % (frame, eid))
out.mkdir(parents=True, exist_ok=True)
sources = {}
for stage, ext in [('vertex', 'vs'), ('pixel', 'ps')]:
    src = (ROOT / 'Raw/Shaders' / (d['stages'][stage]['source_hash'] + '.' + stage + '.glsl')).read_text()
    (out / (ext + '.glsl')).write_text(src)
    sources[stage] = src
(out / 'raw_data.json').write_text(json.dumps(d, indent=2))
lines = ['# Shader Analysis — Frame %s EID %d' % (frame,eid), '', '## 1. DrawCall Summary',
         '- API: OpenGL; Indexed TriangleList; ForwardLit; RT0.',
         '- Role: textured character/surface shader, custom diffuse lighting, emission, rim and height-distance fog.',
         '- Indices: %d; instances: %d.' % (d['numIndices'], d['numInstances']),
         '', '## 2. Pipeline State', '```json', json.dumps(d['fixed']['api_specific']['depth_state']),
         json.dumps(d['fixed']['common']['color_blends'][0]), '```', '', '## 3. CB Mapping Table',
         'Named Unity uniforms retain their source semantic stems; original names are the lookup keys. Values below are full capture precision.',
         '| Stage | CB | GLSL Ref | Inferred Name | Snapshot Value | Confidence |', '|---|---|---|---|---|---|']
names = {'_MainTex_ST':'baseTextureScaleOffset', '_EmissionColor':'emissionTint', '_Color':'materialColorTint',
         '_MainLightOn':'mainLightBlendWeight','_MaxAddIntensity1':'maximumAdditionalLightIntensity',
         '_VertexOffsetY':'localVertexHeightOffset','_AlphaIsR':'useRedAsOpacity','_Intensity':'outputIntensity',
         '_NoMainTextureOn':'ignoreBaseTexture','_HeroDayNight_ON':'heroDayNightBlend',
         '_EMISSIONMAPON_BUILDING_ON':'buildingEmissionEnabled','_AlphFadeY_ON':'heightAlphaFadeEnabled',
         '_EMISSIONMAPON_ON':'emissionTextureEnabled','_BlinnPhongOn':'blinnPhongEnabled',
         '_Fresnel_ON':'rimLightEnabled','_SheetAnimationON':'atlasAnimationEnabled',
         '_GPUSKin_TextureSize':'skinAnimationTextureSize','_FogGlobalDensity':'fogDensity',
         '_LightColor1':'firstSceneLightColor','_LightColor2':'secondSceneLightColor'}
for stage in ('vertex','pixel'):
    for cb in d['stages'][stage]['constant_buffers']:
        for v in cb['variables']:
            n=v['name']; vals=v.get('value',[])
            if v.get('members'): vals=[m.get('value') for m in v['members']]
            semantic=names.get(n, re.sub(r'^hlslccmtx4x4', '', re.sub(r'[^a-zA-Z0-9]', '',n)))
            semantic=semantic[0].lower()+semantic[1:]+'Snapshot'
            lines.append('|%s|%s|`%s`|%s|`%s`|HIGH: named uniform; numeric snapshot|' % (stage,cb['name'],n,semantic,json.dumps(vals)))
lines += ['', '## 4. Texture/Sampler Mapping', '| Slot | GLSL name | Resource | Semantic | Usage |','|---|---|---|---|---|']
for r in d['stages']['pixel']['resources']:
    slot=r['slot']; texnames={0:'_BaseMap',1:'_MGA',2:'_EmissionMap',3:'_ReflectionMap'} if eid==187 else {0:'_MainTex',1:'_EmissionMap'}
    semantics={0:'baseColor',1:'metallicRoughnessOcclusionEmissionMask',2:'emissionTexture',3:'reflectionCubemap'} if eid==187 else {0:'baseColorAndOpacity',1:'emissionTexture'}
    name=texnames[slot]
    lines.append('|%d|%s|%s|%s|.rgba / .rgb; see source branch|'%(slot,name,r['resource_id'],semantics[slot]))
lines += ['', '## 5. Varying Mapping', '| Source | Semantic | VS expression | PS usage |','|---|---|---|---|',
          '|vs_TEXCOORD0|baseUV|in_TEXCOORD0.xy|base/atlas UV|',
          '|vs_TEXCOORD1|worldNormal|normalize(transpose(worldToObject) * localNormal)|lighting/rim|',
          '|vs_TEXCOORD2.xyz|worldPosition|objectToWorld * (localPosition + Y offset)|view and height fade|',
          '|vs_TEXCOORD2.w|heightDistanceFog|density integration * distance, smoothstep|fog mix|',
          '|vs_TEXCOORD3|ambientIrradiance|second-order SH evaluated at world normal, clamped nonnegative|ambient lighting|',
          '|vs_TEXCOORD5/6|unusedLightingOutputs|zero|not consumed by PS|',
          '', '## 6. Vertex Input Mapping', '| Input | Semantic | Format |','|---|---|---|']
for a in d['vertex_inputs']:
    if a['used'] and a['name']: lines.append('|%s|%s|%s|'%(a['name'],a['name'].replace('in_',''),json.dumps(a['format'])))
if eid==187:
    start=lines.index('## 5. Varying Mapping'); end=lines.index('## 6. Vertex Input Mapping')
    lines[start:end]=['## 5. Varying Mapping','|Source|Semantic|VS source|PS usage|','|---|---|---|---|',
        '|vs_TEXCOORD0|packedBaseAndSecondaryUV|in_TEXCOORD0.xy and in_TEXCOORD1.xy|base/MGA/emission UV|',
        '|vs_TEXCOORD2.xyz/w|worldNormal/worldPositionX|normal transformed by inverse-transpose / objectToWorld position.x|normal/view direction|',
        '|vs_TEXCOORD3.xyz/w|worldTangent/worldPositionY|tangent transformed by objectToWorld / position.y|position assembly; tangent xyz not consumed|',
        '|vs_TEXCOORD4.xyz/w|worldBitangent/worldPositionZ|cross(normal,tangent)*handedness / position.z|position assembly; bitangent xyz not consumed|',
        '|vs_TEXCOORD5.xyz/w|ambientIrradiance/fogFactor|captured SH and height-distance fog|indirect diffuse and fog blend|',
        '|vs_TEXCOORD6|screenPosition|GL projected position|not consumed by PS|','']
    lines=[line.replace('textured character/surface shader, custom diffuse lighting, emission, rim and height-distance fog','metallic surface with captured cubemap environment BRDF, custom diffuse lighting, emission, rim and height-distance fog') for line in lines]
(out/'output_spec.md').write_text('\n'.join(lines)+'\n',encoding='utf-8')
print(out)
