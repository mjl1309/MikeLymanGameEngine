//
//  ObjectRenderer.h
//  BoidsGame
//
//  Created by Mike Lyman on 8/9/14.
//  Copyright (c) 2014 Mike Lyman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES3/gl.h>
#include <OpenGLES/ES2/glext.h>
#import <GLKit/GLKMath.h>
@class PhysicsBody;

#define BUFFER_OFFSET( offset ) ((GLvoid*) (offset))
#define ARC4RANDOM_MAX      0x100000000



@interface ObjectRenderer : NSObject
{
    GLuint _modelUniform;
    int _numVertices;
}

@property GLuint vao;
@property GLKMatrix4 modelMatrix;
@property GLKVector4 rotationVector;
@property GLKVector4 positionVector;
@property float rotationAmount;

- (id)initWithModelUniform:(GLuint)modelUniform;

- (void)createVaoWithShaderProgram:(GLuint)shaderProgram
                              points:(GLKVector4*)points
                              colors:(GLKVector4*)colors
                         numVertices:(int)numvertices;

- (void)updateWithTime:(float)dt
           physicsBody:(PhysicsBody*)body;

- (void)drawObject;



@end
