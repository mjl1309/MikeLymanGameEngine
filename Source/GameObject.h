//
//  GameObject.h
//  BoidsGame
//
//  Created by Mike Lyman on 8/11/14.
//  Copyright (c) 2014 Mike Lyman. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PhysicsBody;
@class ObjectRenderer;
@class ShaderInfoObject;

@interface GameObject : NSObject {
    
}

@property PhysicsBody *physicsBody;
@property ObjectRenderer *renderer;

- (id)initWithShaderInfo:(ShaderInfoObject*)shaderInfo;

- (void)update:(float)dt;



@end
