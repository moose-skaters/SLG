#version 450
uniform vec4 _MainLightPosition;
uniform vec3 _WorldSpaceCameraPos;
uniform vec4 _LightColor2;
uniform float _LightIntensity2;
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
  vec4 _SepcularGloss_ST;
  vec4 _Dump_ST;
  vec4 _MainTex_ST;
  vec4 _DetailTex_ST;
  vec4 _ReflectionMap_HDR;
  vec4 _SpecColor;
  vec4 _BaseColor;
  vec4 ReflectionDir;
  vec4 _CustomSpecLightDir;
  vec4 _ShadowColor;
  vec4 _CustomLightDir;
  vec4 _AmbientSky;
  vec4 _AmbientEquator;
  vec4 _AmbientGround;
  float _Shininess;
  float _Reflectivity;
  float _Smoothness0;
  float _CutValue;
  float _Leather;
  float _Cloth;
  float _Skin;
  float _ReflectionIntenSity;
  float _DetailIntensity;
  float _CustomSpecLightDir_ON;
  vec4 _Fresnel_Color;
  float _Fresnel_Bisa;
  float _Fresnel_Scale;
  float _Fresnel_Intensity;
  float _Fresnel_ON;
  float _FadeY;
  float _AlphFadeY_ON;
};
layout(location = 0) uniform sampler2D _SepcularGloss;
layout(location = 1) uniform sampler2D _MainTex;
layout(location = 2) uniform sampler2D _DetailTex;
layout(location = 3) uniform samplerCube _ReflectionMap;
in vec4 vs_TEXCOORD0;
in vec2 vs_TEXCOORD3;
in vec3 vs_TEXCOORD4;
layout(location = 0) out vec4 SV_Target0;
vec3 u_xlat0;
vec4 u_xlat16_0;
vec3 u_xlat1;
vec4 u_xlat16_1;
vec3 u_xlat2;
vec3 u_xlat3;
vec3 u_xlat16_4;
vec4 u_xlat16_5;
vec4 u_xlat16_6;
vec2 u_xlat7;
vec4 u_xlat16_7;
vec3 u_xlat16_8;
vec3 u_xlat16_9;
vec3 u_xlat10;
vec3 u_xlat16_14;
bool u_xlatb30;
float u_xlat31;
float u_xlat10_32;
float u_xlat16_34;
float u_xlat16_35;
float u_xlat16_38;
#define _CustomSpecLightDir_ON 0.350000
#define _Fresnel_ON 1.000000
#define _Fresnel_Color vec4(0.120000,0.320000,0.180000,0.700000)
#define _Fresnel_Bisa 0.050000
#define _Fresnel_Scale 0.700000
#define _Fresnel_Intensity 0.650000
#define _ReflectionIntenSity 1.300000
#define _Smoothness0 0.450000
#define _Reflectivity 0.800000
#define _ReflectionMap_HDR vec4(6.000000,1.600000,0.000000,1.000000)
#define _BaseColor vec4(0.700000,0.800000,0.900000,0.650000)
#define _FadeY 3.500000
#define _AlphFadeY_ON 1.000000
void main(){
  (u_xlat0.xy = ((vs_TEXCOORD3.xy * _SepcularGloss_ST.xy) + _SepcularGloss_ST.zw));
  (u_xlat16_0 = texture(_SepcularGloss, u_xlat0.xy));
  (u_xlat1.xyz = ((-vs_TEXCOORD0.xyz) + _WorldSpaceCameraPos.xyz));
  (u_xlat31 = dot(u_xlat1.xyz, u_xlat1.xyz));
  (u_xlat31 = inversesqrt(u_xlat31));
  (u_xlat2.xyz = (vec3(u_xlat31) * u_xlat1.xyz));
  (u_xlat3.xyz = ((-_MainLightPosition.xyz) + _CustomSpecLightDir.xyz));
  (u_xlat3.xyz = ((vec3(vec3(_CustomSpecLightDir_ON, _CustomSpecLightDir_ON, _CustomSpecLightDir_ON)) * u_xlat3.xyz) + _MainLightPosition.xyz));
  (u_xlat1.xyz = ((u_xlat1.xyz * vec3(u_xlat31)) + u_xlat3.xyz));
  (u_xlat31 = dot(u_xlat1.xyz, u_xlat1.xyz));
  (u_xlat31 = inversesqrt(u_xlat31));
  (u_xlat1.xyz = (vec3(u_xlat31) * u_xlat1.xyz));
  (u_xlat31 = dot(vs_TEXCOORD4.xyz, vs_TEXCOORD4.xyz));
  (u_xlat31 = inversesqrt(u_xlat31));
  (u_xlat3.xyz = (vec3(u_xlat31) * vs_TEXCOORD4.xyz));
  (u_xlat16_4.x = dot(u_xlat1.xyz, u_xlat3.xyz));
  (u_xlat1.xy = ((vs_TEXCOORD3.xy * _MainTex_ST.xy) + _MainTex_ST.zw));
  (u_xlat16_1 = texture(_MainTex, u_xlat1.xy));
  (u_xlat16_5 = (_LightColor2 * _BaseColor));
  (u_xlat16_5 = (u_xlat16_5 * vec4(_LightIntensity2)));
  (u_xlat16_6 = (u_xlat16_1 * u_xlat16_5));
  (u_xlat16_4.x = max(u_xlat16_4.x, 0.0));
  (u_xlat16_14.x = (_Shininess * 128.0));
  (u_xlat31 = log2(u_xlat16_4.x));
  (u_xlat31 = (u_xlat31 * u_xlat16_14.x));
  (u_xlat31 = exp2(u_xlat31));
  (u_xlat7.xy = ((vs_TEXCOORD3.xy * _DetailTex_ST.xy) + _DetailTex_ST.zw));
  (u_xlat10_32 = texture(_DetailTex, u_xlat7.xy).x);
  (u_xlat16_4.xyz = (_LightColor2.xyz * _SpecColor.xyz));
  (u_xlat16_4.xyz = (u_xlat16_4.xyz * vec3(_LightIntensity2)));
  (u_xlat16_4.xyz = (vec3(u_xlat31) * u_xlat16_4.xyz));
  (u_xlat7.xy = (u_xlat16_0.zx * vec2(_Reflectivity, _Smoothness0)));
  (u_xlat10.x = (u_xlat16_0.y * u_xlat10_32));
  (u_xlat10.x = (u_xlat10.x * _Leather));
  (u_xlat10.x = ((u_xlat10.x * _DetailIntensity) + u_xlat7.y));
  (u_xlat10.x = ((u_xlat16_0.z * _Cloth) + u_xlat10.x));
  (u_xlat10.x = ((u_xlat16_0.w * _Skin) + u_xlat10.x));
  (u_xlat10.xyz = (u_xlat10.xxx * u_xlat16_4.xyz));
  (u_xlat10.xyz = clamp(u_xlat10.xyz, 0.0, 1.0));
  (u_xlat16_4.xyz = ((u_xlat16_1.xyz * u_xlat16_5.xyz) + u_xlat10.xyz));
  (u_xlat16_8.xyz = ((-_ShadowColor.xyz) + vec3(1.0, 1.0, 1.0)));
  (u_xlat16_8.xyz = ((unity_LightData.zzz * u_xlat16_8.xyz) + _ShadowColor.xyz));
  (u_xlat10.x = dot((-u_xlat2.xyz), u_xlat3.xyz));
  (u_xlat10.x = (u_xlat10.x + u_xlat10.x));
  (u_xlat10.xyz = ((u_xlat3.xyz * (-u_xlat10.xxx)) + (-u_xlat2.xyz)));
  (u_xlat31 = dot(u_xlat3.xyz, u_xlat2.xyz));
  (u_xlat16_34 = ((-u_xlat31) + 1.0));
  (u_xlat16_34 = (u_xlat16_34 * u_xlat16_34));
  (u_xlat16_34 = (u_xlat16_34 * u_xlat16_34));
  (u_xlat16_35 = (((-u_xlat16_0.x) * _Smoothness0) + 1.0));
  (u_xlat16_38 = (u_xlat7.x + u_xlat7.y));
  (u_xlat16_38 = clamp(u_xlat16_38, 0.0, 1.0));
  (u_xlat16_9.x = (((-u_xlat16_35) * 0.69999999) + 1.7));
  (u_xlat16_35 = (u_xlat16_35 * u_xlat16_9.x));
  (u_xlat16_35 = (u_xlat16_35 * 6.0));
  (u_xlat16_9.xyz = (u_xlat10.xyz + ReflectionDir.xyz));
  (u_xlat16_7 = textureLod(_ReflectionMap, u_xlat16_9.xyz, u_xlat16_35));
  (u_xlat10.xyz = (u_xlat16_7.xyz * vec3(vec3(_ReflectionIntenSity, _ReflectionIntenSity, _ReflectionIntenSity))));
  (u_xlat16_35 = ((u_xlat16_7.w * _ReflectionIntenSity) + -1.0));
  (u_xlat16_35 = ((_ReflectionMap_HDR.w * u_xlat16_35) + 1.0));
  (u_xlat16_35 = max(u_xlat16_35, 0.0));
  (u_xlat16_35 = log2(u_xlat16_35));
  (u_xlat16_35 = (u_xlat16_35 * _ReflectionMap_HDR.y));
  (u_xlat16_35 = exp2(u_xlat16_35));
  (u_xlat16_35 = (u_xlat16_35 * _ReflectionMap_HDR.x));
  (u_xlat16_9.xyz = (u_xlat10.xyz * vec3(u_xlat16_35)));
  (u_xlat16_5.xyz = (((-u_xlat16_1.xyz) * u_xlat16_5.xyz) + vec3(u_xlat16_38)));
  (u_xlat16_5.xyz = ((vec3(u_xlat16_34) * u_xlat16_5.xyz) + u_xlat16_6.xyz));
  (u_xlat16_5.xyz = (u_xlat16_5.xyz * u_xlat16_9.xyz));
  (u_xlat0.xyz = (u_xlat16_0.xxx * u_xlat16_5.xyz));
  (u_xlat0.xyz = ((u_xlat16_4.xyz * u_xlat16_8.xyz) + u_xlat0.xyz));
  (u_xlatb30 = (0.5 < _Fresnel_ON));
  if (u_xlatb30)
  {
    (u_xlat16_4.x = dot(u_xlat3.xyz, u_xlat2.xyz));
    (u_xlat16_4.x = clamp(u_xlat16_4.x, 0.0, 1.0));
    (u_xlat16_4.x = ((-u_xlat16_4.x) + 1.0));
    (u_xlat16_14.x = (u_xlat16_4.x * u_xlat16_4.x));
    (u_xlat16_14.x = (u_xlat16_14.x * u_xlat16_14.x));
    (u_xlat16_4.x = (u_xlat16_4.x * u_xlat16_14.x));
    (u_xlat16_4.x = ((_Fresnel_Scale * u_xlat16_4.x) + _Fresnel_Bisa));
    (u_xlat16_4.x = (u_xlat16_4.x * _Fresnel_Intensity));
    (u_xlat16_14.xyz = ((-u_xlat0.xyz) + _Fresnel_Color.xyz));
    (u_xlat16_6.xyz = ((u_xlat16_4.xxx * u_xlat16_14.xyz) + u_xlat0.xyz));
  }
  else
  {
    (u_xlat16_6.xyz = u_xlat0.xyz);
  }
  (SV_Target0 = u_xlat16_6);
  return ;
}
