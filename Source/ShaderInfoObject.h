//
//  ShaderInfoObject.h
//  MikeLymanGameEngine
//
//  Created by Mike Lyman on 8/17/14.
//  Copyright (c) 2014 Mike Lyman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES3/gl.h>
#include <OpenGLES/ES2/glext.h>

@interface ShaderInfoObject : NSObject {
    
}

@property GLuint shaderUniform;
@property GLuint modelUniform;
@property GLuint viewUniform;
@property GLuint projectionUniform;
@property GLuint positionAttribute;
@property GLuint sourceColorAttribute;
@property GLuint normalAttribute;

@end
