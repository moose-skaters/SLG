#version 450
uniform vec2 _GlobalMipBias;
layout(location = 0) uniform sampler2D _CameraDepthAttachment;
in vec2 vs_TEXCOORD0;
float u_xlat0;
void main(){
  (u_xlat0 = texture(_CameraDepthAttachment, vs_TEXCOORD0.xy, _GlobalMipBias.x).x);
  (gl_FragDepth = u_xlat0);
  return ;
}
