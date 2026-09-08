#version 450
uniform vec4 _Time;
uniform vec2 _GlobalMipBias;
uniform vec4 _ZBufferParams;
layout(std140, binding = 0) uniform UnityPerMaterial{
  vec4 _FogNoiseMap_ST;
  vec4 _BlendMask_ST;
  vec4 _FogNoiseSpeed;
  vec4 _BlendColor;
  vec4 _FogColor;
  float _FogIntensity;
  float _FogFadeOff;
};
layout(location = 0) uniform sampler2D _FogNoiseMap;
layout(location = 1) uniform sampler2D _BlendMask;
layout(location = 2) uniform sampler2D _CameraDepthTexture;
in vec4 vs_TEXCOORD3;
in vec4 vs_TEXCOORD4;
layout(location = 0) out vec4 SV_Target0;
vec2 u_xlat0;
float u_xlat10_0;
vec3 u_xlat16_1;
vec2 u_xlat2;
float u_xlat16_2;
void main(){
  (u_xlat0.xy = (vs_TEXCOORD3.xy / vs_TEXCOORD3.ww));
  (u_xlat0.x = texture(_CameraDepthTexture, u_xlat0.xy, _GlobalMipBias.x).x);
  (u_xlat0.x = ((_ZBufferParams.z * u_xlat0.x) + _ZBufferParams.w));
  (u_xlat0.x = (1.0 / u_xlat0.x));
  (u_xlat0.x = (u_xlat0.x + (-vs_TEXCOORD3.w)));
  (u_xlat0.x = (u_xlat0.x / _FogFadeOff));
  (u_xlat2.xy = ((_Time.xx * _FogNoiseSpeed.xy) + vs_TEXCOORD4.xy));
  (u_xlat16_2 = texture(_FogNoiseMap, u_xlat2.xy).x);
  (u_xlat0.x = (u_xlat16_2 * u_xlat0.x));
  (u_xlat0.x = clamp(u_xlat0.x, 0.0, 1.0));
  (SV_Target0.w = u_xlat0.x);
  (u_xlat10_0 = texture(_BlendMask, vs_TEXCOORD4.zw).x);
  (u_xlat16_1.xyz = ((-_BlendColor.xyz) + _FogColor.xyz));
  (u_xlat16_1.xyz = ((vec3(u_xlat10_0) * u_xlat16_1.xyz) + _BlendColor.xyz));
  (SV_Target0.xyz = (u_xlat16_1.xyz * vec3(_FogIntensity)));
  return ;
}
