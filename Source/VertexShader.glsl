// input
attribute vec4 position;
attribute vec4 sourceColor;
attribute vec4 normal;
// transforms
uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;
// output
varying vec4 destinationColor;
//varying float lightIntensity;

struct lightSource
{
    vec4 position;
    vec4 diffuse;
    vec4 specular;
    float constAtten, linAtten, quadAtten; // attenuation constants (light fall off)
    float spotCutOff, spotExponent;
    vec3 spotDirection;
};

lightSource light0 = lightSource(
    vec4(0.0, 1.0, -10.0, 1.0),
    vec4(1.0, 1.0, 1.0, 1.0),
    vec4(1.0, 1.0, 1.0, 1.0),
    0.5, 0.05, 0.0,
    180.0, 0.0,
    vec3(0.0, 0.0, -1.0));

vec4 scene_ambient = vec4(0.2, 0.2, 0.2, 1.0);

struct material
{
    vec4 ambient;
    vec4 diffuse;
    vec4 specular;
    float shininess;
};

material material0 = material(
      vec4(0.2, 0.2, 0.2, 1.0),
      vec4(0.5, 0.3, 0.3, 1.0),
      vec4(1.0, 1.0, 1.0, 1.0),
      0.5
      );

void main(void) {
    mat4 mvp = projection * view * model; // should be projection * view * model??
    vec3 normalDirection = normalize( -mvp * normal).xyz;
    vec3 viewDirection = normalize( vec3( -vec4(0.0, 0.0, 0.0, 1.0) - model * position));
    // lighting
    vec3 lightDirection;
    float attenuation;
    
    // Is it a point/spot light or a directional light?
    // can be optimized: http://en.wikibooks.org/wiki/GLSL_Programming/GLUT/Diffuse_Reflection
    if ( light0.position.w == 0.0) // directional
    {
        attenuation = 1.0; // no attenuation
        lightDirection = normalize(vec3(light0.position));
    }
    else
    {
        vec3 vertexToLightSource = vec3(light0.position - model * position);
        float distance = length(vertexToLightSource);
        attenuation = 1.0 / (light0.constAtten
                             + light0.linAtten * distance
                             + light0.quadAtten * distance * distance);
        lightDirection = normalize(vertexToLightSource);
        
        if ( light0.spotCutOff <= 90.0) // spotlight
        {
            float clampedCosine = max(0.0, dot(-lightDirection, normalize(light0.spotDirection)));
            if ( clampedCosine < cos(radians(light0.spotCutOff))) // outside of spotlight cone
            {
                attenuation = 0.0;
            }
            else
            {
                attenuation = attenuation * pow(clampedCosine, light0.spotExponent);
            }
        }
    }
    
    vec3 ambientLighting = vec3(scene_ambient) * vec3(material0.ambient);
    vec3 diffuseReflection = attenuation * vec3(light0.diffuse) * vec3(material0.diffuse)
        * max(0.0, dot(normalDirection, lightDirection));
    vec3 specularReflection;
    if ( dot(normalDirection, lightDirection) < 0.0) // light source on wrong side
    {
        specularReflection = vec3(0.0, 0.0, 0.0); // no specular reflection
    }
    else
    {
        specularReflection = attenuation * vec3(light0.specular) * vec3(material0.specular)
        * pow(max(0.0, dot(reflect(-lightDirection, normalDirection), viewDirection)),
              material0.shininess);
    }
    
    destinationColor = vec4(ambientLighting + diffuseReflection + specularReflection, 1.0);
    gl_Position = mvp * position;
}