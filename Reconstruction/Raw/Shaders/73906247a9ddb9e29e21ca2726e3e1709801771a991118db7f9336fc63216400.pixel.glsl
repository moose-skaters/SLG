#version 450
uniform vec2 _GlobalMipBias;
uniform vec4 _Lut_Params;
uniform vec4 _UserLut_Params;
uniform vec4 _Bloom_Params;
uniform float _Bloom_RGBM;
uniform vec4 _Vignette_Params1;
uniform vec4 _Vignette_Params2;
layout(location = 0) uniform sampler2D _SourceTex;
layout(location = 1) uniform sampler2D _Bloom_Texture;
layout(location = 2) uniform sampler2D _InternalLut;
layout(location = 3) uniform sampler2D _UserLut;
in vec2 vs_TEXCOORD0;
layout(location = 0) out vec4 SV_Target0;
vec4 u_xlat10_0;
vec3 u_xlat1;
vec4 u_xlat10_1;
bool u_xlatb1;
vec3 u_xlat2;
vec3 u_xlat16_2;
bool u_xlatb2;
vec3 u_xlat16_3;
vec3 u_xlat4;
vec3 u_xlat16_4;
vec4 u_xlat5;
vec3 u_xlat10_5;
vec2 u_xlat6;
vec3 u_xlat10_6;
vec2 u_xlat7;
vec3 u_xlat16_8;
vec3 u_xlat10_10;
float u_xlat28;
bool u_xlatb28;
void main(){
  (u_xlat10_0 = texture(_SourceTex, vs_TEXCOORD0.xy, _GlobalMipBias.x));
  (u_xlat10_1 = texture(_Bloom_Texture, vs_TEXCOORD0.xy, _GlobalMipBias.x));
  (u_xlatb2 = (0.0 < _Bloom_RGBM));
  if (u_xlatb2)
  {
    (u_xlat16_3.xyz = (u_xlat10_1.www * u_xlat10_1.xyz));
    (u_xlat2.xyz = (u_xlat16_3.xyz * vec3(8.0, 8.0, 8.0)));
    (u_xlat16_2.xyz = u_xlat2.xyz);
  }
  else
  {
    (u_xlat16_2.xyz = u_xlat10_1.xyz);
  }
  (u_xlat1.xyz = (u_xlat16_2.xyz * _Bloom_Params.xxx));
  (u_xlat1.xyz = ((u_xlat1.xyz * _Bloom_Params.yzw) + u_xlat10_0.xyz));
  (u_xlatb28 = (0.0 < _Vignette_Params2.z));
  if (u_xlatb28)
  {
    (u_xlat4.xy = (vs_TEXCOORD0.xy + (-_Vignette_Params2.xy)));
    (u_xlat4.yz = (abs(u_xlat4.xy) * _Vignette_Params2.zz));
    (u_xlat4.x = (u_xlat4.y * _Vignette_Params1.w));
    (u_xlat28 = dot(u_xlat4.xz, u_xlat4.xz));
    (u_xlat28 = ((-u_xlat28) + 1.0));
    (u_xlat28 = max(u_xlat28, 0.0));
    (u_xlat28 = log2(u_xlat28));
    (u_xlat28 = (u_xlat28 * _Vignette_Params2.w));
    (u_xlat28 = exp2(u_xlat28));
    (u_xlat4.xyz = ((-_Vignette_Params1.xyz) + vec3(1.0, 1.0, 1.0)));
    (u_xlat4.xyz = ((vec3(u_xlat28) * u_xlat4.xyz) + _Vignette_Params1.xyz));
    (u_xlat4.xyz = (u_xlat1.xyz * u_xlat4.xyz));
    (u_xlat16_4.xyz = u_xlat4.xyz);
  }
  else
  {
    (u_xlat16_4.xyz = u_xlat1.xyz);
  }
  (u_xlat16_3.xyz = (u_xlat16_4.xyz * _Lut_Params.www));
  (u_xlat16_3.xyz = clamp(u_xlat16_3.xyz, 0.0, 1.0));
  (u_xlatb1 = (0.0 < _UserLut_Params.w));
  if (u_xlatb1)
  {
    (u_xlat1.xyz = log2(u_xlat16_3.xyz));
    (u_xlat1.xyz = (u_xlat1.xyz * vec3(0.41666666, 0.41666666, 0.41666666)));
    (u_xlat1.xyz = exp2(u_xlat1.xyz));
    (u_xlat1.xyz = ((u_xlat1.xyz * vec3(1.0549999, 1.0549999, 1.0549999)) + vec3(-0.055, -0.055, -0.055)));
    (u_xlat1.xyz = max(u_xlat1.xyz, vec3(0.0, 0.0, 0.0)));
    (u_xlat5.xyz = (u_xlat1.zxy * _UserLut_Params.zzz));
    (u_xlat28 = floor(u_xlat5.x));
    (u_xlat5.xw = (_UserLut_Params.xy * vec2(0.5, 0.5)));
    (u_xlat5.yz = ((u_xlat5.yz * _UserLut_Params.xy) + u_xlat5.xw));
    (u_xlat5.x = ((u_xlat28 * _UserLut_Params.y) + u_xlat5.y));
    (u_xlat10_6.xyz = textureLod(_UserLut, u_xlat5.xz, 0.0).xyz);
    (u_xlat7.x = _UserLut_Params.y);
    (u_xlat7.y = 0.0);
    (u_xlat5.xy = (u_xlat5.xz + u_xlat7.xy));
    (u_xlat10_5.xyz = textureLod(_UserLut, u_xlat5.xy, 0.0).xyz);
    (u_xlat28 = ((u_xlat1.z * _UserLut_Params.z) + (-u_xlat28)));
    (u_xlat5.xyz = ((-u_xlat10_6.xyz) + u_xlat10_5.xyz));
    (u_xlat5.xyz = ((vec3(u_xlat28) * u_xlat5.xyz) + u_xlat10_6.xyz));
    (u_xlat5.xyz = ((-u_xlat1.xyz) + u_xlat5.xyz));
    (u_xlat1.xyz = ((_UserLut_Params.www * u_xlat5.xyz) + u_xlat1.xyz));
    (u_xlat16_8.xyz = ((u_xlat1.xyz * vec3(0.30530602, 0.30530602, 0.30530602)) + vec3(0.68217111, 0.68217111, 0.68217111)));
    (u_xlat16_8.xyz = ((u_xlat1.xyz * u_xlat16_8.xyz) + vec3(0.012522878, 0.012522878, 0.012522878)));
    (u_xlat16_3.xyz = (u_xlat1.xyz * u_xlat16_8.xyz));
  }
  (u_xlat1.xyz = (u_xlat16_3.zxy * _Lut_Params.zzz));
  (u_xlat1.x = floor(u_xlat1.x));
  (u_xlat5.xy = (_Lut_Params.xy * vec2(0.5, 0.5)));
  (u_xlat5.yz = ((u_xlat1.yz * _Lut_Params.xy) + u_xlat5.xy));
  (u_xlat5.x = ((u_xlat1.x * _Lut_Params.y) + u_xlat5.y));
  (u_xlat10_10.xyz = textureLod(_InternalLut, u_xlat5.xz, 0.0).xyz);
  (u_xlat6.x = _Lut_Params.y);
  (u_xlat6.y = 0.0);
  (u_xlat5.xy = (u_xlat5.xz + u_xlat6.xy));
  (u_xlat10_5.xyz = textureLod(_InternalLut, u_xlat5.xy, 0.0).xyz);
  (u_xlat1.x = ((u_xlat16_3.z * _Lut_Params.z) + (-u_xlat1.x)));
  (u_xlat5.xyz = ((-u_xlat10_10.xyz) + u_xlat10_5.xyz));
  (u_xlat10_0.xyz = ((u_xlat1.xxx * u_xlat5.xyz) + u_xlat10_10.xyz));
  (SV_Target0 = u_xlat10_0);
  return ;
}
