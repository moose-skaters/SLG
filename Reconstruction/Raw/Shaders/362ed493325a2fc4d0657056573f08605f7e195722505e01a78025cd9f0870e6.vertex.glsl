#version 450
uniform vec4 _ScaleBiasRt;
in vec4 in_POSITION0;
in vec2 in_TEXCOORD0;
out vec2 vs_TEXCOORD0;
void main(){
  (gl_Position.y = (in_POSITION0.y * _ScaleBiasRt.x));
  (gl_Position.xz = in_POSITION0.xz);
  (gl_Position.w = 1.0);
  (vs_TEXCOORD0.xy = in_TEXCOORD0.xy);
  return ;
}
