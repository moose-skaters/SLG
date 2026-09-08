#version 450
uniform vec3 _WorldSpaceCameraPos;
uniform vec2 _GlobalMipBias;
layout(std140, binding = 0) uniform UnityPerMaterial{
  vec4 _MainTex_ST;
  vec4 _MainColor;
  vec4 _Main02Color;
  vec4 _MainTex02_ST;
  vec4 _mainUVMove;
  vec4 _main02UVMove;
  vec4 _NoiseColor;
  vec4 _NoiseTex_ST;
  vec4 _noiseUVMove;
  vec4 _WPODir;
  vec4 _DissolveTex_ST;
  vec4 _EdgeColor;
  vec4 _depc;
  vec4 _dissolveUVMove;
  vec4 _MaskTex_ST;
  vec4 _maskUVMove;
  vec4 _FresnelColor;
  vec4 _FalseViewDir;
  vec4 _HeightFadeParam;
  int _MaskType;
  float _HeightFade;
  float _MWarpMode;
  float _M02WarpMode;
  float _UVChannel;
  float _BlackOff;
  float _BlackOff_1;
  float _NWarpMode;
  float _DistortIntensity;
  float _DissolveDirToggle;
  float _DissolveDir;
  float _InvertDissolveDir;
  float _particleUV;
  float _dissolveMode;
  float _DWarpMode;
  float _DistortMod;
  float _WPOMod;
  float _MaskTexUV;
  float _MKWarpMode;
  float _CameraOffset;
  float _BlendMode;
  float _InvertMode;
  float _FalseFresnel;
  float _FresnelPower;
  float _Desaturate;
  float _MainColorIntensity;
  float _Main02ColorIntensity;
  float _NoiseColorIntensity;
  float _EdgeColorIntensity;
  float _FresnelColorIntensity;
  float _MainAngle;
  float _Main02Angle;
  float _NoiseAngle;
  float _DissolveAngle;
  float _MaskAngle;
  float _RimIntencity;
  float _ScreenSpaceUV_ON;
  float _MNBlendMode;
};
layout(location = 0) uniform sampler2D _MainTex;
layout(location = 1) uniform sampler2D _MainTex02;
layout(location = 2) uniform sampler2D _MaskTex;
in vec4 vs_TEXCOORD0;
in vec4 vs_TEXCOORD1;
in vec4 vs_TEXCOORD3;
in vec3 vs_TEXCOORD4;
in vec3 vs_TEXCOORD5;
layout(location = 0) out vec4 SV_Target0;
vec3 u_xlat0;
vec4 u_xlat16_0;
bvec2 u_xlatb0;
float u_xlat16_1;
vec3 u_xlat2;
vec4 u_xlat16_2;
vec4 u_xlat3;
vec4 u_xlat16_3;
vec4 u_xlat16_4;
vec4 u_xlat16_5;
vec4 u_xlat16_6;
vec4 u_xlat16_7;
vec3 u_xlat16_9;
float u_xlat11;
float u_xlat24;
#define _MNBlendMode 0.35
#define _BlackOff 0.4
#define _Desaturate 0.25
#define _HeightFade 0.3
#define _HeightFadeParam vec4(-1.0,5.0,0.0,0.0)
#define _MainAngle 37
#define _Main02Angle 21
#define _MaskType 3
#define _BlendMode 0.65
#define _InvertMode 0.4
#define _FalseFresnel 0.3
#define _FalseViewDir vec4(0.2,1.0,0.3,0.0)
#define _FresnelPower 2
#define _FresnelColorIntensity 0.7
#define _FresnelColor vec4(0.4,0.6,0.8,0.75)
#define _DistortIntensity 0.07
#define _DistortMod 0.35
#define _DissolveDirToggle 0.7
#define _DissolveDir 0.6
#define _InvertDissolveDir 0.4
#define _depc vec4(0.35,0.6,0.0,0.07)
#define _dissolveMode 0.3
void main(){
  (u_xlat0.xy = vs_TEXCOORD1.zw);
  (u_xlat0.xy = clamp(u_xlat0.xy, 0.0, 1.0));
  (u_xlat0.xy = (u_xlat0.xy + (-vs_TEXCOORD1.zw)));
  (u_xlat0.xy = ((vec2(vec2(_MKWarpMode, _MKWarpMode)) * u_xlat0.xy) + vs_TEXCOORD1.zw));
  (u_xlat16_0.xy = texture(_MaskTex, u_xlat0.xy, _GlobalMipBias.x).xw);
  (u_xlat16_1 = min(u_xlat16_0.y, u_xlat16_0.x));
  (u_xlatb0.xy = equal(ivec4(_MaskType), ivec4(1, 3, 0, 0)).xy);
  (u_xlat16_9.x = ((u_xlatb0.y) ? (u_xlat16_1) : (1.0)));
  (u_xlat16_9.x = ((u_xlatb0.x) ? (1.0) : (u_xlat16_9.x)));
  (u_xlat16_1 = (((_MaskType != 0)) ? (u_xlat16_9.x) : (u_xlat16_1)));
  (u_xlat0.x = float(_MaskType));
  (u_xlatb0.xy = equal(u_xlat0.xxxx, vec4(0.0, 3.0, 0.0, 0.0)).xy);
  (u_xlatb0.x = (u_xlatb0.y || u_xlatb0.x));
  (u_xlat16_1 = ((u_xlatb0.x) ? (u_xlat16_1) : (1.0)));
  (u_xlat16_9.x = dot(_FalseViewDir.xyz, _FalseViewDir.xyz));
  (u_xlat16_9.x = inversesqrt(u_xlat16_9.x));
  (u_xlat0.xyz = ((-vs_TEXCOORD5.xyz) + _WorldSpaceCameraPos.xyz));
  (u_xlat24 = dot(u_xlat0.xyz, u_xlat0.xyz));
  (u_xlat24 = inversesqrt(u_xlat24));
  (u_xlat0.xyz = (vec3(u_xlat24) * u_xlat0.xyz));
  (u_xlat2.xyz = ((_FalseViewDir.xyz * u_xlat16_9.xxx) + (-u_xlat0.xyz)));
  (u_xlat0.xyz = ((vec3(vec3(_FalseFresnel, _FalseFresnel, _FalseFresnel)) * u_xlat2.xyz) + u_xlat0.xyz));
  (u_xlat0.x = dot(vs_TEXCOORD4.xyz, u_xlat0.xyz));
  (u_xlat16_9.x = ((-u_xlat0.x) + 1.0));
  (u_xlat16_9.x = clamp(u_xlat16_9.x, 0.0, 1.0));
  (u_xlat0.x = log2(u_xlat16_9.x));
  (u_xlat0.x = (u_xlat0.x * _FresnelPower));
  (u_xlat0.x = exp2(u_xlat0.x));
  (u_xlat16_9.x = ((u_xlat0.x * -2.0) + 1.0));
  (u_xlat16_9.x = ((_InvertMode * u_xlat16_9.x) + u_xlat0.x));
  (u_xlat16_0 = (u_xlat16_9.xxxx * _FresnelColor));
  (u_xlat16_2 = (u_xlat16_0 * vec4(_FresnelColorIntensity)));
  (u_xlat3 = vs_TEXCOORD0);
  (u_xlat3 = clamp(u_xlat3, 0.0, 1.0));
  (u_xlat3 = (u_xlat3 + (-vs_TEXCOORD0)));
  (u_xlat3 = ((vec4(_MWarpMode, _MWarpMode, _M02WarpMode, _M02WarpMode) * u_xlat3) + vs_TEXCOORD0));
  (u_xlat16_4 = texture(_MainTex, u_xlat3.xy, _GlobalMipBias.x));
  (u_xlat16_3 = texture(_MainTex02, u_xlat3.zw, _GlobalMipBias.x));
  (u_xlat16_5 = (u_xlat16_4 * _MainColor));
  (u_xlat16_5 = (u_xlat16_5 * vec4(_MainColorIntensity)));
  (u_xlat16_6 = (u_xlat16_3 * _Main02Color));
  (u_xlat16_5 = ((u_xlat16_6 * vec4(vec4(_Main02ColorIntensity, _Main02ColorIntensity, _Main02ColorIntensity, _Main02ColorIntensity))) + u_xlat16_5));
  (u_xlat16_6 = (u_xlat16_4 * u_xlat16_3));
  (u_xlat16_7 = (u_xlat16_6 * _MainColor));
  (u_xlat16_5 = (((-u_xlat16_7) * vec4(_MainColorIntensity)) + u_xlat16_5));
  (u_xlat16_7 = (u_xlat16_7 * vec4(_MainColorIntensity)));
  (u_xlat16_5 = ((vec4(_MNBlendMode) * u_xlat16_5) + u_xlat16_7));
  (u_xlat16_0 = ((u_xlat16_0 * vec4(_FresnelColorIntensity)) + u_xlat16_5));
  (u_xlat16_7 = (u_xlat16_2 * u_xlat16_5));
  (u_xlat16_5 = (((-u_xlat16_5) * u_xlat16_2) + u_xlat16_0));
  (u_xlat16_0 = ((u_xlat16_0 * u_xlat16_2.wwww) + (-u_xlat16_7)));
  (u_xlat16_0 = ((vec4(vec4(_BlendMode, _BlendMode, _BlendMode, _BlendMode)) * u_xlat16_0) + u_xlat16_7));
  (u_xlat16_2 = ((vec4(vec4(_BlendMode, _BlendMode, _BlendMode, _BlendMode)) * u_xlat16_5) + u_xlat16_7));
  (u_xlat16_0 = (u_xlat16_0 + (-u_xlat16_2)));
  (u_xlat16_0 = ((vec4(_InvertMode) * u_xlat16_0) + u_xlat16_2));
  (u_xlat16_9.x = (u_xlat16_3.x + u_xlat16_4.x));
  (u_xlat16_9.x = clamp(u_xlat16_9.x, 0.0, 1.0));
  (u_xlat16_9.x = (((-u_xlat16_3.x) * u_xlat16_4.x) + u_xlat16_9.x));
  (u_xlat16_9.x = ((_MNBlendMode * u_xlat16_9.x) + u_xlat16_6.x));
  (u_xlat16_9.x = ((u_xlat16_0.w * u_xlat16_9.x) + (-u_xlat16_0.w)));
  (u_xlat16_9.x = ((_BlackOff * u_xlat16_9.x) + u_xlat16_0.w));
  (u_xlat16_1 = (u_xlat16_1 * u_xlat16_9.x));
  (u_xlat16_1 = clamp(u_xlat16_1, 0.0, 1.0));
  (u_xlat3.x = ((-_HeightFadeParam.x) + _HeightFadeParam.y));
  (u_xlat3.x = (1.0 / float(u_xlat3.x)));
  (u_xlat11 = (vs_TEXCOORD5.y + (-_HeightFadeParam.x)));
  (u_xlat3.x = (u_xlat3.x * u_xlat11));
  (u_xlat3.x = clamp(u_xlat3.x, 0.0, 1.0));
  (u_xlat3.x = (u_xlat3.x + -1.0));
  (u_xlat3.x = ((_HeightFade * u_xlat3.x) + 1.0));
  (u_xlat3.x = (u_xlat16_1 * u_xlat3.x));
  (u_xlat16_1 = (u_xlat3.x * vs_TEXCOORD3.w));
  (u_xlat16_9.x = dot(u_xlat16_0.xyz, vec3(0.22, 0.70700002, 0.071000002)));
  (u_xlat16_9.xyz = ((-u_xlat16_0.xyz) + u_xlat16_9.xxx));
  (u_xlat16_9.xyz = ((vec3(vec3(_Desaturate, _Desaturate, _Desaturate)) * u_xlat16_9.xyz) + u_xlat16_0.xyz));
  (u_xlat16_9.xyz = (u_xlat16_9.xyz * vs_TEXCOORD3.xyz));
  (SV_Target0.xyz = (vec3(u_xlat16_1) * u_xlat16_9.xyz));
  (SV_Target0.w = u_xlat16_1);
  return ;
}
