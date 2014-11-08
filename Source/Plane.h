//
//  Plane.h
//  MikeLymanGameEngine
//
//  Created by Mike Lyman on 11/8/14.
//  Copyright (c) 2014 Mike Lyman. All rights reserved.
//

#import "GameObject.h"
@class ShaderInfoObject;


@interface Plane : GameObject

- (id)initWithShaderInfo:(ShaderInfoObject*)shaderInfo;

@end
