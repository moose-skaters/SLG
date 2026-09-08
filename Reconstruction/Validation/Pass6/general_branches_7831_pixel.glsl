#version 450
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
layout(location = 1) uniform sampler2D _NoiseTex;
in vec4 vs_TEXCOORD0;
in vec4 vs_TEXCOORD1;
in vec4 vs_TEXCOORD3;
in vec3 vs_TEXCOORD5;
in vec4 vs_TEXCOORD6;
layout(location = 0) out vec4 SV_Target0;
vec2 u_xlat0;
vec4 u_xlat16_0;
vec4 u_xlat16_1;
vec4 u_xlat16_2;
vec4 u_xlat16_3;
float u_xlat4;
vec2 u_xlat8;
float u_xlat16_13;
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
  (u_xlat0.xy = vs_TEXCOORD1.xy);
  (u_xlat0.xy = clamp(u_xlat0.xy, 0.0, 1.0));
  (u_xlat0.xy = (u_xlat0.xy + (-vs_TEXCOORD1.xy)));
  (u_xlat0.xy = ((vec2(vec2(_NWarpMode, _NWarpMode)) * u_xlat0.xy) + vs_TEXCOORD1.xy));
  (u_xlat16_0.x = texture(_NoiseTex, u_xlat0.xy, _GlobalMipBias.x).y);
  (u_xlat16_1.x = (u_xlat16_0.x + -0.5));
  (u_xlat0.x = (vs_TEXCOORD6.w + (-_DistortIntensity)));
  (u_xlat0.x = ((_DistortMod * u_xlat0.x) + _DistortIntensity));
  (u_xlat0.xy = ((u_xlat16_1.xx * u_xlat0.xx) + vs_TEXCOORD0.xy));
  (u_xlat8.xy = u_xlat0.xy);
  (u_xlat8.xy = clamp(u_xlat8.xy, 0.0, 1.0));
  (u_xlat8.xy = ((-u_xlat0.xy) + u_xlat8.xy));
  (u_xlat0.xy = ((vec2(vec2(_MWarpMode, _MWarpMode)) * u_xlat8.xy) + u_xlat0.xy));
  (u_xlat16_0 = texture(_MainTex, u_xlat0.xy, _GlobalMipBias.x));
  (u_xlat16_1 = (u_xlat16_0 * _MainColor));
  (u_xlat16_1 = (u_xlat16_1 * vec4(_MainColorIntensity)));
  (u_xlat16_2.x = ((-_MNBlendMode) + 1.0));
  (u_xlat16_3 = (u_xlat16_2.xxxx * _Main02Color));
  (u_xlat16_2 = (u_xlat16_0 * u_xlat16_2.xxxx));
  (u_xlat16_2 = (u_xlat16_2 * _MainColor));
  (u_xlat16_1 = ((u_xlat16_3 * vec4(vec4(_Main02ColorIntensity, _Main02ColorIntensity, _Main02ColorIntensity, _Main02ColorIntensity))) + u_xlat16_1));
  (u_xlat16_1 = (((-u_xlat16_2) * vec4(_MainColorIntensity)) + u_xlat16_1));
  (u_xlat16_2 = (u_xlat16_2 * vec4(_MainColorIntensity)));
  (u_xlat16_1 = ((vec4(_MNBlendMode) * u_xlat16_1) + u_xlat16_2));
  (u_xlat16_2.x = dot(u_xlat16_1.xyz, vec3(0.22, 0.70700002, 0.071000002)));
  (u_xlat16_2.xyz = ((-u_xlat16_1.xyz) + u_xlat16_2.xxx));
  (u_xlat16_1.xyz = ((vec3(vec3(_Desaturate, _Desaturate, _Desaturate)) * u_xlat16_2.xyz) + u_xlat16_1.xyz));
  (u_xlat16_1.xyz = (u_xlat16_1.xyz * vs_TEXCOORD3.xyz));
  (u_xlat16_2.x = ((u_xlat16_1.w * u_xlat16_0.x) + (-u_xlat16_1.w)));
  (u_xlat16_13 = ((_BlackOff * u_xlat16_2.x) + u_xlat16_1.w));
  (u_xlat16_13 = clamp(u_xlat16_13, 0.0, 1.0));
  (u_xlat0.x = ((-_HeightFadeParam.x) + _HeightFadeParam.y));
  (u_xlat0.x = (1.0 / float(u_xlat0.x)));
  (u_xlat4 = (vs_TEXCOORD5.y + (-_HeightFadeParam.x)));
  (u_xlat0.x = (u_xlat0.x * u_xlat4));
  (u_xlat0.x = clamp(u_xlat0.x, 0.0, 1.0));
  (u_xlat0.x = (u_xlat0.x + -1.0));
  (u_xlat0.x = ((_HeightFade * u_xlat0.x) + 1.0));
  (u_xlat0.x = (u_xlat0.x * u_xlat16_13));
  (u_xlat16_13 = (u_xlat0.x * vs_TEXCOORD3.w));
  (SV_Target0.xyz = (vec3(u_xlat16_13) * u_xlat16_1.xyz));
  (SV_Target0.w = u_xlat16_13);
  return ;
}
