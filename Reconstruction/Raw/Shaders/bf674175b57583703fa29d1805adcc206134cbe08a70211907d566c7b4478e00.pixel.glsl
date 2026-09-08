#version 450
layout(location = 0) uniform sampler2D _BaseMap;
in vec4 vs_COLOR0;
in vec2 vs_TEXCOORD0;
layout(location = 0) out vec4 SV_Target0;
float u_xlat16_0;
void main(){
  (u_xlat16_0 = texture(_BaseMap, vs_TEXCOORD0.xy).w);
  (SV_Target0.w = (u_xlat16_0 * vs_COLOR0.w));
  (SV_Target0.xyz = vs_COLOR0.xyz);
  return ;
}
