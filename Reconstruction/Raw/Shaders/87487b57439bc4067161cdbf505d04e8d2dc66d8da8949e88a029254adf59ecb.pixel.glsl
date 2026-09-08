#version 450
uniform vec2 _GlobalMipBias;
uniform vec4 _SourceTex_TexelSize;
layout(location = 0) uniform sampler2D _SourceTex;
in vec2 vs_TEXCOORD0;
layout(location = 0) out vec4 SV_Target0;
vec4 u_xlat0;
vec3 u_xlat10_0;
vec4 u_xlat1;
vec3 u_xlat10_1;
vec3 u_xlat10_2;
vec3 u_xlat16_3;
void main(){
  (u_xlat0.x = 0.0);
  (u_xlat0.yw = (_SourceTex_TexelSize.yy * vec2(3.2307692, 1.3846154)));
  (u_xlat1 = ((-u_xlat0.xyxw) + vs_TEXCOORD0.xyxy));
  (u_xlat0 = (u_xlat0.xwxy + vs_TEXCOORD0.xyxy));
  (u_xlat10_2.xyz = texture(_SourceTex, u_xlat1.zw, _GlobalMipBias.x).xyz);
  (u_xlat10_1.xyz = texture(_SourceTex, u_xlat1.xy, _GlobalMipBias.x).xyz);
  (u_xlat16_3.xyz = (u_xlat10_2.xyz * vec3(0.31621623, 0.31621623, 0.31621623)));
  (u_xlat16_3.xyz = ((u_xlat10_1.xyz * vec3(0.07027027, 0.07027027, 0.07027027)) + u_xlat16_3.xyz));
  (u_xlat10_1.xyz = texture(_SourceTex, vs_TEXCOORD0.xy, _GlobalMipBias.x).xyz);
  (u_xlat16_3.xyz = ((u_xlat10_1.xyz * vec3(0.22702703, 0.22702703, 0.22702703)) + u_xlat16_3.xyz));
  (u_xlat10_1.xyz = texture(_SourceTex, u_xlat0.xy, _GlobalMipBias.x).xyz);
  (u_xlat10_0.xyz = texture(_SourceTex, u_xlat0.zw, _GlobalMipBias.x).xyz);
  (u_xlat16_3.xyz = ((u_xlat10_1.xyz * vec3(0.31621623, 0.31621623, 0.31621623)) + u_xlat16_3.xyz));
  (SV_Target0.xyz = ((u_xlat10_0.xyz * vec3(0.07027027, 0.07027027, 0.07027027)) + u_xlat16_3.xyz));
  (SV_Target0.w = 1.0);
  return ;
}
