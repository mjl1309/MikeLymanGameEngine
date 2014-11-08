// input
attribute vec4 position;
attribute vec4 sourceColor;
attribute vec4 normal;
// transforms
uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;
// lighting
uniform vec3 lightDirection;
// output
varying vec4 destinationColor;
//varying float lightIntensity;

struct lightSource
{
    vec4 position;
    vec4 diffuse;
    float constAtten, linAtten, quadAtten; // attenuation constants (light fall off)
};

lightSource light0 = lightSource(
    vec4(0.0, 0.0, -15.0, 1.0),
    vec4(1.0, 1.0, 1.0, 1.0),
                                 0.5, 0.05, 0.00);

struct material
{
    vec4 diffuse;
};

material material0 = material(vec4(vec4(1.0, 1.0, 1.0, 1.0)));

void main(void) {
    mat4 mvp = projection * view * model; // should be projection * view * model??
    vec4 normalDirection = normalize( -mvp * normal);

    // lighting
    vec3 lightDir;
    float attenuation;
    // Is it a point/spot light or a directional light?
    // can be optimized: http://en.wikibooks.org/wiki/GLSL_Programming/GLUT/Diffuse_Reflection
    if ( light0.position.w == 0.0) // directional
    {
        attenuation = 1.0; // no attenuation
        lightDir = normalize(vec3(light0.position));
    }
    else
    {
        vec3 vertexToLightSource = vec3(light0.position - model * position);
        float distance = length(vertexToLightSource);
        attenuation = 1.0 / (light0.constAtten
                             + light0.linAtten * distance
                             + light0.quadAtten * distance * distance);
        lightDir = normalize(vertexToLightSource);
    }
    
    vec3 diffuseReflection = attenuation * vec3(light0.diffuse) * vec3(material0.diffuse)
    * max(0.0, dot(vec3(normalDirection), lightDir));
    
    destinationColor = vec4(diffuseReflection, 1.0);
    gl_Position = mvp * position;
}