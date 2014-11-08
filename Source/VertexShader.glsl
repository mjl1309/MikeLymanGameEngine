attribute vec4 position;
attribute vec4 sourceColor;
attribute vec4 normal;

varying vec4 destinationColor;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

varying float lightIntensity;
uniform vec3 lightDirection;


void main(void) {
    vec4 newNormal = projection * model * view * normal;
    destinationColor = sourceColor;
    gl_Position = projection * model * view * position;
    lightIntensity = max(0.0, dot(newNormal.xyz, lightDirection));
}