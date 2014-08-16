//
//  OpenGLView.h
//  BoidsGame
//
//  Created by Mike Lyman on 11/6/13.
//  Copyright (c) 2013 Mike Lyman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES3/gl.h>
#include <OpenGLES/ES2/glext.h>

@interface OpenGLView : UIView {
    CAEAGLLayer *_eaglLayer;
    EAGLContext *_context;
    GLuint _colorRenderBuffer;
    GLuint _positionAttribute;
    GLuint _sourceColorAttribute;
    GLuint _projectionUniform;
    GLuint _viewUniform;
    GLuint _modelUniform;
    GLuint _modelViewUniform;
    float _currentRotation;
    GLuint _depthRenderBuffer;
    GLuint _floorTexture;
    GLuint _fishTexture;
    GLuint _texCoordSlot;
    GLuint _textureUniform;
    
    GLuint _vertexBuffer;
    GLuint _indexBuffer;
    GLuint _vertexBuffer2;
    GLuint _indexBuffer2;
    
    GLuint _vao;
    
    NSMutableArray *_gameObjects;
    
    double _frameTimeStamp;
}

@end
