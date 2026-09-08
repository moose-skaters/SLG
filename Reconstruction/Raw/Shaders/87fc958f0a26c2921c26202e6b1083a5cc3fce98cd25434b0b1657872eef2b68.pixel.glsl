#version 450
uniform vec4 _TextureSampleAdd;
uniform vec4 _ClipRect;
uniform float _Grey_ON;
layout(location = 0) uniform sampler2D _MainTex;
in vec4 vs_COLOR0;
in vec2 vs_TEXCOORD0;
in vec4 vs_TEXCOORD1;
layout(location = 0) out vec4 SV_Target0;
vec4 u_xlat0;
bvec4 u_xlatb0;
vec4 u_xlat1;
vec4 u_xlat16_1;
vec4 u_xlat2;
vec3 u_xlat16_3;
void main(){
  (u_xlatb0.xy = greaterThanEqual(vs_TEXCOORD1.xyxx, _ClipRect.xyxx).xy);
  (u_xlatb0.zw = greaterThanEqual(_ClipRect.zzzw, vs_TEXCOORD1.xxxy).zw);
  (u_xlat0.x = ((u_xlatb0.x) ? (1.0) : (0.0)));
  (u_xlat0.y = ((u_xlatb0.y) ? (1.0) : (0.0)));
  (u_xlat0.z = ((u_xlatb0.z) ? (1.0) : (0.0)));
  (u_xlat0.w = ((u_xlatb0.w) ? (1.0) : (0.0)));
  (u_xlat0.xy = (u_xlat0.zw * u_xlat0.xy));
  (u_xlat0.x = (u_xlat0.y * u_xlat0.x));
  (u_xlat16_1 = texture(_MainTex, vs_TEXCOORD0.xy));
  (u_xlat2.xyz = ((u_xlat16_1.xyz * u_xlat16_1.www) + _TextureSampleAdd.xyz));
  (u_xlat2.w = (u_xlat16_1.w + _TextureSampleAdd.w));
  (u_xlat1 = (u_xlat2 * vs_COLOR0));
  (u_xlat2 = (u_xlat0.xxxx * u_xlat1));
  (u_xlat16_3.x = (u_xlat2.y + u_xlat2.x));
  (u_xlat16_3.x = ((u_xlat1.z * u_xlat0.x) + u_xlat16_3.x));
  (u_xlat16_3.xyz = ((u_xlat16_3.xxx * vec3(0.33333334, 0.33333334, 0.33333334)) + (-u_xlat2.xyz)));
  (SV_Target0.xyz = ((vec3(_Grey_ON) * u_xlat16_3.xyz) + u_xlat2.xyz));
  (SV_Target0.w = u_xlat2.w);
  return ;
}
