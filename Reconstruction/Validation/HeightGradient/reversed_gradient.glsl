#version 450
uniform vec4 _LightColor1;
uniform float _LightIntensity1;
layout(std140, binding = 0) uniform UnityPerMaterial{
  vec4 _Color;
  vec4 _GradientColor;
  float _GradientHeightStart;
  float _GradientHeightEnd;
  float _CutOff;
  float _Intensity;
  float _GradientPower;
};
layout(location = 0) uniform sampler2D _MainTex;
in vec2 vs_TEXCOORD0;
in vec4 vs_TEXCOORD2;
layout(location = 0) out vec4 SV_Target0;
vec3 u_xlat0;
vec4 u_xlat16_1;
vec4 u_xlat16_2;
vec3 u_xlat3;
#define _GradientHeightStart 2.0
#define _GradientHeightEnd 0.5
#define _GradientPower 2.0
#define _GradientColor vec4(0.03,0.12,0.05,0.4)
#define _Color vec4(0.75,0.6,0.8,0.7)
#define _Intensity 0.8
void main(){
  (u_xlat0.x = ((-_GradientHeightStart) + _GradientHeightEnd));
  (u_xlat0.x = (1.0 / u_xlat0.x));
  (u_xlat3.x = (vs_TEXCOORD2.y + (-_GradientHeightStart)));
  (u_xlat0.x = (u_xlat0.x * u_xlat3.x));
  (u_xlat0.x = clamp(u_xlat0.x, 0.0, 1.0));
  (u_xlat3.x = ((u_xlat0.x * -2.0) + 3.0));
  (u_xlat0.x = (u_xlat0.x * u_xlat0.x));
  (u_xlat0.x = (u_xlat0.x * u_xlat3.x));
  (u_xlat0.x = log2(u_xlat0.x));
  (u_xlat0.x = (u_xlat0.x * _GradientPower));
  (u_xlat0.x = exp2(u_xlat0.x));
  (u_xlat16_1 = texture(_MainTex, vs_TEXCOORD0.xy));
  (u_xlat16_2 = (_Color * vec4(vec4(_Intensity, _Intensity, _Intensity, _Intensity))));
  (u_xlat16_1 = (u_xlat16_1 * u_xlat16_2));
  (u_xlat16_2.xyz = (u_xlat16_1.xyz * _LightColor1.xyz));
  (SV_Target0.w = u_xlat16_1.w);
  (u_xlat3.xyz = ((u_xlat16_2.xyz * vec3(_LightIntensity1)) + (-_GradientColor.xyz)));
  (u_xlat0.xyz = ((u_xlat0.xxx * u_xlat3.xyz) + _GradientColor.xyz));
  (SV_Target0.xyz = u_xlat0.xyz);
  return ;
}
