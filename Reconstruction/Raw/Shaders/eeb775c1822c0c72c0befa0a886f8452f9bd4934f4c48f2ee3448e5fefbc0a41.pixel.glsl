#version 450
uniform vec2 _GlobalMipBias;
layout(std140, binding = 0) uniform UnityPerMaterial{
  vec4 _MainTex_ST;
  float _Alpha;
};
layout(location = 0) uniform sampler2D _MainTex;
in vec4 vs_COLOR0;
in vec2 vs_TEXCOORD0;
in float vs_TEXCOORD1;
layout(location = 0) out vec4 SV_Target0;
vec4 u_xlat0;
float u_xlat16_0;
void main(){
  (u_xlat16_0 = texture(_MainTex, vs_TEXCOORD0.xy, _GlobalMipBias.x).w);
  (u_xlat0.x = (u_xlat16_0 * vs_COLOR0.w));
  (u_xlat0.w = (u_xlat0.x * _Alpha));
  (u_xlat0.xyz = (vs_COLOR0.xyz * vec3(vs_TEXCOORD1)));
  (SV_Target0 = u_xlat0);
  return ;
}
