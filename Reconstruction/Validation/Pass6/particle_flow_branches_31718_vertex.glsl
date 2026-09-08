#version 450
uniform vec4 _Time;
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
  vec4 _Main_Tex_ST;
  vec4 _Flowmap_Tex_ST;
  vec4 _Mask_Tex_ST;
  vec4 _Fire_Color;
  vec4 _Diss_Tex_ST;
  vec4 _Color;
  vec2 _Flowmap_UV;
  vec2 _Diss_UV;
  float _LightAngle;
  float _Mask_Power;
  float _Fire_Tex_Soft_Value;
  float _Fire_ON;
  float _A_R_ON;
  float _Diss_Tex_Soft_Value;
  float _Alpha;
};
layout(location = 4) uniform sampler2D _Flowmap_Tex;
in vec4 in_POSITION0;
in vec4 in_COLOR0;
in vec4 in_TEXCOORD0;
in vec4 in_TEXCOORD1;
out vec4 vs_COLOR0;
out vec4 vs_TEXCOORD0;
out vec4 vs_TEXCOORD1;
out vec4 vs_TEXCOORD2;
out vec2 vs_TEXCOORD3;
vec4 u_xlat0;
vec4 u_xlat1;
vec2 u_xlat2;
vec3 u_xlat3;
float u_xlat16_4;
vec2 u_xlat16_5;
vec2 u_xlat12;
#define _ParallaxOn 1
#define _ParallaxChannel 0
#define _ParallaxScale 0.05
#define _ParallaxEdgeColor vec4(0.1,0.03,0.02,1.0)
#define _FlipBookBlend_On 1
#define _AlphaPremultiply 1
#define _Saturation 0.5
#define _Contrast 1.2
#define _Alpha_NO_R 0.35
#define _AlphaSub 0.1
#define _Main_tex_Rotator 25
#define _Particle_SpeedUV 0.7
#define _Fire_ON 0.4
#define _Mask_Power 1.4
#define _A_R_ON 0.4
#define _Diss_Tex_Soft_Value 0.25
#define _Fire_Tex_Soft_Value 0.2
#define _LightAngle 0.25
void main(){
  (u_xlat0 = (in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1]));
  (u_xlat0 = ((hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx) + u_xlat0));
  (u_xlat0 = ((hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz) + u_xlat0));
  (u_xlat0 = (u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3]));
  (u_xlat1 = (u_xlat0.yyyy * hlslcc_mtx4x4unity_MatrixVP[1]));
  (u_xlat1 = ((hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat0.xxxx) + u_xlat1));
  (u_xlat1 = ((hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat0.zzzz) + u_xlat1));
  (gl_Position = ((hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat0.wwww) + u_xlat1));
  (vs_COLOR0 = in_COLOR0);
  (vs_TEXCOORD0.xy = in_TEXCOORD0.xy);
  (vs_TEXCOORD0.zw = vec2(0.0, 0.0));
  (vs_TEXCOORD1 = in_TEXCOORD1);
  (u_xlat0.xy = ((in_TEXCOORD0.xy * _Flowmap_Tex_ST.xy) + _Flowmap_Tex_ST.zw));
  (u_xlat0.xy = ((_Time.yy * _Flowmap_UV.xy) + u_xlat0.xy));
  (u_xlat0.xy = textureLod(_Flowmap_Tex, u_xlat0.xy, 1.0).xy);
  (u_xlat12.xy = ((in_TEXCOORD0.xy * _Main_Tex_ST.xy) + _Main_Tex_ST.zw));
  (u_xlat1.xy = ((-u_xlat12.xy) + u_xlat0.xy));
  (vs_TEXCOORD2.zw = u_xlat0.xy);
  (u_xlat0.xy = ((in_TEXCOORD1.yy * u_xlat1.xy) + u_xlat12.xy));
  (u_xlat0.xy = (u_xlat0.xy + vec2(-0.5, -0.5)));
  (u_xlat1.x = sin(abs(in_TEXCOORD1.x)));
  (u_xlat2.x = cos(abs(in_TEXCOORD1.x)));
  (u_xlat3.z = u_xlat1.x);
  (u_xlat3.y = u_xlat2.x);
  (u_xlat3.x = (-u_xlat1.x));
  (u_xlat1.y = dot(u_xlat0.xy, u_xlat3.xy));
  (u_xlat1.x = dot(u_xlat0.xy, u_xlat3.yz));
  (vs_TEXCOORD2.xy = (u_xlat1.xy + vec2(0.5, 0.5)));
  (u_xlat0.xy = ((in_TEXCOORD0.xy * _Mask_Tex_ST.xy) + _Mask_Tex_ST.zw));
  (u_xlat0.xy = (u_xlat0.xy + vec2(-0.5, -0.5)));
  (u_xlat16_4 = sin(_LightAngle));
  (u_xlat16_5.x = cos(_LightAngle));
  (u_xlat1.x = (-u_xlat16_4));
  (u_xlat16_5.y = u_xlat16_4);
  (u_xlat2.x = dot(u_xlat0.xy, u_xlat16_5.xy));
  (u_xlat1.y = u_xlat16_5.x);
  (u_xlat2.y = dot(u_xlat0.xy, u_xlat1.xy));
  (vs_TEXCOORD3.xy = (u_xlat2.xy + vec2(0.5, 0.5)));
  return ;
}
