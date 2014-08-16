//
//  PhysicsBody.m
//  BoidsGame
//
//  Created by Mike Lyman on 8/11/14.
//  Copyright (c) 2014 Mike Lyman. All rights reserved.
//

#import "PhysicsBody.h"

@implementation PhysicsBody

- (id)initWithPosition:(GLKVector4)position
              velocity:(GLKVector4)velocity
          acceleration:(GLKVector4)acceleration
                  mass:(float)mass
{
    self = [super init];
    if ( self ) {
        self.position = position;
        self.velocity = velocity;
        self.acceleration = acceleration;
        self.mass = mass;
    }
    return self;
}

- (void)update:(float)dt {
    self.velocity = GLKVector4Add(self.velocity, GLKVector4MultiplyScalar(self.acceleration, dt) );
    GLKVector4 displacement = GLKVector4MultiplyScalar(self.velocity, dt / self.mass);
    GLKVector4 newPosition = GLKVector4Add(displacement, self.position);
    self.position = newPosition;
}



@end
