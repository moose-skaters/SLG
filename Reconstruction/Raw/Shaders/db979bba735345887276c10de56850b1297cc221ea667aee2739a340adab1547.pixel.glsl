#version 450
uniform vec4 _TextureSampleAdd;
uniform vec4 _ClipRect;
layout(location = 0) uniform sampler2D _MainTex;
in vec4 vs_COLOR0;
in vec2 vs_TEXCOORD0;
in vec4 vs_TEXCOORD2;
layout(location = 0) out vec4 SV_Target0;
vec4 u_xlat0;
vec4 u_xlat16_0;
float u_xlat16_1;
vec4 u_xlat2;
vec4 u_xlat16_2;
float u_xlat16_4;
void main(){
  (u_xlat0.xy = ((-_ClipRect.xy) + _ClipRect.zw));
  (u_xlat0.xy = (u_xlat0.xy + (-abs(vs_TEXCOORD2.xy))));
  (u_xlat0.xy = (u_xlat0.xy * vs_TEXCOORD2.zw));
  (u_xlat0.xy = clamp(u_xlat0.xy, 0.0, 1.0));
  (u_xlat16_1 = (u_xlat0.y * u_xlat0.x));
  (u_xlat16_4 = (vs_COLOR0.w * 255.0));
  (u_xlat16_4 = roundEven(u_xlat16_4));
  (u_xlat16_0.w = (u_xlat16_4 * 0.0039215689));
  (u_xlat16_2 = texture(_MainTex, vs_TEXCOORD0.xy));
  (u_xlat2 = (u_xlat16_2 + _TextureSampleAdd));
  (u_xlat16_0.xyz = vs_COLOR0.xyz);
  (u_xlat0 = (u_xlat16_0 * u_xlat2));
  (u_xlat16_1 = (u_xlat16_1 * u_xlat0.w));
  (SV_Target0.xyz = (u_xlat0.xyz * vec3(u_xlat16_1)));
  (SV_Target0.w = u_xlat16_1);
  return ;
}
