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

// Может он не так уж и нужен, но пусть будет
@interface KeepAliveDelegate : NSObject <CLLocationManagerDelegate>
@end

@interface eyeAppDelegate : UIResponder <UIApplicationDelegate, 
UITabBarControllerDelegate,EventSinkDelegate,CLLocationManagerDelegate>
{
    id<EventSinkDelegate> eventSink;
    KeepAliveDelegate *keepAlive;
    CLLocationManager *locMgr;
    CLLocationManager *locMgrKeepAlive;
    NSOperationQueue *nsQueue;
    BOOL    inBackground;
    //BOOL    jobStarted;
    //NSTimer *alive;
    NSLock *nsLock;
    //dispatch_queue_t queue;
    UIBackgroundTaskIdentifier bgTask;
}


@property (strong, nonatomic) CLLocationManager *locMgrKeepAlive;
@property (strong, nonatomic) NSOperationQueue *nsQueue;
@property (strong, nonatomic) NSLock *nsLock;
@property (strong, nonatomic) CLLocationManager *locMgr;
@property (strong, nonatomic) id eventSink;
@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;

@end
