#version 450
uniform vec4 _Time;
layout(std140, binding = 0) uniform UnityPerMaterial{
  vec4 _Remp_Tex_ST;
  vec4 _Mask_Tex_ST;
  vec4 _Diss_Tex_ST;
  vec4 _Turb_Tex_UV;
  vec4 _Turb_Tex_ST;
  vec4 _Main_Tex_ST;
  vec4 _MainTex_ST;
  vec4 _Main_Tex_Color;
  vec4 _Diss_Tex_EdgeColor;
  vec2 _Remp_Tex_UV;
  vec2 _Main_Tex_UV;
  vec2 _Mask_Tex_UV;
  vec2 _Diss_Tex_UV;
  float _Diss_Tex_EdgeWidth;
  float _Main_Tex_Alpha;
  float _Diss_Tex_value;
  float _Turb_Mask_Value;
  float _Turb_Diss_Value;
  float _Main_Tex_A_NO_R;
  float _StencilReadMask;
  float _Turb_RempTex_Value;
  float _Mask_Tex_Rotator;
  float _Main_Tex_Brightness;
  float _Main_Tex_Rotator;
  float _Turb_Main_Value;
  float _StencilComp;
  float _StencilWriteMask;
  float _Stencil;
  float _StencilOp;
  float _Diss_Tex_Soft_value;
  float _Tex_2_A_NO_R;
  float _Mask_Tex_A;
  float _Diss_Tex_Particle_ON;
  float _Main_Tex_Particle_Speed;
  float _Turb_MainTex_ON;
  float _Turb_Noise_Polar_ON;
  float _Diss_Tex_Edge_NO;
  float _RotatorFromZero_On;
  int _UseUITex;
  int _MaskTex02On;
  int _Mask_Tex02_A;
  float _Mask_Tex02_Rotator;
  vec4 _Mask_Tex02_UV;
  vec4 _Mask_Tex02_ST;
  int _Mask01RotatorFromZero_On;
  int _Mask02RotatorFromZero_On;
  int _HDRColorFix;
};
layout(location = 0) uniform sampler2D _Turb_Tex;
layout(location = 1) uniform sampler2D _MainTex;
layout(location = 2) uniform sampler2D _Main_Tex;
in vec4 vs_TEXCOORD0;
in vec4 vs_TEXCOORD1;
in vec2 vs_TEXCOORD2;
in vec4 vs_TEXCOORD3;
in vec4 vs_COLOR0;
layout(location = 0) out vec4 SV_Target0;
vec4 u_xlat0;
vec2 u_xlat1;
vec4 u_xlat16_1;
vec4 u_xlat10_1;
vec3 u_xlat16_2;
float u_xlat16_3;
vec3 u_xlat16_4;
float u_xlat6;
float u_xlat16_8;
vec2 u_xlat10;
bool u_xlatb10;
vec2 u_xlat11;
float u_xlat16_17;
void main(){
  (u_xlat0 = (((_UseUITex != 0)) ? (_MainTex_ST) : (_Main_Tex_ST)));
  (u_xlat1.xy = ((vs_TEXCOORD0.xy * _Turb_Tex_ST.xy) + _Turb_Tex_ST.zw));
  (u_xlat11.xy = ((-u_xlat1.xy) + vs_TEXCOORD3.zw));
  (u_xlat1.xy = ((vec2(vec2(_Turb_Noise_Polar_ON, _Turb_Noise_Polar_ON)) * u_xlat11.xy) + u_xlat1.xy));
  (u_xlat1.xy = ((_Time.yy * _Turb_Tex_UV.xy) + u_xlat1.xy));
  (u_xlat16_1.x = texture(_Turb_Tex, u_xlat1.xy).x);
  (u_xlat6 = (vs_TEXCOORD1.w + (-_Turb_Main_Value)));
  (u_xlat6 = ((_Turb_MainTex_ON * u_xlat6) + _Turb_Main_Value));
  (u_xlat0.xy = ((vs_TEXCOORD0.xy * u_xlat0.xy) + u_xlat0.zw));
  (u_xlat10.xy = ((_Time.yy * vec2(_Main_Tex_UV.x, _Main_Tex_UV.y)) + u_xlat0.xy));
  (u_xlat0.xy = (u_xlat0.xy + vs_TEXCOORD1.xy));
  (u_xlat0.xy = ((-u_xlat10.xy) + u_xlat0.xy));
  (u_xlat0.xy = ((vec2(_Main_Tex_Particle_Speed) * u_xlat0.xy) + u_xlat10.xy));
  (u_xlat0.xy = ((u_xlat16_1.xx * vec2(u_xlat6)) + u_xlat0.xy));
  (u_xlat0.xy = (((-vec2(_RotatorFromZero_On)) * vec2(0.5, 0.5)) + u_xlat0.xy));
  (u_xlatb10 = (0.0 < _Main_Tex_Rotator));
  if (u_xlatb10)
  {
    (u_xlat1.x = dot(u_xlat0.xy, vs_TEXCOORD2.xy));
    (u_xlat10.xy = (vs_TEXCOORD2.yx * vec2(-1.0, 1.0)));
    (u_xlat1.y = dot(u_xlat0.xy, u_xlat10.xy));
    (u_xlat0.xy = ((vec2(_RotatorFromZero_On) * vec2(0.5, 0.5)) + u_xlat1.xy));
  }
  if ((_UseUITex != 0))
  {
    (u_xlat10_1 = texture(_MainTex, u_xlat0.xy));
    (u_xlat16_1 = u_xlat10_1);
  }
  else
  {
    (u_xlat16_1 = texture(_Main_Tex, u_xlat0.xy));
    (u_xlat16_1 = u_xlat16_1);
  }
  (u_xlat16_2.xyz = (u_xlat16_1.xyz * _Main_Tex_Color.xyz));
  (u_xlat16_2.xyz = (u_xlat16_2.xyz * vec3(vec3(_Main_Tex_Brightness, _Main_Tex_Brightness, _Main_Tex_Brightness))));
  (u_xlat16_2.xyz = (u_xlat16_2.xyz * vs_COLOR0.xyz));
  (u_xlat16_17 = ((-u_xlat16_1.w) + u_xlat16_1.x));
  (u_xlat16_17 = ((_Main_Tex_A_NO_R * u_xlat16_17) + u_xlat16_1.w));
  (u_xlat16_17 = (u_xlat16_17 * _Main_Tex_Color.w));
  (u_xlat16_17 = (u_xlat16_17 * _Main_Tex_Alpha));
  (u_xlat16_3 = (u_xlat16_17 * vs_COLOR0.w));
  (u_xlat16_8 = float(_HDRColorFix));
  (u_xlat16_4.xyz = ((u_xlat16_2.xyz * vec3(u_xlat16_3)) + (-u_xlat16_2.xyz)));
  (SV_Target0.xyz = ((vec3(u_xlat16_8) * u_xlat16_4.xyz) + u_xlat16_2.xyz));
  (u_xlat16_2.x = (((-u_xlat16_17) * vs_COLOR0.w) + 1.0));
  (SV_Target0.w = ((u_xlat16_8 * u_xlat16_2.x) + u_xlat16_3));
  return ;
}
