#version 450
uniform vec4 _Time;
layout(std140, binding = 0) uniform UnityPerMaterial{
  vec4 _Main_Tex_ST;
  vec4 _Noise_ST;
  vec4 _Main_Color;
  vec2 _Noise_UV;
  float _Noise_Value;
  float _Power;
};
layout(location = 0) uniform sampler2D _Noise;
layout(location = 1) uniform sampler2D _Main_Tex;
in vec4 vs_COLOR0;
in vec4 vs_TEXCOORD3;
layout(location = 0) out vec4 SV_Target0;
vec3 u_xlat0;
vec4 u_xlat16_0;
vec3 u_xlat1;
float u_xlat2;
void main(){
  (u_xlat0.xy = ((vs_TEXCOORD3.xy * _Noise_ST.xy) + _Noise_ST.zw));
  (u_xlat0.xz = ((_Time.yy * _Noise_UV.xy) + u_xlat0.xy));
  (u_xlat2 = log2(u_xlat0.y));
  (u_xlat2 = (u_xlat2 * _Power));
  (u_xlat2 = exp2(u_xlat2));
  (u_xlat16_0.x = texture(_Noise, u_xlat0.xz).x);
  (u_xlat0.x = (u_xlat16_0.x * _Noise_Value));
  (u_xlat1.xy = ((vs_TEXCOORD3.xy * _Main_Tex_ST.xy) + _Main_Tex_ST.zw));
  (u_xlat1.z = ((u_xlat0.x * u_xlat2) + u_xlat1.y));
  (u_xlat16_0 = texture(_Main_Tex, u_xlat1.xz));
  (u_xlat16_0 = (u_xlat16_0 * vs_COLOR0));
  (SV_Target0 = (u_xlat16_0 * _Main_Color));
  return ;
}
