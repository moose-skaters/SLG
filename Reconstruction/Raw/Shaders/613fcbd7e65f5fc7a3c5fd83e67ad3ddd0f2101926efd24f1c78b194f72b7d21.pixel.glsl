#version 450
vec4 ImmCB_0[4];
uniform vec4 _AdditionalLightsCount;
uniform vec4 _AdditionalLightsPosition[32];
uniform vec4 _AdditionalLightsColor[32];
uniform vec4 _AdditionalLightsAttenuation[32];
uniform vec4 _AdditionalLightsSpotDir[32];
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
layout(location = 0) uniform sampler2D _MainTex;
layout(location = 1) uniform sampler2D _PlaneBlurShadowMap;
in vec2 vs_TEXCOORD0;
in vec4 vs_TEXCOORD2;
in vec4 vs_TEXCOORD5;
layout(location = 0) out vec4 SV_Target0;
vec2 u_xlat0;
vec4 u_xlat16_0;
vec4 u_xlat16_1;
vec3 u_xlat16_2;
vec3 u_xlat4;
vec3 u_xlat8;
int u_xlati8;
uint u_xlatu8;
float u_xlat13;
int u_xlati13;
uint u_xlatu15;
float u_xlat16_17;
float u_xlat18;
void main(){
  (ImmCB_0[0] = vec4(1.0, 0.0, 0.0, 0.0));
  (ImmCB_0[1] = vec4(0.0, 1.0, 0.0, 0.0));
  (ImmCB_0[2] = vec4(0.0, 0.0, 1.0, 0.0));
  (ImmCB_0[3] = vec4(0.0, 0.0, 0.0, 1.0));
  (u_xlat16_0 = texture(_MainTex, vs_TEXCOORD0.xy));
  (u_xlat16_1 = (u_xlat16_0 * _Color));
  (u_xlat16_2.x = min(_AdditionalLightsCount.x, unity_LightData.y));
  (u_xlatu15 = uint(int(u_xlat16_2.x)));
  (u_xlat16_2.xyz = u_xlat16_1.xyz);
  for (uint u_xlatu_loop_1 = 0u; (u_xlatu_loop_1 < u_xlatu15); (u_xlatu_loop_1++))
  {
    (u_xlatu8 = uint((u_xlatu_loop_1 >> 2u)));
    (u_xlati13 = int(uint((u_xlatu_loop_1 & 3u))));
    (u_xlat8.x = dot(unity_LightIndices[int(u_xlatu8)], ImmCB_0[u_xlati13]));
    (u_xlati8 = int(u_xlat8.x));
    (u_xlat4.xyz = (((-vs_TEXCOORD2.xyz) * _AdditionalLightsPosition[u_xlati8].www) + _AdditionalLightsPosition[u_xlati8].xyz));
    (u_xlat13 = dot(u_xlat4.xyz, u_xlat4.xyz));
    (u_xlat13 = max(u_xlat13, 6.1035156e-05));
    (u_xlat18 = inversesqrt(u_xlat13));
    (u_xlat4.xyz = (vec3(u_xlat18) * u_xlat4.xyz));
    (u_xlat18 = (1.0 / float(u_xlat13)));
    (u_xlat13 = ((u_xlat13 * _AdditionalLightsAttenuation[u_xlati8].x) + _AdditionalLightsAttenuation[u_xlati8].y));
    (u_xlat13 = clamp(u_xlat13, 0.0, 1.0));
    (u_xlat13 = (u_xlat13 * u_xlat18));
    (u_xlat16_17 = dot(_AdditionalLightsSpotDir[u_xlati8].xyz, u_xlat4.xyz));
    (u_xlat16_17 = ((u_xlat16_17 * _AdditionalLightsAttenuation[u_xlati8].z) + _AdditionalLightsAttenuation[u_xlati8].w));
    (u_xlat16_17 = clamp(u_xlat16_17, 0.0, 1.0));
    (u_xlat16_17 = (u_xlat16_17 * u_xlat16_17));
    (u_xlat13 = (u_xlat16_17 * u_xlat13));
    (u_xlat13 = min(u_xlat13, 0.0099999998));
    (u_xlat8.xyz = (vec3(u_xlat13) * _AdditionalLightsColor[u_xlati8].xyz));
    (u_xlat8.xyz = (u_xlat8.xyz * vec3(vec3(_MaxAddIntensity1, _MaxAddIntensity1, _MaxAddIntensity1))));
    (u_xlat16_2.xyz = ((u_xlat8.xyz * u_xlat16_0.xyz) + u_xlat16_2.xyz));
  }
  (u_xlat16_1.x = ((u_xlat16_1.x * _Color.w) + (-u_xlat16_1.w)));
  (SV_Target0.w = ((_AlphaIsR * u_xlat16_1.x) + u_xlat16_1.w));
  if ((_BlurPlaneShadowOn != 0))
  {
    (u_xlat0.x = (1.0 / float(vs_TEXCOORD5.w)));
    (u_xlat0.xy = (u_xlat0.xx * vs_TEXCOORD5.xy));
    (u_xlat16_0.x = texture(_PlaneBlurShadowMap, u_xlat0.xy).x);
    (u_xlat16_1.xyz = (u_xlat16_2.xyz * vec3(0.5, 0.5, 0.5)));
    (SV_Target0.xyz = ((u_xlat16_0.xxx * u_xlat16_1.xyz) + u_xlat16_1.xyz));
  }
  else
  {
    (SV_Target0.xyz = u_xlat16_2.xyz);
  }
  return ;
}
