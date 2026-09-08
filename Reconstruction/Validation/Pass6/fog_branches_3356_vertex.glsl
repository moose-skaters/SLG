#version 450
uniform vec4 _ProjectionParams;
uniform vec4 hlslcc_mtx4x4unity_MatrixVP[4];
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
  vec4 _EdgeNoiseFlowDir;
  vec4 _ShadeOffset;
  vec4 _EdgeClamp;
  vec4 _MainTex_ST;
  vec4 _BlendNoise_ST;
  vec4 _EdgeNoise_ST;
  vec4 _EdgeNoise2_ST;
  vec4 _FogShadowOffset;
  vec4 _FogSpeed;
  vec4 _FogNightShadowColor;
  vec4 _Color;
  vec4 _TopColor;
  vec4 _NightEdgeColor;
  vec4 _NightTopColor;
  vec4 _NightColor;
  vec4 _EdgeColor;
  vec4 _EdgeSpeed;
  vec4 _DepthColor;
  vec4 _NightDepthColor;
  vec4 _VertexOffset;
  vec4 _FogShadowColor;
  float _OffsetY;
  float _OffsetX;
  float _FogFallOff;
  float _UvScale;
  float _FogEdgeMin;
  float _AlphaDisMin;
  float _AlphaDisMax;
  float _FogPower;
  float _Level2;
  float _Level3;
  float _Level4;
  float _FogStart;
  float _FogEnd;
  float _EdgeContrast;
  float _DepthColorOn;
  float _HeightStart;
  float _HeightEnd;
  float _EdgeSmootMin;
  float _EdgeSmootMax;
  float _EdgeNoise2Blend;
  float _FogPowerShadow;
};
in vec4 in_POSITION0;
in vec2 in_TEXCOORD0;
out vec3 vs_TEXCOORD0;
out vec4 vs_TEXCOORD1;
out vec2 vs_TEXCOORD4;
vec4 u_xlat0;
vec4 u_xlat1;
#define _Timeline 0.35
#define _Level2 0.4
#define _Level3 0.6
#define _Level4 0.3
#define _AlphaDisMin 0.1
#define _AlphaDisMax 0.7
#define _FogShadowOffset vec4(0.01,-0.03,0.005,0.0)
#define _VertexOffset vec4(18.0,0.0,-0.5,0.0)
#define _FogFallOff 32
#define _FogPowerShadow 1.5
#define _FogSpeed vec4(0.015,-0.012,0.008,0.02)
#define _Color vec4(0.18,0.1,0.2,0.65)
#define _NightColor vec4(0.04,0.08,0.15,0.9)
#define _MainTex_ST vec4(3.0,4.0,0.1,0.05)
#define _BlendNoise_ST vec4(6.0,5.0,0.2,0.1)
#define _Time vec4(8.0,160.0,320.0,480.0)
void main(){
  (u_xlat0.xyz = (in_POSITION0.xyz + (-_FogShadowOffset.xyz)));
  (u_xlat1.xyz = (u_xlat0.yyy * hlslcc_mtx4x4unity_ObjectToWorld[1].xyz));
  (u_xlat0.xyw = ((hlslcc_mtx4x4unity_ObjectToWorld[0].xyz * u_xlat0.xxx) + u_xlat1.xyz));
  (u_xlat0.xyz = ((hlslcc_mtx4x4unity_ObjectToWorld[2].xyz * u_xlat0.zzz) + u_xlat0.xyw));
  (u_xlat0.xyz = (u_xlat0.xyz + hlslcc_mtx4x4unity_ObjectToWorld[3].xyz));
  (u_xlat1 = (u_xlat0.yyyy * hlslcc_mtx4x4unity_MatrixVP[1]));
  (u_xlat1 = ((hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat0.xxxx) + u_xlat1));
  (u_xlat1 = ((hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat0.zzzz) + u_xlat1));
  (vs_TEXCOORD0.xyz = u_xlat0.xyz);
  (u_xlat0 = (u_xlat1 + hlslcc_mtx4x4unity_MatrixVP[3]));
  (gl_Position = u_xlat0);
  (u_xlat0.y = (u_xlat0.y * _ProjectionParams.x));
  (u_xlat1.xzw = (u_xlat0.xwy * vec3(0.5, 0.5, 0.5)));
  (vs_TEXCOORD1.zw = u_xlat0.zw);
  (vs_TEXCOORD1.xy = (u_xlat1.zz + u_xlat1.xw));
  (vs_TEXCOORD4.xy = in_TEXCOORD0.xy);
  return ;
}
