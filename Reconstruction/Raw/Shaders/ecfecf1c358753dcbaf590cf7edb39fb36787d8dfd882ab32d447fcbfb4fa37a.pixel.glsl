#version 450
layout(std140, binding = 0) uniform UnityPerMaterial{
  vec4 _Color;
  vec4 _VertexOffset;
  float _AlphaIsR;
  float _Intensity;
  float _Tiling;
};
layout(location = 0) uniform sampler2D _MainTex;
in vec2 vs_TEXCOORD0;
layout(location = 0) out vec4 SV_Target0;
vec2 u_xlat0;
vec4 u_xlat16_0;
vec4 u_xlat16_1;
float u_xlat16_3;
void main(){
  (u_xlat0.xy = (vs_TEXCOORD0.xy * vec2(vec2(_Tiling, _Tiling))));
  (u_xlat16_0 = texture(_MainTex, u_xlat0.xy));
  (u_xlat16_1 = (_Color * vec4(vec4(_Intensity, _Intensity, _Intensity, _Intensity))));
  (u_xlat16_0 = (u_xlat16_0 * u_xlat16_1));
  (u_xlat16_1.x = (u_xlat16_0.w * _Color.w));
  (u_xlat16_3 = ((u_xlat16_0.x * _Color.w) + (-u_xlat16_1.x)));
  (SV_Target0.xyz = u_xlat16_0.xyz);
  (SV_Target0.w = ((_AlphaIsR * u_xlat16_3) + u_xlat16_1.x));
  return ;
}
