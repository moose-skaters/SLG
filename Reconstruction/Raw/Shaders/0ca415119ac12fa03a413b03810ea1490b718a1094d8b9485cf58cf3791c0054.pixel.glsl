#version 450
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
layout(location = 0) out vec4 SV_Target0;
void main(){
  (SV_Target0.w = (vs_COLOR0.w * _Alpha));
  (SV_Target0.xyz = vs_COLOR0.xyz);
  return ;
}
