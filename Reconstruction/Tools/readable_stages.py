"""Human translations of captured programs. No GLSL is executed by Unity.

Keys are hashes of the exact source, so unrelated variants cannot silently share
an implementation. Named locals describe the source's actual arithmetic.
"""
STAGES = {}


def add(prefix, name, code, semantics=None, helpers=''):
    STAGES[prefix] = {'name': name, 'code': code.strip(), 'semantics': semantics or {}, 'helpers':helpers}


TRANSFORM = '''
float4 positionWS = TransformCapturedObject(input.in_POSITION0);
output.positionCS = TransformCapturedWorld(positionWS);
'''

add('9a35ed8b31cf', 'TintedTextureVertex', TRANSFORM + '''
output.vs_TEXCOORD0 = input.in_TEXCOORD0 * _MainTex_ST.xy + _MainTex_ST.zw;
''', {'vs_TEXCOORD0':'uv'})
add('026d46dbd64e', 'TintedTextureFragment', '''
return SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.vs_TEXCOORD0) * _Color;
''', {'vs_TEXCOORD0':'uv'})

for prefix, axis, name in [('4ad49bbc4fc3','y','VerticalGaussianVertex'),('0e02b33e36c5','x','HorizontalGaussianVertex')]:
    delta = 'float2(0.0, _MainTex_TexelSize.y)' if axis == 'y' else 'float2(_MainTex_TexelSize.x, 0.0)'
    add(prefix,name,TRANSFORM+'''
float2 sampleOffset = '''+delta+''' * _BlurSize;
output.vs_TEXCOORD0 = input.in_TEXCOORD0;
output.vs_TEXCOORD1 = input.in_TEXCOORD0 + sampleOffset;
output.vs_TEXCOORD2 = input.in_TEXCOORD0 - sampleOffset;
output.vs_TEXCOORD3 = input.in_TEXCOORD0 + sampleOffset * 2.0;
output.vs_TEXCOORD4 = input.in_TEXCOORD0 - sampleOffset * 2.0;
''',{'vs_TEXCOORD0':'centerUV','vs_TEXCOORD1':'positiveNearUV','vs_TEXCOORD2':'negativeNearUV','vs_TEXCOORD3':'positiveFarUV','vs_TEXCOORD4':'negativeFarUV'})
add('8a90c52e9e3a','FiveTapGaussianFragment','''
// Source weights sum to 1.000000008; retain their literal precision and order.
float3 blurred = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.vs_TEXCOORD1).rgb * 0.24420001;
float4 center = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.vs_TEXCOORD0);
blurred = center.rgb * 0.40259999 + blurred;
blurred = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.vs_TEXCOORD2).rgb * 0.24420001 + blurred;
blurred = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.vs_TEXCOORD3).rgb * 0.054499999 + blurred;
blurred = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.vs_TEXCOORD4).rgb * 0.054499999 + blurred;
return float4(blurred, center.a);
''')
add('5f4f84ae995c','SourceTextureVertex',TRANSFORM+'''
output.vs_TEXCOORD0 = input.in_TEXCOORD0;
''',{'vs_TEXCOORD0':'uv'})
add('c7ce5b89b06f','SourceTextureFragment','''
return SAMPLE_TEXTURE2D_BIAS(_SourceTex, sampler_SourceTex, input.vs_TEXCOORD0, _GlobalMipBias.x);
''',{'vs_TEXCOORD0':'uv'})
add('60ebfa0fc865','ProjectedBlurVertex',TRANSFORM+'''
float4 clipPosition = output.positionCS;
output.vs_TEXCOORD3 = float4(clipPosition.x * 0.5 + clipPosition.w * 0.5,
    clipPosition.y * _ProjectionParams.x * 0.5 + clipPosition.w * 0.5, clipPosition.zw);
''',{'vs_TEXCOORD3':'projectedScreenPosition'})
add('f94449788014','ProjectedBlurFragment','''
float2 screenUV = input.vs_TEXCOORD3.xy / input.vs_TEXCOORD3.ww;
return float4(SAMPLE_TEXTURE2D(blurURP_1, sampler_blurURP_1, screenUV).rgb, 1.0);
''',{'vs_TEXCOORD3':'projectedScreenPosition'})
add('d6e7e240fa2b','PortraitVertex',TRANSFORM+'''
output.vs_COLOR0 = float4((input.in_COLOR0.rgb * input.in_COLOR0.a) * (_Color.rgb * _Color.a), input.in_COLOR0.a * _Color.a);
output.vs_TEXCOORD0 = input.in_TEXCOORD0;
output.vs_TEXCOORD1 = input.in_POSITION0;
''',{'vs_COLOR0':'premultipliedTint','vs_TEXCOORD0':'uv','vs_TEXCOORD1':'localPosition'})
add('87fc958f0a26','PortraitFragment','''
float inside = all(input.vs_TEXCOORD1.xy >= _ClipRect.xy) && all(input.vs_TEXCOORD1.xy <= _ClipRect.zw) ? 1.0 : 0.0;
float4 texel = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.vs_TEXCOORD0);
float4 premultipliedSample = float4(texel.rgb * texel.a + _TextureSampleAdd.rgb, texel.a + _TextureSampleAdd.a);
float4 color = premultipliedSample * input.vs_COLOR0 * inside;
float grey = ((color.g + color.r) + color.b) * 0.33333334;
return float4(_Grey_ON * (grey.xxx - color.rgb) + color.rgb, color.a);
''',{'vs_COLOR0':'premultipliedTint','vs_TEXCOORD0':'uv','vs_TEXCOORD1':'localPosition'})
add('158a21150fae','CanvasSpriteVertex',TRANSFORM+'''
// This is Unity's captured gamma-to-linear approximation, including low-end branch.
float3 gammaColor = input.in_COLOR0.rgb;
float3 polynomial = gammaColor * 0.265885 + 0.73658401;
polynomial = gammaColor * polynomial - 0.0098018404;
polynomial = gammaColor * polynomial + 0.0031969701;
float3 lowRange = gammaColor * 0.084971003 - 0.00016302901;
float3 linearColor = float3(gammaColor.r < 0.072549 ? lowRange.r : polynomial.r,
    gammaColor.g < 0.072549 ? lowRange.g : polynomial.g,
    gammaColor.b < 0.072549 ? lowRange.b : polynomial.b);
output.vs_COLOR0 = float4(_UIVertexColorAlwaysGammaSpace != 0 ? linearColor : gammaColor, input.in_COLOR0.a) * _Color;
output.vs_TEXCOORD0 = input.in_TEXCOORD0 * _MainTex_ST.xy + _MainTex_ST.zw;
output.vs_TEXCOORD1 = input.in_POSITION0;
float2 projectionScale = _ScreenParams.y * hlslcc_mtx4x4glstate_matrix_projection[1].xy;
projectionScale = hlslcc_mtx4x4glstate_matrix_projection[0].xy * _ScreenParams.x + projectionScale;
float2 pixelSize = output.positionCS.w / abs(projectionScale);
output.vs_TEXCOORD2.zw = 0.25 / (float2(_UIMaskSoftnessX, _UIMaskSoftnessY) * 0.25 + abs(pixelSize));
float4 rect = clamp(_ClipRect, -20000000000.0, 20000000000.0);
output.vs_TEXCOORD2.xy = input.in_POSITION0.xy * 2.0 - rect.xy - rect.zw;
''',{'vs_COLOR0':'tint','vs_TEXCOORD0':'uv','vs_TEXCOORD1':'localPosition','vs_TEXCOORD2':'maskData'})
add('8ea560eff6e9','CanvasSpriteFragment','''
float roundedAlpha = round(input.vs_COLOR0.a * 255.0) * 0.0039215689;
float4 sampleColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.vs_TEXCOORD0) + _TextureSampleAdd;
float4 color = float4(input.vs_COLOR0.rgb, roundedAlpha) * sampleColor;
return float4(color.rgb * color.a, color.a);
''',{'vs_COLOR0':'tint','vs_TEXCOORD0':'uv'})

def font_vertex(underlay):
    code = '''
float4 localPosition = input.in_POSITION0;
localPosition.xy += float2(_VertexOffsetX, _VertexOffsetY);
float4 positionWS = TransformCapturedObject(localPosition);
output.positionCS = TransformCapturedWorld(positionWS);
float3 viewDirection = normalize(_WorldSpaceCameraPos - positionWS.xyz);
float3 normalWS = normalize(float3(dot(input.in_NORMAL0, hlslcc_mtx4x4unity_WorldToObject[0].xyz),
    dot(input.in_NORMAL0, hlslcc_mtx4x4unity_WorldToObject[1].xyz),
    dot(input.in_NORMAL0, hlslcc_mtx4x4unity_WorldToObject[2].xyz)));
float2 projectedScale = _ScreenParams.y * hlslcc_mtx4x4glstate_matrix_projection[1].xy;
projectedScale = hlslcc_mtx4x4glstate_matrix_projection[0].xy * _ScreenParams.x + projectedScale;
float2 pixelSize = output.positionCS.w / (abs(projectedScale) * float2(_ScaleX, _ScaleY));
float inversePixelSize = rsqrt(dot(pixelSize, pixelSize));
float signedDistanceScale = inversePixelSize * ((_Sharpness + 1.0) * (abs(input.in_TEXCOORD1.y) * _GradientScale));
if (hlslcc_mtx4x4glstate_matrix_projection[3].w == 0.0)
{
    float minimumScale = (1.0 - _PerspectiveFilter) * abs(signedDistanceScale);
    signedDistanceScale = abs(dot(normalWS, viewDirection)) * (signedDistanceScale - minimumScale) + minimumScale;
}
float softenedScale = signedDistanceScale / ((_OutlineSoftness * _ScaleRatioA) * signedDistanceScale + 1.0);
float outline = softenedScale * (_OutlineWidth * _ScaleRatioA);
float boldWeight = input.in_TEXCOORD1.y <= 0.0 ? _WeightBold : _WeightNormal;
float contour = 0.5 - ((boldWeight * 0.25 + _FaceDilate) * _ScaleRatioA) * 0.5;
float bias = contour * softenedScale - 0.5;
output.vs_TEXCOORD1 = float4(softenedScale, bias - outline * 0.5, bias + outline * 0.5, bias);
float4 rect = clamp(_ClipRect, -20000000000.0, 20000000000.0);
output.vs_TEXCOORD0 = float4(input.in_TEXCOORD0, (localPosition.xy - rect.xy) / (rect.zw - rect.xy));
output.vs_TEXCOORD2 = float4(localPosition.xy * 2.0 - rect.xy - rect.zw,
    0.25 / (float2(_MaskSoftnessX, _MaskSoftnessY) * 0.25 + pixelSize));
'''
    code += '''
float4 faceColor = float4(input.in_COLOR0.rgb, 1.0) * _FaceColor;
faceColor.rgb *= faceColor.a;
float4 outlineColor = float4(_OutlineColor.rgb * _OutlineColor.a, _OutlineColor.a);
''' if underlay else '''
float4 faceColor = input.in_COLOR0 * _FaceColor;
faceColor.rgb *= faceColor.a;
float4 outlineColor = float4(_OutlineColor.rgb * (_OutlineColor.a * input.in_COLOR0.a), _OutlineColor.a * input.in_COLOR0.a);
'''
    code += '''
output.vs_COLOR0 = faceColor;
output.vs_COLOR1 = sqrt(min(outline, 1.0)) * (outlineColor - faceColor) + faceColor;
'''
    if underlay:
        code += '''
float4 underlay = float4(_UnderlaySoftness, _UnderlayDilate, _UnderlayOffsetX, _UnderlayOffsetY) * _ScaleRatioC;
float2 underlayUV = input.in_TEXCOORD0 - underlay.zw * _GradientScale / float2(_TextureWidth, _TextureHeight);
float underlayScale = signedDistanceScale / (underlay.x * signedDistanceScale + 1.0);
float underlayBias = contour * underlayScale - 0.5 - (underlay.y * underlayScale) * 0.5;
output.vs_TEXCOORD3 = float4(underlayUV, input.in_COLOR0.a, 0.0);
output.vs_TEXCOORD4 = float2(underlayScale, underlayBias);
'''
    return code

FONT_SEMANTICS = {'vs_COLOR0':'faceColor','vs_COLOR1':'outlineColor','vs_TEXCOORD0':'atlasAndMaskUV','vs_TEXCOORD1':'contourParameters','vs_TEXCOORD2':'maskData','vs_TEXCOORD3':'underlayUVAndOpacity','vs_TEXCOORD4':'underlayParameters'}
add('f94902b64c8a','DistanceFieldUnderlayVertex',font_vertex(True),FONT_SEMANTICS)
add('457b5452bc80','DistanceFieldVertex',font_vertex(False),FONT_SEMANTICS)
add('90b67741695d','DistanceFieldUnderlayFragment','''
float underlayDistance = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.vs_TEXCOORD3.xy).a;
float underlayCoverage = saturate(underlayDistance * input.vs_TEXCOORD4.x - input.vs_TEXCOORD4.y);
float4 underlayColor = underlayCoverage * float4(_UnderlayColor.rgb * _UnderlayColor.a, _UnderlayColor.a);
float glyphDistance = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.vs_TEXCOORD0.xy).a;
float2 coverage = saturate(glyphDistance * input.vs_TEXCOORD1.xx - input.vs_TEXCOORD1.zy);
float4 contourColor = coverage.x * (input.vs_COLOR0 - input.vs_COLOR1) + input.vs_COLOR1;
float4 glyphColor = coverage.y * contourColor;
return (underlayColor * (1.0 - contourColor.a * coverage.y) + glyphColor) * input.vs_TEXCOORD3.z;
''',FONT_SEMANTICS)
add('06c1b7014d0b','DistanceFieldFragment','''
float distance = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.vs_TEXCOORD0.xy).a;
float coverage = saturate(distance * input.vs_TEXCOORD1.x - input.vs_TEXCOORD1.w);
return coverage * input.vs_COLOR0;
''',FONT_SEMANTICS)
add('8a6251e77858','FramebufferCopyVertex','''
output.positionCS = float4(input.vertex.xy, 0.0, 1.0);
output.texCoord = input.vertex.zw * uvOffsetAndScale.zw + uvOffsetAndScale.xy;
''',{'texCoord':'uv'})
add('8c02ab489edb','FramebufferCopyFragment','''
return SAMPLE_TEXTURE2D(tex, sampler_tex, input.texCoord);
''',{'texCoord':'uv'})
add('b4582a0f2dae','WindowRotationVertex','''
output.positionCS = mul(projection, input.position);
output.outTexCoords = mul(_utexture, input.texCoords).xy;
''',{'outTexCoords':'uv'})
add('ce94cd0ec731','WindowRotationFragment','''
return float4(SAMPLE_TEXTURE2D(sampler, sampler_sampler, input.outTexCoords).rgb, 1.0);
''',{'outTexCoords':'uv'})
add('d6e433fffc4c','WindowPresentationVertex','''
output.positionCS = float4(input.position.xy * scale - translation, input.position.zw);
output.outCoord = input.inCoord * coordScale + coordTranslation;
''',{'outCoord':'uv'})
add('79cf613491a6','WindowPresentationFragment','''
return SAMPLE_TEXTURE2D(tex, sampler_tex, input.outCoord);
''',{'outCoord':'uv'})
