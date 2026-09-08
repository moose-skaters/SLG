#version 450
vec4 ImmCB_0[4];
uniform vec4 _AdditionalLightsCount;
uniform vec4 _AdditionalLightsPosition[32];
uniform vec4 _AdditionalLightsColor[32];
uniform vec4 _AdditionalLightsAttenuation[32];
uniform vec4 _AdditionalLightsSpotDir[32];
uniform float _Timeline;
uniform int _BlurPlaneShadowOn;
layout(std140, binding = 0) uniform UnityPerDraw{
  vec4 hlslcc_mtx4x4unity_ObjectToWorld[4];
  vec4 hlslcc_mtx4x4unity_WorldToObject[4];
  vec4 unity_LODFade;
  vec4 unity_WorldTransformParams;
  vec4 unity_RenderingLayer;
  vec4 unity_LightData;
  vec4 unity_LightIndices[2];
  vec4 unity_ProbesOcclusion;
  vec4 unity_SpecCube0_HDR;
  vec4 unity_SpecCube1_HDR;
  vec4 unity_SpecCube0_BoxMax;
  vec4 unity_SpecCube0_BoxMin;
  vec4 unity_SpecCube0_ProbePosition;
  vec4 unity_SpecCube1_BoxMax;
  vec4 unity_SpecCube1_BoxMin;
  vec4 unity_SpecCube1_ProbePosition;
  vec4 unity_LightmapST;
  vec4 unity_DynamicLightmapST;
  vec4 unity_SHAr;
  vec4 unity_SHAg;
  vec4 unity_SHAb;
  vec4 unity_SHBr;
  vec4 unity_SHBg;
  vec4 unity_SHBb;
  vec4 unity_SHC;
  vec4 hlslcc_mtx4x4unity_MatrixPreviousM[4];
  vec4 hlslcc_mtx4x4unity_MatrixPreviousMI[4];
  vec4 unity_MotionVectorsParams;
};
layout(std140, binding = 1) uniform UnityPerMaterial{
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
layout(location = 1) uniform sampler2D _EmissionMap;
layout(location = 2) uniform sampler2D _PlaneBlurShadowMap;
in vec2 vs_TEXCOORD0;
in vec4 vs_TEXCOORD2;
in vec4 vs_TEXCOORD5;
layout(location = 0) out vec4 SV_Target0;
vec2 u_xlat0;
float u_xlat16_0;
vec4 u_xlat10_0;
vec3 u_xlat16_1;
vec3 u_xlat10_2;
vec3 u_xlat16_3;
vec3 u_xlat5;
vec3 u_xlat16_7;
vec3 u_xlat10;
int u_xlati10;
uint u_xlatu10;
float u_xlat16;
int u_xlati16;
float u_xlat16_19;
uint u_xlatu20;
float u_xlat16_21;
float u_xlat22;
void main(){
  (ImmCB_0[0] = vec4(1.0, 0.0, 0.0, 0.0));
  (ImmCB_0[1] = vec4(0.0, 1.0, 0.0, 0.0));
  (ImmCB_0[2] = vec4(0.0, 0.0, 1.0, 0.0));
  (ImmCB_0[3] = vec4(0.0, 0.0, 0.0, 1.0));
  (u_xlat10_0 = texture(_MainTex1, vs_TEXCOORD0.xy));
  (u_xlat16_1.xyz = (u_xlat10_0.xyz * _Color1.xyz));
  (u_xlat10_2.xyz = texture(_EmissionMap, vs_TEXCOORD0.xy).xyz);
  (u_xlat16_19 = min(_AdditionalLightsCount.x, unity_LightData.y));
  (u_xlatu20 = uint(int(u_xlat16_19)));
  (u_xlat16_3.xyz = u_xlat16_1.xyz);
  for (uint u_xlatu_loop_1 = 0u; (u_xlatu_loop_1 < u_xlatu20); (u_xlatu_loop_1++))
  {
    (u_xlatu10 = uint((u_xlatu_loop_1 >> 2u)));
    (u_xlati16 = int(uint((u_xlatu_loop_1 & 3u))));
    (u_xlat10.x = dot(unity_LightIndices[int(u_xlatu10)], ImmCB_0[u_xlati16]));
    (u_xlati10 = int(u_xlat10.x));
    (u_xlat5.xyz = (((-vs_TEXCOORD2.xyz) * _AdditionalLightsPosition[u_xlati10].www) + _AdditionalLightsPosition[u_xlati10].xyz));
    (u_xlat16 = dot(u_xlat5.xyz, u_xlat5.xyz));
    (u_xlat16 = max(u_xlat16, 6.1035156e-05));
    (u_xlat22 = inversesqrt(u_xlat16));
    (u_xlat5.xyz = (vec3(u_xlat22) * u_xlat5.xyz));
    (u_xlat22 = (1.0 / float(u_xlat16)));
    (u_xlat16 = ((u_xlat16 * _AdditionalLightsAttenuation[u_xlati10].x) + _AdditionalLightsAttenuation[u_xlati10].y));
    (u_xlat16 = clamp(u_xlat16, 0.0, 1.0));
    (u_xlat16 = (u_xlat16 * u_xlat22));
    (u_xlat16_19 = dot(_AdditionalLightsSpotDir[u_xlati10].xyz, u_xlat5.xyz));
    (u_xlat16_19 = ((u_xlat16_19 * _AdditionalLightsAttenuation[u_xlati10].z) + _AdditionalLightsAttenuation[u_xlati10].w));
    (u_xlat16_19 = clamp(u_xlat16_19, 0.0, 1.0));
    (u_xlat16_19 = (u_xlat16_19 * u_xlat16_19));
    (u_xlat16 = (u_xlat16_19 * u_xlat16));
    (u_xlat16 = min(u_xlat16, 0.0099999998));
    (u_xlat10.xyz = (vec3(u_xlat16) * _AdditionalLightsColor[u_xlati10].xyz));
    (u_xlat10.xyz = (u_xlat10.xyz * vec3(vec3(_MaxAddIntensity1, _MaxAddIntensity1, _MaxAddIntensity1))));
    (u_xlat16_3.xyz = ((u_xlat10.xyz * u_xlat10_0.xyz) + u_xlat16_3.xyz));
  }
  (u_xlat16_7.xyz = (u_xlat10_2.xyz * _EmissionColor.xyz));
  (u_xlat16_21 = ((_Timeline * (-_EmissionIntensity)) + _EmissionIntensity));
  (u_xlat16_7.xyz = ((u_xlat16_7.xyz * vec3(u_xlat16_21)) + u_xlat16_3.xyz));
  (u_xlat16_3.x = (u_xlat10_0.w * _Color.w));
  (u_xlat16_1.x = ((u_xlat16_1.x * _Color.w) + (-u_xlat16_3.x)));
  (SV_Target0.w = ((_AlphaIsR * u_xlat16_1.x) + u_xlat16_3.x));
  if ((_BlurPlaneShadowOn != 0))
  {
    (u_xlat0.x = (1.0 / float(vs_TEXCOORD5.w)));
    (u_xlat0.xy = (u_xlat0.xx * vs_TEXCOORD5.xy));
    (u_xlat16_0 = texture(_PlaneBlurShadowMap, u_xlat0.xy).x);
    (u_xlat16_3.xyz = (u_xlat16_7.xyz * vec3(0.5, 0.5, 0.5)));
    (SV_Target0.xyz = ((vec3(u_xlat16_0) * u_xlat16_3.xyz) + u_xlat16_3.xyz));
  }
  else
  {
    (SV_Target0.xyz = u_xlat16_7.xyz);
  }
  return ;
}
