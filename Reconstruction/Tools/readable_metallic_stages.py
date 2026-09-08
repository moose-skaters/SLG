"""Captured metallic workflow with independent ambient, emission, rim and fog controls."""
from readable_lighting_stages import SH, FOG
SEMANTICS={'vs_TEXCOORD0':'baseAndSecondaryUV','vs_TEXCOORD2':'normalAndPositionX',
    'vs_TEXCOORD3':'tangentAndPositionY','vs_TEXCOORD4':'bitangentAndPositionZ',
    'vs_TEXCOORD5':'ambientAndFog','vs_TEXCOORD6':'screenPosition'}
VERTEX='''
float4 positionWS = TransformCapturedObject(input.in_POSITION0);
output.positionCS = TransformCapturedWorld(float4(positionWS.xyz,1));
output.vs_TEXCOORD0 = float4(input.in_TEXCOORD0,input.in_TEXCOORD1);
float3 normalWS = float3(dot(input.in_NORMAL0,hlslcc_mtx4x4unity_WorldToObject[0].xyz),
    dot(input.in_NORMAL0,hlslcc_mtx4x4unity_WorldToObject[1].xyz),dot(input.in_NORMAL0,hlslcc_mtx4x4unity_WorldToObject[2].xyz));
normalWS = rsqrt(max(dot(normalWS,normalWS),0))*normalWS;
float3 tangentWS = input.in_TANGENT0.y*hlslcc_mtx4x4unity_ObjectToWorld[1].xyz;
tangentWS = hlslcc_mtx4x4unity_ObjectToWorld[0].xyz*input.in_TANGENT0.x+tangentWS;
tangentWS = hlslcc_mtx4x4unity_ObjectToWorld[2].xyz*input.in_TANGENT0.z+tangentWS;
tangentWS = rsqrt(max(dot(tangentWS,tangentWS),0))*tangentWS;
float handedness = (unity_WorldTransformParams.w>=0 ? 1.0 : -1.0)*input.in_TANGENT0.w;
float3 bitangentWS = (normalWS.yzx*tangentWS.zxy-normalWS.zxy*tangentWS.yzx)*handedness;
output.vs_TEXCOORD2 = float4(normalWS,positionWS.x);
output.vs_TEXCOORD3 = float4(tangentWS,positionWS.y);
output.vs_TEXCOORD4 = float4(bitangentWS,positionWS.z);
output.vs_TEXCOORD5 = float4(CapturedSphericalHarmonics(normalWS),CapturedHeightFog(positionWS.xyz));
float4 clipPosition = output.positionCS;
output.vs_TEXCOORD6 = float4(float2(clipPosition.x,clipPosition.y*_ProjectionParams.x)*0.5+clipPosition.w*0.5,clipPosition.zw);
'''
FRAGMENT='''
float3 normalWS = rsqrt(dot(input.vs_TEXCOORD2.xyz,input.vs_TEXCOORD2.xyz))*input.vs_TEXCOORD2.xyz;
float3 positionWS = float3(input.vs_TEXCOORD2.w,input.vs_TEXCOORD3.w,input.vs_TEXCOORD4.w);
float3 toCamera = _WorldSpaceCameraPos-positionWS;
float viewLengthSquared = dot(toCamera,toCamera);
float3 viewDirection = toCamera*rsqrt(max(viewLengthSquared,0));
float2 baseUV = _UV2_ON*(input.vs_TEXCOORD0.zw-input.vs_TEXCOORD0.xy)+input.vs_TEXCOORD0.xy;
baseUV = baseUV*_BaseMap_ST.xy+_BaseMap_ST.zw;
float3 baseTexel = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,baseUV).rgb;
float2 packedUV = input.vs_TEXCOORD0.xy*_MGA_ST.xy+_MGA_ST.zw;
float4 packed = SAMPLE_TEXTURE2D(_MGA,sampler_MGA,packedUV);
float metallic = saturate(packed.r*_MetallicIntensity);
float roughness = min(max(packed.g*_RoughnessIntensity,0.001),1.0);
float3 albedo = baseTexel*_BaseColor.rgb;
float3 emission;
if (_EmissionMap_ON>0.5)
    emission = SAMPLE_TEXTURE2D(_EmissionMap,sampler_EmissionMap,input.vs_TEXCOORD0.xy).rgb*(_EmissiveColor.rgb*_EmissiveIntensity);
else emission = packed.a*(_EmissiveColor.rgb*_EmissiveIntensity);
float smoothness = max(1.0-roughness,0.001);
float ambientOcclusion = min(packed.b*_AoIntensity,1.0);
float oneMinusReflectivity = -metallic*0.95999998+0.95999998;
float grazingDifference = smoothness-oneMinusReflectivity;
float3 diffuse = albedo*oneMinusReflectivity;
float3 specular = metallic*(albedo-0.039999999)+0.039999999;
float microfacetRoughness = 1.0-smoothness;
microfacetRoughness = max(microfacetRoughness*microfacetRoughness,0.0078125);
float grazing = min(grazingDifference+1.0,1.0);
float fresnel = 1.0-saturate(dot(normalWS,viewDirection));
fresnel *= fresnel;
fresnel *= fresnel;
float normalization = 1.0/(microfacetRoughness*microfacetRoughness+1.0);
float3 environmentBRDF = normalization*(fresnel*(grazing.xxx-specular)+specular);
float3 indirectSpecular = environmentBRDF*_GlossyEnvironmentColor.rgb;
float3 indirect = input.vs_TEXCOORD5.rgb*diffuse+indirectSpecular;
float inverseCustomLightLength = rsqrt(dot(_CustomLightDir,_CustomLightDir));
float3 lightDirection = _CustmLightDir_ON*(_CustomLightDir.xyz*inverseCustomLightLength-_MainLightPosition.xyz)+_MainLightPosition.xyz;
float lambert = saturate(dot(normalWS,lightDirection));
float3 mainColor = _MainLightColor.rgb*_CustomLightIntensity;
mainColor = _HeroDayNight_ON*(_LightColor2.rgb*_LightIntensity2-mainColor)+mainColor;
float3 directLight = (lambert*unity_LightData.z)*mainColor;
float3 lighting = diffuse*directLight;
lighting = indirect*ambientOcclusion+lighting;
lighting = emission+lighting;
if (_Fresnel_ON>0.5)
{
    float3 rimView = rsqrt(viewLengthSquared)*toCamera;
    float edge = 1.0-saturate(dot(normalWS,rimView));
    float rim = edge*edge;
    rim = edge*rim;
    rim = edge*rim;
    rim = edge*rim;
    rim = (_Fresnel_Scale*rim+_Fresnel_Bisa)*_Fresnel_Intensity;
    float edgeSquared = edge*edge;
    float narrowRim = ((edge*edgeSquared)*_Fresnel_Scale_Edge)*_Fresnel_Intensity;
    float3 rimColor = _Fresnel_Color.rgb*rim+narrowRim*_Fresnel_Color_Edge.rgb;
    lighting = rimColor+lighting;
}
float fogWeight = saturate(input.vs_TEXCOORD5.w)*_FogColor.a;
lighting = fogWeight*(_FogColor.rgb-lighting)+lighting;
float3 dayTint = _DayNightInfluence*(_LightColor2.rgb*_LightIntensity2-1.0)+1.0;
return float4(dayTint*lighting,1.0);
'''
def register(add):
    add('16eccad43192','MetallicFogVertex',VERTEX,SEMANTICS,SH+FOG)
    add('5d175b84331e','MetallicAmbientFogFragment',FRAGMENT,SEMANTICS)
    add('88473450891b','MetallicVertex',VERTEX.replace('CapturedHeightFog(positionWS.xyz)','0.0'),SEMANTICS,SH)
    from readable_skin_stages import INSTANCE_DECLARATIONS
    from readable_stages import STAGES
    add('53e3e6b0aba8','InstancedMetallicFogVertex',VERTEX,SEMANTICS,SH+FOG)
    STAGES['53e3e6b0aba8'].update(declarations=INSTANCE_DECLARATIONS,expand_instances=True)
    cubemap='''
float reflectedDot = dot(-viewDirection,normalWS);
reflectedDot = reflectedDot+reflectedDot;
float3 reflectionDirection = normalWS*(-reflectedDot)-viewDirection;
float perceptualRoughness = 1.0-smoothness;
float mip = (perceptualRoughness*(-perceptualRoughness*0.69999999+1.7))*6.0;
float reflectionScale = exp2(log2(_ReflectionIntenSity)*0.44);
float4 environmentSample = SAMPLE_TEXTURECUBE_LOD(_ReflectionMap,sampler_ReflectionMap,reflectionDirection+reflectionDir.xyz,mip);
float3 scaledEnvironment = reflectionScale*environmentSample.rgb;
float encodedAlpha = _ReflectionMap_HDR.w*(environmentSample.a*reflectionScale-1.0)+1.0;
float environmentDecode = exp2(log2(max(encodedAlpha,0))*_ReflectionMap_HDR.y)*_ReflectionMap_HDR.x;
float3 indirectSpecular = environmentBRDF*(scaledEnvironment*environmentDecode);
'''
    add('645428051b77','MetallicCubemapFogFragment',FRAGMENT.replace('float3 indirectSpecular = environmentBRDF*_GlossyEnvironmentColor.rgb;',cubemap),SEMANTICS)
