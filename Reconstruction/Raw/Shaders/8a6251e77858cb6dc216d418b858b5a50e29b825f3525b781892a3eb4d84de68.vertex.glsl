#version 330
in vec4 vertex;
uniform vec4 uvOffsetAndScale;
out vec2 texCoord;
void main(){
  (gl_Position = vec4(vertex.xy, 0.0, 1.0));
  (texCoord = ((vertex.zw * uvOffsetAndScale.zw) + uvOffsetAndScale.xy));
}
