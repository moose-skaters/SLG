#version 450
uniform vec4 _Color;
layout(location = 0) uniform sampler2D _MainTex;
in vec2 vs_TEXCOORD0;
layout(location = 0) out vec4 SV_Target0;
vec4 u_xlat0;
void main(){
  (u_xlat0 = texture(_MainTex, vs_TEXCOORD0.xy));
  (u_xlat0 = (u_xlat0 * _Color));
  (SV_Target0 = u_xlat0);
  return ;
}
