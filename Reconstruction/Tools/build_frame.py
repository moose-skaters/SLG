"""Build readable URP programs and exact mesh input packages from captured data."""
import collections
import hashlib
import json
import pathlib
import re
import struct
import sys
from readable_stages import STAGES
from readable_lighting_stages import register as register_lighting
from readable_stages import add
register_lighting(add)
from readable_effect_stages import register as register_effects
register_effects(add)
from readable_skin_stages import register as register_skin
register_skin(add)
from readable_particle_surface import register as register_particle_surface
register_particle_surface(add)
from readable_scene_stages import register as register_scene
register_scene(add)
from readable_light_beam import register as register_light_beam
register_light_beam(add)
from readable_metallic_stages import register as register_metallic
register_metallic(add)

ROOT = pathlib.Path('D:/Last-Z')
RAW = ROOT / 'Reconstruction/Raw'
ASSETS = ROOT / 'Assets/LastZ'
TYPE = {'float':'float','int':'int','uint':'uint','bool':'bool','mat4':'float4x4'}
for gl,hl in [('vec','float'),('ivec','int'),('uvec','uint'),('bvec','bool')]:
    TYPE.update({gl+str(n):hl+str(n) for n in range(2,5)})
TYPEPAT = '|'.join(TYPE)


def safe_name(n):
    return {'hlslcc_mtx4x4unity_ObjectToWorld':'_CaptureObjectToWorld',
            'hlslcc_mtx4x4unity_WorldToObject':'_CaptureWorldToObject',
            'hlslcc_mtx4x4unity_MatrixVP':'_CaptureViewProjection',
            'hlslcc_mtx4x4glstate_matrix_projection':'_CaptureProjection'}.get(n,'_Capture'+n.lstrip('_')[0].upper()+n.lstrip('_')[1:])


def attr_semantic(n):
    if n in ('vertex','position') or 'POSITION' in n: return 'POSITION'
    if n in ('texCoords','inCoord'): return 'TEXCOORD0'
    return n.replace('in_','')


def read_stage(d, stage):
    h=d['stages'][stage]['source_hash']
    return h, (RAW/'Shaders'/(h+'.'+stage+'.glsl')).read_text(encoding='utf-8'), STAGES[h[:12]]


def build_shader(d):
    vh,vs,v=read_stage(d,'vertex'); ph,ps,p=read_stage(d,'pixel')
    key=vh[:12]+'_'+ph[:12]
    code=v['code']+'\n'+p['code']
    helpers=v.get('helpers','')+'\n'+p.get('helpers','')
    if 'TransformCapturedObject' in code:
        helpers += '''
// GLSL column vectors preserve the original matrix multiplication order.
float4 TransformCapturedObject(float4 localPosition)
{
    float4 world = localPosition.y * hlslcc_mtx4x4unity_ObjectToWorld[1];
    world = hlslcc_mtx4x4unity_ObjectToWorld[0] * localPosition.x + world;
    world = hlslcc_mtx4x4unity_ObjectToWorld[2] * localPosition.z + world;
    return world + hlslcc_mtx4x4unity_ObjectToWorld[3];
}
float4 TransformCapturedWorld(float4 world)
{
    float4 clipPosition = world.y * hlslcc_mtx4x4unity_MatrixVP[1];
    clipPosition = hlslcc_mtx4x4unity_MatrixVP[0] * world.x + clipPosition;
    clipPosition = hlslcc_mtx4x4unity_MatrixVP[2] * world.z + clipPosition;
    return hlslcc_mtx4x4unity_MatrixVP[3] * world.w + clipPosition;
}
'''
    declarations=collections.OrderedDict()
    for typ,name,count in re.findall(r'^\s*(?:uniform\s+)?('+TYPEPAT+r')\s+(\w+)\s*(\[\d+\])?\s*;',vs+'\n'+ps+'\n'+v.get('declarations','')+'\n'+p.get('declarations',''),re.M):
        if re.search(r'\b'+re.escape(name)+r'\b',code+helpers):
            declarations[name]=(TYPE[typ],count)
    textures={name:kind for kind,name in re.findall(r'uniform\s+(sampler\w*)\s+(\w+)\s*;',vs+'\n'+ps)}
    semantics=dict(v['semantics']); semantics.update(p['semantics'])
    attributes=re.findall(r'^in\s+('+TYPEPAT+r')\s+(\w+)\s*;',vs,re.M)
    varyings=re.findall(r'^out\s+('+TYPEPAT+r')\s+(\w+)\s*;',vs,re.M)
    varying_names={name:semantics.get(name,name) for _,name in varyings}
    property_lines=[]; uniforms=[]; bindings=[]
    for name,(typ,count) in declarations.items():
        target=safe_name(name)
        uniforms.append('    '+typ+' '+target+count+'; // source: '+name)
        bindings.append({'source':name,'target':target,'type':typ,'array':int(count[1:-1]) if count else 0})
        if not count and typ!='float4x4':
            prop_type='Vector' if typ[-1:] in '234' else 'Integer' if typ in ('int','uint') else 'Float'
            default='(0,0,0,0)' if prop_type=='Vector' else '0'
            property_lines.append('        '+target+' ("'+name+'", '+prop_type+') = '+default)
    texture_lines=[]
    for name,kind in textures.items():
        target=safe_name(name); suffix='CUBE' if kind=='samplerCube' else '2D'
        texture_lines.append('TEXTURE'+suffix+'('+target+'); SAMPLER(sampler'+target+');')
        property_lines.append('        '+target+' ("'+name+'", '+('Cube' if suffix=='CUBE' else '2D')+') = "white" {}')
    def translate_names(text):
        for name in textures:
            text=re.sub(r'\bsampler_'+re.escape(name.lstrip('_'))+r'\b','sampler'+safe_name(name),text)
        for name in sorted(set(declarations)|set(textures),key=len,reverse=True):
            text=re.sub(r'\b'+re.escape(name)+r'\b',safe_name(name),text)
        for name in varying_names:
            text=re.sub(r'\b'+name+r'\b',varying_names[name],text)
        return text
    attrs='\n'.join('    '+TYPE[typ]+' '+name+' : '+attr_semantic(name)+';' for typ,name in attributes)
    varying='\n'.join('    '+TYPE[typ]+' '+varying_names[name]+' : TEXCOORD'+str(index)+';' for index,(typ,name) in enumerate(varyings))
    shader_name='LastZ/Reconstructed/'+p['name']+'_'+key
    shader='''// Readable reconstruction of original captured shader programs.
// Vertex source SHA256: %s
// Fragment source SHA256: %s
// Validation is tracked in Reconstruction/Reports; compilation alone is not fidelity.
Shader "%s"
{
    Properties
    {
%s
        [HideInInspector] _CaptureSrcBlend ("Source RGB blend", Float) = 1
        [HideInInspector] _CaptureDstBlend ("Destination RGB blend", Float) = 0
        [HideInInspector] _CaptureSrcBlendAlpha ("Source alpha blend", Float) = 1
        [HideInInspector] _CaptureDstBlendAlpha ("Destination alpha blend", Float) = 0
        [HideInInspector] _CaptureBlendOp ("RGB blend operation", Float) = 0
        [HideInInspector] _CaptureBlendOpAlpha ("Alpha blend operation", Float) = 0
        [HideInInspector] _CaptureZTest ("Depth comparison", Float) = 8
        [HideInInspector] _CaptureZWrite ("Depth write", Float) = 0
        [HideInInspector] _CaptureCull ("Cull", Float) = 0
        [HideInInspector] _CaptureColorMask ("Color mask", Float) = 15
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" }
        Pass
        {
            Name "CapturedPass"
            Tags { "LightMode"="UniversalForward" }
            Blend [_CaptureSrcBlend] [_CaptureDstBlend], [_CaptureSrcBlendAlpha] [_CaptureDstBlendAlpha]
            BlendOp [_CaptureBlendOp], [_CaptureBlendOpAlpha]
            ZTest [_CaptureZTest] ZWrite [_CaptureZWrite] Cull [_CaptureCull]
            ColorMask [_CaptureColorMask]
            HLSLPROGRAM
            #pragma target 4.5
            #pragma vertex Vertex
            #pragma fragment Fragment
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            CBUFFER_START(UnityPerMaterial)
%s
            CBUFFER_END
%s
struct Attributes
{
%s
};
struct Varyings
{
    float4 positionCS : SV_POSITION;
%s
};
%s
Varyings Vertex(Attributes input)
{
    Varyings output = (Varyings)0;
%s
    // Match Unity's platform depth convention. ShaderLab reverses comparison states on D3D.
    #if !defined(SHADER_API_GLCORE) && !defined(SHADER_API_GLES3)
    output.positionCS.y = -output.positionCS.y;
    #if UNITY_REVERSED_Z
    output.positionCS.z = (output.positionCS.w - output.positionCS.z) * 0.5;
    #else
    output.positionCS.z = (output.positionCS.z + output.positionCS.w) * 0.5;
    #endif
    #endif
    return output;
}
float4 Fragment(Varyings input) : SV_Target
{
%s
}
            ENDHLSL
        }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
'''%(vh,ph,shader_name,'\n'.join(property_lines),'\n'.join(uniforms),'\n'.join(texture_lines),attrs,varying,translate_names(helpers),translate_names(v['code']),translate_names(p['code']))
    out=ASSETS/'Shaders'/p['name']/(key+'.shader'); out.parent.mkdir(parents=True,exist_ok=True)
    if p.get('depth_output'):
        shader=shader.replace('float4 Fragment(Varyings input) : SV_Target','float Fragment(Varyings input) : SV_Depth')
    out.write_text(shader,encoding='utf-8')
    return {'name':shader_name,'path':str(out.relative_to(ROOT)).replace('\\','/'),'key':key,'bindings':bindings,'textures':{n:safe_name(n) for n in textures}}


def values(var):
    if var.get('members'): return sum((values(m) for m in var['members']),[])
    v=var.get('value',[])
    return v if isinstance(v,list) else [v]


def mesh(d, out, instance=0):
    attrs=[a for a in d['vertex_inputs'] if a['used'] and a['name']]
    ib=d['index_buffer']; count=d['numIndices']
    if d['flag_bits'] & 65536:
        raw=(RAW/'Blobs'/(ib['blob']['sha256']+'.bin')).read_bytes()
        size=ib['byteStride']; offset=ib['byteOffset']+d['indexOffset']*size
        indices=list(struct.unpack_from('<'+str(count)+{1:'B',2:'H',4:'I'}[size],raw,offset))
        indices=[i+d['baseVertex'] for i in indices]
    else: indices=list(range(d['vertexOffset'],d['vertexOffset']+count))
    if d['topology'].endswith('TriangleStrip'):
        indices=[v for n in range(len(indices)-2) for v in ([indices[n],indices[n+1],indices[n+2]] if n%2==0 else [indices[n+1],indices[n],indices[n+2]])]
    elif d['topology'].endswith('TriangleFan'):
        indices=[v for n in range(1,len(indices)-1) for v in (indices[0],indices[n],indices[n+1])]
    elif not d['topology'].endswith('TriangleList'):
        raise ValueError('Unsupported topology '+d['topology'])
    unique=sorted(set(indices)); remap={v:i for i,v in enumerate(unique)}
    blobs={v['blob']['sha256']:(RAW/'Blobs'/(v['blob']['sha256']+'.bin')).read_bytes() for v in d['vertex_buffers'] if 'blob'in v}
    data=[]
    for index in unique:
        for a in attrs:
            fmt=a['format']; n=fmt['compCount']; size=fmt['compByteWidth']; comp=fmt['compType']; vb=d['vertex_buffers'][a['vertexBuffer']]
            if fmt['type']!=0: raise ValueError('Packed vertex format '+str(fmt))
            if a['genericEnabled']: v=a['genericValue']['floatValue'][:n]
            else:
                off=vb['byteOffset']+a['byteOffset']+((instance+d.get('instanceOffset',0))//max(a.get('instanceRate',1),1) if a['perInstance'] else index)*vb['byteStride']
                raw=blobs[vb['blob']['sha256']]
                kind={1:{2:'e',4:'f',8:'d'},2:{1:'B',2:'H',4:'I'},3:{1:'b',2:'h',4:'i'},4:{1:'B',2:'H',4:'I'},5:{1:'b',2:'h',4:'i'}}[comp][size]
                v=list(struct.unpack_from('<'+str(n)+kind,raw,off))
                if comp==2: v=[x/float((1<<(size*8))-1) for x in v]
                elif comp==3: v=[max(-1,x/float((1<<(size*8-1))-1)) for x in v]
            data.extend(v+[0.0]*(3-n if n<3 else 0)+([1.0] if n<4 else []))
    binary=struct.pack('<III',len(unique),len(attrs),len(indices))+struct.pack('<'+str(len(data))+'f',*data)+struct.pack('<'+str(len(indices))+'I',*(remap[i] for i in indices))
    digest=hashlib.sha256(binary).hexdigest()
    path=out/(digest+'.bytes'); path.parent.mkdir(parents=True,exist_ok=True)
    if not path.exists():path.write_bytes(binary)
    return {'file':str(path.relative_to(ROOT)).replace('\\','/'),'attributes':[attr_semantic(a['name']) for a in attrs], 'vertexCount':len(unique),'indexCount':len(indices)}


if __name__=='__main__':
    frame=sys.argv[1] if len(sys.argv)>1 else '10105'
    raw=RAW/('Frame_'+frame)
    draws=sorted([json.loads(p.read_text()) for p in (raw/'Draws').glob('*.json')],key=lambda d:d['eventId'])
    shaders={}; prepared=[]; missing=[]
    for d in draws:
        pair=tuple(d['stages'][s]['source_hash'] for s in ('vertex','pixel'))
        if any(h[:12] not in STAGES for h in pair):
            missing.append(d['eventId']); continue
        if pair not in shaders:shaders[pair]=build_shader(d)
        shader=shaders[pair]
        uniforms={v['name']:v for s in ('vertex','pixel') for cb in d['stages'][s]['constant_buffers'] for v in cb['variables']}
        expanded=STAGES[pair[0][:12]].get('expand_instances',False)
        for instance in range(d['numInstances'] if expanded else 1):
            per_instance=dict(uniforms)
            if expanded:
                base=int(values(uniforms.get('unity_BaseInstanceID',{'value':[0]}))[0])
                for array_name in ('unity_Builtins0Array','unity_Builtins1Array','unity_Builtins2Array','GPUSkinArray'):
                    if array_name not in uniforms:continue
                    for member in uniforms[array_name]['members'][base+instance]['members']:
                        per_instance[member['name'].removesuffix('Array') if hasattr(str,'removesuffix') else re.sub('Array$','',member['name'])]=member
            bindings=[dict(b,values=values(per_instance[b['source']])) for b in shader['bindings'] if b['source'] in per_instance]
            prepared.append({'eid':d['eventId'],'instanceIndex':instance,'mesh':mesh(d,ASSETS/'Frames'/('Frame_'+frame)/'MeshData',instance),
            'shader':shader,'uniforms':bindings,'raw':str((raw/'Draws'/('e%d.json'%d['eventId'])).relative_to(ROOT)).replace('\\','/'),
            'outputs':d['outputs'],'depth':d['depthOut'],'fixed':d['fixed'],'resources':d['stages']['pixel']['resources'],
            'vertexResources':d['stages']['vertex']['resources'],'instances':1 if expanded else d['numInstances']})
    manifest={'frame':frame,'draws':prepared,'missingEids':missing,'rawCapture':str((raw/'capture.json').relative_to(ROOT)).replace('\\','/')}
    path=ROOT/'Reconstruction/Prepared'/('Frame_'+frame+'.json');path.parent.mkdir(parents=True,exist_ok=True)
    path.write_text(json.dumps(manifest,indent=2),encoding='utf-8')
    print(json.dumps({'frame':frame,'prepared':len(prepared),'missing':missing,'shaders':len(shaders)}))
