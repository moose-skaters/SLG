"""Source-audited character lighting variants; all source uniforms stay editable."""

VERTEX_SEMANTICS={'vs_TEXCOORD0':'uv','vs_TEXCOORD1':'normalWS','vs_TEXCOORD2':'worldPositionAndFog','vs_TEXCOORD3':'ambientSH','vs_TEXCOORD5':'unusedLighting','vs_TEXCOORD6':'unusedAdditionalLighting'}

FOG = '''
// Captured height-density integration, including its additional exponential factor.
float CapturedHeightFog(float3 worldPosition)
{
    float height = ((worldPosition.y - _WorldSpaceCameraPos.y) - _FogHeight) * (_FogFallOff * 0.0099999998);
    float exponential = exp2(-height);
    float integratedDensity = (exponential * _FogGlobalDensity) * ((1.0 - exponential) / height);
    float3 toCamera = _WorldSpaceCameraPos - worldPosition;
    float distance = sqrt(max(dot(toCamera, toCamera), 6.1035156e-05));
    float distanceRamp = max((distance - _FogStartDis) / _FogGradientDis, 0.0);
    float fogRamp = saturate((1.0 / (_FogEnd - _FogStart)) * (integratedDensity * distanceRamp - _FogStart));
    float smoothPolynomial = fogRamp * -2.0 + 3.0;
    return (fogRamp * fogRamp) * smoothPolynomial;
}
'''

SH = '''
float3 CapturedSphericalHarmonics(float3 normalWS)
{
    float normalDifference = normalWS.x * normalWS.x - normalWS.y * normalWS.y;
    float4 products = normalWS.yzzx * normalWS.xyzz;
    float3 quadratic = float3(dot(unity_SHBr, products), dot(unity_SHBg, products), dot(unity_SHBb, products));
    quadratic = unity_SHC.xyz * normalDifference + quadratic;
    float4 homogeneousNormal = float4(normalWS, 1.0);
    float3 firstOrder = float3(dot(unity_SHAr, homogeneousNormal), dot(unity_SHAg, homogeneousNormal), dot(unity_SHAb, homogeneousNormal));
    return max(quadratic + firstOrder, 0.0);
}
'''

BASE_VERTEX = '''
float4 localPosition = input.in_POSITION0;
localPosition.y += _VertexOffsetY;
float4 worldPosition = TransformCapturedObject(localPosition);
output.positionCS = TransformCapturedWorld(float4(worldPosition.xyz, 1.0));
output.vs_TEXCOORD0 = input.in_TEXCOORD0;
float3 transformedNormal = float3(dot(input.in_NORMAL0, hlslcc_mtx4x4unity_WorldToObject[0].xyz),
    dot(input.in_NORMAL0, hlslcc_mtx4x4unity_WorldToObject[1].xyz),
    dot(input.in_NORMAL0, hlslcc_mtx4x4unity_WorldToObject[2].xyz));
float3 normalWS = rsqrt(max(dot(transformedNormal, transformedNormal), 0.0)) * transformedNormal;
output.vs_TEXCOORD1 = normalWS;
output.vs_TEXCOORD2 = float4(worldPosition.xyz, FOG_EXPRESSION);
output.vs_TEXCOORD3 = CapturedSphericalHarmonics(normalWS);
output.vs_TEXCOORD5 = 0.0;
output.vs_TEXCOORD6 = 0.0;
'''

ATLAS = '''
float2 CapturedAtlasUV(float2 baseUV)
{
    if (_SheetAnimationON == 0.0) return baseUV;
    float animationTime = _Time.y * _MainTexSheetAnimSpeed;
    float cellCount = trunc(_MainTexSheet.y * _MainTexSheet.x);
    float signedFrameProduct = cellCount * animationTime;
    float signedFrameDivisor = signedFrameProduct >= -signedFrameProduct ? cellCount : -cellCount;
    float wrappedFrame = frac((1.0 / signedFrameDivisor) * animationTime) * signedFrameDivisor;
    float signedColumnProduct = wrappedFrame * _MainTexSheet.x;
    float signedColumnDivisor = signedColumnProduct >= -signedColumnProduct ? _MainTexSheet.x : -_MainTexSheet.x;
    float wrappedColumn = frac((1.0 / signedColumnDivisor) * wrappedFrame) * signedColumnDivisor;
    float invertedRow = (-trunc(wrappedFrame / _MainTexSheet.x) + _MainTexSheet.y) - 1.0;
    float4 reciprocalSheetSize = 1.0 / _MainTexSheet.xyxy;
    float2 lowerCorner = reciprocalSheetSize.xy * float2(trunc(wrappedColumn), trunc(invertedRow));
    float2 upperCorner = float2((int)wrappedColumn + 1, (int)invertedRow + 1) * reciprocalSheetSize.zw;
    return baseUV * (upperCorner - lowerCorner) + lowerCorner;
}
'''

LIGHTING = '''
float2 surfaceUV = CapturedAtlasUV(input.vs_TEXCOORD0);
float2 baseUV = surfaceUV * _MainTex_ST.xy + _MainTex_ST.zw;
float4 baseTexel = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, baseUV);
float3 textureOrWhite = _NoMainTextureOn * (1.0 - baseTexel.rgb) + baseTexel.rgb;
float4 scaledTint = _Color * _Intensity;
float3 albedo = textureOrWhite * scaledTint.rgb;
float textureOpacity = baseTexel.a * scaledTint.a;
float3 firstLightColor = _LightColor1.rgb * _LightIntensity1;
float3 sceneLightTint = _HeroDayNight_ON * (_LightColor2.rgb * _LightIntensity2 - firstLightColor) + firstLightColor;
float3 sceneTintedAlbedo = albedo * sceneLightTint;
float lambert = saturate(dot(_MainLightPosition.xyz, input.vs_TEXCOORD1));
float3 lighting = _BlinnPhongOn > 0.5 ? lambert * sceneTintedAlbedo : sceneTintedAlbedo;
ADDITIONAL_LIGHTS
lighting = _BlinnPhongOn * (albedo * input.vs_TEXCOORD3) + lighting;
if (_Fresnel_ON > 0.5)
{
    float3 toCamera = _WorldSpaceCameraPos - input.vs_TEXCOORD2.xyz;
    float3 viewDirection = rsqrt(dot(toCamera, toCamera)) * toCamera;
    float rimBase = 1.0 - saturate(dot(input.vs_TEXCOORD1, viewDirection));
    float rimSquared = rimBase * rimBase;
    float rimCubic = rimBase * rimSquared;
    float rimQuintic = rimCubic * rimSquared;
    float broadRim = (_Fresnel_Scale * rimQuintic + _Fresnel_Bisa) * _Fresnel_Intensity;
    float edgeRim = (rimCubic * _Fresnel_Scale_Edge) * _Fresnel_Intensity;
    lighting += _Fresnel_Color.rgb * broadRim + edgeRim * _Fresnel_Color_Edge.rgb;
}
if (_EMISSIONMAPON_ON > 0.5)
{
    float3 emissionTexel = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, surfaceUV).rgb;
    float3 tintedEmission = emissionTexel * _EmissionColor.rgb;
    float3 constantEmission = tintedEmission * _EmissionIntensity;
    float timelineIntensity = _Timeline * -_EmissionIntensity + _EmissionIntensity;
    float3 buildingEmission = _EMISSIONMAPON_BUILDING_ON * (tintedEmission * timelineIntensity - constantEmission) + constantEmission;
    lighting += buildingEmission;
}
FOG_COMPOSITION
// The source multiplies material alpha twice. Red opacity uses already tinted albedo.
float alphaOpacity = textureOpacity * _Color.a;
float opacity = _AlphaIsR * (albedo.r * _Color.a - alphaOpacity) + alphaOpacity;
float heightVisible = input.vs_TEXCOORD2.y >= _FadeY ? 1.0 : 0.0;
opacity = _AlphFadeY_ON * (heightVisible * opacity - opacity) + opacity;
return float4(lighting, opacity);
'''

ADDITIONAL = '''
uint additionalCount = (uint)(int)min(_AdditionalLightsCount.x, unity_LightData.y);
for (uint light = 0; light < additionalCount; ++light)
{
    uint packedVector = light >> 2;
    uint component = light & 3;
    int index = (int)unity_LightIndices[packedVector][component];
    float3 toLight = _AdditionalLightsPosition[index].xyz - input.vs_TEXCOORD2.xyz * _AdditionalLightsPosition[index].w;
    float distanceSquared = max(dot(toLight, toLight), 6.1035156e-05);
    float3 direction = rsqrt(distanceSquared) * toLight;
    float attenuation = saturate(distanceSquared * _AdditionalLightsAttenuation[index].x + _AdditionalLightsAttenuation[index].y) * (1.0 / distanceSquared);
    float spot = saturate(dot(_AdditionalLightsSpotDir[index].xyz, direction) * _AdditionalLightsAttenuation[index].z + _AdditionalLightsAttenuation[index].w);
    attenuation = (spot * spot) * attenuation;
    attenuation = min(attenuation, 0.0099999998);
    float3 additionalColor = (attenuation * _AdditionalLightsColor[index].rgb) * _MaxAddIntensity1;
    lighting = additionalColor * baseTexel.rgb + lighting;
}
'''


def register(add):
    for prefix in ('79fa3dc70233','61b4f94f8d7b'):
        add(prefix,'CapturedDiffuseVertex',BASE_VERTEX.replace('FOG_EXPRESSION','0.0'),VERTEX_SEMANTICS,SH)
    add('491082b1ac74','CapturedFogDiffuseVertex',BASE_VERTEX.replace('FOG_EXPRESSION','CapturedHeightFog(worldPosition.xyz)'),VERTEX_SEMANTICS,SH+FOG)
    for prefix,fog,additional in [('8b6ca3511b4f',False,False),('cfd52185cba5',True,False),('3742ab6ed8ff',False,True)]:
        body=LIGHTING.replace('ADDITIONAL_LIGHTS',ADDITIONAL if additional else '')
        body=body.replace('FOG_COMPOSITION','float fogWeight = saturate(input.vs_TEXCOORD2.w) * _FogColor.a;\nlighting = fogWeight * (_FogColor.rgb - lighting) + lighting;' if fog else '')
        add(prefix,'CapturedDiffuse'+('Fog' if fog else '')+('AdditionalLights' if additional else '')+'Fragment',body,VERTEX_SEMANTICS,ATLAS)
    for prefix,fog,additional in [('3edaf5a64eab',False,False),('9bad21e099c4',False,True)]:
        body=LIGHTING.replace('ADDITIONAL_LIGHTS',ADDITIONAL if additional else '').replace('FOG_COMPOSITION','')
        body=body.replace('float3 textureOrWhite', 'clip(baseTexel.a - _CutOff);\nfloat3 textureOrWhite')
        add(prefix,'CapturedCutoutDiffuse'+('AdditionalLights' if additional else '')+'Fragment',body,VERTEX_SEMANTICS,ATLAS)
