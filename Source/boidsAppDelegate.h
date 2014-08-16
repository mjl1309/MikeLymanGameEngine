//
//  boidsAppDelegate.h
//  BoidsGame
//
//  Created by Mike Lyman on 11/6/13.
//  Copyright (c) 2013 Mike Lyman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"

@interface boidsAppDelegate : UIResponder <UIApplicationDelegate> {
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) IBOutlet OpenGLView *glView;

@end
