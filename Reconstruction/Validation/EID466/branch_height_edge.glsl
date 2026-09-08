#version 450
vec4 ImmCB_0[4];
uniform vec4 _MainLightPosition;
uniform vec4 _MainLightColor;
uniform vec3 _WorldSpaceCameraPos;
uniform vec2 _GlobalMipBias;
uniform int _BlurPlaneShadowOn;
layout(std140, binding = 0) uniform UnityPerDraw{
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
layout(std140, binding = 1) uniform UnityPerMaterial{
  float _AlphaScale;
  vec4 _SparkMap_ST;
  vec4 _WorldEdge;
  vec4 _Control_ST;
  vec4 _BaseNormal_ST;
  vec4 _NormalMask_ST;
  vec4 _Control_TexelSize;
  vec4 _SparkColor;
  vec4 _Color_Golobal;
  vec4 _Splat0_ST;
  vec4 _Splat1_ST;
  vec4 _Splat2_ST;
  vec4 _Splat3_ST;
  vec4 _Splat_Golobal_ST;
  vec4 _Color_Splat1;
  vec4 _Color_Splat2;
  vec4 _Color_Splat3;
  vec4 _Color_Splat4;
  vec4 _specColor;
  float _MinHeight;
  float _MaxHeight;
  float _HeightBlendScale;
  float _Weight;
  float _NormalMinHeight;
  float _NormalMaxHeight;
  float _BaseNormalScale;
  float _Color_Splat1_Intensity;
  float _Color_Splat2_Intensity;
  float _Color_Splat3_Intensity;
  float _Color_Splat4_Intensity;
  float _SparkColorIntensity;
  float _specScale;
  float _WorldUVON;
  int _HeightBlendOn;
  float _LightColorDesat;
  vec4 _BlurPlaneShadowColor;
  int _FakeNormalOn;
  vec4 _FakeNormalDir;
  float _FakeNormalChannel;
  float _FakeNormalScale;
  vec3 _EdgeColor01;
};
layout(location = 0) uniform sampler2D _PlaneBlurShadowMap;
layout(location = 1) uniform sampler2D _Control;
layout(location = 2) uniform sampler2D _BaseNormal;
layout(location = 3) uniform sampler2D _NormalMask;
layout(location = 4) uniform sampler2D _Splat0;
layout(location = 5) uniform sampler2D _Splat1;
layout(location = 6) uniform sampler2D _Splat2;
layout(location = 7) uniform sampler2D _Splat3;
layout(location = 8) uniform sampler2D _Splat_Golobal;
layout(location = 9) uniform sampler2D _SparkMap;
layout(location = 10) uniform sampler2D _SpecMaskMap;
in vec4 vs_TEXCOORD0;
in vec4 vs_TEXCOORD1;
in vec4 vs_TEXCOORD2;
in vec4 vs_TEXCOORD3;
in vec3 vs_TEXCOORD8;
in vec4 vs_TEXCOORD6;
in vec4 vs_TEXCOORD7;
layout(location = 0) out vec4 SV_TARGET0;
vec2 u_xlat0;
vec4 u_xlat16_0;
vec4 u_xlat1;
vec4 u_xlat16_1;
vec3 u_xlat2;
vec4 u_xlat16_2;
uint u_xlatu2;
vec3 u_xlat3;
vec4 u_xlat16_3;
vec4 u_xlat16_4;
vec4 u_xlat16_5;
vec4 u_xlat16_6;
vec4 u_xlat7;
vec4 u_xlat16_7;
vec4 u_xlat16_8;
vec3 u_xlat16_9;
float u_xlat12;
vec3 u_xlat16_16;
vec3 u_xlat16_18;
vec2 u_xlat22;
vec2 u_xlat23;
float u_xlat16_23;
float u_xlat32;
float u_xlat16_32;
float u_xlat33;
float u_xlat16_36;

#define _HeightBlendOn 1
#define _FakeNormalOn 1
#define _FakeNormalDir vec4(0.01,0.005,0.0,0.0)
#define _EdgeColor01 vec3(0.08,0.03,0.01)

void main(){
  (ImmCB_0[0] = vec4(1.0, 0.0, 0.0, 0.0));
  (ImmCB_0[1] = vec4(0.0, 1.0, 0.0, 0.0));
  (ImmCB_0[2] = vec4(0.0, 0.0, 1.0, 0.0));
  (ImmCB_0[3] = vec4(0.0, 0.0, 0.0, 1.0));
  (u_xlat0.xy = (vs_TEXCOORD0.zw * _Control_ST.xy));
  (u_xlat16_0 = texture(_Control, u_xlat0.xy, _GlobalMipBias.x));
  if ((_FakeNormalOn != 0))
  {
    (u_xlat1.xy = ((vs_TEXCOORD0.zw * _Control_ST.xy) + _FakeNormalDir.xy));
    (u_xlat16_1 = texture(_Control, u_xlat1.xy, _GlobalMipBias.x));
    (u_xlat16_1 = u_xlat16_1);
  }
  else
  {
    (u_xlat16_1 = u_xlat16_0);
  }
  (u_xlat2.xy = ((vs_TEXCOORD0.zw * _Splat0_ST.xy) + _Splat0_ST.zw));
  (u_xlat22.xy = ((vs_TEXCOORD0.zw * _Splat1_ST.xy) + _Splat1_ST.zw));
  (u_xlat3.xy = ((vs_TEXCOORD0.zw * _Splat2_ST.xy) + _Splat2_ST.zw));
  (u_xlat23.xy = ((vs_TEXCOORD0.zw * _Splat3_ST.xy) + _Splat3_ST.zw));
  (u_xlat16_4 = texture(_Splat0, u_xlat2.xy, _GlobalMipBias.x));
  (u_xlat16_2 = texture(_Splat1, u_xlat22.xy, _GlobalMipBias.x));
  (u_xlat16_5 = texture(_Splat2, u_xlat3.xy, _GlobalMipBias.x));
  (u_xlat16_3 = texture(_Splat3, u_xlat23.xy, _GlobalMipBias.x));
  if ((_HeightBlendOn != 0))
  {
    (u_xlat16_6.x = (u_xlat16_0.x * u_xlat16_4.w));
    (u_xlat16_6.y = (u_xlat16_0.y * u_xlat16_2.w));
    (u_xlat16_6.z = (u_xlat16_0.z * u_xlat16_5.w));
    (u_xlat16_6.w = (u_xlat16_0.w * u_xlat16_3.w));
    (u_xlat16_7.x = max(u_xlat16_6.w, u_xlat16_6.z));
    (u_xlat16_7.x = max(u_xlat16_6.y, u_xlat16_7.x));
    (u_xlat16_7.x = max(u_xlat16_6.x, u_xlat16_7.x));
    (u_xlat16_6 = (u_xlat16_6 + (-u_xlat16_7.xxxx)));
    (u_xlat16_6 = (u_xlat16_6 + vec4(vec4(_Weight, _Weight, _Weight, _Weight))));
    (u_xlat16_6 = max(u_xlat16_6, vec4(0.0, 0.0, 0.0, 0.0)));
    (u_xlat16_7 = (u_xlat16_0 * u_xlat16_6));
    (u_xlat16_6.x = (u_xlat16_7.y + u_xlat16_7.x));
    (u_xlat16_6.x = ((u_xlat16_6.z * u_xlat16_0.z) + u_xlat16_6.x));
    (u_xlat16_6.x = ((u_xlat16_6.w * u_xlat16_0.w) + u_xlat16_6.x));
    (u_xlat16_6.x = (u_xlat16_6.x + 6.1035156e-05));
    (u_xlat16_6.x = (1.0 / float(u_xlat16_6.x)));
    (u_xlat16_6 = (u_xlat16_6.xxxx * u_xlat16_7));
    (u_xlat16_7.x = (u_xlat16_1.x * u_xlat16_4.w));
    (u_xlat16_7.y = (u_xlat16_1.y * u_xlat16_2.w));
    (u_xlat16_7.z = (u_xlat16_1.z * u_xlat16_5.w));
    (u_xlat16_7.w = (u_xlat16_1.w * u_xlat16_3.w));
    (u_xlat16_8.x = max(u_xlat16_7.w, u_xlat16_7.z));
    (u_xlat16_8.x = max(u_xlat16_7.y, u_xlat16_8.x));
    (u_xlat16_8.x = max(u_xlat16_7.x, u_xlat16_8.x));
    (u_xlat16_7 = (u_xlat16_7 + (-u_xlat16_8.xxxx)));
    (u_xlat16_7 = (u_xlat16_7 + vec4(vec4(_Weight, _Weight, _Weight, _Weight))));
    (u_xlat16_7 = max(u_xlat16_7, vec4(0.0, 0.0, 0.0, 0.0)));
    (u_xlat16_8 = (u_xlat16_1 * u_xlat16_7));
    (u_xlat16_7.x = (u_xlat16_8.y + u_xlat16_8.x));
    (u_xlat16_7.x = ((u_xlat16_7.z * u_xlat16_1.z) + u_xlat16_7.x));
    (u_xlat16_7.x = ((u_xlat16_7.w * u_xlat16_1.w) + u_xlat16_7.x));
    (u_xlat16_7.x = (u_xlat16_7.x + 6.1035156e-05));
    (u_xlat16_7.x = (1.0 / float(u_xlat16_7.x)));
    (u_xlat16_7 = (u_xlat16_7.xxxx * u_xlat16_8));
    (u_xlat7 = u_xlat16_7);
  }
  else
  {
    (u_xlat16_6 = u_xlat16_0);
    (u_xlat7 = u_xlat16_1);
  }
  (u_xlat0.x = dot(u_xlat16_6, vec4(1.0, 1.0, 1.0, 1.0)));
  (u_xlat16_8.x = (u_xlat0.x + 6.1035156e-05));
  (u_xlat16_8.x = (1.0 / float(u_xlat16_8.x)));
  (u_xlat16_0 = (u_xlat16_6 * u_xlat16_8.xxxx));
  (u_xlat16_18.xyz = (u_xlat16_0.xxx * u_xlat16_4.xyz));
  (u_xlat16_18.xyz = (u_xlat16_18.xyz * vec3(vec3(_Color_Splat1_Intensity, _Color_Splat1_Intensity, _Color_Splat1_Intensity))));
  (u_xlat16_9.xyz = (u_xlat16_0.yyy * u_xlat16_2.xyz));
  (u_xlat16_9.xyz = (u_xlat16_9.xyz * vec3(_Color_Splat2_Intensity)));
  (u_xlat16_9.xyz = (u_xlat16_9.xyz * _Color_Splat2.xyz));
  (u_xlat16_18.xyz = ((u_xlat16_18.xyz * _Color_Splat1.xyz) + u_xlat16_9.xyz));
  (u_xlat16_9.xyz = (u_xlat16_0.zzz * u_xlat16_5.xyz));
  (u_xlat16_9.xyz = (u_xlat16_9.xyz * vec3(vec3(_Color_Splat3_Intensity, _Color_Splat3_Intensity, _Color_Splat3_Intensity))));
  (u_xlat16_18.xyz = ((u_xlat16_9.xyz * _Color_Splat3.xyz) + u_xlat16_18.xyz));
  (u_xlat16_9.xyz = (u_xlat16_0.www * u_xlat16_3.xyz));
  (u_xlat16_9.xyz = (u_xlat16_9.xyz * vec3(vec3(_Color_Splat4_Intensity, _Color_Splat4_Intensity, _Color_Splat4_Intensity))));
  (u_xlat16_18.xyz = ((u_xlat16_9.xyz * _Color_Splat4.xyz) + u_xlat16_18.xyz));
  if ((_FakeNormalOn != 0))
  {
    (u_xlatu2 = uint(_FakeNormalChannel));
    (u_xlat1 = (((-u_xlat16_6) * u_xlat16_8.xxxx) + u_xlat7));
    (u_xlat2.x = dot(u_xlat1, ImmCB_0[int(u_xlatu2)]));
    (u_xlat16_18.xyz = ((_EdgeColor01.xyz * u_xlat2.xxx) + u_xlat16_18.xyz));
  }
  (u_xlat2.x = ((-_NormalMinHeight) + _NormalMaxHeight));
  (u_xlat12 = (_WorldSpaceCameraPos.y + (-_NormalMinHeight)));
  (u_xlat2.x = (1.0 / u_xlat2.x));
  (u_xlat2.x = (u_xlat2.x * u_xlat12));
  (u_xlat2.x = clamp(u_xlat2.x, 0.0, 1.0));
  (u_xlat12 = ((u_xlat2.x * -2.0) + 3.0));
  (u_xlat2.x = (u_xlat2.x * u_xlat2.x));
  (u_xlat2.x = (u_xlat2.x * u_xlat12));
  (u_xlat16_6.x = ((u_xlat2.x * (-_BaseNormalScale)) + _BaseNormalScale));
  (u_xlat2.xy = (vs_TEXCOORD0.zw * _BaseNormal_ST.xy));
  (u_xlat16_2.xyz = texture(_BaseNormal, u_xlat2.xy, _GlobalMipBias.x).xyz);
  (u_xlat16_16.xyz = ((u_xlat16_2.xyz * vec3(2.0, 2.0, 2.0)) + vec3(-1.0, -1.0, -1.0)));
  (u_xlat16_16.xy = (u_xlat16_6.xx * u_xlat16_16.xy));
  (u_xlat16_9.x = (-vs_TEXCOORD2.x));
  (u_xlat16_9.y = vs_TEXCOORD3.x);
  (u_xlat16_9.z = vs_TEXCOORD1.x);
  (u_xlat2.x = dot(u_xlat16_16.xyz, u_xlat16_9.xyz));
  (u_xlat16_9.x = (-vs_TEXCOORD2.y));
  (u_xlat16_9.y = vs_TEXCOORD3.y);
  (u_xlat16_9.z = vs_TEXCOORD1.y);
  (u_xlat2.y = dot(u_xlat16_16.xyz, u_xlat16_9.xyz));
  (u_xlat16_9.x = (-vs_TEXCOORD2.z));
  (u_xlat16_9.y = vs_TEXCOORD3.z);
  (u_xlat16_9.z = vs_TEXCOORD1.z);
  (u_xlat2.z = dot(u_xlat16_16.xyz, u_xlat16_9.xyz));
  (u_xlat3.xy = (vs_TEXCOORD0.zw * _NormalMask_ST.xy));
  (u_xlat16_32 = texture(_NormalMask, u_xlat3.xy, _GlobalMipBias.x).x);
  (u_xlat2.xyz = (u_xlat2.xyz + vec3(-1.0, -1.0, -1.0)));
  (u_xlat2.xyz = ((vec3(u_xlat16_32) * u_xlat2.xyz) + vec3(1.0, 1.0, 1.0)));
  (u_xlat32 = dot(_MainLightColor.xyz, vec3(0.21259999, 0.71520001, 0.0722)));
  (u_xlat3.xyz = ((-vec3(u_xlat32)) + _MainLightColor.xyz));
  (u_xlat3.xyz = ((vec3(_LightColorDesat) * u_xlat3.xyz) + vec3(u_xlat32)));
  (u_xlat2.x = dot(u_xlat2.xyz, _MainLightPosition.xyz));
  (u_xlat2.x = clamp(u_xlat2.x, 0.0, 1.0));
  (u_xlat2.xyz = (u_xlat16_18.xyz * u_xlat2.xxx));
  (u_xlat2.xyz = (u_xlat3.xyz * u_xlat2.xyz));
  (u_xlat16_6.xyz = (u_xlat16_18.xyz * vs_TEXCOORD8.xyz));
  (u_xlat2.xyz = ((u_xlat2.xyz * unity_LightData.zzz) + u_xlat16_6.xyz));
  (u_xlat32 = (_WorldSpaceCameraPos.y + (-_MinHeight)));
  (u_xlat33 = ((-_MinHeight) + _MaxHeight));
  (u_xlat33 = (1.0 / float(u_xlat33)));
  (u_xlat32 = (u_xlat32 * u_xlat33));
  (u_xlat32 = clamp(u_xlat32, 0.0, 1.0));
  (u_xlat16_4.xyz = texture(_Splat_Golobal, vs_TEXCOORD6.xy, _GlobalMipBias.x).xyz);
  (u_xlat16_6.xyz = (u_xlat3.xyz * u_xlat16_4.xyz));
  (u_xlat3.xy = (vs_TEXCOORD7.xy / vs_TEXCOORD7.ww));
  (u_xlat16_23 = texture(_SparkMap, vs_TEXCOORD6.zw, _GlobalMipBias.x).w);
  (u_xlat16_4.xy = texture(_SpecMaskMap, u_xlat3.xy, _GlobalMipBias.x).xy);
  (u_xlat16_8.xyz = (vec3(u_xlat16_23) * _SparkColor.xyz));
  (u_xlat16_8.xyz = (u_xlat16_8.xyz * vec3(vec3(_SparkColorIntensity, _SparkColorIntensity, _SparkColorIntensity))));
  (u_xlat16_8.xyz = (u_xlat16_4.xxx * u_xlat16_8.xyz));
  (u_xlat16_9.xyz = (u_xlat16_0.zzz * u_xlat16_8.xyz));
  (u_xlat16_8.xyz = ((u_xlat16_8.xyz * u_xlat16_0.yyy) + u_xlat16_9.xyz));
  (u_xlat16_8.xyz = (u_xlat2.xyz + u_xlat16_8.xyz));
  (u_xlat16_9.xyz = (u_xlat16_4.yyy * _specColor.xyz));
  (u_xlat16_8.xyz = ((u_xlat16_9.xyz * vec3(_specScale)) + u_xlat16_8.xyz));
  (u_xlat16_6.xyz = ((u_xlat16_6.xyz * _Color_Golobal.xyz) + (-u_xlat16_8.xyz)));
  (u_xlat16_6.xyz = ((vec3(u_xlat32) * u_xlat16_6.xyz) + u_xlat16_8.xyz));
  if ((_BlurPlaneShadowOn != 0))
  {
    (u_xlat16_2.x = texture(_PlaneBlurShadowMap, u_xlat3.xy).x);
    (u_xlat16_36 = ((-_BlurPlaneShadowColor.w) + 1.0));
    (u_xlat16_8.xyz = (vec3(u_xlat16_36) * u_xlat16_6.xyz));
    (u_xlat16_8.xyz = ((_BlurPlaneShadowColor.xyz * _BlurPlaneShadowColor.www) + u_xlat16_8.xyz));
    (u_xlat16_9.xyz = (u_xlat16_6.xyz + (-u_xlat16_8.xyz)));
    (u_xlat16_6.xyz = ((u_xlat16_2.xxx * u_xlat16_9.xyz) + u_xlat16_8.xyz));
  }
  (SV_TARGET0.xyz = u_xlat16_6.xyz);
  (SV_TARGET0.w = _AlphaScale);
  return ;
}
