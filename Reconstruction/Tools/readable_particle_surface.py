"""Readable particle surface model: UV motion, parallax, flipbooks and color grading."""
SEMANTICS={'vs_TEXCOORD0':'positionWS','vs_TEXCOORD1':'baseUV','vs_TEXCOORD2':'customData',
    'vs_TEXCOORD3':'normalWS','vs_TEXCOORD4':'mainAndMaskUV','vs_TEXCOORD5':'noiseAndSecondUV',
    'vs_TEXCOORD6':'flipbookBlend','vs_TEXCOORD7':'nextFrameUV','vs_COLOR0':'vertexTint','vs_TEXCOORD8':'parallaxDirection'}
VERTEX='''
float4 positionWS = TransformCapturedObject(input.in_POSITION0);
output.positionCS = TransformCapturedWorld(float4(positionWS.xyz,1));
float2 mainUV = input.in_TEXCOORD0.xy * _Main_Tex_ST.xy + _Main_Tex_ST.zw;
float2 scrollingUV = _Time.yy * _Main_UV + mainUV;
float2 particleUV = mainUV + input.in_TEXCOORD1.xy;
mainUV = _Particle_SpeedUV * (particleUV-scrollingUV) + scrollingUV;
float angle = _Main_tex_Rotator * 0.017453294;
float sine = sin(angle);
float cosine = cos(angle);
output.vs_TEXCOORD4.xy = float2(dot(mainUV,float2(cosine,sine)),dot(mainUV,float2(-sine,cosine)));
float2 secondUV = input.in_TEXCOORD0.xy * _Tex_2_ST.xy + _Tex_2_ST.zw;
output.vs_TEXCOORD5.zw = _Time.yy * _Tex_2_UV + secondUV;
if (_ParallaxOn != 0)
{
    float3 tangentWS = input.in_TANGENT0.y * hlslcc_mtx4x4unity_ObjectToWorld[1].xyz;
    tangentWS = hlslcc_mtx4x4unity_ObjectToWorld[0].xyz * input.in_TANGENT0.x + tangentWS;
    tangentWS = hlslcc_mtx4x4unity_ObjectToWorld[2].xyz * input.in_TANGENT0.z + tangentWS;
    tangentWS = rsqrt(max(dot(tangentWS,tangentWS),0)) * tangentWS;
    float3 viewDirection = _WorldSpaceCameraPos-positionWS.xyz;
    viewDirection = rsqrt(dot(viewDirection,viewDirection)) * viewDirection;
    output.vs_TEXCOORD8 = float3((tangentWS.x*viewDirection.x+tangentWS.y*viewDirection.y)+tangentWS.z*viewDirection.z,0,0);
}
else output.vs_TEXCOORD8 = 0;
output.vs_TEXCOORD1 = float4(input.in_TEXCOORD0.xy,0,0);
output.vs_TEXCOORD2 = input.in_TEXCOORD1;
output.vs_TEXCOORD3 = 0;
output.vs_TEXCOORD4.zw = 0;
output.vs_TEXCOORD5.xy = 0;
output.vs_TEXCOORD0 = positionWS.xyz;
output.vs_TEXCOORD7 = input.in_TEXCOORD0.zw;
output.vs_TEXCOORD6 = input.in_TEXCOORD2.x;
output.vs_COLOR0 = input.in_COLOR0;
'''

SAMPLE='''
float4 texel = SAMPLE_TEXTURE2D(_Main_Tex,sampler_Main_Tex,input.vs_TEXCOORD4.xy);
float opacity = saturate(texel.a-_AlphaSub);
opacity = _Alpha_NO_R * (texel.r-opacity) + opacity;
float4 surface = float4(texel.rgb,opacity);
if (_ParallaxOn != 0)
{
    float height = surface[_ParallaxChannel];
    float2 parallaxOffset = (1.0-height) * input.vs_TEXCOORD8.xy;
    float2 parallaxUV = parallaxOffset * _ParallaxScale + input.vs_TEXCOORD4.xy;
    float4 shifted = SAMPLE_TEXTURE2D(_Main_Tex,sampler_Main_Tex,parallaxUV);
    float edgeWeight = _Alpha_NO_R * (shifted.r-shifted.a) + shifted.a;
    surface.rgb = edgeWeight * (shifted.rgb-_ParallaxEdgeColor.rgb) + _ParallaxEdgeColor.rgb;
}
if (_FlipBookBlend_On != 0)
{
    float4 nextFrame = SAMPLE_TEXTURE2D(_Main_Tex,sampler_Main_Tex,input.vs_TEXCOORD7);
    nextFrame.a = saturate(nextFrame.a-_AlphaSub);
    surface = input.vs_TEXCOORD6 * (nextFrame-surface) + surface;
}
'''
GRADE='''
float luminance = dot(surface.rgb,float3(0.29899999,0.58700001,0.114));
surface.rgb = _Saturation * (surface.rgb-luminance.xxx) + luminance.xxx;
float3 contrasted = saturate((surface.rgb-0.5) * _Contrast + 0.5);
float3 color = ((contrasted * _Main_Color.rgb) * _Brightness) * input.vs_COLOR0.rgb;
float opacity = saturate(((surface.a*_Main_Color.a)*_Alpha)*input.vs_COLOR0.a);
return float4(_AlphaPremultiply != 0 ? opacity * color : color,opacity);
'''

def register(add):
    add('580c7d2c8635','ParticleSurfaceVertex',VERTEX,SEMANTICS)
    sample=SAMPLE.replace('opacity','sampleOpacity')
    add('b2720701b9cd','ParticleSurfaceFragment',sample+GRADE,SEMANTICS)
    noise='''
float2 noiseUV = input.vs_TEXCOORD1.xy * _Turb_Noise_ST.xy + _Turb_Noise_ST.zw;
noiseUV = noiseUV + noiseUV;
noiseUV = _Time.yy * _Turb_UV + noiseUV;
float noise = SAMPLE_TEXTURE2D(_Turb_Noise,sampler_Turb_Noise,noiseUV).r;
float2 distortedUV = noise.xx * _Turb_MainTex_Value + input.vs_TEXCOORD4.xy;
'''
    add('ee5d759936ae','DistortedParticleSurfaceFragment',noise+sample.replace('input.vs_TEXCOORD4.xy','distortedUV')+GRADE,SEMANTICS)
    dissolve='''
float dissolveAmount = _Particle_diss_ON * (input.vs_TEXCOORD2.z-_Diss_value) + _Diss_value;
float2 dissolveUV = input.vs_TEXCOORD1.xy * _Diss_Tex_ST.xy + _Diss_Tex_ST.zw;
dissolveUV = _Time.yy * _Diss_UV + dissolveUV;
float dissolveTexel = SAMPLE_TEXTURE2D(_Diss_Tex,sampler_Diss_Tex,dissolveUV).r;
float threshold = -dissolveAmount * (2.0-_Diss_Soft_value) + (dissolveTexel+1.0);
float inverseSoftness = 1.0 / (1.0-_Diss_Soft_value);
float outerRamp = saturate(((threshold+_EdgeWidth)-_Diss_Soft_value)*inverseSoftness);
float outerCoverage = (outerRamp*outerRamp) * (outerRamp*-2.0+3.0);
float innerRamp = saturate(inverseSoftness * (threshold-_Diss_Soft_value));
float innerCoverage = (innerRamp*innerRamp) * (innerRamp*-2.0+3.0);
float edgeCoverage = outerCoverage-innerCoverage;
color = edgeCoverage * (_Diss_Edge_color.rgb-color) + color;
float dissolveCoverage = _Diss_Edge_NO * edgeCoverage + innerCoverage;
surface.a *= dissolveCoverage;
'''
    add('cf2840221bef','DissolvingParticleSurfaceFragment',sample+GRADE.replace('float opacity =',dissolve+'\nfloat opacity ='),SEMANTICS)
