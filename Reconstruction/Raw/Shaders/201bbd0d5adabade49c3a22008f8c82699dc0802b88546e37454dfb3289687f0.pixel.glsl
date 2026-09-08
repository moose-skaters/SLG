#version 450
vec4 ImmCB_0[4];
layout(std140, binding = 0) uniform UnityPerMaterial{
  vec4 _Turb_Noise_ST;
  vec4 _Mask_ST;
  vec4 _Tex_2_ST;
  vec4 _Main_Tex_ST;
  vec4 _Diss_Tex_ST;
  vec4 _Vertex_offset_ST;
  vec4 _Polar_UV;
  vec4 _Diss_Edge_color;
  vec4 _Main_Color;
  vec4 _VertexOffset_Value;
  vec2 _Tex_2_UV;
  vec2 _Diss_UV;
  vec2 _Remap_01;
  vec2 _Main_UV;
  vec2 _Turb_UV;
  vec2 _VertexOffset_UV;
  vec2 _Mask_UV;
  float _ZTest;
  float _Mask_Tex_Rotator;
  float _Fresnel_Scale;
  float _Fresnel_Power;
  float _Fresnel_speed;
  float _Fresnel_Bias;
  float _Alpha;
  float _AlphaSub;
  float _Diss_Soft_value;
  float _EdgeWidth;
  float _Diss_value;
  float _Turb_Diss_Value;
  float _Turb_Tex2_Value;
  float _Brightness;
  float _Saturation;
  float _Contrast;
  float _Main_tex_Rotator;
  float _Turb_MainTex_Value;
  float _Alpha_NO_R;
  float _Tex2_A_NO_R;
  vec4 _Tex02_Color;
  float _Mask_A;
  float _Diss_Edge_NO;
  float _Particle_diss_ON;
  float _Particle_SpeedUV;
  float _Polar_UV_offset;
  float _Tex2_Particle_SpeedUV;
  int _FlipBookBlend_On;
  int _AlphaPremultiply;
  int _InvertFresnel;
  int _ParallaxOn;
  int _ParallaxChannel;
  float _ParallaxScale;
  vec4 _ParallaxEdgeColor;
};
layout(location = 0) uniform sampler2D _Main_Tex;
layout(location = 1) uniform sampler2D _Mask;
in vec4 vs_TEXCOORD4;
in vec4 vs_TEXCOORD5;
in vec2 vs_TEXCOORD7;
in float vs_TEXCOORD6;
in vec4 vs_COLOR0;
in vec3 vs_TEXCOORD8;
layout(location = 0) out vec4 SV_Target0;
vec4 u_xlat0;
vec4 u_xlat16_0;
vec4 u_xlat16_1;
vec2 u_xlat2;
vec4 u_xlat16_2;
int u_xlati2;
vec3 u_xlat16_3;
float u_xlat16_5;
vec3 u_xlat16_7;
float u_xlat12;
float u_xlat16_13;
void main(){
  (ImmCB_0[0] = vec4(1.0, 0.0, 0.0, 0.0));
  (ImmCB_0[1] = vec4(0.0, 1.0, 0.0, 0.0));
  (ImmCB_0[2] = vec4(0.0, 0.0, 1.0, 0.0));
  (ImmCB_0[3] = vec4(0.0, 0.0, 0.0, 1.0));
  (u_xlat16_0 = texture(_Main_Tex, vs_TEXCOORD4.xy));
  (u_xlat16_1.x = (u_xlat16_0.w + (-_AlphaSub)));
  (u_xlat16_1.x = clamp(u_xlat16_1.x, 0.0, 1.0));
  (u_xlat16_5 = (u_xlat16_0.x + (-u_xlat16_1.x)));
  (u_xlat16_1.w = ((_Alpha_NO_R * u_xlat16_5) + u_xlat16_1.x));
  if ((_ParallaxOn != 0))
  {
    (u_xlat16_0.w = u_xlat16_1.w);
    (u_xlati2 = _ParallaxChannel);
    (u_xlat16_3.x = dot(u_xlat16_0, ImmCB_0[u_xlati2]));
    (u_xlat12 = ((-u_xlat16_3.x) + 1.0));
    (u_xlat2.xy = (vec2(u_xlat12) * vs_TEXCOORD8.xy));
    (u_xlat2.xy = ((u_xlat2.xy * vec2(_ParallaxScale)) + vs_TEXCOORD4.xy));
    (u_xlat16_2 = texture(_Main_Tex, u_xlat2.xy));
    (u_xlat16_3.x = ((-u_xlat16_2.w) + u_xlat16_2.x));
    (u_xlat16_3.x = ((_Alpha_NO_R * u_xlat16_3.x) + u_xlat16_2.w));
    (u_xlat16_7.xyz = (u_xlat16_2.xyz + (-_ParallaxEdgeColor.xyz)));
    (u_xlat16_1.xyz = ((u_xlat16_3.xxx * u_xlat16_7.xyz) + _ParallaxEdgeColor.xyz));
  }
  else
  {
    (u_xlat16_1.xyz = u_xlat16_0.xyz);
  }
  if ((_FlipBookBlend_On != 0))
  {
    (u_xlat16_0 = texture(_Main_Tex, vs_TEXCOORD7.xy));
    (u_xlat16_3.x = (u_xlat16_0.w + (-_AlphaSub)));
    (u_xlat16_3.x = clamp(u_xlat16_3.x, 0.0, 1.0));
    (u_xlat0.xyz = ((-u_xlat16_1.xyz) + u_xlat16_0.xyz));
    (u_xlat0.w = ((-u_xlat16_1.w) + u_xlat16_3.x));
    (u_xlat0 = ((vec4(vs_TEXCOORD6) * u_xlat0) + u_xlat16_1));
    (u_xlat16_1 = u_xlat0);
  }
  (u_xlat16_3.x = dot(u_xlat16_1.xyz, vec3(0.29899999, 0.58700001, 0.114)));
  (u_xlat16_1.xyz = (u_xlat16_1.xyz + (-u_xlat16_3.xxx)));
  (u_xlat16_1.xyz = ((vec3(_Saturation) * u_xlat16_1.xyz) + u_xlat16_3.xxx));
  (u_xlat0.xyz = (u_xlat16_1.xyz + vec3(-0.5, -0.5, -0.5)));
  (u_xlat0.xyz = ((u_xlat0.xyz * vec3(vec3(_Contrast, _Contrast, _Contrast))) + vec3(0.5, 0.5, 0.5)));
  (u_xlat0.xyz = clamp(u_xlat0.xyz, 0.0, 1.0));
  (u_xlat16_1.xyz = (u_xlat0.xyz * _Main_Color.xyz));
  (u_xlat16_1.xyz = (u_xlat16_1.xyz * vec3(vec3(_Brightness, _Brightness, _Brightness))));
  (u_xlat16_1.xyz = (u_xlat16_1.xyz * vs_COLOR0.xyz));
  (u_xlat16_0.xy = texture(_Mask, vs_TEXCOORD5.xy).xw);
  (u_xlat16_3.x = ((-u_xlat16_0.x) + u_xlat16_0.y));
  (u_xlat16_3.x = ((_Mask_A * u_xlat16_3.x) + u_xlat16_0.x));
  (u_xlat16_13 = (u_xlat16_1.w * _Main_Color.w));
  (u_xlat16_13 = (u_xlat16_13 * _Alpha));
  (u_xlat16_13 = (u_xlat16_3.x * u_xlat16_13));
  (u_xlat0.x = (u_xlat16_13 * vs_COLOR0.w));
  (u_xlat0.x = clamp(u_xlat0.x, 0.0, 1.0));
  (u_xlat16_3.xyz = (u_xlat0.xxx * u_xlat16_1.xyz));
  (SV_Target0.xyz = (((int(_AlphaPremultiply) != 0)) ? (u_xlat16_3.xyz) : (u_xlat16_1.xyz)));
  (SV_Target0.w = u_xlat0.x);
  return ;
}
