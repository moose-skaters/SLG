#version 450
uniform vec4 _FogColor;
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
in float vs_TEXCOORD2;
in vec4 vs_TEXCOORD3;
layout(location = 0) out vec4 SV_Target0;
vec3 u_xlat0;
vec4 u_xlat16_1;
vec3 u_xlat16_2;
vec3 u_xlat16_3;
vec3 u_xlat4;
void main(){
  (u_xlat0.x = vs_TEXCOORD2);
  (u_xlat0.x = clamp(u_xlat0.x, 0.0, 1.0));
  (u_xlat0.x = (u_xlat0.x * _FogColor.w));
  (u_xlat16_1 = texture(_MainTex, vs_TEXCOORD3.zw));
  (u_xlat16_1 = (u_xlat16_1 * _BaseColor));
  (u_xlat16_2.xyz = (_LightColor1.xyz * vec3(_LightIntensity1)));
  (u_xlat16_3.xyz = (u_xlat16_1.xyz * u_xlat16_2.xyz));
  (u_xlat4.xyz = (((-u_xlat16_1.xyz) * u_xlat16_2.xyz) + _FogColor.xyz));
  (SV_Target0.w = u_xlat16_1.w);
  (u_xlat0.xyz = ((u_xlat0.xxx * u_xlat4.xyz) + u_xlat16_3.xyz));
  (SV_Target0.xyz = u_xlat0.xyz);
  return ;
}
