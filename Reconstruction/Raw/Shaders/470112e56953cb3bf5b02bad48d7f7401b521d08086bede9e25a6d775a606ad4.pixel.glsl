#version 450
uniform vec2 _GlobalMipBias;
uniform int unity_BaseInstanceID;
layout(std140, binding = 0) uniform UnityPerMaterial{
  vec4 _Bounds;
  vec4 _CircleCenter;
  vec4 _RendererColor;
  vec4 _Color;
  vec2 _Flip;
  float _Angle;
  float _Radius;
  float _Feather;
};
struct UnityPerInstanceArray_Type {
  float _Progress;
};
layout(std140, binding = 1) uniform UnityInstancing_UnityPerInstance{
  UnityPerInstanceArray_Type UnityPerInstanceArray[128];
};
layout(location = 0) uniform sampler2D _MainTex;
in vec4 vs_COLOR0;
in vec2 vs_TEXCOORD0;
in vec3 vs_TEXCOORD1;
flat in uint vs_SV_InstanceID0;
layout(location = 0) out vec4 SV_Target0;
vec4 u_xlat0;
vec4 u_xlat16_0;
int u_xlati0;
bool u_xlatb0;
vec2 u_xlat1;
float u_xlat16_2;
vec2 u_xlat3;
bool u_xlatb3;
bool u_xlatb4;
float u_xlat6;
bool u_xlatb6;
vec2 u_xlat7;
float u_xlat9;
bool u_xlatb9;
void main(){
  (u_xlati0 = (int(vs_SV_InstanceID0) + unity_BaseInstanceID));
  (u_xlat3.xy = (_Bounds.wz * vec2(0.0099999998, 0.0099999998)));
  (u_xlat1.xy = ((-u_xlat3.xy) * _Bounds.yx));
  (u_xlat7.xy = ((-_Bounds.yx) + vec2(1.0, 1.0)));
  (u_xlat16_2 = (1.0 + (-UnityPerInstanceArray[u_xlati0]._Progress)));
  (u_xlat16_2 = ((u_xlat16_2 * 360.0) + _Angle));
  (u_xlat0.xw = ((u_xlat3.xy * _Bounds.yx) + vs_TEXCOORD1.yx));
  (u_xlat3.xy = ((u_xlat3.xy * u_xlat7.xy) + (-u_xlat1.xy)));
  (u_xlat0.xy = (u_xlat0.xw / u_xlat3.xy));
  (u_xlat0.xy = ((u_xlat0.xy * vec2(2.0, 2.0)) + vec2(-1.0, -1.0)));
  (u_xlat6 = min(abs(u_xlat0.y), abs(u_xlat0.x)));
  (u_xlat9 = max(abs(u_xlat0.y), abs(u_xlat0.x)));
  (u_xlat9 = (1.0 / u_xlat9));
  (u_xlat6 = (u_xlat9 * u_xlat6));
  (u_xlat9 = (u_xlat6 * u_xlat6));
  (u_xlat1.x = ((u_xlat9 * 0.0208351) + -0.085133001));
  (u_xlat1.x = ((u_xlat9 * u_xlat1.x) + 0.180141));
  (u_xlat1.x = ((u_xlat9 * u_xlat1.x) + -0.3302995));
  (u_xlat9 = ((u_xlat9 * u_xlat1.x) + 0.99986601));
  (u_xlat1.x = (u_xlat9 * u_xlat6));
  (u_xlatb4 = (abs(u_xlat0.y) < abs(u_xlat0.x)));
  (u_xlat1.x = ((u_xlat1.x * -2.0) + 1.5707964));
  (u_xlat1.x = ((u_xlatb4) ? (u_xlat1.x) : (0.0)));
  (u_xlat6 = ((u_xlat6 * u_xlat9) + u_xlat1.x));
  (u_xlatb9 = (u_xlat0.y < (-u_xlat0.y)));
  (u_xlat9 = ((u_xlatb9) ? (-3.1415927) : (0.0)));
  (u_xlat6 = (u_xlat9 + u_xlat6));
  (u_xlat9 = min(u_xlat0.y, u_xlat0.x));
  (u_xlat0.x = max(u_xlat0.y, u_xlat0.x));
  (u_xlatb3 = (u_xlat9 < (-u_xlat9)));
  (u_xlatb0 = (u_xlat0.x >= (-u_xlat0.x)));
  (u_xlatb0 = (u_xlatb0 && u_xlatb3));
  (u_xlat0.x = ((u_xlatb0) ? ((-u_xlat6)) : (u_xlat6)));
  (u_xlat3.x = (u_xlat0.x * 57.299999));
  (u_xlatb6 = (u_xlat0.x < 0.0));
  (u_xlat0.x = ((u_xlat0.x * 57.299999) + 360.0));
  (u_xlat0.x = ((u_xlatb6) ? (u_xlat0.x) : (u_xlat3.x)));
  (u_xlatb3 = (u_xlat0.x >= _Angle));
  (u_xlatb6 = (u_xlat16_2 >= u_xlat0.x));
  (u_xlatb3 = (u_xlatb6 && u_xlatb3));
  if (u_xlatb3)
  {
    discard;
  }
  (u_xlat3.x = (u_xlat16_2 + -360.0));
  (u_xlat3.x = min(u_xlat3.x, 360.0));
  (u_xlatb3 = (u_xlat3.x >= u_xlat0.x));
  if (u_xlatb3)
  {
    discard;
  }
  (u_xlat3.x = (_Angle + 360.0));
  (u_xlat3.x = min(u_xlat3.x, 360.0));
  (u_xlatb0 = (u_xlat0.x >= u_xlat3.x));
  if (u_xlatb0)
  {
    discard;
  }
  (u_xlat16_0 = texture(_MainTex, vs_TEXCOORD0.xy, _GlobalMipBias.x));
  (u_xlat0 = (u_xlat16_0 * vs_COLOR0));
  (SV_Target0.xyz = (u_xlat0.www * u_xlat0.xyz));
  (SV_Target0.w = u_xlat0.w);
  return ;
}
