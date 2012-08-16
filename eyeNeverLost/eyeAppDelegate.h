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

enum {
    locationNone,
    locationReady
};

@interface eyeAppDelegate : UIResponder <UIApplicationDelegate, 
UITabBarControllerDelegate,EventSinkDelegate,CLLocationManagerDelegate>
{
    id<EventSinkDelegate> eventSink;
    KeepAliveDelegate *keepAlive;
    CLLocationManager *locMgr;
    CLLocationManager *locMgrKeepAlive;
    NSOperationQueue *nsQueue;
    BOOL    inBackground;
    NSLock *nsLock;
    UIBackgroundTaskIdentifier bgTask;
    int updateCounter;
    //NSMutableArray *msgQueue;
    int locationCount;
    NSTimeInterval firstUpdate;
    CLLocation *lastLocation;
    BOOL isUpdating;
    BOOL isFirstStart;
    int  updateInterval;
    NSString *beaconID;
    GatewayUtil *gwUtil;
}

//@property (strong, nonatomic) NSMutableArray *msgQueue;
@property (strong, nonatomic) KeepAliveDelegate* keepAlive;
@property (strong, nonatomic) CLLocationManager *locMgrKeepAlive;
@property (strong, nonatomic) NSOperationQueue *nsQueue;
@property (strong, nonatomic) NSLock *nsLock;
@property (strong, nonatomic) CLLocationManager *locMgr;
@property (strong, nonatomic) id eventSink;
@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;

-(void)sendLocation;
- (void) initUpdateInterval;

@end
