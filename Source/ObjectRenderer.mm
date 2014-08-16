//
//  ObjectRenderer.mm
//  BoidsGame
//
//  Created by Mike Lyman on 8/9/14.
//  Copyright (c) 2014 Mike Lyman. All rights reserved.
//

#import "ObjectRenderer.h"
#import "OpenGLView.h"
#import <GLKit/GLKMath.h>
#import "PhysicsBody.h"


@implementation ObjectRenderer

- (id)initWithModelUniform:(GLuint)modelUniform {
    self = [super init];
    if ( self ) {
        self.modelMatrix = GLKMatrix4MakeTranslation(0, 0, -7);
        _modelUniform = modelUniform;
        
//        self.positionVector = GLKVector4Make( (arc4random_uniform(10)) - 5, (arc4random_uniform(15)), -20.0f, 0.0f);
        self.positionVector = GLKVector4Make( -10.0f + arc4random_uniform(20),
                                             10.0f + arc4random_uniform(5),
                                             -20.0f,
                                             0.0f);
        
        self.rotationVector = GLKVector4Make( ((float)arc4random() / ARC4RANDOM_MAX),
                                             ((float)arc4random() / ARC4RANDOM_MAX),
                                              ((float)arc4random() / ARC4RANDOM_MAX),
                                             
                                               1.0f);
        self.rotationAmount = arc4random() % 360;
    }
    return self;
}

- (void)createVaoWithShaderProgram:(GLuint)shaderProgram
                              points:(GLKVector4*)points
                              colors:(GLKVector4*)colors
                         numVertices:(int)numvertices
{
    self.vao = createVao(shaderProgram, points, colors, numvertices);
    _numVertices = numvertices;
}



GLuint createVao( GLuint shaderProgram, GLKVector4 points[], GLKVector4 colors[], int numVertices )
{
    // Grab a new VAO
    GLuint vao;
    // openGL returns 1 free array 'name' to us inside vertexArrayObject. Using 0 resets all vertex arrays
    glGenVertexArrays( 1, &vao );
    glBindVertexArray( vao );
    glUseProgram( shaderProgram ); // TODO: try using different shaders for different objects
    
    GLuint bufferObject;
    glGenBuffers( 1, &bufferObject );
    glBindBuffer( GL_ARRAY_BUFFER, bufferObject );
    
    int sizeOfPointsAndColors = sizeof( GLfloat ) * 4 * numVertices * 2;
    int sizeOfPoints = sizeof( GLfloat ) * 4 * numVertices;
    
    glBufferData( GL_ARRAY_BUFFER, sizeOfPointsAndColors, NULL, GL_DYNAMIC_DRAW );
    
    glBufferSubData( GL_ARRAY_BUFFER, 0, sizeOfPoints, points );
    glBufferSubData( GL_ARRAY_BUFFER, sizeOfPoints, sizeOfPoints, colors );
    
    GLuint vPositionUniform = glGetAttribLocation( shaderProgram, "position" );
    glEnableVertexAttribArray( vPositionUniform );
    glVertexAttribPointer( vPositionUniform, 4, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET( 0 ) );
    
    GLuint vColorUniform = glGetAttribLocation( shaderProgram, "sourceColor" );
    glEnableVertexAttribArray( vColorUniform );
    glVertexAttribPointer( vColorUniform, 4, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET( sizeOfPoints ) );
    
    glBindVertexArray(0);
    return vao;
}

- (void)updateWithTime:(float)dt
           physicsBody:(PhysicsBody*)body {
    
    self.positionVector = body.position;

    self.rotationAmount += dt;
    
    GLKMatrix4 translation = GLKMatrix4MakeTranslation(self.positionVector.x,
                                                       self.positionVector.y,
                                                       self.positionVector.z);
    
    GLKMatrix4 rotation = GLKMatrix4MakeRotation(self.rotationAmount,
                                                 self.rotationVector.x,
                                                 self.rotationVector.y,
                                                 self.rotationVector.z);
    
    self.modelMatrix = GLKMatrix4Multiply(translation, rotation);
}

- (void)drawObject {
    glUniformMatrix4fv( _modelUniform, 1, 0, self.modelMatrix.m );
    glBindVertexArray( self.vao );
    glDrawArrays(GL_TRIANGLES, 0, _numVertices);
}

@end
