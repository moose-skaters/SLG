#version 330
#extension GL_ARB_gpu_shader5 : enable
#extension GL_EXT_gpu_shader5 : enable
in vec4 position;
in vec2 inCoord;
out vec2 outCoord;
uniform vec2 translation;
uniform vec2 scale;
uniform vec2 coordTranslation;
uniform vec2 coordScale;
void main(){
  (gl_Position.xy = ((position.xy * scale.xy) - translation.xy));
  (gl_Position.zw = position.zw);
  (outCoord = ((inCoord * coordScale) + coordTranslation));
}
