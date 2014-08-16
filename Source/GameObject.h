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

@interface GameObject : NSObject {
    
}

@property PhysicsBody *physicsBody;
@property ObjectRenderer *renderer;

- (id)initWithTEMP:(GLuint)modelUniform
              TEMP:(GLuint)shaderProgram;

- (void)update:(float)dt;



@end
