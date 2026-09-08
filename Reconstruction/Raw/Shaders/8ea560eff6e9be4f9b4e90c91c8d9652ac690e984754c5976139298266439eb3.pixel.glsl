#version 450
uniform vec4 _TextureSampleAdd;
layout(location = 0) uniform sampler2D _MainTex;
in vec4 vs_COLOR0;
in vec2 vs_TEXCOORD0;
layout(location = 0) out vec4 SV_Target0;
vec4 u_xlat0;
vec4 u_xlat16_0;
vec4 u_xlat1;
vec4 u_xlat16_1;
void main(){
  (u_xlat16_0.x = (vs_COLOR0.w * 255.0));
  (u_xlat16_0.x = roundEven(u_xlat16_0.x));
  (u_xlat16_0.w = (u_xlat16_0.x * 0.0039215689));
  (u_xlat16_1 = texture(_MainTex, vs_TEXCOORD0.xy));
  (u_xlat1 = (u_xlat16_1 + _TextureSampleAdd));
  (u_xlat16_0.xyz = vs_COLOR0.xyz);
  (u_xlat0 = (u_xlat16_0 * u_xlat1));
  (SV_Target0.xyz = (u_xlat0.www * u_xlat0.xyz));
  (SV_Target0.w = u_xlat0.w);
  return ;
}
