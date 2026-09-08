#version 450
layout(location = 0) uniform sampler2D _MainTex;
in vec2 vs_TEXCOORD0;
in vec2 vs_TEXCOORD1;
in vec2 vs_TEXCOORD2;
in vec2 vs_TEXCOORD3;
in vec2 vs_TEXCOORD4;
layout(location = 0) out vec4 SV_Target0;
vec3 u_xlat0;
vec3 u_xlat16_0;
vec4 u_xlat16_1;
vec3 u_xlat16_2;
void main(){
  (u_xlat16_0.xyz = texture(_MainTex, vs_TEXCOORD1.xy).xyz);
  (u_xlat0.xyz = (u_xlat16_0.xyz * vec3(0.24420001, 0.24420001, 0.24420001)));
  (u_xlat16_1 = texture(_MainTex, vs_TEXCOORD0.xy));
  (u_xlat0.xyz = ((u_xlat16_1.xyz * vec3(0.40259999, 0.40259999, 0.40259999)) + u_xlat0.xyz));
  (u_xlat16_2.xyz = texture(_MainTex, vs_TEXCOORD2.xy).xyz);
  (u_xlat0.xyz = ((u_xlat16_2.xyz * vec3(0.24420001, 0.24420001, 0.24420001)) + u_xlat0.xyz));
  (u_xlat16_2.xyz = texture(_MainTex, vs_TEXCOORD3.xy).xyz);
  (u_xlat0.xyz = ((u_xlat16_2.xyz * vec3(0.054499999, 0.054499999, 0.054499999)) + u_xlat0.xyz));
  (u_xlat16_2.xyz = texture(_MainTex, vs_TEXCOORD4.xy).xyz);
  (u_xlat16_1.xyz = ((u_xlat16_2.xyz * vec3(0.054499999, 0.054499999, 0.054499999)) + u_xlat0.xyz));
  (SV_Target0 = u_xlat16_1);
  return ;
}
