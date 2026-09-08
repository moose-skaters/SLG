"""Capture-lossless extraction extension, executed inside the existing MCP replay session.

Keeps original input buffers, every uniform, draw order and fixed-function state.
No heuristic world-position selection; Unity reconstruction must derive transforms
from the vertex program. Content-addressed blobs preserve buffers that change
between draws and deduplicate identical data across all captures.
"""
import os
import json
import hashlib
import traceback
import math
import renderdoc as rd


def serialize_variables_exact(variables):
    result = []
    for var in variables:
        typ = str(var.type).split('.')[-1]
        item = {'name': var.name, 'type': str(var.type), 'rows': var.rows, 'columns': var.columns}
        count = var.rows * var.columns
        accessor = 's32v' if typ in ('SInt', 'Int', 'SInt32', 'Bool') else 'u32v' if typ in ('UInt', 'UInt32') else 'f64v' if typ == 'Double' else 'f32v'
        item['value'] = [scalar(v) for v in getattr(var.value, accessor)[:count]]
        if var.members:
            item['members'] = serialize_variables_exact(var.members)
        result.append(item)
    return result


ROOT = 'D:/Last-Z/Reconstruction'


def json_write(path, data):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path + '.tmp', 'w', encoding='utf-8') as stream:
        json.dump(data, stream, ensure_ascii=True, separators=(',', ':'), allow_nan=False)
    os.replace(path + '.tmp', path)


def scalar(value, depth=0):
    if isinstance(value, float) and not math.isfinite(value):
        return 'NaN' if math.isnan(value) else 'Infinity' if value > 0 else '-Infinity'
    if value is None or isinstance(value, (bool, int, float, str)):
        return value
    if isinstance(value, bytes):
        return {'byte_count': len(value)}
    if depth > 5:
        return str(value)
    if isinstance(value, (list, tuple)) or type(value).__name__.endswith('Array'):
        return [scalar(v, depth + 1) for v in value]
    if isinstance(value, rd.ResourceId):
        return str(value)
    fields = {}
    for name in dir(value):
        if name.startswith('_') or name in ('this', 'thisown'):
            continue
        try:
            item = getattr(value, name)
            if not callable(item):
                fields[name] = scalar(item, depth + 1)
        except Exception:
            pass
    return fields if fields else str(value)


def blob(data):
    data = bytes(data)
    digest = hashlib.sha256(data).hexdigest()
    path = ROOT + '/Raw/Blobs/' + digest + '.bin'
    if not os.path.exists(path):
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, 'wb') as stream:
            stream.write(data)
    return {'sha256': digest, 'bytes': len(data)}


def export(facade, params):
    frame = str(params['frame'])
    if not frame.isdigit():
        raise ValueError('frame must contain digits only')
    out = ROOT + '/Raw/Frame_' + frame
    result = {'frame': frame, 'exported': 0, 'errors': [], 'output': out}
    first, last = int(params.get('first', 0)), int(params.get('last', 2147483647))
    metadata_only = bool(params.get('metadata_only', False))

    def replay(controller):
        try:
            _export(controller, facade, params, out, result, first, last, metadata_only)
        except Exception:
            result['errors'].append(traceback.format_exc())
    facade._invoke(replay)
    return result


def _export(controller, facade, params, out, result, first, last, metadata_only):
    service = facade._pipeline
    actions = []
    def flatten(items, parent=''):
        for action in items:
            label = action.GetName(controller.GetStructuredFile())
            info = {k: scalar(getattr(action, k)) for k in
                    ('eventId', 'actionId', 'flags', 'numIndices', 'numInstances',
                     'baseVertex', 'vertexOffset', 'instanceOffset', 'indexOffset',
                     'outputs', 'depthOut', 'copySource', 'copyDestination') if hasattr(action, k)}
            info.update(name=label, parent=parent, flag_bits=int(action.flags))
            actions.append((action, info))
            flatten(action.children, parent + '/' + label)
    flatten(controller.GetRootActions())
    textures = controller.GetTextures()
    texture_map = {str(t.resourceId): t for t in textures}
    if not os.path.exists(out + '/capture.json') or params.get('update_capture', False):
        json_write(out + '/capture.json', {'filename': facade.ctx.GetCaptureFilename(),
                   'api': str(controller.GetAPIProperties().pipelineType),
                   'actions': [info for _, info in actions],
                   'textures': [scalar(t) for t in textures],
                   'buffers': [scalar(b) for b in controller.GetBuffers()],
                   'messages': [scalar(m) for m in controller.GetDebugMessages()]})
    output_ids = set(str(r) for a, _ in actions for r in a.outputs if r != rd.ResourceId.Null())
    output_ids.update(str(a.depthOut) for a, _ in actions if a.depthOut != rd.ResourceId.Null())
    for action, info in actions:
        eid = action.eventId
        if eid < first or eid > last or not (action.flags & rd.ActionFlags.Drawcall):
            continue
        path = out + '/Draws/e' + str(eid) + '.json'
        if os.path.exists(path) and not params.get('overwrite', False):
            continue
        try:
            controller.SetFrameEvent(eid, True)
            pipe = controller.GetPipelineState()
            item = dict(info)
            item['topology'] = str(pipe.GetPrimitiveTopology())
            item['stages'] = {}
            item['fixed'] = service._collect_fragment_output_state(controller, pipe,
                            controller.GetAPIProperties().pipelineType, eid)
            item['gl'] = scalar(controller.GetGLPipelineState())
            for stage in (rd.ShaderStage.Vertex, rd.ShaderStage.Fragment):
                refl = pipe.GetShaderReflection(stage)
                if refl is None:
                    continue
                name = 'vertex' if stage == rd.ShaderStage.Vertex else 'pixel'
                source = service._try_native_glsl_from_raw_bytes(refl)
                if source is None:
                    raise RuntimeError('No original GLSL for ' + str(refl.resourceId))
                digest = hashlib.sha256(source.encode('utf-8')).hexdigest()
                spath = ROOT + '/Raw/Shaders/' + digest + '.' + name + '.glsl'
                if not os.path.exists(spath):
                    os.makedirs(os.path.dirname(spath), exist_ok=True)
                    with open(spath, 'w', encoding='utf-8') as stream:
                        stream.write(source)
                stage_data = {'resource_id': str(refl.resourceId), 'source_hash': digest,
                    'encoding': str(refl.encoding),
                    'resource_reflection': [scalar(v) for v in refl.readOnlyResources],
                    'input_signature': [scalar(v) for v in refl.inputSignature],
                    'output_signature': [scalar(v) for v in refl.outputSignature],
                    'constant_buffers': service._get_cbuffer_info(controller, pipe, refl, stage),
                    'resources': service._get_stage_resources(controller, pipe, stage, refl),
                    'samplers': service._get_stage_samplers(pipe, stage, refl)}
                item['stages'][name] = stage_data
                if not metadata_only:
                    for resource in stage_data['resources']:
                        rid = resource.get('resource_id')
                        tex = texture_map.get(rid)
                        if tex is None or rid in output_ids:
                            continue
                        folder = out + '/Textures/' + rid.split('::')[-1]
                        if os.path.exists(folder + '/texture.json'):
                            continue
                        os.makedirs(folder, exist_ok=True)
                        tex_info = scalar(tex)
                        tex_info['subresources'] = []
                        for layer in range(tex.arraysize):
                            for mip in range(tex.mips):
                                save = rd.TextureSave()
                                save.resourceId = tex.resourceId
                                save.destType = rd.FileType.PNG
                                save.alpha = rd.AlphaMapping.Preserve
                                save.mip = mip
                                save.slice.sliceIndex = layer
                                tpath = folder + '/s%d_m%d.png' % (layer, mip)
                                status = controller.SaveTexture(save, tpath)
                                tex_info['subresources'].append({'mip': mip, 'slice': layer,
                                    'path': tpath, 'save_result': str(status)})
                        json_write(folder + '/texture.json', tex_info)
            item['vertex_inputs'] = [scalar(a) for a in pipe.GetVertexInputs()]
            item['vertex_buffers'] = []
            if not metadata_only:
                cache = {}
                used_buffers = set(a.vertexBuffer for a in pipe.GetVertexInputs() if a.used and a.name)
                for vb_index, vb in enumerate(pipe.GetVBuffers()):
                    v = scalar(vb)
                    if vb_index in used_buffers and vb.resourceId != rd.ResourceId.Null():
                        key = str(vb.resourceId)
                        if key not in cache:
                            cache[key] = blob(controller.GetBufferData(vb.resourceId, 0, 0))
                        v['blob'] = cache[key]
                    item['vertex_buffers'].append(v)
                ib = pipe.GetIBuffer()
                item['index_buffer'] = scalar(ib)
                if ib.resourceId != rd.ResourceId.Null():
                    item['index_buffer']['blob'] = blob(controller.GetBufferData(ib.resourceId, 0, 0))
            json_write(path, item)
            result['exported'] += 1
        except Exception:
            result['errors'].append({'eid': eid, 'error': traceback.format_exc()})
    if params.get('reference', False):
        draw_actions = [a for a, _ in actions if a.flags & rd.ActionFlags.Drawcall]
        final = draw_actions[-1]
        controller.SetFrameEvent(final.eventId, True)
        folder = ROOT + '/References/Frame_' + str(params['frame'])
        os.makedirs(folder, exist_ok=True)
        for index, rid in enumerate(final.outputs):
            if rid == rd.ResourceId.Null():
                continue
            save = rd.TextureSave()
            save.resourceId, save.destType = rid, rd.FileType.PNG
            save.alpha = rd.AlphaMapping.Preserve
            status = controller.SaveTexture(save, folder + '/final_%d.png' % index)
            result['reference'] = str(status)


def dispatch(facade, params):
    if params.get('probe_postvs', False):
        result = {}
        def replay(controller):
            controller.SetFrameEvent(int(params['eid']), True)
            mesh = controller.GetPostVSData(int(params.get('instance',0)),0,rd.MeshDataStage.VSOut)
            result['mesh'] = scalar(mesh)
            result['blob'] = blob(controller.GetBufferData(mesh.vertexResourceId,mesh.vertexByteOffset,0))
        facade._invoke(replay)
        return result
    from renderdoc_mcp_bridge.utils.serializers import Serializers
    Serializers.serialize_variables = staticmethod(serialize_variables_exact)
    # qrenderdoc reload can keep a previous service class alive; patch that class's
    # serializer too, rather than assuming both imports share one module object.
    active_serializers = facade._pipeline._get_cbuffer_info.__func__.__globals__['Serializers']
    active_serializers.serialize_variables = staticmethod(serialize_variables_exact)
    if params.get('probe_texture', False):
        result = {}
        def replay(controller):
            eid = int(params['eid'])
            controller.SetFrameEvent(eid, True)
            stack = list(controller.GetRootActions())
            action = None
            while stack:
                candidate = stack.pop()
                if candidate.eventId == eid:
                    action = candidate
                    break
                stack.extend(candidate.children)
            if action is None:
                result['error'] = 'Event not found'
                return
            resource = action.outputs[0]
            if params.get('rid'):
                resource = next(t.resourceId for t in controller.GetTextures() if str(t.resourceId) == params['rid'])
            sub = rd.Subresource()
            sub.mip, sub.slice, sub.sample = 0, 0, 0
            raw = controller.GetTextureData(resource, sub)
            result.update(resource=str(resource), blob=blob(raw))
            save=rd.TextureSave(); save.resourceId=resource; save.destType=rd.FileType.PNG; save.alpha=rd.AlphaMapping.Preserve
            path=ROOT+'/References/Frame_'+str(params['frame'])+'/e%d_probe.png'%eid
            result['png']=path
            controller.SaveTexture(save,path)
        facade._invoke(replay)
        return result
    if params.get('probe_descriptors', False):
        result = {}
        def replay(controller):
            controller.SetFrameEvent(int(params['eid']), True)
            pipe = controller.GetPipelineState()
            result['resources'] = [scalar(v) for v in pipe.GetReadOnlyResources(rd.ShaderStage.Fragment, False)]
            result['access'] = [scalar(v) for v in controller.GetDescriptorAccess()]
            result['sampler_api'] = controller.GetSamplerDescriptors.__doc__
            result['range_fields'] = dir(rd.DescriptorRange())
            result['texture_data_doc'] = controller.GetTextureData.__doc__
        facade._invoke(replay)
        return result
    if params.get('probe_uniform', False):
        result = {}
        def replay(controller):
            controller.SetFrameEvent(int(params['eid']), True)
            pipe = controller.GetPipelineState()
            gl = controller.GetGLPipelineState()
            stage = rd.ShaderStage.Fragment
            refl = pipe.GetShaderReflection(stage)
            for label,pso in [('program',gl.fragmentShader.programResourceId),('shader',refl.resourceId),('pipeline',gl.pipelineResourceId),('null',rd.ResourceId.Null())]:
                try:
                    result[label] = serialize_variables_exact(controller.GetCBufferVariableContents(pso,refl.resourceId,stage,refl.entryPoint,len(refl.constantBlocks)-1,rd.ResourceId.Null(),0,0))
                except Exception as ex:
                    result[label] = str(ex)
        facade._invoke(replay)
        return result
    if params.get('repair_uniforms', False):
        out = ROOT + '/Raw/Frame_' + str(params['frame'])
        repaired = []
        def replay(controller):
            structured=controller.GetStructuredFile()
            changes={}
            for index,chunk in enumerate(structured.chunks):
                if 'TexParameter' not in chunk.name and 'SamplerParameter' not in chunk.name:
                    continue
                children={chunk.GetChild(i).name:chunk.GetChild(i) for i in range(chunk.NumChildren())}
                if 'pname' not in children or children['pname'].data.basic.u != 35400 or 'param' not in children:
                    continue
                resource=children.get('sampler',children.get('texture'))
                if resource is not None:
                    changes.setdefault(str(resource.data.basic.id),[]).append((index,children['param'].data.basic.i != 35402))
            action_map={}
            stack=list(controller.GetRootActions())
            while stack:
                action=stack.pop(); action_map[action.eventId]=action; stack.extend(action.children)
            def decode_enabled(resource, chunk_index):
                enabled=True
                for index,value in changes.get(str(resource),[]):
                    if index<=chunk_index: enabled=value
                return enabled
            texture_map={str(t.resourceId):t for t in controller.GetTextures()}
            for filename in os.listdir(out + '/Draws'):
                path = out + '/Draws/' + filename
                with open(path, encoding='utf-8') as stream:
                    data = json.load(stream)
                def missing(v):
                    return (v.get('rows', 0) * v.get('columns', 0) > 0 and not v.get('value')) or any(missing(m) for m in v.get('members', []))
                if not params.get('force_all', False) and not any(missing(v) for s in data['stages'].values() for cb in s['constant_buffers'] for v in cb['variables']):
                    continue
                controller.SetFrameEvent(data['eventId'], True)
                pipe = controller.GetPipelineState()
                action=action_map[data['eventId']]
                data['chunk_index']=max(ev.chunkIndex for ev in action.events)
                for name,stage in [('vertex',rd.ShaderStage.Vertex),('pixel',rd.ShaderStage.Fragment)]:
                    data['stages'][name]['constant_buffers'] = facade._pipeline._get_cbuffer_info(controller, pipe, pipe.GetShaderReflection(stage), stage)
                    data['stages'][name]['used_resources'] = []
                    for used in pipe.GetReadOnlyResources(stage,False):
                        record=scalar(used)
                        sampler_object=used.sampler.object
                        decode_resource=sampler_object if sampler_object!=rd.ResourceId.Null() else used.descriptor.resource
                        record['srgb_decode']=decode_enabled(decode_resource,data['chunk_index'])
                        data['stages'][name]['used_resources'].append(record)
                        tex=texture_map.get(str(used.descriptor.resource))
                        if tex is not None and tex.format.compType==rd.CompType.Float:
                            folder=out+'/Textures/'+str(tex.resourceId).split('::')[-1]
                            if os.path.exists(folder+'/texture.json') and not os.path.exists(folder+'/raw_texture.json'):
                                subresources=[]
                                for layer in range(tex.arraysize):
                                    for mip in range(tex.mips):
                                        sub=rd.Subresource();sub.mip,sub.slice,sub.sample=mip,layer,0
                                        subresources.append({'mip':mip,'slice':layer,'blob':blob(controller.GetTextureData(tex.resourceId,sub))})
                                json_write(folder+'/raw_texture.json',{'format_name':tex.format.Name(),'subresources':subresources})
                json_write(path, data)
                repaired.append(data['eventId'])
        facade._invoke(replay)
        return {'frame': params['frame'], 'repaired': repaired}
    if params.get('supplement', False):
        result = {}
        def replay(controller):
            try:
                result.update(supplement(controller, facade, params))
            except Exception:
                result['error'] = traceback.format_exc()
        facade._invoke(replay)
        return result
    return export(facade, params)


def supplement(controller, facade, params):
    frame = str(params['frame'])
    if not frame.isdigit():
        raise ValueError('Invalid frame')
    out = ROOT + '/Raw/Frame_' + frame
    structured = controller.GetStructuredFile()
    def sd(obj, depth=0):
        item = {'name': obj.name, 'type': scalar(obj.type), 'data': scalar(obj.data)}
        if depth < 8:
            item['children'] = [sd(obj.GetChild(i), depth + 1) for i in range(obj.NumChildren())]
        return item
    parameters = [dict(chunkIndex=i, chunk=sd(chunk)) for i,chunk in enumerate(structured.chunks) if ('TexParameter' in chunk.name or 'SamplerParameter' in chunk.name)]
    json_write(out + '/texture_parameters.json', parameters)
    special = []
    def walk(actions):
        for action in actions:
            if not action.children and not action.flags & rd.ActionFlags.Drawcall:
                controller.SetFrameEvent(action.eventId, True)
                info = {'eid': action.eventId, 'name': action.GetName(structured),
                        'outputs': [str(x) for x in action.outputs],
                        'depth': str(action.depthOut), 'source': str(action.copySource),
                        'destination': str(action.copyDestination),
                        'gl': scalar(controller.GetGLPipelineState()), 'chunks': []}
                for event in action.events:
                    if event.chunkIndex < len(structured.chunks):
                        chunk = structured.chunks[event.chunkIndex]
                        if 'Clear' in chunk.name or 'Blit' in chunk.name or 'Copy' in chunk.name:
                            info['chunks'].append(sd(chunk))
                special.append(info)
            walk(action.children)
    walk(controller.GetRootActions())
    json_write(out + '/operations.json', special)
    return {'frame': frame, 'operations': len(special)}
