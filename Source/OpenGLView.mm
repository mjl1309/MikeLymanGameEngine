//
//  OpenGLView.m
//  BoidsGame
//
//  Created by Mike Lyman on 11/6/13.
//  Copyright (c) 2013 Mike Lyman. All rights reserved.
//

#import "OpenGLView.h"
#import <GLKit/GLKMath.h>
#import "ObjectRenderer.h"
#import "GameObject.h"


@implementation OpenGLView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer];
        [self setupContext];
        [self setupDepthBuffer]; // not sure why this needs to happen first
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        GLuint shaderProgramUniform = [self compileShaders];
        [self setupDisplayLink];

        
        _gameObjects = [NSMutableArray array];
        for (int i=0; i<20; i++) {
            GameObject *newGameObject = [[GameObject alloc] initWithTEMP:_modelUniform TEMP:shaderProgramUniform];
            [_gameObjects addObject:newGameObject];
        }
        _frameTimeStamp = 0.0;
    }
    return self;
}



+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer*)self.layer;
    _eaglLayer.opaque = YES;
}

- (void)setupContext {
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if ( !_context ) {
        NSLog( @"Failed to initialize OpenGLES context" );
        exit(1);
    }
    if ( ![EAGLContext setCurrentContext:_context] ) {
        NSLog( @"Failed to set current OpenGL context" );
        exit(1);
    }
}

- (void)setupRenderBuffer {
    glGenRenderbuffers( 1, &_colorRenderBuffer );
    glBindRenderbuffer( GL_RENDERBUFFER, _colorRenderBuffer );
    [ _context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer ];
}

- (void)setupFrameBuffer {
    GLuint frameBuffer;
    glGenFramebuffers( 1, &frameBuffer );
    glBindFramebuffer( GL_FRAMEBUFFER, frameBuffer );
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);
}

- (void)setupDepthBuffer {
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.frame.size.width, self.frame.size.height);
}


- (void)renderVao:(CADisplayLink*)displayLink {
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    glClearColor( 0.0f, 104.0f/255.0f, 55.0f/255.0f, 1.0f );
    glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
    glEnable( GL_DEPTH_TEST );

    
    GLKMatrix4 projectionMatrix = GLKMatrix4Identity;
    float h = 4.0f * self.frame.size.height / self.frame.size.width;
    projectionMatrix = GLKMatrix4MakeFrustum(-2, 2, -h/2, h/2, 4, 100);
    glUniformMatrix4fv( _projectionUniform, 1, 0, projectionMatrix.m );

    GLKMatrix4 viewMatrix = GLKMatrix4Identity;
    glUniformMatrix4fv( _viewUniform, 1, 0, viewMatrix.m );

//    GLKMatrix4 modelView = GLKMatrix4Identity;
//    modelView = GLKMatrix4MakeTranslation(sin(CACurrentMediaTime()), 0, -7);
//    _currentRotation += displayLink.duration;
//    modelView = GLKMatrix4Rotate(modelView, _currentRotation, 1, 0, 0);
//    glUniformMatrix4fv( _modelViewUniform, 1, 0, modelView.m );
    
    for ( GameObject *gameObject in _gameObjects ) {
        glViewport(0, 0, self.frame.size.width, self.frame.size.height);
//        glBindVertexArray( renderObject.vao );
//        modelView = GLKMatrix4Multiply(viewMatrix, renderObject.modelMatrix);
//        glUniformMatrix4fv( _modelViewUniform, 1, 0, modelView.m );
        [gameObject.renderer drawObject];
//        glDrawArrays(GL_TRIANGLES, 0, numVerticesTetrahedron );
    }

    
    // Pass the shader the model view matrix
//        glUniformMatrix4fv( _modelViewUniform, 1, 0, modelView.m );
    
    // draw to the whole window

    
    // Use the vao
//    glBindVertexArray( _vao );
    
//    glDrawArrays( GL_TRIANGLES, 0, numVerticesTetrahedron );
    
    // glBindVertexArray(0)
    
    [ _context presentRenderbuffer:GL_RENDERBUFFER ];
//    [ _context presentRenderbuffer:GL_ARRAY_BUFFER ];
    
    [self checkOpenGlError];

}

- (void)setupDisplayLink {
//    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(renderVao:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    CADisplayLink *updateLoop = [CADisplayLink displayLinkWithTarget:self selector:@selector(update:)];
    [updateLoop addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)update:(CADisplayLink*)displayLink {
    double currentTime = [displayLink timestamp];
    double deltaTime = currentTime - _frameTimeStamp;
    if ( _frameTimeStamp == 0.0 ) {
        _frameTimeStamp = currentTime;
        return;
    }
    _frameTimeStamp = currentTime;
    for ( GameObject *gameObject in _gameObjects ) {
        [gameObject update:deltaTime];
    }
}

- (void)checkOpenGlError {
    GLenum errorCode = glGetError();
    if ( errorCode != GL_NO_ERROR ) {
        NSLog(@"ERROR: %d",errorCode);
    }
}

#pragma mark - Texture Setup
// http://www.raywenderlich.com/4404/opengl-es-2-0-for-iphone-tutorial-part-2-textures

// Load a texture with name filename
- (GLuint)setupTexture:(NSString*)fileName {
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if ( !spriteImage ) {
        NSLog( @"Failed to load image %@", fileName );
        exit(1);
    }
    
    size_t width = CGImageGetWidth( spriteImage );
    size_t height = CGImageGetHeight( spriteImage );
    GLubyte *spriteData = (GLubyte*) calloc( width * height *4, sizeof(GLubyte) );
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width * 4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    CGContextRelease(spriteContext);
    
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    free(spriteData);
    return texName;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

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
    _positionAttribute = glGetAttribLocation( programHandle, "position" );
    _sourceColorAttribute = glGetAttribLocation( programHandle, "sourceColor" );
    _projectionUniform = glGetUniformLocation( programHandle, "projection" );
    _viewUniform = glGetUniformLocation( programHandle, "view" );
    _modelUniform = glGetUniformLocation( programHandle, "model" );
//    _modelViewUniform = glGetUniformLocation( programHandle, "modelView" );
    glEnableVertexAttribArray( _positionAttribute );
    glEnableVertexAttribArray( _sourceColorAttribute );
//    _texCoordSlot = glGetAttribLocation( programHandle, "texCoordIn" );
//    glEnableVertexAttribArray( _texCoordSlot );
//    _textureUniform = glGetUniformLocation( programHandle, "texture" );
    return programHandle;
}
















@end
