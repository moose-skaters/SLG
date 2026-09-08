#version 330
#extension GL_ARB_gpu_shader5 : enable
#extension GL_EXT_gpu_shader5 : enable
out vec4 webgl_FragColor;
in vec2 outCoord;
uniform sampler2D tex;
void main(){
  (webgl_FragColor = texture(tex, outCoord));
}
