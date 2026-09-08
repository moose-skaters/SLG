#version 450
uniform vec4 hlslcc_mtx4x4unity_MatrixVP[4];
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
in vec4 in_POSITION0;
in vec2 in_TEXCOORD0;
out vec2 vs_TEXCOORD0;
vec4 u_xlat0;
vec4 u_xlat1;
void main(){
  (u_xlat0 = (in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1]));
  (u_xlat0 = ((hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx) + u_xlat0));
  (u_xlat0 = ((hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz) + u_xlat0));
  (u_xlat0 = (u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3]));
  (u_xlat1 = (u_xlat0.yyyy * hlslcc_mtx4x4unity_MatrixVP[1]));
  (u_xlat1 = ((hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat0.xxxx) + u_xlat1));
  (u_xlat1 = ((hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat0.zzzz) + u_xlat1));
  (gl_Position = ((hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat0.wwww) + u_xlat1));
  (vs_TEXCOORD0.xy = in_TEXCOORD0.xy);
  return ;
}
