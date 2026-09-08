#version 330
#extension GL_ARB_gpu_shader5 : enable
#extension GL_EXT_gpu_shader5 : enable
out vec4 webgl_FragColor;
uniform sampler2D sampler;
in vec2 outTexCoords;
void main(){
  (webgl_FragColor = texture(sampler, outTexCoords));
  (webgl_FragColor.w = 1.0);
}
