#version 450
uniform vec4 _ProjectionParams;
uniform vec4 hlslcc_mtx4x4unity_MatrixVP[4];
uniform int unity_BaseInstanceID;
struct unity_Builtins0Array_Type {
  vec4 hlslcc_mtx4x4unity_ObjectToWorldArray[4];
  vec4 hlslcc_mtx4x4unity_WorldToObjectArray[4];
};
layout(std140, binding = 1) uniform UnityInstancing_PerDraw0{
  unity_Builtins0Array_Type unity_Builtins0Array[128];
};
layout(std140, binding = 0) uniform UnityPerMaterial{
  vec4 _FogNoiseMap_ST;
  vec4 _BlendMask_ST;
  vec4 _FogNoiseSpeed;
  vec4 _BlendColor;
  vec4 _FogColor;
  float _FogIntensity;
  float _FogFadeOff;
};
in vec4 in_POSITION0;
in vec2 in_TEXCOORD0;
out vec4 vs_TEXCOORD3;
out vec4 vs_TEXCOORD4;
flat out uint vs_SV_InstanceID0;
vec4 u_xlat0;
int u_xlati0;
vec4 u_xlat1;
void main(){
  (u_xlati0 = (gl_InstanceID + unity_BaseInstanceID));
  (u_xlati0 = int((u_xlati0 << 3)));
  (u_xlat1 = (in_POSITION0.yyyy * unity_Builtins0Array[(u_xlati0 / 8)].hlslcc_mtx4x4unity_ObjectToWorldArray[1]));
  (u_xlat1 = ((unity_Builtins0Array[(u_xlati0 / 8)].hlslcc_mtx4x4unity_ObjectToWorldArray[0] * in_POSITION0.xxxx) + u_xlat1));
  (u_xlat1 = ((unity_Builtins0Array[(u_xlati0 / 8)].hlslcc_mtx4x4unity_ObjectToWorldArray[2] * in_POSITION0.zzzz) + u_xlat1));
  (u_xlat0 = (u_xlat1 + unity_Builtins0Array[(u_xlati0 / 8)].hlslcc_mtx4x4unity_ObjectToWorldArray[3]));
  (u_xlat1 = (u_xlat0.yyyy * hlslcc_mtx4x4unity_MatrixVP[1]));
  (u_xlat1 = ((hlslcc_mtx4x4unity_MatrixVP[0] * u_xlat0.xxxx) + u_xlat1));
  (u_xlat1 = ((hlslcc_mtx4x4unity_MatrixVP[2] * u_xlat0.zzzz) + u_xlat1));
  (u_xlat0 = ((hlslcc_mtx4x4unity_MatrixVP[3] * u_xlat0.wwww) + u_xlat1));
  (gl_Position = (u_xlat1 + hlslcc_mtx4x4unity_MatrixVP[3]));
  (u_xlat0.y = (u_xlat0.y * _ProjectionParams.x));
  (u_xlat1.xzw = (u_xlat0.xwy * vec3(0.5, 0.5, 0.5)));
  (vs_TEXCOORD3.zw = u_xlat0.zw);
  (vs_TEXCOORD3.xy = (u_xlat1.zz + u_xlat1.xw));
  (vs_TEXCOORD4.xy = ((in_TEXCOORD0.xy * _FogNoiseMap_ST.xy) + _FogNoiseMap_ST.zw));
  (vs_TEXCOORD4.zw = ((in_TEXCOORD0.xy * _BlendMask_ST.xy) + _BlendMask_ST.zw));
  (vs_SV_InstanceID0 = uint(gl_InstanceID));
  return ;
}
