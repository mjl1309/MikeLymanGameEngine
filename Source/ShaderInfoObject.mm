//
//  ShaderInfoObject.mm
//  MikeLymanGameEngine
//
//  Created by Mike Lyman on 8/17/14.
//  Copyright (c) 2014 Mike Lyman. All rights reserved.
//

#import "ShaderInfoObject.h"

@implementation ShaderInfoObject

- (id)init {
    self = [super init];
    if ( self ) {
        self.shaderUniform = [self compileShaders];
    }
    return self;
}

- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"glsl"];
    NSError* error;
    NSString* shaderProgramString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if ( !shaderProgramString ) {
        NSLog( @"Error loading shader: %@", error.localizedDescription );
        exit(1);
    }
    GLuint shaderHandle = glCreateShader( shaderType );
    const char *shaderStringUTF8 = [shaderProgramString UTF8String];
    int shaderStringLength = [shaderProgramString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    glCompileShader(shaderHandle);
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if ( compileSuccess == GL_FALSE ) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog( @"%@", messageString );
        exit(1);
    }
    return shaderHandle;
}

- (GLuint)compileShaders {
    GLuint vertexShader = [self compileShader:@"VertexShader" withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"FragmentShader" withType:GL_FRAGMENT_SHADER];
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if ( linkSuccess == GL_FALSE ) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog( @"%@", messageString );
        exit(1);
    }
    glUseProgram( programHandle );
    self.positionAttribute = glGetAttribLocation( programHandle, "position" );
    self.sourceColorAttribute = glGetAttribLocation( programHandle, "sourceColor" );
    self.projectionUniform = glGetUniformLocation( programHandle, "projection" );
    self.viewUniform = glGetUniformLocation( programHandle, "view" );
    self.modelUniform = glGetUniformLocation( programHandle, "model" );
    glEnableVertexAttribArray( _positionAttribute );
    glEnableVertexAttribArray( _sourceColorAttribute );
    //    _texCoordSlot = glGetAttribLocation( programHandle, "texCoordIn" );
    //    glEnableVertexAttribArray( _texCoordSlot );
    //    _textureUniform = glGetUniformLocation( programHandle, "texture" );
    return programHandle;
}



@end
