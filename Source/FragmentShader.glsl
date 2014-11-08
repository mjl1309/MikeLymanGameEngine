varying lowp vec4 destinationColor;
varying highp float lightIntensity;

void main(void) {
//    lowp vec4 yellow = vec4(1.0, 1.0, 0.0, 1.0);
    gl_FragColor = vec4((destinationColor * lightIntensity * 1.0).rgb, 1.0);
//    gl_FragColor = destinationColor;
}