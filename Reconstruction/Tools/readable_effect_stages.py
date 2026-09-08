"""Semantic HLSL translations of particle, fogged unlit and compositor stages."""
from readable_lighting_stages import FOG

PARTICLE_SEMANTICS = {
    'vs_TEXCOORD0':'mainUV', 'vs_TEXCOORD1':'secondaryUV', 'vs_TEXCOORD2':'noiseUV',
    'vs_TEXCOORD3':'vertexTint','vs_TEXCOORD4':'normalWS','vs_TEXCOORD5':'positionWS',
    'vs_TEXCOORD6':'particleParameters','vs_TEXCOORD8':'viewDirectionWS'
}

def register(add):
    add('fd1e86ca4bec','WorldOffsetUnlitVertex','''
float4 positionWS = TransformCapturedObject(input.in_POSITION0);
positionWS.xyz += _VertexOffset.xyz;
output.vs_TEXCOORD1 = positionWS.xyz;
output.positionCS = TransformCapturedWorld(float4(positionWS.xyz,1.0));
output.vs_TEXCOORD0 = input.in_TEXCOORD0;
''', {'vs_TEXCOORD0':'uv','vs_TEXCOORD1':'positionWS'})
    add('8ada45320557','FoggedUnlitFragment','''
float fogWeight = min(CapturedHeightFog(input.vs_TEXCOORD1),1.0) * _FogColor.a;
float4 texel = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,input.vs_TEXCOORD0 * _Tiling);
float4 tint = _Color * _Intensity;
float3 fogDifference = -texel.rgb * tint.rgb + _FogColor.rgb;
float4 tintedSample = texel * tint;
float3 color = fogWeight * fogDifference + tintedSample.rgb;
float alphaOpacity = tintedSample.a * _Color.a;
float redOpacityDifference = tintedSample.r * _Color.a - alphaOpacity;
return float4(color, _AlphaIsR * redOpacityDifference + alphaOpacity);
''',{'vs_TEXCOORD0':'uv','vs_TEXCOORD1':'positionWS'},FOG)
    add('e7b6bc62f6e1','ScrollingParticleVertex','''
float4 positionWS = TransformCapturedObject(input.in_POSITION0);
float4 positionCS = TransformCapturedWorld(positionWS);
output.positionCS = positionCS;
output.positionCS.z -= _FlyOffset;
float2 projectedUV = (float2(positionCS.x,positionCS.y * _ProjectionParams.x) * 0.5 + positionCS.w * 0.5) / positionCS.w;
float2 timeOffset = frac(_Time.yy * _mainUVMove.xy);
float2 screenUV = projectedUV * _MainTex_ST.xy + _MainTex_ST.zw - 0.5;
screenUV = screenUV * _mainUVMove.z + timeOffset;
screenUV = _particleUV * input.in_TEXCOORD2.xy + screenUV;
screenUV += 0.5;
float2 baseUV = _UVChannel * (saturate(input.in_TEXCOORD1) - input.in_TEXCOORD0) + input.in_TEXCOORD0;
baseUV = baseUV * _MainTex_ST.xy + _MainTex_ST.zw - 0.5;
baseUV = baseUV * _mainUVMove.z + 0.5;
baseUV = timeOffset + baseUV;
baseUV = _particleUV * input.in_TEXCOORD2.xy + baseUV;
output.vs_TEXCOORD0 = float4(_ScreenSpaceUV_ON * (screenUV-baseUV)+baseUV,0,0);
output.vs_TEXCOORD1 = 0;
output.vs_TEXCOORD2 = 0;
output.vs_TEXCOORD3 = input.in_COLOR0;
output.vs_TEXCOORD4 = 0;
output.vs_TEXCOORD5 = 0;
output.vs_TEXCOORD6 = input.in_TEXCOORD2;
output.vs_TEXCOORD8 = 0;
''',PARTICLE_SEMANTICS)
    add('73a4cbd58da6','PremultipliedParticleFragment','''
float heightRamp = saturate((1.0 / (_HeightFadeParam.y-_HeightFadeParam.x)) * (input.vs_TEXCOORD5.y-_HeightFadeParam.x));
float heightOpacity = _HeightFade * (heightRamp-1.0) + 1.0;
float2 uv = _MWarpMode * (saturate(input.vs_TEXCOORD0.xy)-input.vs_TEXCOORD0.xy) + input.vs_TEXCOORD0.xy;
float4 texel = SAMPLE_TEXTURE2D_BIAS(_MainTex,sampler_MainTex,uv,_GlobalMipBias.x);
float4 primary = (texel * _MainColor) * _MainColorIntensity;
float inverseBlend = 1.0 - _MNBlendMode;
float4 secondary = inverseBlend * _Main02Color;
float4 retainedPrimary = (texel * inverseBlend) * _MainColor;
float4 blendDifference = secondary * _Main02ColorIntensity + primary;
blendDifference = -retainedPrimary * _MainColorIntensity + blendDifference;
retainedPrimary *= _MainColorIntensity;
float4 combined = _MNBlendMode * blendDifference + retainedPrimary;
float redAlphaDifference = combined.a * texel.r - combined.a;
float textureOpacity = saturate(_BlackOff * redAlphaDifference + combined.a);
float opacity = (heightOpacity * textureOpacity) * input.vs_TEXCOORD3.a;
float luminance = dot(combined.rgb,float3(0.22,0.70700002,0.071000002));
float3 color = _Desaturate * (luminance.xxx-combined.rgb) + combined.rgb;
color *= input.vs_TEXCOORD3.rgb;
return float4(opacity * color,opacity);
''',PARTICLE_SEMANTICS)
    add('362ed493325a','DepthCopyVertex','''
output.positionCS = float4(input.in_POSITION0.x,input.in_POSITION0.y * _ScaleBiasRt.x,input.in_POSITION0.z,1);
output.vs_TEXCOORD0 = input.in_TEXCOORD0;
''',{'vs_TEXCOORD0':'uv'})
    add('b4141b668ad6','DepthCopyFragment','''
return SAMPLE_TEXTURE2D_BIAS(_CameraDepthAttachment,sampler_CameraDepthAttachment,input.vs_TEXCOORD0,_GlobalMipBias.x).r;
''',{'vs_TEXCOORD0':'uv'})
    from readable_stages import STAGES
    STAGES['b4141b668ad6']['depth_output']=True
