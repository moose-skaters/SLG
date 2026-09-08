#version 450
uniform vec4 _Time;
uniform vec4 _ProjectionParams;
uniform vec4 hlslcc_mtx4x4unity_MatrixVP[4];
uniform float _FlyOffset;
layout(std140, binding = 1) uniform UnityPerDraw{
  vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
  vec4 hlslcc_mtx4x4unity_WorldToObject[4];
  vec4 unity_LODFade;
  vec4 unity_WorldTransformParams;
  vec4 unity_RenderingLayer;
  vec4 unity_LightData;
  vec4 unity_LightIndices[2];
  vec4 unity_ProbesOcclusion;
  vec4 unity_SpecCube0_HDR;
  vec4 unity_SpecCube1_HDR;
  vec4 unity_SpecCube0_BoxMax;
  vec4 unity_SpecCube0_BoxMin;
  vec4 unity_SpecCube0_ProbePosition;
  vec4 unity_SpecCube1_BoxMax;
  vec4 unity_SpecCube1_BoxMin;
  vec4 unity_SpecCube1_ProbePosition;
  vec4 unity_LightmapST;
  vec4 unity_DynamicLightmapST;
  vec4 unity_SHAr;
  vec4 unity_SHAg;
  vec4 unity_SHAb;
  vec4 unity_SHBr;
  vec4 unity_SHBg;
  vec4 unity_SHBb;
  vec4 unity_SHC;
  vec4 hlslcc_mtx4x4unity_MatrixPreviousM[4];
  vec4 hlslcc_mtx4x4unity_MatrixPreviousMI[4];
  vec4 unity_MotionVectorsParams;
};
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
in vec4 in_POSITION0;
in vec2 in_TEXCOORD0;
in vec2 in_TEXCOORD1;
in vec4 in_COLOR0;
in vec4 in_TEXCOORD2;
out vec4 vs_TEXCOORD0;
out vec4 vs_TEXCOORD1;
out vec4 vs_TEXCOORD2;
out vec4 vs_TEXCOORD3;
out vec3 vs_TEXCOORD4;
out vec3 vs_TEXCOORD5;
out vec4 vs_TEXCOORD6;
out vec3 vs_TEXCOORD8;
vec4 u_xlat0;
vec4 u_xlat1;
vec2 u_xlat16_2;
vec2 u_xlat6;
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
  (u_xlat0 = (in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1]));
  (u_xlat0 = ((hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx) + u_xlat0));
  (u_xlat0 = ((hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz) + u_xlat0));
  (u_xlat0 = (u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3]));
  (u_xlat1 = (u_xlat0.yyyy * hlslcc_mtx4x4unity_MatrixVP[1]));
  (u_xlat1 = ((hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat0.xxxx) + u_xlat1));
  (u_xlat1 = ((hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat0.zzzz) + u_xlat1));
  (u_xlat0 = ((hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat0.wwww) + u_xlat1));
  (gl_Position.z = (u_xlat0.z + (-_FlyOffset)));
  (gl_Position.xyw = u_xlat0.xyw);
  (u_xlat0.y = (u_xlat0.y * _ProjectionParams.x));
  (u_xlat1.xzw = (u_xlat0.xwy * vec3(0.5, 0.5, 0.5)));
  (u_xlat0.xy = (u_xlat1.zz + u_xlat1.xw));
  (u_xlat0.xy = (u_xlat0.xy / u_xlat0.ww));
  (u_xlat0.xy = ((u_xlat0.xy * _MainTex_ST.xy) + _MainTex_ST.zw));
  (u_xlat0.xy = (u_xlat0.xy + vec2(-0.5, -0.5)));
  (u_xlat6.xy = (_Time.yy * _mainUVMove.xy));
  (u_xlat6.xy = fract(u_xlat6.xy));
  (u_xlat0.xy = ((u_xlat0.xy * _mainUVMove.zz) + u_xlat6.xy));
  (u_xlat0.xy = ((vec2(vec2(_particleUV, _particleUV)) * in_TEXCOORD2.xy) + u_xlat0.xy));
  (u_xlat0.xy = (u_xlat0.xy + vec2(0.5, 0.5)));
  (u_xlat1.xy = in_TEXCOORD1.xy);
  (u_xlat1.xy = clamp(u_xlat1.xy, 0.0, 1.0));
  (u_xlat1.xy = (u_xlat1.xy + (-in_TEXCOORD0.xy)));
  (u_xlat1.xy = ((vec2(vec2(_UVChannel, _UVChannel)) * u_xlat1.xy) + in_TEXCOORD0.xy));
  (u_xlat1.xy = ((u_xlat1.xy * _MainTex_ST.xy) + _MainTex_ST.zw));
  (u_xlat1.xy = (u_xlat1.xy + vec2(-0.5, -0.5)));
  (u_xlat1.xy = ((u_xlat1.xy * _mainUVMove.zz) + vec2(0.5, 0.5)));
  (u_xlat6.xy = (u_xlat6.xy + u_xlat1.xy));
  (u_xlat6.xy = ((vec2(vec2(_particleUV, _particleUV)) * in_TEXCOORD2.xy) + u_xlat6.xy));
  (u_xlat0.xy = ((-u_xlat6.xy) + u_xlat0.xy));
  (vs_TEXCOORD0.xy = ((vec2(vec2(_ScreenSpaceUV_ON, _ScreenSpaceUV_ON)) * u_xlat0.xy) + u_xlat6.xy));
  (vs_TEXCOORD0.zw = vec2(0.0, 0.0));
  (u_xlat16_2.xy = ((in_TEXCOORD0.xy * _NoiseTex_ST.xy) + _NoiseTex_ST.zw));
  (u_xlat16_2.xy = (u_xlat16_2.xy + vec2(-0.5, -0.5)));
  (u_xlat16_2.xy = ((u_xlat16_2.xy * _noiseUVMove.zz) + vec2(0.5, 0.5)));
  (u_xlat0.xy = (_Time.yy * _noiseUVMove.xy));
  (u_xlat0.xy = fract(u_xlat0.xy));
  (vs_TEXCOORD1.xy = (u_xlat0.xy + u_xlat16_2.xy));
  (vs_TEXCOORD1.zw = vec2(0.0, 0.0));
  (vs_TEXCOORD2 = vec4(0.0, 0.0, 0.0, 0.0));
  (vs_TEXCOORD3 = in_COLOR0);
  (vs_TEXCOORD4.xyz = vec3(0.0, 0.0, 0.0));
  (vs_TEXCOORD5.xyz = vec3(0.0, 0.0, 0.0));
  (vs_TEXCOORD6 = in_TEXCOORD2);
  (vs_TEXCOORD8.xyz = vec3(0.0, 0.0, 0.0));
  return ;
}
