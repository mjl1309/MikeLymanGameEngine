//
//  Plane.m
//  MikeLymanGameEngine
//
//  Created by Mike Lyman on 11/8/14.
//  Copyright (c) 2014 Mike Lyman. All rights reserved.
//

#import "Plane.h"
#import <GLKit/GLKMath.h>
#import "ObjectRenderer.h"
#import "PhysicsBody.h"
#import "ShaderInfoObject.h"

@implementation Plane

- (id)initWithShaderInfo:(ShaderInfoObject*)shaderInfo {
    self = [super initWithShaderInfo:shaderInfo];
    if ( self ) {
        float width = 20.0f;
        float length = 20.0f;
        int rezWidth = 100;
        int rezLength = 100;
        int numVertices = 6 * rezLength * rezWidth;
        GLKVector4 *vertices = (GLKVector4*)malloc(sizeof(GLKVector4) * numVertices);
        GLKVector4 *colors = (GLKVector4*)malloc(sizeof(GLKVector4) * numVertices);
        float xPos = 0.0f;
        float yPos = 0.0f;
        float xStep = width / rezWidth;
        float yStep = length / rezLength;
        int verticesIndex = 0;
        GLKVector4 o = GLKVector4Make(-width/2, -length/2, 0.0, 1.0);

        // can be optimized if using triangle strips
        for (int j = 0; j < rezLength; j++) {
            xPos = 0.0f;
            for (int i = 0; i < rezWidth; i++) {
                vertices[verticesIndex] = GLKVector4Add(o, GLKVector4Make( xPos, yPos, 0.0f, 1.0f) );
                vertices[verticesIndex+1] = GLKVector4Add(o, GLKVector4Make( xPos + xStep, yPos, 0.0f, 1.0f) );
                vertices[verticesIndex+2] = GLKVector4Add(o, GLKVector4Make( xPos + xStep, yPos + yStep, 0.0f, 1.0f) );
                vertices[verticesIndex+3] = GLKVector4Add(o, GLKVector4Make( xPos, yPos, 0.0f, 1.0f) );
                vertices[verticesIndex+4] = GLKVector4Add(o, GLKVector4Make( xPos + xStep, yPos + yStep, 0.0f, 1.0f) );
                vertices[verticesIndex+5] = GLKVector4Add(o, GLKVector4Make( xPos, yPos + yStep, 0.0f, 1.0f) );
                verticesIndex+=6;
                xPos += xStep;
            }
            yPos += yStep;
        }
        for (int i = 0; i < numVertices; i++) {
            colors[i] = GLKVector4Make(1.0, 0.0, 0.0, 1.0);
        }
        
        self.renderer = [[ObjectRenderer alloc] initWithModelUniform:shaderInfo.modelUniform];
        [self.renderer createVaoWithShaderProgram:shaderInfo.shaderUniform points:vertices colors:colors numVertices:numVertices];
        GLKVector4 position = GLKVector4Make(0.0f,
                                             0.0f,
                                             -20.0f,
                                             0.0f);
        
        GLKVector4 velocity = GLKVector4Make(0.0f, 0.0f, 0.0f, 0.0f);
        GLKVector4 acceleration = GLKVector4Make(0.0f, 0.0f, 0.0f, 0.0f);
        self.renderer.rotationVector = GLKVector4Make(1.0, 0.0, 0.0, 0.0);
        self.renderer.rotationAmount = 00.0f;
        float mass = 1.0f;
        self.physicsBody = [[PhysicsBody alloc] initWithPosition:position velocity:velocity acceleration:acceleration mass:mass];
    }
    return self;
}

- (void)update:(float)dt {
    [super update:dt];
//    self.renderer.rotationAmount += dt / 3;
}


@end
