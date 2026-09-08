#version 450
layout(std140, binding = 0) uniform UnityPerMaterial{
  vec4 _BaseColor;
  float _Cutoff;
  float _Surface;
  float _WidthOutLine;
  float _OutlineScale;
  float _OutlineWidth;
  float _CameraDistanceImpact;
  float _OutlineDepthOffset;
};
layout(location = 0) out vec4 SV_Target0;
void main(){
  (SV_Target0.xyz = _BaseColor.xyz);
  (SV_Target0.w = 1.0);
  return ;
}
