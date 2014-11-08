//
//  GameObject.m
//  BoidsGame
//
//  Created by Mike Lyman on 8/11/14.
//  Copyright (c) 2014 Mike Lyman. All rights reserved.
//

#import "GameObject.h"
#import <GLKit/GLKMath.h>
#import "ObjectRenderer.h"
#import "PhysicsBody.h"
#import "ShaderInfoObject.h"


@implementation GameObject {
    
}

static GLKVector4 vertex_colors[9] = {
    { 0.0, 0.0, 0.0, 1.0 },  // black 0
    { 1.0, 0.0, 0.0, 1.0 },  // red 1
    { 1.0, 1.0, 0.0, 1.0 },  // yellow 2
    { 0.0, 1.0, 0.0, 1.0 },  // green 3
    { 0.0, 0.0, 1.0, 1.0 },  // blue 4
    { 1.0, 0.0, 1.0, 1.0 },  // magenta 5
    { 1.0, 1.0, 1.0, 1.0 },  // white 6
    { 0.0, 1.0, 1.0, 1.0 },   // cyan 7
	{ 0.25, 0.25, 0.25, 1.0 } // gray 8
};

// Tetrahedron (4 sides)
static const int numVertices = 12;
static GLKVector4 vertices[ 12 ] = {
	// face 0
	{ -1.0, -1.0, -1.0, 1.0 },
	{ 1.0, -1.0, 0.0, 1.0 },
	{-1.0, -1.0, 1.0, 1.0 },
	// face 1
	{ -1.0, 1.0, 0.0, 1.0 },
	{ 1.0, -1.0, 0.0, 1.0 },
	{ -1.0, -1.0, -1.0, 1.0 },
	// face 2
	{ -1.0, 1.0, 0.0, 1.0 },
	{ -1.0, -1.0, 1.0, 1.0 },
	{ 1.0, -1.0, 0.0, 1.0 },
	// face 3
	{ -1.0, 1.0, 0.0, 1.0 },
	{ -1.0, -1.0, -1.0, 1.0 },
	{ -1.0, -1.0, 1.0, 1.0 }
};

static GLKVector4 colors[ 12 ] = {
	vertex_colors[1],
	vertex_colors[1],
	vertex_colors[1],
    
	vertex_colors[4],
	vertex_colors[4],
	vertex_colors[4],
    
	vertex_colors[7],
	vertex_colors[7],
	vertex_colors[7],
    
	vertex_colors[2],
	vertex_colors[2],
	vertex_colors[2]
};



- (id)initWithShaderInfo:(ShaderInfoObject*)shaderInfo {
    self = [super init];
    if ( self ) {
//        self.renderer = [[ObjectRenderer alloc] initWithModelUniform:shaderInfo.modelUniform];
//        [self.renderer createVaoWithShaderProgram:shaderInfo.shaderUniform points:vertices colors:colors numVertices:numVertices];
//        
//        GLKVector4 position = GLKVector4Make( -10.0f + arc4random_uniform(20), 10.0f + arc4random_uniform(5), -20.0f, 0.0f);
//        GLKVector4 velocity = GLKVector4Make(0.0f, -2.0f, 0.0f, 1.0f);
//        GLKVector4 acceleration = GLKVector4Make(0.0f, -0.0f, 0.0f, 1.0f);
//        float mass = 1.0f;
//        self.physicsBody = [[PhysicsBody alloc] initWithPosition:position velocity:velocity acceleration:acceleration mass:mass];
    }
    return self;
}

- (void)update:(float)dt {
    [self.physicsBody update:dt];
    [self.renderer updateWithTime:dt physicsBody:self.physicsBody];
}

@end
