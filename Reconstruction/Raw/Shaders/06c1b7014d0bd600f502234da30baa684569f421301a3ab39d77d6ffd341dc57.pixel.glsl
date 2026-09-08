#version 450
layout(location = 0) uniform sampler2D _MainTex;
in vec4 vs_COLOR0;
in vec4 vs_TEXCOORD0;
in vec4 vs_TEXCOORD1;
layout(location = 0) out vec4 SV_Target0;
float u_xlat16_0;
float u_xlat16_1;
void main(){
  (u_xlat16_0 = texture(_MainTex, vs_TEXCOORD0.xy).w);
  (u_xlat16_1 = ((u_xlat16_0 * vs_TEXCOORD1.x) + (-vs_TEXCOORD1.w)));
  (u_xlat16_1 = clamp(u_xlat16_1, 0.0, 1.0));
  (SV_Target0 = (vec4(u_xlat16_1) * vs_COLOR0));
  return ;
}
