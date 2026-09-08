#version 330
#extension GL_ARB_gpu_shader5 : enable
#extension GL_EXT_gpu_shader5 : enable
in vec4 texCoords;
out vec2 outTexCoords;
in vec4 position;
uniform mat4 projection;
uniform mat4 _utexture;
void main(){
  (gl_Position = (projection * position));
  (outTexCoords = (_utexture * texCoords).xy);
}
