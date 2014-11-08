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
        
        self.rotationVector = GLKVector4Make( 1.0f, 1.0f, 1.0f, 1.0f);
        self.rotationAmount = 0;
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
    
    int sizeOfPoints = sizeof( GLfloat ) * 4 * numVertices;
    int sizeOfNormals = sizeof( GLfloat) * 4 * numVertices;
    int bufferSize = sizeOfPoints * 2 + sizeOfNormals;
    
    glBufferData( GL_ARRAY_BUFFER, bufferSize, NULL, GL_DYNAMIC_DRAW );
    
    // Generate normals based on vertices
    GLKVector4* normals = generateNormals(points, numVertices);
    
    glBufferSubData( GL_ARRAY_BUFFER, 0, sizeOfPoints, points );
    glBufferSubData( GL_ARRAY_BUFFER, sizeOfPoints, sizeOfPoints, colors );
    glBufferSubData( GL_ARRAY_BUFFER, sizeOfPoints * 2, sizeOfNormals, normals);
    
    GLuint vPositionUniform = glGetAttribLocation( shaderProgram, "position" );
    glEnableVertexAttribArray( vPositionUniform );
    glVertexAttribPointer( vPositionUniform, 4, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET( 0 ) );
    
    GLuint vColorUniform = glGetAttribLocation( shaderProgram, "sourceColor" );
    glEnableVertexAttribArray( vColorUniform );
    glVertexAttribPointer( vColorUniform, 4, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET( sizeOfPoints ) );
    
    GLuint vNormalAttrib = glGetAttribLocation( shaderProgram, "normal" );
    glEnableVertexAttribArray( vNormalAttrib );
    glVertexAttribPointer( vNormalAttrib, 4, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(sizeOfPoints * 2));
    
    glBindVertexArray(0);
    return vao;
}

// Generates normals based on vertices passed in. Assumes that every 3 vertices are used only once for a single triangle.
GLKVector4* generateNormals( GLKVector4 points[], int numPoints ) {
    GLKVector4 *normals = new GLKVector4[numPoints];
    int normalIndex = 0;
    for (int i=0; i<numPoints; i+=3) {
        GLKVector4 u = GLKVector4Make(points[i+1].x - points[i].x, points[i+1].y - points[i].y, points[i+1].z - points[i].z, 1.0);
        GLKVector4 v = GLKVector4Make(points[i+2].x - points[i].x, points[i+2].y - points[i].y, points[i+2].z - points[i].z, 1.0);
        GLKVector4 n = GLKVector4CrossProduct(u, v);
        n = GLKVector4Normalize(n);
        normals[normalIndex] = n;
        normals[normalIndex+1] = n;
        normals[normalIndex+2] = n;
        normalIndex+=3;
    }
    return normals;
}


- (void)updateWithTime:(float)dt
           physicsBody:(PhysicsBody*)body {
    
    self.positionVector = body.position;

//    self.rotationAmount += dt;
    
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
