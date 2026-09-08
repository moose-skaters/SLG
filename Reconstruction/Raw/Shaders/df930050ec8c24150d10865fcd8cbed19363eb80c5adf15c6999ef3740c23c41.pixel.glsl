#version 450
uniform vec4 _Color;
uniform float _Cutoff;
layout(location = 0) uniform sampler2D _MainTex;
in vec2 vs_TEXCOORD0;
layout(location = 0) out vec4 SV_Target0;
float u_xlat16_0;
bool u_xlatb0;
float u_xlat16_1;
void main(){
  (u_xlat16_0 = texture(_MainTex, vs_TEXCOORD0.xy).w);
  (u_xlat16_1 = (u_xlat16_0 + (-_Cutoff)));
  (u_xlatb0 = (u_xlat16_1 < 0.0));
  if (u_xlatb0)
  {
    discard;
  }
  (SV_Target0 = _Color);
  return ;
}
