#version 450
uniform vec4 _TintColor;
layout(location = 0) uniform sampler2D _MainTex;
in vec4 vs_COLOR0;
in vec2 vs_TEXCOORD0;
layout(location = 0) out vec4 SV_Target0;
vec4 u_xlat0;
vec4 u_xlat16_1;
void main(){
  (u_xlat0 = (vs_COLOR0 + vs_COLOR0));
  (u_xlat0 = (u_xlat0 * _TintColor));
  (u_xlat16_1 = texture(_MainTex, vs_TEXCOORD0.xy));
  (u_xlat0 = (u_xlat0 * u_xlat16_1));
  (SV_Target0.w = u_xlat0.w);
  (SV_Target0.w = clamp(SV_Target0.w, 0.0, 1.0));
  (SV_Target0.xyz = u_xlat0.xyz);
  return ;
}
