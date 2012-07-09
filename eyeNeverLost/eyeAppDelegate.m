//
//  eyeAppDelegate.m
//  eyeNeverLost
//
//  Created by Snow Leopard User on 04/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "eyeAppDelegate.h"

#import "eyeFirstViewController.h"
#import "eyeMapViewController.h"
#import "eyeSecondViewController.h"

@implementation eyeAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize eventSink,locMgr,nsLock,nsQueue;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    UIViewController *vcLogin, *vcStats,*vcMap;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        vcLogin = [[eyeFirstViewController alloc] initWithNibName:@"eyeFirstViewController_iPhone" bundle:nil];
        vcStats = [[eyeSecondViewController alloc] initWithNibName:@"eyeSecondViewController_iPhone" bundle:nil];
        vcMap   = [[eyeMapViewController alloc] initWithNibName:
                   @"eyeMapViewController" bundle:nil];
    } else {
        vcLogin = [[eyeFirstViewController alloc] initWithNibName:@"eyeFirstViewController_iPad" bundle:nil];
        vcStats = [[eyeSecondViewController alloc] initWithNibName:@"eyeSecondViewController_iPad" bundle:nil];
    }
    
    eyeFirstViewController *vc1 = (eyeFirstViewController*)vcLogin;
    eyeSecondViewController *vc2 = (eyeSecondViewController*)vcStats;
    vc1.eventSink = self;
    self.eventSink = vc2;
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:vcLogin, vcStats,vcMap, nil];

    self.tabBarController.delegate = self;
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    self.locMgr = [[CLLocationManager alloc] init];
    self.locMgr.delegate = self;
    self.locMgr.desiredAccuracy = kCLLocationAccuracyBest;
    self.locMgr.distanceFilter =  kCLDistanceFilterNone; 

    self.nsLock = [[NSLock alloc] init];
    self.nsQueue = [[NSOperationQueue alloc]init];
    
    
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    netlog(@"Updating location %@\n",[newLocation description]);

    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    int nMode = [uDef integerForKey:@"LocationMode"];
    
    /*
     В режиме гибрида, сперва мы получаем события от GSM модуля,
     не выключая его и не отправляя его координаты, 
     включаем GPS, когда придет события от GPS - вырубам апдейты от GPS и отсылаем его координаты
     и снова ждем события от GSM...
     */
    if ( nMode == kHYBRID ) {
        BOOL isGSM = [uDef boolForKey:@"isGSM"];
        if ( isGSM ) { // событие от GSM, не отсылаем координаты, в врубаем GPS
            netlog(@"Changing to GPS...(Location aren't sent)\n");
            [manager startUpdatingLocation];
        } else { // событие от GPS, вырубаем GPS и отсылаем координаты,снова ждем события от GSM
            netlog(@"Changing to GSM...(GPS coordinates is about to be sent)\n");
            [manager stopUpdatingLocation];
        }
        // триггер режима
        [uDef setBool:!isGSM forKey:@"isGSM"];
        [uDef synchronize];
        // если событие от GSM - вываливаемся, скоро должно придти событие от GPS
        if ( isGSM == YES )
            return;
    } // Hybrid mode 

    
    // дабы не блокироваться в [Gateway saveLocation] запускаемся в блоке
    NSBlockOperation *block = [NSBlockOperation blockOperationWithBlock:^{

        // не знаю, имеет ли смысл, но так спокойнее
        // судя по временя в логе - без лока образуется каша
        // может по этому часть данных не отослалась....блянах
        netlog(@"send: Waiting for lock\n");
        [nsLock lock]; 
        netlog(@"send: Lock acquired\n");
        
        NSString *beaconID = [uDef stringForKey:@"beaconID"];
        NSString *sStatus = [self.eventSink getStatusString];
        GatewayUtil *gw = [[GatewayUtil alloc]init];
        if ( [gw saveLocation:beaconID longitude:newLocation.coordinate.longitude latitude:newLocation.coordinate.latitude precision:newLocation.horizontalAccuracy status:(sStatus == nil || [sStatus length] == 0 )? @"":sStatus] ) {
            netlog(@"Location are sent\n");
        } else {
            NSString *msg = [gw.response objectForKey:@"msg"];
            netlog(@"Failed to sending location to server: %@\n",msg != nil?msg:@"unexpected");
        }
        [nsLock unlock];
        netlog(@"send: lock released\n");
    }]; // block
        
    // и еще один блок для апдейта статистики
    [block addExecutionBlock:^{
        [self.eventSink updateStats:newLocation];
        netlog(@"Statistics updated\n");
    }]; // execution block update
    
    
    // invoke !
    [nsQueue addOperation:block];
}
/*
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
 // do your background work
    dispatch_async(dispatch_get_main_queue(), ^{
    // update UI, etc.
    myLabel.text = @"Finished";
    });
 });
 
 */


/*
 метод-делегат из EventSinkDelegate для управлением LocationManager'om
 */
- (void)controlLocation:(BOOL)doStart {
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    int nMode = [uDef integerForKey:@"LocationMode"];
    NSString *sModeName = [uDef stringForKey:@"LocationModeString"];
    
    //  флаг активного мониторинга
    [uDef setBool:doStart forKey:@"Active"];
    [uDef synchronize];
    
    // вызов eyeSecondViewController
    // для обнуления счетчика обновлений позиции
    [self.eventSink controlLocation:doStart];
   
    switch ( nMode ) {
        case kGPS:
            if ( doStart == YES ) [locMgr startUpdatingLocation];
            else [locMgr stopUpdatingLocation];
            break;
        case kGSM:
            if ( doStart == YES ) [locMgr startMonitoringSignificantLocationChanges];
            else [locMgr stopMonitoringSignificantLocationChanges]; 
            break;
        default: //  режим гибрида, врубаем сперва режим GSM,
            if ( doStart == YES ) {
                [uDef setBool:YES forKey:@"isGSM"];
                [locMgr startMonitoringSignificantLocationChanges ];
            } else {
                // на всякий случай, чем черт не шутит,,,
                [locMgr stopUpdatingLocation];
                [locMgr stopMonitoringSignificantLocationChanges ];
            }
            break;
    };

    netlog(@"%@ Monitor %@\n",sModeName,doStart == YES?@"Started":@"Stopped");
    
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    // Если мы не активировали свой телефон, то где находится дружбан посмотреть не возможно
    // т.к дружбан привязан к одному из телефонов пользователя
    BOOL fLoggedIn = [uDef boolForKey:@"LoggedIn"];
        if ( [viewController isKindOfClass: [eyeMapViewController class]] && fLoggedIn == NO ) {
        netlog_alert(@"Вы не авторезированы,выберете активный телефон...");
        return NO;
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    netlog(@"applicationWillResignActive\n");
}


//#define _GSM_
#define _BATTERY_DRAIN_

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    netlog(@"applicationDidEnterBackground\n");
    
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    
    // Скажем всем, что мы в ушли в тень
    [uDef setBool:YES forKey:@"Background"];
    [uDef synchronize];

    // Дальше лучше не смотреть, - попытки сохранить батарейку в режиме GPS
    //
#ifdef _BATTERY_DRAIN_    
    netlog(@"BG: Battery drain...\n");
    return;
#endif    
    BOOL fActive = [uDef boolForKey:@"Active"];
    
    if ( fActive ) {
        netlog(@"Changing location update modes to GSM\n");
        [locMgr stopUpdatingLocation];
#ifdef _GSM_
        [locMgr startMonitoringSignificantLocationChanges];
#endif 
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    netlog(@"applicationWillEnterForeground\n");
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    [uDef setBool:NO forKey:@"Background"];
    [uDef synchronize];

#ifdef _BATTERY_DRAIN_  
    netlog(@"FG: Battery drain...\n");
    return;
#endif
    
    BOOL fActive = [uDef boolForKey:@"Active"];
    if ( fActive ) {
        netlog(@"Changing location update modes to GPS\n");
    }
    inBackground = NO;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    netlog(@"applicationDidBecomeActive\n");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    netlog(@"applicationWillTerminate\n");
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
