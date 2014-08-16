//
//  PhysicsBody.h
//  BoidsGame
//
//  Created by Mike Lyman on 8/11/14.
//  Copyright (c) 2014 Mike Lyman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKMath.h>

@interface PhysicsBody : NSObject {
    
}

@property GLKVector4 acceleration;
@property GLKVector4 velocity;
@property GLKVector4 position;
@property float mass;

- (id)initWithPosition:(GLKVector4)position
              velocity:(GLKVector4)velocity
          acceleration:(GLKVector4)acceleration
                  mass:(float)mass;

- (void)update:(float)dt;

@end
