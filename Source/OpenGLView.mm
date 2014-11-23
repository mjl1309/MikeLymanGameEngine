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
#import "ShaderInfoObject.h"
#import "PhysicsBody.h"
#import "Boid.h"
#import "Plane.h"


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
        
        [self setupDisplayLink];

        // ** Shaders ** //
        self.shaders = [NSMutableArray array];
        [self.shaders addObject: [[ShaderInfoObject alloc] init] ];
        
        // ** Game Objects ** //
        _gameObjects = [NSMutableArray array];
//        for (int i=0; i<10; i++) {
//            Boid *newBoid = [[Boid alloc] initWithShaderInfo:self.shaders[0]];
//            [_gameObjects addObject:newBoid];
//        }
        Boid *b1 = [[Boid alloc]initWithShaderInfo:self.shaders[0]];
        b1.physicsBody.position = GLKVector4Make(-5, -5, -20, 0);
        Boid *b2 = [[Boid alloc]initWithShaderInfo:self.shaders[0]];
        b2.physicsBody.position = GLKVector4Make(3, 3, -10, 0);
        [_gameObjects addObject:b1];
        [_gameObjects addObject:b2];
        
        Plane *p1 = [[Plane alloc] initWithShaderInfo:self.shaders[0]];
        p1.physicsBody.position = GLKVector4Make(-2.5, 0.0, -20.0, 0.0);
        p1.renderer.rotationVector = GLKVector4Make(0.0, 1.0, 0.0, 0.0);
        p1.renderer.rotationAmount = 0.0f;
        [_gameObjects addObject:p1];
        
        Plane *p2 = [[Plane alloc] initWithShaderInfo:self.shaders[0]];
        p2.physicsBody.position = GLKVector4Make(-7.5, 0.0, -20.0, 0.0);
        p2.renderer.rotationVector = GLKVector4Make(0.0, 1.0, 0.0, 0.0);
        p2.renderer.rotationAmount = 30.0f;
        [_gameObjects addObject:p2];
        
        Plane *p3 = [[Plane alloc] initWithShaderInfo:self.shaders[0]];
        p3.physicsBody.position = GLKVector4Make(2.5, 0.0, -20.0, 0.0);
        p3.renderer.rotationVector = GLKVector4Make(0.0, 1.0, 0.0, 0.0);
        p3.renderer.rotationAmount = -30.0f;
        [_gameObjects addObject:p3];
        
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
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES3;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if ( !_context ) {
        NSLog( @"Failed to initialize OpenGLES3 context, attempting to use OpenGLES2" );
        api = kEAGLRenderingAPIOpenGLES2;
        _context = [[EAGLContext alloc] initWithAPI:api];
        if ( !_context ) {
            NSLog( @"Failed to initialize OpenGLES2 context, aborting" );
            exit(1);
        }
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
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glClearColor( 0.0f, 104.0f/255.0f, 55.0f/255.0f, 1.0f );
//        glClearColor( 0.0f, 0.0f, 0.0f, 1.0f );
    glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
    glEnable( GL_DEPTH_TEST );
//    glEnable( GL_CULL_FACE );

    
    // TEMP HARD CODED
    ShaderInfoObject* shader = [self.shaders objectAtIndex:0];
    
    GLKMatrix4 projectionMatrix = GLKMatrix4Identity;
    float h = 4.0f * self.frame.size.height / self.frame.size.width;
    projectionMatrix = GLKMatrix4MakeFrustum(-2, 2, -h/2, h/2, 4, 100);
    glUniformMatrix4fv( shader.projectionUniform, 1, 0, projectionMatrix.m );

    GLKMatrix4 viewMatrix = GLKMatrix4Identity;
    glUniformMatrix4fv( shader.viewUniform, 1, 0, viewMatrix.m );
    
    for ( GameObject *gameObject in _gameObjects ) {
        glViewport(0, 0, self.frame.size.width, self.frame.size.height);
        [gameObject.renderer drawObject];
    }
    
    [ _context presentRenderbuffer:GL_RENDERBUFFER ];
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

















@end
