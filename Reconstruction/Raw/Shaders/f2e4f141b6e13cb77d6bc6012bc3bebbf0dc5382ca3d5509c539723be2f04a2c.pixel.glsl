#version 450
uniform vec2 _GlobalMipBias;
uniform vec4 _SourceTex_TexelSize;
layout(location = 0) uniform sampler2D _SourceTex;
in vec2 vs_TEXCOORD0;
layout(location = 0) out vec4 SV_Target0;
vec4 u_xlat0;
vec3 u_xlat10_0;
vec3 u_xlat1;
vec3 u_xlat10_1;
vec3 u_xlat16_2;
void main(){
  (u_xlat0.xz = (_SourceTex_TexelSize.xx * vec2(-4.0, -2.0)));
  (u_xlat0.y = 0.0);
  (u_xlat0.w = 0.0);
  (u_xlat0 = (u_xlat0 + vs_TEXCOORD0.xyxy));
  (u_xlat10_1.xyz = texture(_SourceTex, u_xlat0.zw, _GlobalMipBias.x).xyz);
  (u_xlat10_0.xyz = texture(_SourceTex, u_xlat0.xy, _GlobalMipBias.x).xyz);
  (u_xlat1.xyz = (u_xlat10_1.xyz * vec3(0.24420001, 0.24420001, 0.24420001)));
  (u_xlat16_2.xyz = ((u_xlat10_0.xyz * vec3(0.054499999, 0.054499999, 0.054499999)) + u_xlat1.xyz));
  (u_xlat0.xz = (_SourceTex_TexelSize.xx * vec2(2.0, 4.0)));
  (u_xlat0.y = 0.0);
  (u_xlat0.w = 0.0);
  (u_xlat0 = (u_xlat0 + vs_TEXCOORD0.xyxy));
  (u_xlat10_1.xyz = texture(_SourceTex, u_xlat0.xy, _GlobalMipBias.x).xyz);
  (u_xlat10_0.xyz = texture(_SourceTex, u_xlat0.zw, _GlobalMipBias.x).xyz);
  (u_xlat16_2.xyz = ((u_xlat10_1.xyz * vec3(0.24420001, 0.24420001, 0.24420001)) + u_xlat16_2.xyz));
  (u_xlat16_2.xyz = ((u_xlat10_0.xyz * vec3(0.054499999, 0.054499999, 0.054499999)) + u_xlat16_2.xyz));
  (u_xlat10_0.xyz = texture(_SourceTex, vs_TEXCOORD0.xy, _GlobalMipBias.x).xyz);
  (SV_Target0.xyz = ((u_xlat10_0.xyz * vec3(0.40259999, 0.40259999, 0.40259999)) + u_xlat16_2.xyz));
  (SV_Target0.w = 1.0);
  return ;
}
