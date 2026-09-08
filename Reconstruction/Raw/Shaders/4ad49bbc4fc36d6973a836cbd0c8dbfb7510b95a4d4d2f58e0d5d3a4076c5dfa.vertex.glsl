#version 450
uniform vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
uniform vec4 hlslcc_mtx4x4unity_MatrixVP[4];
uniform vec4 _MainTex_TexelSize;
uniform float _BlurSize;
in vec4 in_POSITION0;
in vec2 in_TEXCOORD0;
out vec2 vs_TEXCOORD0;
out vec2 vs_TEXCOORD1;
out vec2 vs_TEXCOORD2;
out vec2 vs_TEXCOORD3;
out vec2 vs_TEXCOORD4;
vec4 u_xlat0;
vec4 u_xlat1;
float u_xlat16_2;
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
  (u_xlat16_2 = (_MainTex_TexelSize.y + _MainTex_TexelSize.y));
  (u_xlat0.w = (u_xlat16_2 * _BlurSize));
  (u_xlat0.y = (_MainTex_TexelSize.y * _BlurSize));
  (u_xlat0.x = 0.0);
  (u_xlat0.z = 0.0);
  (u_xlat1 = (u_xlat0 + in_TEXCOORD0.xyxy));
  (u_xlat0 = ((-u_xlat0) + in_TEXCOORD0.xyxy));
  (vs_TEXCOORD2.xy = u_xlat0.xy);
  (vs_TEXCOORD4.xy = u_xlat0.zw);
  (vs_TEXCOORD1.xy = u_xlat1.xy);
  (vs_TEXCOORD3.xy = u_xlat1.zw);
  return ;
}
