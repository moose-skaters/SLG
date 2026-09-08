#version 450
uniform vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform vec4 hlslcc_mtx4x4unity_MatrixVP[4];
uniform vec4 _Color;
in vec4 in_POSITION0;
in vec4 in_COLOR0;
in vec2 in_TEXCOORD0;
out vec4 vs_COLOR0;
out vec2 vs_TEXCOORD0;
out vec4 vs_TEXCOORD1;
vec4 u_xlat0;
vec4 u_xlat1;
vec3 u_xlat16_2;
vec3 u_xlat16_3;
void main(){
  (u_xlat0 = (in_POSITION0.yyyy * hlslcc_mtx4x4unity_ObjectToWorld[1]));
  (u_xlat0 = ((hlslcc_mtx4x4unity_ObjectToWorld[0] * in_POSITION0.xxxx) + u_xlat0));
  (u_xlat0 = ((hlslcc_mtx4x4unity_ObjectToWorld[2] * in_POSITION0.zzzz) + u_xlat0));
  (u_xlat0 = (u_xlat0 + hlslcc_mtx4x4unity_ObjectToWorld[3]));
  (u_xlat1 = (u_xlat0.yyyy * hlslcc_mtx4x4unity_MatrixVP[1]));
  (u_xlat1 = ((hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat0.xxxx) + u_xlat1));
  (u_xlat1 = ((hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat0.zzzz) + u_xlat1));
  (gl_Position = ((hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat0.wwww) + u_xlat1));
  (u_xlat16_2.xyz = (in_COLOR0.www * in_COLOR0.xyz));
  (u_xlat16_3.xyz = (_Color.www * _Color.xyz));
  (u_xlat0.xyz = (u_xlat16_2.xyz * u_xlat16_3.xyz));
  (u_xlat16_2.x = _Color.w);
  (u_xlat0.w = (u_xlat16_2.x * in_COLOR0.w));
  (vs_COLOR0 = u_xlat0);
  (vs_TEXCOORD0.xy = in_TEXCOORD0.xy);
  (vs_TEXCOORD1 = in_POSITION0);
  return ;
}
