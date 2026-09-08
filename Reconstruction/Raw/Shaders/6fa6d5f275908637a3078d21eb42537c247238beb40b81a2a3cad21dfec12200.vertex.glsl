#version 450
uniform vec4 hlslcc_mtx4x4unity_MatrixVP[4];
uniform int unity_BaseInstanceID;
struct unity_Builtins0Array_Type {
  vec4 hlslcc_mtx4x4unity_ObjectToWorldArray[4];
  vec4 hlslcc_mtx4x4unity_WorldToObjectArray[4];
};
layout(std140, binding = 2) uniform UnityInstancing_PerDraw0{
  unity_Builtins0Array_Type unity_Builtins0Array[128];
};
layout(std140, binding = 0) uniform UnityPerMaterial{
  vec4 _Bounds;
  vec4 _CircleCenter;
  vec4 _RendererColor;
  vec4 _Color;
  vec2 _Flip;
  float _Angle;
  float _Radius;
  float _Feather;
};
in vec4 in_POSITION0;
in vec4 in_COLOR0;
in vec2 in_TEXCOORD0;
out vec4 vs_COLOR0;
out vec2 vs_TEXCOORD0;
out vec3 vs_TEXCOORD1;
flat out uint vs_SV_InstanceID0;
vec4 u_xlat0;
int u_xlati0;
vec4 u_xlat1;
vec2 u_xlat2;
void main(){
  (u_xlati0 = (gl_InstanceID + unity_BaseInstanceID));
  (u_xlati0 = int((u_xlati0 << 3)));
  (u_xlat2.xy = (in_POSITION0.xy * _Flip.xy));
  (u_xlat1 = (u_xlat2.yyyy * unity_Builtins0Array[(u_xlati0 / 8)].hlslcc_mtx4x4unity_ObjectToWorldArray[1]));
  (u_xlat1 = ((unity_Builtins0Array[(u_xlati0 / 8)].hlslcc_mtx4x4unity_ObjectToWorldArray[0] * u_xlat2.xxxx) + u_xlat1));
  (vs_TEXCOORD1.xy = u_xlat2.xy);
  (u_xlat1 = ((unity_Builtins0Array[(u_xlati0 / 8)].hlslcc_mtx4x4unity_ObjectToWorldArray[2] * in_POSITION0.zzzz) + u_xlat1));
  (u_xlat0 = (u_xlat1 + unity_Builtins0Array[(u_xlati0 / 8)].hlslcc_mtx4x4unity_ObjectToWorldArray[3]));
  (u_xlat1 = (u_xlat0.yyyy * hlslcc_mtx4x4unity_MatrixVP[1]));
  (u_xlat1 = ((hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat0.xxxx) + u_xlat1));
  (u_xlat1 = ((hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat0.zzzz) + u_xlat1));
  (gl_Position = ((hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat0.wwww) + u_xlat1));
  (u_xlat0 = (in_COLOR0 * _Color));
  (u_xlat0 = (u_xlat0 * _RendererColor));
  (vs_COLOR0 = u_xlat0);
  (vs_TEXCOORD0.xy = in_TEXCOORD0.xy);
  (vs_TEXCOORD1.z = in_POSITION0.z);
  (vs_SV_InstanceID0 = uint(gl_InstanceID));
  return ;
}
