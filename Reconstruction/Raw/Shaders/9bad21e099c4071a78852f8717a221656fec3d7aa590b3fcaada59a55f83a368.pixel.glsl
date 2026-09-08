#version 450
vec4 ImmCB_0[4];
uniform vec4 _MainLightPosition;
uniform vec4 _AdditionalLightsCount;
uniform vec4 _AdditionalLightsPosition[32];
uniform vec4 _AdditionalLightsColor[32];
uniform vec4 _AdditionalLightsAttenuation[32];
uniform vec4 _AdditionalLightsSpotDir[32];
uniform vec4 _Time;
uniform vec3 _WorldSpaceCameraPos;
uniform float _Timeline;
uniform vec4 _LightColor1;
uniform vec4 _LightColor2;
uniform float _LightIntensity1;
uniform float _LightIntensity2;
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
  vec4 _MainTex_ST;
  vec4 _EmissionColor;
  vec4 _Color;
  vec4 _Fresnel_Color;
  vec4 _Fresnel_Color_Edge;
  vec4 _GPUSKin_TextureSize;
  vec4 _ShadowColor;
  float _VertexOffsetY;
  float _MainLightOn;
  float _MaxAddIntensity1;
  float _EmissionIntensity;
  float _Fresnel_Bisa;
  float _Fresnel_Scale;
  float _Fresnel_Intensity;
  float _CutOff;
  float _AlphaIsR;
  float _Intensity;
  float _NoMainTextureOn;
  float _HeroDayNight_ON;
  float _EMISSIONMAPON_BUILDING_ON;
  float _FadeY;
  float _AlphFadeY_ON;
  float _Fresnel_Scale_Edge;
  float _EMISSIONMAPON_ON;
  float _BlinnPhongOn;
  float _Fresnel_ON;
  float _SheetAnimationON;
  float _MainTexSheetAnimSpeed;
  vec4 _MainTexSheet;
};
layout(location = 0) uniform sampler2D _MainTex;
layout(location = 1) uniform sampler2D _EmissionMap;
in vec2 vs_TEXCOORD0;
in vec3 vs_TEXCOORD1;
in vec4 vs_TEXCOORD2;
in vec3 vs_TEXCOORD3;
layout(location = 0) out vec4 SV_Target0;
vec2 u_xlat0;
vec3 u_xlat10_0;
ivec3 u_xlati0;
bool u_xlatb0;
vec4 u_xlat16_1;
vec4 u_xlat16_2;
vec4 u_xlat16_3;
vec3 u_xlat16_4;
vec4 u_xlat5;
int u_xlati5;
uint u_xlatu5;
bvec3 u_xlatb5;
vec3 u_xlat6;
vec3 u_xlat16_7;
float u_xlat8;
bool u_xlatb8;
vec2 u_xlat16_10;
vec2 u_xlat16;
uint u_xlatu16;
bool u_xlatb16;
float u_xlat16_18;
vec2 u_xlat16_19;
float u_xlat16_26;
float u_xlat16_27;
float u_xlat29;
int u_xlati29;
float u_xlat30;
void main(){
  (ImmCB_0[0] = vec4(1.0, 0.0, 0.0, 0.0));
  (ImmCB_0[1] = vec4(0.0, 1.0, 0.0, 0.0));
  (ImmCB_0[2] = vec4(0.0, 0.0, 1.0, 0.0));
  (ImmCB_0[3] = vec4(0.0, 0.0, 0.0, 1.0));
  (u_xlatb0 = (vec4(0.0, 0.0, 0.0, 0.0) != vec4(_SheetAnimationON)));
  if (u_xlatb0)
  {
    (u_xlat0.x = (_Time.y * _MainTexSheetAnimSpeed));
    (u_xlat16_1.x = (_MainTexSheet.y * _MainTexSheet.x));
    (u_xlat8 = trunc(u_xlat16_1.x));
    (u_xlat16.x = (u_xlat8 * u_xlat0.x));
    (u_xlatb16 = (u_xlat16.x >= (-u_xlat16.x)));
    (u_xlat8 = ((u_xlatb16) ? (u_xlat8) : ((-u_xlat8))));
    (u_xlat16.x = (1.0 / u_xlat8));
    (u_xlat0.x = (u_xlat16.x * u_xlat0.x));
    (u_xlat0.x = fract(u_xlat0.x));
    (u_xlat0.x = (u_xlat0.x * u_xlat8));
    (u_xlat8 = (u_xlat0.x * _MainTexSheet.x));
    (u_xlatb8 = (u_xlat8 >= (-u_xlat8)));
    (u_xlat8 = ((u_xlatb8) ? (_MainTexSheet.x) : ((-_MainTexSheet.x))));
    (u_xlat16.x = (1.0 / u_xlat8));
    (u_xlat16.x = (u_xlat16.x * u_xlat0.x));
    (u_xlat16.x = fract(u_xlat16.x));
    (u_xlat8 = (u_xlat16.x * u_xlat8));
    (u_xlati0.z = int(u_xlat8));
    (u_xlat0.x = (u_xlat0.x / _MainTexSheet.x));
    (u_xlat16_1.x = trunc(u_xlat0.x));
    (u_xlat16_1.x = ((-u_xlat16_1.x) + _MainTexSheet.y));
    (u_xlat16_1.x = (u_xlat16_1.x + -1.0));
    (u_xlati0.x = int(u_xlat16_1.x));
    (u_xlat16_2 = (vec4(1.0, 1.0, 1.0, 1.0) / _MainTexSheet.xyxy));
    (u_xlat16_3.x = trunc(u_xlat8));
    (u_xlat16_3.y = trunc(u_xlat16_1.x));
    (u_xlati0.xy = (u_xlati0.xz + ivec2(1, 1)));
    (u_xlat16_19.xy = vec2(u_xlati0.yx));
    (u_xlat16_1.xy = (u_xlat16_2.xy * u_xlat16_3.xy));
    (u_xlat0.xy = ((u_xlat16_19.xy * u_xlat16_2.zw) + (-u_xlat16_1.xy)));
    (u_xlat0.xy = ((vs_TEXCOORD0.xy * u_xlat0.xy) + u_xlat16_1.xy));
  }
  else
  {
    (u_xlat0.xy = vs_TEXCOORD0.xy);
  }
  (u_xlat16.xy = ((u_xlat0.xy * _MainTex_ST.xy) + _MainTex_ST.zw));
  (u_xlat16_1 = texture(_MainTex, u_xlat16.xy));
  (u_xlat16_2.xyz = ((-u_xlat16_1.xyz) + vec3(1.0, 1.0, 1.0)));
  (u_xlat16_2.xyz = ((vec3(vec3(_NoMainTextureOn, _NoMainTextureOn, _NoMainTextureOn)) * u_xlat16_2.xyz) + u_xlat16_1.xyz));
  (u_xlat16_26 = (u_xlat16_1.w + (-_CutOff)));
  (u_xlatb16 = (u_xlat16_26 < 0.0));
  if (u_xlatb16)
  {
    discard;
  }
  (u_xlat16_3 = (_Color * vec4(vec4(_Intensity, _Intensity, _Intensity, _Intensity))));
  (u_xlat16_2.xyz = (u_xlat16_2.xyz * u_xlat16_3.xyz));
  (u_xlat16_26 = (u_xlat16_1.w * u_xlat16_3.w));
  (u_xlat16_3.xyz = (_LightColor1.xyz * vec3(_LightIntensity1)));
  (u_xlat16_4.xyz = ((_LightColor2.xyz * vec3(vec3(_LightIntensity2, _LightIntensity2, _LightIntensity2))) + (-u_xlat16_3.xyz)));
  (u_xlat16_3.xyz = ((vec3(vec3(_HeroDayNight_ON, _HeroDayNight_ON, _HeroDayNight_ON)) * u_xlat16_4.xyz) + u_xlat16_3.xyz));
  (u_xlat16_3.xyz = (u_xlat16_2.xyz * u_xlat16_3.xyz));
  (u_xlatb5.xyz = lessThan(vec4(0.5, 0.5, 0.5, 0.0), vec4(_BlinnPhongOn, _Fresnel_ON, _EMISSIONMAPON_ON, _BlinnPhongOn)).xyz);
  (u_xlat16_27 = dot(_MainLightPosition.xyz, vs_TEXCOORD1.xyz));
  (u_xlat16_27 = clamp(u_xlat16_27, 0.0, 1.0));
  (u_xlat16_4.xyz = (vec3(u_xlat16_27) * u_xlat16_3.xyz));
  (u_xlat16_3.xyz = ((u_xlatb5.x) ? (u_xlat16_4.xyz) : (u_xlat16_3.xyz)));
  (u_xlat16_27 = min(_AdditionalLightsCount.x, unity_LightData.y));
  (u_xlatu16 = uint(int(u_xlat16_27)));
  (u_xlat16_4.xyz = u_xlat16_3.xyz);
  for (uint u_xlatu_loop_1 = 0u; (u_xlatu_loop_1 < u_xlatu16); (u_xlatu_loop_1++))
  {
    (u_xlatu5 = uint((u_xlatu_loop_1 >> 2u)));
    (u_xlati29 = int(uint((u_xlatu_loop_1 & 3u))));
    (u_xlat5.x = dot(unity_LightIndices[int(u_xlatu5)], ImmCB_0[u_xlati29]));
    (u_xlati5 = int(u_xlat5.x));
    (u_xlat6.xyz = (((-vs_TEXCOORD2.xyz) * _AdditionalLightsPosition[u_xlati5].www) + _AdditionalLightsPosition[u_xlati5].xyz));
    (u_xlat29 = dot(u_xlat6.xyz, u_xlat6.xyz));
    (u_xlat29 = max(u_xlat29, 6.1035156e-05));
    (u_xlat30 = inversesqrt(u_xlat29));
    (u_xlat6.xyz = (vec3(u_xlat30) * u_xlat6.xyz));
    (u_xlat30 = (1.0 / float(u_xlat29)));
    (u_xlat29 = ((u_xlat29 * _AdditionalLightsAttenuation[u_xlati5].x) + _AdditionalLightsAttenuation[u_xlati5].y));
    (u_xlat29 = clamp(u_xlat29, 0.0, 1.0));
    (u_xlat29 = (u_xlat29 * u_xlat30));
    (u_xlat16_27 = dot(_AdditionalLightsSpotDir[u_xlati5].xyz, u_xlat6.xyz));
    (u_xlat16_27 = ((u_xlat16_27 * _AdditionalLightsAttenuation[u_xlati5].z) + _AdditionalLightsAttenuation[u_xlati5].w));
    (u_xlat16_27 = clamp(u_xlat16_27, 0.0, 1.0));
    (u_xlat16_27 = (u_xlat16_27 * u_xlat16_27));
    (u_xlat29 = (u_xlat16_27 * u_xlat29));
    (u_xlat29 = min(u_xlat29, 0.0099999998));
    (u_xlat6.xyz = (vec3(u_xlat29) * _AdditionalLightsColor[u_xlati5].xyz));
    (u_xlat6.xyz = (u_xlat6.xyz * vec3(vec3(_MaxAddIntensity1, _MaxAddIntensity1, _MaxAddIntensity1))));
    (u_xlat16_4.xyz = ((u_xlat6.xyz * u_xlat16_1.xyz) + u_xlat16_4.xyz));
  }
  (u_xlat16_3.xyz = (u_xlat16_2.xyz * vs_TEXCOORD3.xyz));
  (u_xlat16_3.xyz = ((vec3(vec3(_BlinnPhongOn, _BlinnPhongOn, _BlinnPhongOn)) * u_xlat16_3.xyz) + u_xlat16_4.xyz));
  if (u_xlatb5.y)
  {
    (u_xlat5.xyw = ((-vs_TEXCOORD2.xyz) + _WorldSpaceCameraPos.xyz));
    (u_xlat16.x = dot(u_xlat5.xyw, u_xlat5.xyw));
    (u_xlat16.x = inversesqrt(u_xlat16.x));
    (u_xlat5.xyw = (u_xlat16.xxx * u_xlat5.xyw));
    (u_xlat16_10.x = dot(vs_TEXCOORD1.xyz, u_xlat5.xyw));
    (u_xlat16_10.x = clamp(u_xlat16_10.x, 0.0, 1.0));
    (u_xlat16_10.x = ((-u_xlat16_10.x) + 1.0));
    (u_xlat16_18 = (u_xlat16_10.x * u_xlat16_10.x));
    (u_xlat16_10.x = (u_xlat16_10.x * u_xlat16_18));
    (u_xlat16_18 = (u_xlat16_10.x * u_xlat16_18));
    (u_xlat16_10.y = ((_Fresnel_Scale * u_xlat16_18) + _Fresnel_Bisa));
    (u_xlat16_10.x = (u_xlat16_10.x * _Fresnel_Scale_Edge));
    (u_xlat16_10.xy = (u_xlat16_10.xy * vec2(vec2(_Fresnel_Intensity, _Fresnel_Intensity))));
    (u_xlat16_4.xyz = (u_xlat16_10.xxx * _Fresnel_Color_Edge.xyz));
    (u_xlat16_4.xyz = ((_Fresnel_Color.xyz * u_xlat16_10.yyy) + u_xlat16_4.xyz));
    (u_xlat16_3.xyz = (u_xlat16_3.xyz + u_xlat16_4.xyz));
  }
  if (u_xlatb5.z)
  {
    (u_xlat10_0.xyz = texture(_EmissionMap, u_xlat0.xy).xyz);
    (u_xlat16_4.xyz = (u_xlat10_0.xyz * _EmissionColor.xyz));
    (u_xlat16_7.xyz = (u_xlat16_4.xyz * vec3(vec3(_EmissionIntensity, _EmissionIntensity, _EmissionIntensity))));
    (u_xlat16_10.x = ((_Timeline * (-_EmissionIntensity)) + _EmissionIntensity));
    (u_xlat16_4.xyz = ((u_xlat16_4.xyz * u_xlat16_10.xxx) + (-u_xlat16_7.xyz)));
    (u_xlat16_4.xyz = ((vec3(_EMISSIONMAPON_BUILDING_ON) * u_xlat16_4.xyz) + u_xlat16_7.xyz));
    (SV_Target0.xyz = (u_xlat16_3.xyz + u_xlat16_4.xyz));
  }
  else
  {
    (SV_Target0.xyz = u_xlat16_3.xyz);
  }
  (u_xlat16_10.x = (u_xlat16_26 * _Color.w));
  (u_xlat16_2.x = ((u_xlat16_2.x * _Color.w) + (-u_xlat16_10.x)));
  (u_xlat16_2.x = ((_AlphaIsR * u_xlat16_2.x) + u_xlat16_10.x));
  (u_xlatb0 = (vs_TEXCOORD2.y >= _FadeY));
  (u_xlat0.x = ((u_xlatb0) ? (1.0) : (0.0)));
  (u_xlat16_10.x = ((u_xlat0.x * u_xlat16_2.x) + (-u_xlat16_2.x)));
  (SV_Target0.w = ((_AlphFadeY_ON * u_xlat16_10.x) + u_xlat16_2.x));
  return ;
}
