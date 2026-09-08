#version 450
uniform vec2 _GlobalMipBias;
uniform vec4 _Params;
layout(location = 0) uniform sampler2D _SourceTex;
in vec2 vs_TEXCOORD0;
layout(location = 0) out vec4 SV_Target0;
float u_xlat0;
vec3 u_xlat1;
vec3 u_xlat10_1;
vec3 u_xlat16_2;
float u_xlat3;
float u_xlat16_5;
float u_xlat6;
float u_xlat9;
void main(){
  (u_xlat0 = ((_Params.w * 4.0) + 9.9999997e-05));
  (u_xlat0 = (1.0 / float(u_xlat0)));
  (u_xlat3 = (_Params.w + _Params.w));
  (u_xlat10_1.xyz = texture(_SourceTex, vs_TEXCOORD0.xy, _GlobalMipBias.x).xyz);
  (u_xlat1.xyz = min(u_xlat10_1.xyz, _Params.yyy));
  (u_xlat16_2.x = max(u_xlat1.y, u_xlat1.x));
  (u_xlat16_2.x = max(u_xlat1.z, u_xlat16_2.x));
  (u_xlat6 = (u_xlat16_2.x + (-_Params.z)));
  (u_xlat16_2.x = max(u_xlat16_2.x, 9.9999997e-05));
  (u_xlat16_2.x = (1.0 / float(u_xlat16_2.x)));
  (u_xlat9 = (u_xlat6 + _Params.w));
  (u_xlat9 = max(u_xlat9, 0.0));
  (u_xlat3 = min(u_xlat3, u_xlat9));
  (u_xlat16_5 = (u_xlat3 * u_xlat3));
  (u_xlat0 = (u_xlat0 * u_xlat16_5));
  (u_xlat0 = max(u_xlat0, u_xlat6));
  (u_xlat0 = (u_xlat16_2.x * u_xlat0));
  (u_xlat16_2.xyz = (vec3(u_xlat0) * u_xlat1.xyz));
  (SV_Target0.xyz = max(u_xlat16_2.xyz, vec3(0.0, 0.0, 0.0)));
  (SV_Target0.w = 1.0);
  return ;
}
