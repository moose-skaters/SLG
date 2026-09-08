#version 450
uniform vec4 _LightColor1;
uniform float _LightIntensity1;
layout(std140, binding = 0) uniform UnityPerMaterial{
  vec4 _SepcularGloss_ST;
  vec4 _MainTex_ST;
  vec4 _ReflectionMap_HDR;
  vec4 _BaseColor;
  vec4 ReflectionDir;
  float _Reflectivity;
  float _Smoothness0;
  float _CutValue;
  float _ReflectionIntenSity;
};
layout(location = 0) uniform sampler2D _MainTex;
in vec4 vs_TEXCOORD3;
layout(location = 0) out vec4 SV_Target0;
vec3 u_xlat16_0;
vec4 u_xlat16_1;
void main(){
  (u_xlat16_0.xyz = (_LightColor1.xyz * vec3(_LightIntensity1)));
  (u_xlat16_1 = texture(_MainTex, vs_TEXCOORD3.zw));
  (u_xlat16_1 = (u_xlat16_1 * _BaseColor));
  (SV_Target0.xyz = (u_xlat16_0.xyz * u_xlat16_1.xyz));
  (SV_Target0.w = u_xlat16_1.w);
  return ;
}
