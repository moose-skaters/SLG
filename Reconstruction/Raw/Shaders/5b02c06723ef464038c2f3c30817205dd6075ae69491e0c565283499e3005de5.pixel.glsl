#version 450
uniform vec4 _FogColor;
layout(std140, binding = 0) uniform UnityPerMaterial{
  vec4 _CustomLightDir;
  vec4 _GPUSKin_TextureSize;
  vec4 _ShadowColor;
  float _UseCustomLightDir;
  float _GroundHeight;
  float _ShadowFalloff;
  float _Alpha;
};
in vec4 vs_COLOR0;
in float vs_TEXCOORD0;
layout(location = 0) out vec4 SV_Target0;
vec3 u_xlat0;
vec3 u_xlat1;
void main(){
  (u_xlat0.x = vs_TEXCOORD0);
  (u_xlat0.x = clamp(u_xlat0.x, 0.0, 1.0));
  (u_xlat0.x = (u_xlat0.x * _FogColor.w));
  (u_xlat1.xyz = ((-vs_COLOR0.xyz) + _FogColor.xyz));
  (u_xlat0.xyz = ((u_xlat0.xxx * u_xlat1.xyz) + vs_COLOR0.xyz));
  (SV_Target0.xyz = u_xlat0.xyz);
  (SV_Target0.w = (vs_COLOR0.w * _Alpha));
  return ;
}
