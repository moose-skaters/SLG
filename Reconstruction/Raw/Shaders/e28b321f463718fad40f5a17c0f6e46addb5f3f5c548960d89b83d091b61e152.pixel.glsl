#version 450
uniform int _BlurPlaneShadowOn;
layout(std140, binding = 0) uniform UnityPerMaterial{
  vec4 _EmissionColor;
  vec4 _Color;
  vec4 _Color1;
  vec4 _Fresnel_Color;
  vec4 _GPUSKin_TextureSize;
  float _VertexOffsetY;
  float _MainLightOn;
  float _MaxAddIntensity1;
  float _EmissionIntensity;
  float _Fresnel_Bisa;
  float _Fresnel_Scale;
  float _Fresnel_Intensity;
  float _CutOff;
  float _AlphaIsR;
  float _FogON;
};
layout(location = 0) uniform sampler2D _MainTex1;
layout(location = 1) uniform sampler2D _PlaneBlurShadowMap;
in vec2 vs_TEXCOORD0;
in vec4 vs_TEXCOORD5;
layout(location = 0) out vec4 SV_Target0;
vec2 u_xlat0;
float u_xlat16_0;
vec4 u_xlat10_0;
vec3 u_xlat16_1;
vec3 u_xlat16_2;
float u_xlat16_10;
void main(){
  (u_xlat10_0 = texture(_MainTex1, vs_TEXCOORD0.xy));
  (u_xlat16_1.xyz = (u_xlat10_0.xyz * _Color1.xyz));
  (u_xlat16_10 = (u_xlat10_0.w * _Color.w));
  (u_xlat16_2.x = ((u_xlat16_1.x * _Color.w) + (-u_xlat16_10)));
  (SV_Target0.w = ((_AlphaIsR * u_xlat16_2.x) + u_xlat16_10));
  if ((_BlurPlaneShadowOn != 0))
  {
    (u_xlat0.x = (1.0 / float(vs_TEXCOORD5.w)));
    (u_xlat0.xy = (u_xlat0.xx * vs_TEXCOORD5.xy));
    (u_xlat16_0 = texture(_PlaneBlurShadowMap, u_xlat0.xy).x);
    (u_xlat16_2.xyz = (u_xlat16_1.xyz * vec3(0.5, 0.5, 0.5)));
    (SV_Target0.xyz = ((vec3(u_xlat16_0) * u_xlat16_2.xyz) + u_xlat16_2.xyz));
  }
  else
  {
    (SV_Target0.xyz = u_xlat16_1.xyz);
  }
  return ;
}
