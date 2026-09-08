#version 450
uniform vec2 _GlobalMipBias;
uniform vec4 _Params;
layout(location = 0) uniform sampler2D _SourceTex;
layout(location = 1) uniform sampler2D _SourceTexLowMip;
in vec2 vs_TEXCOORD0;
layout(location = 0) out vec4 SV_Target0;
vec3 u_xlat0;
vec3 u_xlat10_0;
vec3 u_xlat10_1;
void main(){
  (u_xlat10_0.xyz = texture(_SourceTexLowMip, vs_TEXCOORD0.xy, _GlobalMipBias.x).xyz);
  (u_xlat10_1.xyz = texture(_SourceTex, vs_TEXCOORD0.xy, _GlobalMipBias.x).xyz);
  (u_xlat0.xyz = (u_xlat10_0.xyz + (-u_xlat10_1.xyz)));
  (u_xlat0.xyz = ((_Params.xxx * u_xlat0.xyz) + u_xlat10_1.xyz));
  (SV_Target0.xyz = u_xlat0.xyz);
  (SV_Target0.w = 1.0);
  return ;
}
