"""Environment color and planar shadow shaders, shared across material snapshots."""
from readable_lighting_stages import ADDITIONAL
SEMANTICS={'vs_TEXCOORD0':'uv','vs_TEXCOORD1':'normalWS','vs_TEXCOORD2':'positionAndFog','vs_TEXCOORD3':'ambient','vs_TEXCOORD5':'screenPosition'}
VERTEX='''
float4 localPosition = input.in_POSITION0;
localPosition.y += _VertexOffsetY;
float4 worldPosition = TransformCapturedObject(localPosition);
output.positionCS = TransformCapturedWorld(float4(worldPosition.xyz,1));
output.vs_TEXCOORD0 = input.in_TEXCOORD0;
float3 normalWS = float3(dot(input.in_NORMAL0,hlslcc_mtx4x4unity_WorldToObject[0].xyz),
    dot(input.in_NORMAL0,hlslcc_mtx4x4unity_WorldToObject[1].xyz),dot(input.in_NORMAL0,hlslcc_mtx4x4unity_WorldToObject[2].xyz));
output.vs_TEXCOORD1 = rsqrt(max(dot(normalWS,normalWS),0)) * normalWS;
output.vs_TEXCOORD2 = float4(worldPosition.xyz,0);
output.vs_TEXCOORD3 = 0;
float4 clipPosition = output.positionCS;
output.vs_TEXCOORD5 = float4(float2(clipPosition.x,clipPosition.y*_ProjectionParams.x)*0.5+clipPosition.w*0.5,clipPosition.zw);
'''
FRAGMENT='''
float4 baseTexel = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,input.vs_TEXCOORD0);
float4 tinted = baseTexel * _Color;
float3 lighting = tinted.rgb;
ADDITIONAL_LIGHTS
float opacity = _AlphaIsR * (tinted.r*_Color.a-tinted.a) + tinted.a;
if (_BlurPlaneShadowOn != 0)
{
    float2 shadowUV = (1.0/input.vs_TEXCOORD5.w) * input.vs_TEXCOORD5.xy;
    float shadow = SAMPLE_TEXTURE2D(_PlaneBlurShadowMap,sampler_PlaneBlurShadowMap,shadowUV).r;
    float3 halfLight = lighting * 0.5;
    lighting = shadow * halfLight + halfLight;
}
return float4(lighting,opacity);
'''
def register(add):
    for prefix in ['ba4b9f7a81a5','255b1057b665']:
        add(prefix,'PlanarShadowReceiverVertex',VERTEX,SEMANTICS)
    add('613fcbd7e65f','PlanarShadowAdditionalLightsFragment',FRAGMENT.replace('ADDITIONAL_LIGHTS',ADDITIONAL),SEMANTICS)
    add('3a0b322bcd00','PlanarShadowReceiverFragment',FRAGMENT.replace('ADDITIONAL_LIGHTS',''),SEMANTICS)
