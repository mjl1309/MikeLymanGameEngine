//
//  Boid.m
//  MikeLymanGameEngine
//
//  Created by Mike Lyman on 8/28/14.
//  Copyright (c) 2014 Mike Lyman. All rights reserved.
//

#import "Boid.h"
#import <GLKit/GLKMath.h>
#import "ObjectRenderer.h"
#import "PhysicsBody.h"
#import "ShaderInfoObject.h"

@implementation Boid

static GLKVector4 vertex_colors[12] = {
    { 0.0, 0.0, 0.0, 1.0 },  // black 0
    { 1.0, 0.0, 0.0, 1.0 },  // red 1
    { 1.0, 1.0, 0.0, 1.0 },  // yellow 2
    { 0.0, 1.0, 0.0, 1.0 },  // green 3
    { 0.0, 0.0, 1.0, 1.0 },  // blue 4
    { 1.0, 0.0, 1.0, 1.0 },  // magenta 5
    { 1.0, 1.0, 1.0, 1.0 },  // white 6
    { 0.0, 1.0, 1.0, 1.0 },   // cyan 7
	{ 0.25, 0.25, 0.25, 1.0 }, // gray 8
    { 0.0, 0.25, 0.75, 1.0 }, // fish colors: darkest blue 9
    { 0.0, 0.35, 0.85, 1.0 }, // fish colors: dark blue 10
    { 0.0, 0.45, 0.95, 1.0 } // fish colors: light blue 11
};

// Tetrahedron (4 sides)
static const int numVertices = 24;
static const float faceLen = 1.0f;
static const float tailLen = 1.75f;
static const float headHeight = 1.25f;
static const float chinHeight = 0.75f;
static const float faceWidth = 0.75f;
static GLKVector4 vertices[ 24 ] = {
	// right cheek
	{ faceLen, 0.0, 0.0, 1.0 },
	{ 0.0, headHeight, 0.0, 1.0 },
	{ 0.0, 0.0, faceWidth, 1.0 },

	// right jaw
	{ faceLen, 0.0, 0.0, 1.0 },
	{ 0.0, 0.0, faceWidth, 1.0 },
	{ 0.0, -chinHeight, 0.0f, 1.0 },

	// left cheek
	{ faceLen, 0.0, 0.0, 1.0 },
	{ 0.0, 0.0, -faceWidth, 1.0 },
	{ 0.0, headHeight, 0.0, 1.0 },
    
    // left jaw
    { faceLen, 0.0, 0.0, 1.0 },
	{ 0.0, -chinHeight, 0.0, 1.0 },
    { 0.0, 0.0, -faceWidth, 1.0 },
    
    // right top tail
    { 0.0, 0.0, faceWidth, 1.0 },
    { 0.0, headHeight, 0.0, 1.0 },
	{ -tailLen, 0.0, 0.0, 1.0 },
    
    // right bottom tail
    { 0.0, 0.0, faceWidth, 1.0 },
	{ -tailLen, 0.0, 0.0, 1.0 },
    { 0.0, -chinHeight, 0.0, 1.0 },
    
    // left top tail
    { 0.0, 0.0, -faceWidth, 1.0 },
	{ -tailLen, 0.0, 0.0, 1.0 },
    { 0.0, headHeight, 0.0, 1.0 },
    
    // left bottom tail
    { 0.0, 0.0, -faceWidth, 1.0 },
    { 0.0, -chinHeight, 0.0, 1.0 },
    { -tailLen, 0.0, 0.0, 1.0 }
};

static GLKVector4 colors[ 24 ] = {
	// right cheek
    vertex_colors[10],
	vertex_colors[10],
	vertex_colors[10],
    
    // right jaw
	vertex_colors[10],
	vertex_colors[10],
	vertex_colors[10],
    
    // left cheek
	vertex_colors[10],
	vertex_colors[10],
	vertex_colors[10],
    
    // left jaw
    vertex_colors[10],
	vertex_colors[10],
	vertex_colors[10],
    
    // right top tail
    vertex_colors[10],
	vertex_colors[10],
	vertex_colors[10],
    
    // right bottom tail
    vertex_colors[10],
	vertex_colors[10],
	vertex_colors[10],
    
    // left top tail
    vertex_colors[10],
	vertex_colors[10],
	vertex_colors[10],
    
    // left bottom tail
    vertex_colors[10],
	vertex_colors[10],
	vertex_colors[10]
};


- (id)initWithShaderInfo:(ShaderInfoObject*)shaderInfo {
    self = [super initWithShaderInfo:shaderInfo];
    if ( self ) {
        self.renderer = [[ObjectRenderer alloc] initWithModelUniform:shaderInfo.modelUniform];
        [self.renderer createVaoWithShaderProgram:shaderInfo.shaderUniform points:vertices colors:colors numVertices:numVertices];
        
//        GLKVector4 position = GLKVector4Make( -10.0f + arc4random_uniform(20), 10.0f + arc4random_uniform(5), -20.0f, 0.0f);
//        GLKVector4 position = GLKVector4Make( 0, 0, -10.0f, 0.0f);
        GLKVector4 position = GLKVector4Make( -10.0f + arc4random_uniform(20),
                                             -10.0f + arc4random_uniform(20),
                                             -20.0f + arc4random_uniform(10),
                                             0.0f);
        
        GLKVector4 velocity = GLKVector4Make(0.0f, -0.0f, 0.0f, 0.0f);
        GLKVector4 acceleration = GLKVector4Make(0.0f, 0.0f, 0.0f, 0.0f);
        float mass = 1.0f;
        self.physicsBody = [[PhysicsBody alloc] initWithPosition:position velocity:velocity acceleration:acceleration mass:mass];
//        self.renderer.rotationVector = GLKVector4Make(0, 1.0, 0, 0);
        self.renderer.rotationVector = GLKVector4Make( ((float)arc4random() / ARC4RANDOM_MAX),
                                             ((float)arc4random() / ARC4RANDOM_MAX),
                                             ((float)arc4random() / ARC4RANDOM_MAX),
                                                      1.0);
        self.renderer.rotationAmount = arc4random() % 360;
    }
    return self;
}

- (void)update:(float)dt {
    [super update:dt];
    self.renderer.rotationAmount += 50 * dt;
}




@end
