"""Billboard light shafts. The captured atan polynomial is retained, not replaced by atan2."""
SEMANTICS={'vs_INTERP0':'tangentWS','vs_INTERP1':'uv','vs_INTERP2':'positionWS','vs_INTERP3':'normalWS','vs_INTERP4':'viewDirection'}
VERTEX='''
float2 cameraZX = _WorldSpaceCameraPos.y * hlslcc_mtx4x4unity_WorldToObject[1].zx;
cameraZX = hlslcc_mtx4x4unity_WorldToObject[0].zx * _WorldSpaceCameraPos.x + cameraZX;
cameraZX = hlslcc_mtx4x4unity_WorldToObject[2].zx * _WorldSpaceCameraPos.z + cameraZX;
cameraZX += hlslcc_mtx4x4unity_WorldToObject[3].zx;
float2 magnitude = abs(cameraZX);
float ratio = (1.0/max(magnitude.y,magnitude.x)) * min(magnitude.y,magnitude.x);
float ratioSquared = ratio * ratio;
float polynomial = ratioSquared * 0.0208351 - 0.085133001;
polynomial = ratioSquared * polynomial + 0.180141;
polynomial = ratioSquared * polynomial - 0.3302995;
polynomial = ratioSquared * polynomial + 0.99986601;
float angle = ratio * polynomial;
float quadrant = magnitude.y < magnitude.x ? angle * -2.0 + 1.5707964 : 0.0;
angle = ratio * polynomial + quadrant;
angle = (-cameraZX.y < cameraZX.y ? -3.1415927 : 0.0) + angle;
float minNegative = min(-cameraZX.y,-cameraZX.x);
float maxNegative = max(-cameraZX.y,-cameraZX.x);
if (maxNegative >= -maxNegative && minNegative < -minNegative) angle = -angle;
angle = _Follow_Camera != 0 ? angle-1.5707965 : 0;
float cosine = cos(angle), negativeSine = sin(-angle);
float3 localPosition = float3(dot(float2(cosine,negativeSine),input.in_POSITION0.xz),input.in_POSITION0.y,
    dot(float2(-negativeSine,cosine),input.in_POSITION0.xz));
float4 worldPosition = TransformCapturedObject(float4(localPosition,1));
output.positionCS = TransformCapturedWorld(float4(worldPosition.xyz,1));
float3 tangent = input.in_TANGENT0.y*hlslcc_mtx4x4unity_ObjectToWorld[1].xyz;
tangent = hlslcc_mtx4x4unity_ObjectToWorld[0].xyz*input.in_TANGENT0.x+tangent;
tangent = hlslcc_mtx4x4unity_ObjectToWorld[2].xyz*input.in_TANGENT0.z+tangent;
output.vs_INTERP0 = float4(rsqrt(max(dot(tangent,tangent),0))*tangent,input.in_TANGENT0.w);
output.vs_INTERP1 = input.in_TEXCOORD0;
output.vs_INTERP2 = worldPosition.xyz;
float3 normal = float3(dot(input.in_NORMAL0,hlslcc_mtx4x4unity_WorldToObject[0].xyz),
    dot(input.in_NORMAL0,hlslcc_mtx4x4unity_WorldToObject[1].xyz),dot(input.in_NORMAL0,hlslcc_mtx4x4unity_WorldToObject[2].xyz));
output.vs_INTERP3 = rsqrt(max(dot(normal,normal),0))*normal;
output.vs_INTERP4 = unity_OrthoParams.w == 0 ? _WorldSpaceCameraPos-worldPosition.xyz :
    float3(hlslcc_mtx4x4unity_MatrixV[0].z,hlslcc_mtx4x4unity_MatrixV[1].z,hlslcc_mtx4x4unity_MatrixV[2].z);
'''
FRAGMENT='''
float2 clipZW = input.vs_INTERP2.y*hlslcc_mtx4x4unity_MatrixVP[1].zw;
clipZW = hlslcc_mtx4x4unity_MatrixVP[0].zw*input.vs_INTERP2.x+clipZW;
clipZW = hlslcc_mtx4x4unity_MatrixVP[2].zw*input.vs_INTERP2.z+clipZW;
clipZW += hlslcc_mtx4x4unity_MatrixVP[3].zw;
float perspectiveFade = (_ProjectionParams.z-clipZW.y)/_Depth_Fade;
float orthographicDepth = ((clipZW.x+1.0)*_Depth_Fade)*0.5;
orthographicDepth = orthographicDepth*(_ProjectionParams.z-_ProjectionParams.y)+_ProjectionParams.y;
float orthoFade = saturate(_ProjectionParams.y-orthographicDepth);
float depthFade = saturate(_Ortographic_Camera != 0 ? orthoFade : perspectiveFade);
float3 color = _GlobalDayTime*(_ColorNight.rgb-_Color.rgb)+_Color.rgb;
color *= SAMPLE_TEXTURE2D_BIAS(_Ray_Texture,sampler_Ray_Texture,input.vs_INTERP1.xy,_GlobalMipBias.x).r;
color *= saturate((1.0-input.vs_INTERP1.y)/(_Top_Fade*0.2));
color = depthFade*color;
float3 fromCamera = input.vs_INTERP2-_WorldSpaceCameraPos;
float cameraFade = saturate((sqrt(dot(fromCamera,fromCamera))-0.5)/_Camera_Fade_Distance);
color = cameraFade*color;
float bottomFade = saturate((input.vs_INTERP1.y-0.21763764)*253.87+51.717636);
float3 fadedColor = bottomFade*color;
float3 fogDifference = -color*bottomFade+max(fadedColor,_Fog_Color.rgb);
float fogMotion = ((_Fog_Speed*0.1)*_TimeParameters.x)*_Fog_Direction.x;
float fogWeight = (saturate(fogMotion*-0.25+input.vs_INTERP2.x)*fadedColor.r)*_Fog_influence;
color = fogWeight*fogDifference+fadedColor;
// Preserve the source's world -> local -> world normal conversions for nonuniform scales.
float3 normalWS = (1.0/sqrt(dot(input.vs_INTERP3,input.vs_INTERP3)))*input.vs_INTERP3;
float3 normalOS = float3(dot(normalWS,hlslcc_mtx4x4unity_ObjectToWorld[0].xyz),
    dot(normalWS,hlslcc_mtx4x4unity_ObjectToWorld[1].xyz),dot(normalWS,hlslcc_mtx4x4unity_ObjectToWorld[2].xyz));
normalOS = rsqrt(dot(normalOS,normalOS))*normalOS;
normalWS = normalOS.y*hlslcc_mtx4x4unity_ObjectToWorld[1].xyz;
normalWS = hlslcc_mtx4x4unity_ObjectToWorld[0].xyz*normalOS.x+normalWS;
normalWS = hlslcc_mtx4x4unity_ObjectToWorld[2].xyz*normalOS.z+normalWS;
normalWS = rsqrt(max(dot(normalWS,normalWS),0))*normalWS;
float3 viewDirection = rsqrt(dot(input.vs_INTERP4,input.vs_INTERP4))*input.vs_INTERP4;
float facing = dot(normalWS,viewDirection/_Camera_Fade_Parallel);
float negativeFacing = min(max(facing,-1.0),0.0);
float parallelFade = saturate(facing)-negativeFacing;
return float4(parallelFade*color,1.0);
'''
def register(add):
    add('c843dfdfc3ac','BillboardLightBeamVertex',VERTEX,SEMANTICS)
    add('bc295f54207c','BillboardLightBeamFragment',FRAGMENT,SEMANTICS)
