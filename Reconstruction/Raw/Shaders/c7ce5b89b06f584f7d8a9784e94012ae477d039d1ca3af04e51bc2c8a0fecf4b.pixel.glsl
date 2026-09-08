#version 450
uniform vec2 _GlobalMipBias;
layout(location = 0) uniform sampler2D _SourceTex;
in vec2 vs_TEXCOORD0;
layout(location = 0) out vec4 SV_Target0;
vec4 u_xlat16_0;
void main(){
  (u_xlat16_0 = texture(_SourceTex, vs_TEXCOORD0.xy, _GlobalMipBias.x));
  (SV_Target0 = u_xlat16_0);
  return ;
}
