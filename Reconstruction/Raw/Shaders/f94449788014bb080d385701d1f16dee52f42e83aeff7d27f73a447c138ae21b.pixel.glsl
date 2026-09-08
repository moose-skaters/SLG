#version 450
layout(location = 0) uniform sampler2D blurURP_1;
in vec4 vs_TEXCOORD3;
layout(location = 0) out vec4 SV_Target0;
vec2 u_xlat0;
vec3 u_xlat16_0;
void main(){
  (u_xlat0.xy = (vs_TEXCOORD3.xy / vs_TEXCOORD3.ww));
  (u_xlat16_0.xyz = texture(blurURP_1, u_xlat0.xy).xyz);
  (SV_Target0.xyz = u_xlat16_0.xyz);
  (SV_Target0.w = 1.0);
  return ;
}
