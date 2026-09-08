"""Four-influence texture skinning, retaining the source's frozen animation time."""
from readable_lighting_stages import BASE_VERTEX, VERTEX_SEMANTICS, SH, FOG

SKIN = '''
// Animation stores three float4 rows per bone. Integer texel centers avoid
// filtering adjacent bone rows; both neighboring animation frames are sampled.
float4 ReadCapturedBoneRow(float address)
{
    float2 inverseSize = 1.0 / _GPUSKin_TextureSize.xy;
    float row = floor(address * inverseSize.x);
    float column = -row * _GPUSKin_TextureSize.x + address;
    float2 uv = float2((column+0.5)*inverseSize.x,(row+0.5)*inverseSize.y);
    return SAMPLE_TEXTURE2D_LOD(_GPUSKin_Matrix,sampler_GPUSKin_Matrix,uv,0.0);
}
float3 SkinCapturedInfluence(float4 positionOS,float bone,float currentBase,float nextBase,float frameBlend)
{
    float address = bone * 3.0;
    float4 nextX = ReadCapturedBoneRow(address+nextBase);
    float4 nextY = ReadCapturedBoneRow(address+nextBase+1.0);
    float4 nextZ = ReadCapturedBoneRow(address+nextBase+2.0);
    float4 currentX = ReadCapturedBoneRow(address+currentBase);
    float4 currentY = ReadCapturedBoneRow(address+currentBase+1.0);
    float4 currentZ = ReadCapturedBoneRow(address+currentBase+2.0);
    float4 rowX = frameBlend * (nextX-currentX) + currentX;
    float4 rowY = frameBlend * (nextY-currentY) + currentY;
    float4 rowZ = frameBlend * (nextZ-currentZ) + currentZ;
    return float3(dot(rowX,positionOS),dot(rowY,positionOS),dot(rowZ,positionOS));
}
float4 SkinCapturedPosition(float4 positionOS,float4 firstInfluences,float4 lastInfluences)
{
    float currentFrame = floor(_GPUSKin_ClipParams.y);
    float currentBase = currentFrame * _GPUSKin_TextureSize.z + _GPUSKin_ClipParams.x;
    float nextBase = (currentFrame+1.0) * _GPUSKin_TextureSize.z + _GPUSKin_ClipParams.x;
    float frameBlend = frac(_GPUSKin_ClipParams.y);
    // Preserve source accumulation order: second, first, third, fourth.
    float3 position = SkinCapturedInfluence(positionOS,firstInfluences.z,currentBase,nextBase,frameBlend) * firstInfluences.w;
    position = SkinCapturedInfluence(positionOS,firstInfluences.x,currentBase,nextBase,frameBlend) * firstInfluences.y + position;
    position = SkinCapturedInfluence(positionOS,lastInfluences.x,currentBase,nextBase,frameBlend) * lastInfluences.y + position;
    position = SkinCapturedInfluence(positionOS,lastInfluences.z,currentBase,nextBase,frameBlend) * lastInfluences.w + position;
    return float4(position,1.0);
}
'''

INSTANCE_DECLARATIONS = '''
vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
vec4 hlslcc_mtx4x4unity_WorldToObject[4];
vec4 unity_SHAr;
vec4 unity_SHAg;
vec4 unity_SHAb;
vec4 unity_SHBr;
vec4 unity_SHBg;
vec4 unity_SHBb;
vec4 unity_SHC;
vec4 _GPUSKin_ClipParams;
'''

def register(add):
    body=BASE_VERTEX.replace('float4 localPosition = input.in_POSITION0;',
        'float4 localPosition = SkinCapturedPosition(input.in_POSITION0,input.in_TEXCOORD3,input.in_TEXCOORD4);')
    add('880f1ff4573d','InstancedTextureSkinFogVertex',body.replace('FOG_EXPRESSION','CapturedHeightFog(worldPosition.xyz)'),VERTEX_SEMANTICS,SH+FOG+SKIN)
    from readable_stages import STAGES
    STAGES['880f1ff4573d']['declarations']=INSTANCE_DECLARATIONS
    STAGES['880f1ff4573d']['expand_instances']=True
