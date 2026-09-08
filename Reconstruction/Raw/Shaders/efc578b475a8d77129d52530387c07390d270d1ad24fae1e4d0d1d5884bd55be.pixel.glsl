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
layout(location = 0) uniform sampler2D _MainTex1;
layout(location = 1) uniform sampler2D _PlaneBlurShadowMap;
in vec2 vs_TEXCOORD0;
in vec4 vs_TEXCOORD2;
in vec4 vs_TEXCOORD5;
layout(location = 0) out vec4 SV_Target0;
vec2 u_xlat0;
float u_xlat16_0;
vec4 u_xlat10_0;
vec3 u_xlat16_1;
uint u_xlatu2;
vec3 u_xlat16_3;
vec3 u_xlat4;
float u_xlat16_6;
float u_xlat12;
int u_xlati12;
uint u_xlatu12;
float u_xlat16_16;
float u_xlat17;
int u_xlati17;
float u_xlat19;
void main(){
  (ImmCB_0[0] = vec4(1.0, 0.0, 0.0, 0.0));
  (ImmCB_0[1] = vec4(0.0, 1.0, 0.0, 0.0));
  (ImmCB_0[2] = vec4(0.0, 0.0, 1.0, 0.0));
  (ImmCB_0[3] = vec4(0.0, 0.0, 0.0, 1.0));
  (u_xlat10_0 = texture(_MainTex1, vs_TEXCOORD0.xy));
  (u_xlat16_1.xyz = (u_xlat10_0.xyz * _Color1.xyz));
  (u_xlat16_16 = min(_AdditionalLightsCount.x, unity_LightData.y));
  (u_xlatu2 = uint(int(u_xlat16_16)));
  (u_xlat16_3.xyz = u_xlat16_1.xyz);
  for (uint u_xlatu_loop_1 = 0u; (u_xlatu_loop_1 < u_xlatu2); (u_xlatu_loop_1++))
  {
    (u_xlatu12 = uint((u_xlatu_loop_1 >> 2u)));
    (u_xlati17 = int(uint((u_xlatu_loop_1 & 3u))));
    (u_xlat12 = dot(unity_LightIndices[int(u_xlatu12)], ImmCB_0[u_xlati17]));
    (u_xlati12 = int(u_xlat12));
    (u_xlat4.xyz = (((-vs_TEXCOORD2.xyz) * _AdditionalLightsPosition[u_xlati12].www) + _AdditionalLightsPosition[u_xlati12].xyz));
    (u_xlat17 = dot(u_xlat4.xyz, u_xlat4.xyz));
    (u_xlat17 = max(u_xlat17, 6.1035156e-05));
    (u_xlat19 = inversesqrt(u_xlat17));
    (u_xlat4.xyz = (vec3(u_xlat19) * u_xlat4.xyz));
    (u_xlat19 = (1.0 / float(u_xlat17)));
    (u_xlat17 = ((u_xlat17 * _AdditionalLightsAttenuation[u_xlati12].x) + _AdditionalLightsAttenuation[u_xlati12].y));
    (u_xlat17 = clamp(u_xlat17, 0.0, 1.0));
    (u_xlat17 = (u_xlat17 * u_xlat19));
    (u_xlat16_16 = dot(_AdditionalLightsSpotDir[u_xlati12].xyz, u_xlat4.xyz));
    (u_xlat16_16 = ((u_xlat16_16 * _AdditionalLightsAttenuation[u_xlati12].z) + _AdditionalLightsAttenuation[u_xlati12].w));
    (u_xlat16_16 = clamp(u_xlat16_16, 0.0, 1.0));
    (u_xlat16_16 = (u_xlat16_16 * u_xlat16_16));
    (u_xlat17 = (u_xlat16_16 * u_xlat17));
    (u_xlat17 = min(u_xlat17, 0.0099999998));
    (u_xlat4.xyz = (vec3(u_xlat17) * _AdditionalLightsColor[u_xlati12].xyz));
    (u_xlat4.xyz = (u_xlat4.xyz * vec3(vec3(_MaxAddIntensity1, _MaxAddIntensity1, _MaxAddIntensity1))));
    (u_xlat16_3.xyz = ((u_xlat4.xyz * u_xlat10_0.xyz) + u_xlat16_3.xyz));
  }
  (u_xlat16_6 = (u_xlat10_0.w * _Color.w));
  (u_xlat16_1.x = ((u_xlat16_1.x * _Color.w) + (-u_xlat16_6)));
  (SV_Target0.w = ((_AlphaIsR * u_xlat16_1.x) + u_xlat16_6));
  if ((_BlurPlaneShadowOn != 0))
  {
    (u_xlat0.x = (1.0 / float(vs_TEXCOORD5.w)));
    (u_xlat0.xy = (u_xlat0.xx * vs_TEXCOORD5.xy));
    (u_xlat16_0 = texture(_PlaneBlurShadowMap, u_xlat0.xy).x);
    (u_xlat16_1.xyz = (u_xlat16_3.xyz * vec3(0.5, 0.5, 0.5)));
    (SV_Target0.xyz = ((vec3(u_xlat16_0) * u_xlat16_1.xyz) + u_xlat16_1.xyz));
  }
  else
  {
    (SV_Target0.xyz = u_xlat16_3.xyz);
  }
  return ;
}
