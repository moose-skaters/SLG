#version 450
uniform vec4 _UnderlayColor;
layout(location = 0) uniform sampler2D _MainTex;
in vec4 vs_COLOR0;
in vec4 vs_COLOR1;
in vec4 vs_TEXCOORD0;
in vec4 vs_TEXCOORD1;
in vec4 vs_TEXCOORD3;
in vec2 vs_TEXCOORD4;
layout(location = 0) out vec4 SV_Target0;
vec4 u_xlat0;
vec4 u_xlat16_0;
vec4 u_xlat16_1;
vec4 u_xlat16_2;
vec2 u_xlat16_3;
void main(){
  (u_xlat16_0.x = texture(_MainTex, vs_TEXCOORD3.xy).w);
  (u_xlat16_1.x = ((u_xlat16_0.x * vs_TEXCOORD4.x) + (-vs_TEXCOORD4.y)));
  (u_xlat16_1.x = clamp(u_xlat16_1.x, 0.0, 1.0));
  (u_xlat16_0.xyz = (_UnderlayColor.www * _UnderlayColor.xyz));
  (u_xlat16_0.w = _UnderlayColor.w);
  (u_xlat0 = (u_xlat16_1.xxxx * u_xlat16_0));
  (u_xlat16_1 = (vs_COLOR0 + (-vs_COLOR1)));
  (u_xlat16_2.x = texture(_MainTex, vs_TEXCOORD0.xy).w);
  (u_xlat16_3.xy = ((u_xlat16_2.xx * vs_TEXCOORD1.xx) + (-vs_TEXCOORD1.zy)));
  (u_xlat16_3.xy = clamp(u_xlat16_3.xy, 0.0, 1.0));
  (u_xlat16_1 = ((u_xlat16_3.xxxx * u_xlat16_1) + vs_COLOR1));
  (u_xlat16_2 = (u_xlat16_3.yyyy * u_xlat16_1));
  (u_xlat16_1.x = (((-u_xlat16_1.w) * u_xlat16_3.y) + 1.0));
  (u_xlat0 = ((u_xlat0 * u_xlat16_1.xxxx) + u_xlat16_2));
  (u_xlat0 = (u_xlat0 * vs_TEXCOORD3.zzzz));
  (SV_Target0 = u_xlat0);
  return ;
}
