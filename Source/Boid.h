//
//  Boid.h
//  MikeLymanGameEngine
//
//  Created by Mike Lyman on 8/28/14.
//  Copyright (c) 2014 Mike Lyman. All rights reserved.
//

#import "GameObject.h"
@class ShaderInfoObject;

@interface Boid : GameObject


- (id)initWithShaderInfo:(ShaderInfoObject*)shaderInfo;

@end
