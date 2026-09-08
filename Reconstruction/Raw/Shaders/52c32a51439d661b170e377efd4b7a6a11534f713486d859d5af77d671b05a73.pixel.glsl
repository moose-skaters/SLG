#version 450
uniform vec2 _GlobalMipBias;
uniform vec4 _FogColor;
uniform vec4 _LightColor1;
uniform float _LightIntensity1;
layout(std140, binding = 0) uniform UnityPerMaterial{
  vec4 _MainTex_ST;
  vec4 _PositionOffset;
  vec4 _Color;
  float _Glossiness;
  float _Metallic;
  float _Speed;
  float _MaxDist;
  float _SpeedController;
  float _ClipSize;
  float _ScaleMultiplier;
};
layout(location = 0) uniform sampler2D _MainTex;
in vec2 vs_TEXCOORD0;
in float vs_TEXCOORD2;
layout(location = 0) out vec4 SV_Target0;
float u_xlat0;
vec4 u_xlat1;
vec4 u_xlat16_1;
vec3 u_xlat16_2;
vec3 u_xlat16_3;
vec3 u_xlat4;
void main(){
  (u_xlat0 = vs_TEXCOORD2);
  (u_xlat0 = clamp(u_xlat0, 0.0, 1.0));
  (u_xlat0 = (u_xlat0 * _FogColor.w));
  (u_xlat16_1 = texture(_MainTex, vs_TEXCOORD0.xy, _GlobalMipBias.x));
  (u_xlat1 = (u_xlat16_1 * _Color));
  (u_xlat16_2.xyz = (_LightColor1.xyz * vec3(_LightIntensity1)));
  (u_xlat16_3.xyz = (u_xlat1.xyz * u_xlat16_2.xyz));
  (u_xlat4.xyz = (((-u_xlat1.xyz) * u_xlat16_2.xyz) + _FogColor.xyz));
  (u_xlat1.xyz = ((vec3(u_xlat0) * u_xlat4.xyz) + u_xlat16_3.xyz));
  (SV_Target0 = u_xlat1);
  return ;
}
