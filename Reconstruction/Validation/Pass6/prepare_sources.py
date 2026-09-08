from pathlib import Path
import json,struct,csv,shutil,collections
import numpy as np
from PIL import Image
ROOT=Path('D:/Last-Z')
OUT=ROOT/'Reconstruction/Validation/Pass6'
for d in ['backup','mesh_data','texture_data']: (OUT/d).mkdir(parents=True,exist_ok=True)
draw_root=ROOT/'Reconstruction/Raw/Frame_4414/Draws'
blob_root=ROOT/'Reconstruction/Raw/Blobs'
before={x['eid']:x for x in json.loads((OUT/'scene_before.json').read_text(encoding='utf-8'))}
for p in [ROOT/'Assets/Scenes/SampleScene.unity',ROOT/'Assets/LastZ/Shader/Ground.shader',ROOT/'Assets/LastZ/Shader/SceneTint.shader']:
 dst=OUT/'backup'/(p.name+'.txt')
 if not dst.exists():shutil.copy2(p,dst)
blobcache={}
def blob(b):
 key=b['blob']['sha256']
 if key not in blobcache:blobcache[key]=(blob_root/(key+'.bin')).read_bytes()
 return blobcache[key]
def cb_vars(stage,name):
 cb=next((c for c in stage['constant_buffers'] if c['name']==name),None)
 return cb['variables'] if cb else []
def values(variables):return {v['name']:v['value'] for v in variables if v.get('value')}
def matrix(d):
 v=cb_vars(d['stages']['vertex'],'UnityInstancing_PerDraw0')
 if v:
  return [x['value'] for x in v[0]['members'][0]['members'][0]['members']]
 v=cb_vars(d['stages']['vertex'],'UnityPerDraw')
 return [x['value'] for x in next(v for v in v if v['name']=='hlslcc_mtx4x4unity_ObjectToWorld')['members']]
def decode_mesh(d):
 ib=d['index_buffer'];stride=ib['byteStride']
 # Action indexOffset is in index elements, separate from binding byteOffset.
 offset=ib['byteOffset']+d['indexOffset']*stride
 idx=np.frombuffer(blob(ib),dtype='<u2' if stride==2 else '<u4',count=d['numIndices'],offset=offset).astype(np.int64)+d['baseVertex']
 unique=list(dict.fromkeys(idx.tolist()));remap={i:n for n,i in enumerate(unique)}
 attributes={};details=[]
 for a in d['vertex_inputs']:
  if not a['used']:continue
  name=a['name'];fmt=a['format'];n=fmt['compCount'];default=[0.,0.,0.,1.]
  out=[]
  if a['genericEnabled']:
   out=[list(a['genericValue']['floatValue'])]*len(unique)
  else:
   vb=d['vertex_buffers'][a['vertexBuffer']];buf=blob(vb);code='f' if fmt['compType']==1 else 'B'
   for v in unique:
    offset=vb['byteOffset']+a['byteOffset']+v*vb['byteStride']
    val=list(struct.unpack_from('<'+code*n,buf,offset))
    if code=='B':val=[x/255 for x in val]
    out.append(val+default[n:])
  attributes[name]=out
  details.append({'name':name,'components':n,'generic':a['genericEnabled']})
 triangles=[remap[i] for i in idx.tolist()]
 return attributes,triangles,details,idx,unique
families={23411:'Ground',17041:'SceneLit',7527:'SceneLit',17046:'SceneTint',31699:'GeneralVFX',7836:'GeneralVFX',23419:'GeneralVFX',7831:'GeneralVFX',11025:'GeneralVFX',7667:'ParticleVFX',31718:'FlowFire',29912:'FogOfWar',29915:'FogOfWar'}
rows=[];textures={};audit=[]
for di,eid in enumerate(sorted(int(p.stem[1:]) for p in draw_root.glob('e*.json') if 1551<=int(p.stem[1:])<=3479)):
 d=json.loads((draw_root/f'e{eid}.json').read_text());vs=d['stages']['vertex'];ps=d['stages']['pixel'];program=int(d['gl']['fragmentShader']['programResourceId'].split('::')[-1])
 attrs,tris,attr_info,indices,unique=decode_mesh(d)
 # A compact float32 payload per attribute; retain complete TEXCOORD vectors and floating vertex color.
 files={}
 for name,v in attrs.items():
  fn=f'{eid}_{name}.f32';arr=np.array(v,dtype='<f4');(OUT/'mesh_data'/fn).write_bytes(arr.tobytes());files[name]=fn
 (OUT/'mesh_data'/f'{eid}_indices.i32').write_bytes(np.array(tris,dtype='<i4').tobytes())
 m=np.array(matrix(d)).reshape(4,4).T
 csvrows=list(csv.DictReader((ROOT/f'Assets/LastZ/CSV/Frame414/eid_{eid}/eid_{eid}_verts.csv').open(encoding='utf-8-sig')))
 csv_error={};csv_missing=[]
 for name,vals in attrs.items():
  dim=next(x['components'] for x in attr_info if x['name']==name)
  for c,axis in enumerate('xyzw'[:dim]):
   k=name+'.'+axis
   if k not in csvrows[0]:csv_missing.append(k);continue
   if len(csvrows)==len(indices):
    actual=np.array([float(r[k]) for r in csvrows]);expected=np.array(vals)[np.array(tris),c]
    err=np.abs(actual-expected)
    if err.max()>1e-5:csv_error[k]=float(err.max())
 snapshot=before.get(eid,{});objs=snapshot.get('objects',[])
 matrix_error=None if not objs else float(np.max(abs(np.array(objs[0]['matrix']).reshape(4,4).T-m)))
 positions=np.array(attrs['in_POSITION0'])[:,:3]
 audit.append({'eid':eid,'csvMissingComponents':csv_missing,'csvMaxErrors':csv_error,'sceneMatrixMaxError':matrix_error,'sceneCount':len(objs),'sourceVertexCount':len(unique),'sceneVertexCount':objs[0]['vertices'] if objs else 0,'sourceMatrix':m.T.ravel().tolist(),'attributes':attr_info})
 params=values(cb_vars(vs,'UnityPerMaterial'));params.update(values(cb_vars(ps,'UnityPerMaterial')))
 globals=values(cb_vars(vs,'$Globals'));globals.update(values(cb_vars(ps,'$Globals')))
 binds=json.loads((ROOT/f'Assets/LastZ/CSV/Frame414/eid_{eid}/texture_bindings.json').read_text())['bindings']
 # Existing exporter only records pixel samplers: add vertex Flowmap and any remaining VS resource.
 for r in vs.get('resources',[]):
  if r.get('name') and r['type']=='texture' and not any(b['property_name']==r['name'] for b in binds):
   binds.append({'property_name':r['name'],'resource_id':r['resource_id']})
 for bind in binds:
  rid=bind['resource_id'];sources=vs.get('resources',[])+ps.get('resources',[]);resource=next(x for x in sources if x['resource_id']==rid)
  used=next((u for s in [vs,ps] for u in s.get('used_resources',[]) if u['descriptor']['resource']==rid),None)
  if resource['format']=='D24S8':continue
  tid=int(rid.split('::')[-1]);sampler=used['sampler'] if used else None
  # Color-space determined by storage format and GL sRGB decode flag.
  srgb='SRGB' in resource['format'] and (used is None or used.get('srgb_decode',True))
  key=f"{tid}_{'srgb' if srgb else 'linear'}"
  bind['assetKey']=key
  if key not in textures:
   textures[key]={'key':key,'id':tid,'width':resource['width'],'height':resource['height'],'mips':resource['mip_levels'],'srgb':srgb,'sampler':sampler,'referenceEid':eid}
   src=ROOT/f'Reconstruction/Raw/Frame_4414/Textures/{tid}';data=bytearray();missing=False
   for mip in range(resource['mip_levels']):
    png=src/f's0_m{mip}.png'
    if not png.exists():missing=True;break
    im=Image.open(png).convert('RGBA');data+=im.transpose(Image.Transpose.FLIP_TOP_BOTTOM).tobytes()
   if not missing:(OUT/'texture_data'/f'{key}.rgba').write_bytes(data)
   else:textures[key]['needsLiveExport']=True
 state=d['fixed']['fragment_output']
 rows.append({'eid':eid,'family':families[program],'program':program,'params':params,'globals':globals,'bindings':binds,
              'vertexCount':len(unique),'indexCount':len(tris),'attributes':files,'indices':f'{eid}_indices.i32','matrix':m.T.ravel().tolist(),
              'queue':3100+di,'boundsMin':positions.min(0).tolist(),'boundsMax':positions.max(0).tolist(),
              'blend':state['color_blends'][0],'depth':state['depth_state'],'cull':state['rasterizer']['state']['cullMode']})
 mat=ROOT/f'Assets/RdocMeshes/eid_{eid}/eid_{eid}.mat';dest=OUT/'backup'/f'eid_{eid}.mat.txt'
 if mat.exists() and not dest.exists():shutil.copy2(mat,dest)
(OUT/'source.json').write_text(json.dumps(rows,indent=2),encoding='utf-8')
(OUT/'textures.json').write_text(json.dumps(list(textures.values()),indent=2),encoding='utf-8')
(OUT/'geometry_audit.json').write_text(json.dumps(audit,indent=2),encoding='utf-8')
print('draws',len(rows),'textures',len(textures),'missing tex',[t['key'] for t in textures.values() if t.get('needsLiveExport')])
print('Matrix mismatch',[(r['eid'],r['sceneMatrixMaxError']) for r in audit if r['sceneMatrixMaxError'] is None or r['sceneMatrixMaxError']>0.0005])
print('CSV errors',sum(bool(r['csvMaxErrors']) for r in audit),'missing UV components',sum(bool(r['csvMissingComponents']) for r in audit))
for r in audit:
 if r['eid'] in [1600,3081,3128,3151,3176,3356]:print(r['eid'],r['csvMaxErrors'],r['csvMissingComponents'],r['sceneMatrixMaxError'])
