//
//  eyeAppDelegate.h
//  eyeNeverLost
//
//  Created by Snow Leopard User on 04/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventSinkDelegate.h"
#import <CoreLocation/CoreLocation.h>


@interface eyeAppDelegate : UIResponder <UIApplicationDelegate, 
UITabBarControllerDelegate,EventSinkDelegate,CLLocationManagerDelegate>
{
    id<EventSinkDelegate> eventSink;
    CLLocationManager *locMgr;
    NSOperationQueue *nsQueue;
    BOOL    inBackground;
    NSTimer *alive;
    NSLock *nsLock;
}

@property (strong, nonatomic)    NSOperationQueue *nsQueue;
@property (strong, nonatomic) NSLock *nsLock;
@property (strong, nonatomic) CLLocationManager *locMgr;
@property (strong, nonatomic) id eventSink;
@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;

@end
