#version 450
uniform vec4 _Time;
layout(std140, binding = 0) uniform UnityPerMaterial{
  vec4 _Main_Tex_ST;
  vec4 _Flowmap_Tex_ST;
  vec4 _Mask_Tex_ST;
  vec4 _Fire_Color;
  vec4 _Diss_Tex_ST;
  vec4 _Color;
  vec2 _Flowmap_UV;
  vec2 _Diss_UV;
  float _LightAngle;
  float _Mask_Power;
  float _Fire_Tex_Soft_Value;
  float _Fire_ON;
  float _A_R_ON;
  float _Diss_Tex_Soft_Value;
  float _Alpha;
};
layout(location = 0) uniform sampler2D _Main_Tex;
layout(location = 1) uniform sampler2D _Mask_Tex;
layout(location = 2) uniform sampler2D _Fire_Tex;
layout(location = 3) uniform sampler2D _Diss_Tex;
in vec4 vs_COLOR0;
in vec4 vs_TEXCOORD0;
in vec4 vs_TEXCOORD1;
in vec4 vs_TEXCOORD2;
in vec2 vs_TEXCOORD3;
layout(location = 0) out vec4 SV_Target0;
vec3 u_xlat0;
float u_xlat16_0;
vec4 u_xlat16_1;
vec3 u_xlat16_2;
vec4 u_xlat16_3;
float u_xlat4;
vec3 u_xlat16_6;
vec2 u_xlat8;
float u_xlat12;
float u_xlat16_12;
#define _ParallaxOn 1
#define _ParallaxChannel 0
#define _ParallaxScale 0.05
#define _ParallaxEdgeColor vec4(0.1,0.03,0.02,1.0)
#define _FlipBookBlend_On 1
#define _AlphaPremultiply 1
#define _Saturation 0.5
#define _Contrast 1.2
#define _Alpha_NO_R 0.35
#define _AlphaSub 0.1
#define _Main_tex_Rotator 25
#define _Particle_SpeedUV 0.7
#define _Fire_ON 0.4
#define _Mask_Power 1.4
#define _A_R_ON 0.4
#define _Diss_Tex_Soft_Value 0.25
#define _Fire_Tex_Soft_Value 0.2
#define _LightAngle 0.25
void main(){
  (u_xlat0.xy = ((vs_TEXCOORD0.xy * _Diss_Tex_ST.xy) + _Diss_Tex_ST.zw));
  (u_xlat8.xy = ((-u_xlat0.xy) + vs_TEXCOORD2.zw));
  (u_xlat0.xy = ((vs_TEXCOORD1.yy * u_xlat8.xy) + u_xlat0.xy));
  (u_xlat0.xy = ((_Time.yy * vec2(_Diss_UV.x, _Diss_UV.y)) + u_xlat0.xy));
  (u_xlat16_0 = texture(_Diss_Tex, u_xlat0.xy).x);
  (u_xlat0.x = (u_xlat16_0 + 1.0));
  (u_xlat16_1.x = ((-_Diss_Tex_Soft_Value) + 2.0));
  (u_xlat0.x = (((-vs_TEXCOORD1.z) * u_xlat16_1.x) + u_xlat0.x));
  (u_xlat0.x = (u_xlat0.x + (-_Diss_Tex_Soft_Value)));
  (u_xlat4 = ((-_Diss_Tex_Soft_Value) + 1.0));
  (u_xlat4 = (1.0 / u_xlat4));
  (u_xlat0.x = (u_xlat4 * u_xlat0.x));
  (u_xlat0.x = clamp(u_xlat0.x, 0.0, 1.0));
  (u_xlat4 = ((u_xlat0.x * -2.0) + 3.0));
  (u_xlat0.x = (u_xlat0.x * u_xlat0.x));
  (u_xlat0.x = (u_xlat0.x * u_xlat4));
  (u_xlat16_1 = texture(_Main_Tex, vs_TEXCOORD2.xy));
  (u_xlat16_2.x = ((-u_xlat16_1.w) + u_xlat16_1.x));
  (u_xlat16_2.x = ((_A_R_ON * u_xlat16_2.x) + u_xlat16_1.w));
  (u_xlat16_3 = (vs_COLOR0 * _Color));
  (u_xlat16_2.x = (u_xlat16_2.x * u_xlat16_3.w));
  (u_xlat16_6.xyz = (u_xlat16_1.xyz * u_xlat16_3.xyz));
  (u_xlat16_2.x = (u_xlat0.x * u_xlat16_2.x));
  (SV_Target0.w = (u_xlat16_2.x * _Alpha));
  (SV_Target0.w = clamp(SV_Target0.w, 0.0, 1.0));
  (u_xlat16_0 = texture(_Fire_Tex, vs_TEXCOORD2.xy).x);
  (u_xlat0.x = (u_xlat16_0 + 1.0));
  (u_xlat16_2.x = ((-_Fire_Tex_Soft_Value) + 2.0));
  (u_xlat0.x = (((-vs_TEXCOORD1.w) * u_xlat16_2.x) + u_xlat0.x));
  (u_xlat0.x = (u_xlat0.x + (-_Fire_Tex_Soft_Value)));
  (u_xlat4 = ((-_Fire_Tex_Soft_Value) + 1.0));
  (u_xlat4 = (1.0 / u_xlat4));
  (u_xlat0.x = (u_xlat4 * u_xlat0.x));
  (u_xlat0.x = clamp(u_xlat0.x, 0.0, 1.0));
  (u_xlat4 = ((u_xlat0.x * -2.0) + 3.0));
  (u_xlat0.x = (u_xlat0.x * u_xlat0.x));
  (u_xlat0.x = (u_xlat0.x * u_xlat4));
  (u_xlat16_2.x = min(u_xlat0.x, 1.0));
  (u_xlat0.xyz = ((_Fire_Color.xyz * u_xlat16_2.xxx) + u_xlat16_6.xyz));
  (u_xlat16_12 = texture(_Mask_Tex, vs_TEXCOORD3.xy).x);
  (u_xlat12 = log2(u_xlat16_12));
  (u_xlat12 = (u_xlat12 * _Mask_Power));
  (u_xlat12 = exp2(u_xlat12));
  (u_xlat12 = min(u_xlat12, 1.0));
  (u_xlat16_2.xyz = (vec3(u_xlat12) * u_xlat16_6.xyz));
  (u_xlat0.xyz = ((u_xlat0.xyz * vec3(u_xlat12)) + (-u_xlat16_2.xyz)));
  (u_xlat0.xyz = ((vec3(vec3(_Fire_ON, _Fire_ON, _Fire_ON)) * u_xlat0.xyz) + u_xlat16_2.xyz));
  (SV_Target0.xyz = u_xlat0.xyz);
  return ;
}
