#version 450
uniform vec2 _GlobalMipBias;
layout(location = 0) uniform sampler2D _MainTex;
in vec4 vs_COLOR0;
in vec2 vs_TEXCOORD0;
layout(location = 0) out vec4 SV_Target0;
vec4 u_xlat0;
vec4 u_xlat16_0;
void main(){
  (u_xlat16_0 = texture(_MainTex, vs_TEXCOORD0.xy, _GlobalMipBias.x));
  (u_xlat0 = (u_xlat16_0 * vs_COLOR0));
  (SV_Target0.xyz = (u_xlat0.www * u_xlat0.xyz));
  (SV_Target0.w = u_xlat0.w);
  return ;
}
