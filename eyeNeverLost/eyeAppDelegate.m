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

@implementation KeepAliveDelegate

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    netlog(@"KeepAlive %@\n",[newLocation description]);
}
@end

@implementation eyeAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize eventSink,locMgr,nsLock,nsQueue;
@synthesize keepAlive,locMgrKeepAlive;
@synthesize networkInfo;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    //UIViewController *vcLogin, *vcStats,*vcMap;
   // if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    eyeFirstViewController *vcLogin = [[eyeFirstViewController alloc] initWithNibName:@"eyeFirstViewController_iPhone" bundle:nil];
    eyeSecondViewController* vcStats = [[eyeSecondViewController alloc] initWithNibName:@"eyeSecondViewController_iPhone" bundle:nil];
    eyeMapViewController *vcMap   = [[eyeMapViewController alloc] initWithNibName:
                   @"eyeMapViewController" bundle:nil];
    
    
    
    vcMap.eventSink = vcLogin;
    vcLogin.eventSink = self;
    self.eventSink = vcStats;
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:vcLogin, vcStats,vcMap, nil];

    self.tabBarController.delegate = self;
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    self.locMgr = [[CLLocationManager alloc] init];
    self.locMgr.delegate = self;
    self.locMgr.desiredAccuracy = kCLLocationAccuracyBest;
    self.locMgr.distanceFilter =  kCLDistanceFilterNone; 
    [self.locMgr stopUpdatingLocation]; 
    [self.locMgr stopMonitoringSignificantLocationChanges];

    
    self.nsLock = [[NSLock alloc] init];
    self.nsQueue = [[NSOperationQueue alloc]init];
    
    
    self.keepAlive = [[KeepAliveDelegate alloc]init];
    self.locMgrKeepAlive = [[CLLocationManager alloc] init];
    self.locMgrKeepAlive.delegate = self.keepAlive;
    
    gwUtil = [[GatewayUtil alloc] init];
    
    updateCounter = 0;
    locationCount = 0;
    firstUpdate = 0;
    lastLocation = nil;
    isUpdating = NO;
    
    
    UIDevice *device = [UIDevice currentDevice];
    [device setBatteryMonitoringEnabled:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryChanged:) name:@"UIDeviceBatteryLevelDidChangeNotification" object:device];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryChanged:) name:@"UIDeviceBatteryStateDidChangeNotification" object:device];
    
    
    // будем посмотреть на горячую смену сим карты
    networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    networkInfo.subscriberCellularProviderDidUpdateNotifier = ^(CTCarrier* carrier){
        
        NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
        NSString *beacon = [NSString stringWithString:[uDef stringForKey:@"beaconID"]];
        if ( beacon != nil ) {
            GatewayUtil *gw = [[GatewayUtil alloc]init];
            [gw notifySimChanged:beacon changed:YES];
        } else {
            netlog(@"Sim state changed,but no currently active beacon...");
        }
    };
    
    [GatewayUtil checkGPS];
    
    return YES;
}


-(void)selectTab:(int)index {
    [self.tabBarController setSelectedIndex:index];
}

- (void)batteryChanged:(NSNotification *)notification
{
    UIDevice *device = [UIDevice currentDevice];
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    [uDef setFloat:device.batteryLevel forKey:@"batteryLevel"];        
    [uDef synchronize];
}


/*
 метод-делегат из EventSinkDelegate для управлением LocationManager'om
 */
- (void)controlLocation:(BOOL)doStart {
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    beaconID = [NSString stringWithString:[uDef stringForKey:@"beaconID"]];
    [self initUpdateInterval];
    
    //  флаг активного мониторинга
    [uDef setBool:doStart forKey:@"Active"];
    [uDef synchronize];
    
    netlog(@"GPS Monitor %@ for %@\n",doStart == YES?@"Started":@"Stopped",beaconID);

    locationCount = 0;
    firstUpdate = 0;
    lastLocation = nil;
    updateCounter = 0;
    
    if ( doStart == YES )  { 
        isUpdating = YES;
        isFirstStart = YES;
        [locMgr startUpdatingLocation];
    }
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    // Если мы не активировали свой телефон, то где находится дружбан посмотреть не возможно
    // т.к дружбан привязан к одному из телефонов пользователя
    BOOL fActive = [uDef boolForKey:@"Active"];
    if ( [viewController isKindOfClass: [eyeMapViewController class]] && fActive == NO ) {
        toast(@"Вы не авторезированы",@"");
        return NO;
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    netlog(@"applicationWillResignActive\n");
}



- (void)applicationDidEnterBackground:(UIApplication *)application
{
    netlog(@"applicationDidEnterBackground\n");
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    BOOL fActive = [uDef boolForKey:@"Active"];
    int sendTimeout = 15; // seconds  //[uDef integerForKey:@"sendTimeout"];
    
    // Скажем всем, что мы в ушли в тень
    [uDef setBool:YES forKey:@"Background"];
    [uDef synchronize];

    // Если не активированы, вываливаемся нах 
    if ( fActive == NO ) 
        return;
    
    netlog(@"Interval is set to %d secs\n",updateInterval);
    
    bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        netlog(@"TASK ENDED\n");
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    inBackground = YES;
    netlog(@"Background job started\n");
    // захренариваем фоновый тред
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Используем свой таймер, а не [UIApplication backgroundTimeRemaining]
        // потому как иногда ( незнаю почему ) в нем появляется запредельное значение ( потом снова все - ок )
        int nDeadlineCounter = 0;
        // счетчик для отсылки в БД
        while ( inBackground == YES ) {

            [NSThread sleepForTimeInterval:1.0];   
            
            nDeadlineCounter++;
            updateCounter++;
            NSTimeInterval nTimeRemaining = [application backgroundTimeRemaining];
            
            //netlog(@"background job: update:%d [ remaining %f ]\n",nInterval - updateCounter,nTimeRemaining);
            // не будем ждать 10-ти минут, передернем на минутку пораньше
            // ( только если наш интервал меньше 10 минут, иначе нет смысла добавочно   
            // перезапускать )
            if ( updateInterval >= 600 && nDeadlineCounter >= 540 ) { // 9 мин
                netlog(@"Triggering Location Services to bybass 10 min restriction ( now %f )\n",nTimeRemaining);
                // сбрасываем счетчик
                // по идее можно юзать и locMgr и попутно апдейтить нашу позицию
                // но пока оставим пустой обработчик
                [self.locMgrKeepAlive startUpdatingLocation];
                [self.locMgrKeepAlive stopUpdatingLocation]; 
                nDeadlineCounter = 0;
            }
            
            // запрашиваем падейт по интервалу
            if ( updateCounter >= updateInterval && isUpdating == NO) {
                isUpdating = YES;
                updateCounter = 0;
                [locMgr startUpdatingLocation];
                nDeadlineCounter = 0;
            }
            
            // Если есть число локаций и прошло достаточно времяни для отсылки - отсылаем
            if ( locationCount > 0  ) {
                NSTimeInterval diff = [[NSDate date]timeIntervalSince1970] - firstUpdate;
                // в течении этого времени будем слушать 
                if ( diff >= sendTimeout ) {
                    isUpdating = NO;
                    [self sendLocation];
                    locationCount = 0;
                }
            }
            
        } // while in background
        netlog(@"Background job finished\n");
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }); // dispatch
}

- (void)sendLocation {
    // [[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground
    
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    beaconID = [NSString stringWithString:[uDef stringForKey:@"beaconID"]];
    
    [locMgr stopUpdatingLocation];
    [self.eventSink updateStats:lastLocation updateView:NO];
    
    NSString *sStatus = [self.eventSink getStatusString];
    NSString *error  = nil;
    if ( [gwUtil saveLocation:beaconID longitude:lastLocation.coordinate.longitude latitude:lastLocation.coordinate.latitude precision:lastLocation.horizontalAccuracy status:(sStatus == nil || [sStatus length] == 0 )? @"":sStatus date:lastLocation.timestamp error:&error] == YES ) {
        netlog(@"%@ Locations(%d) are sent: %@\n",inBackground==YES?@"Background":		@"Foreground",locationCount,error==nil?@"no error":error);
        if ( error != nil && inBackground == NO ) {
            alert(@"Ошибка",@"Ошибка записи позиции в базу: %@",error);
            
        }
    } else {
        NSString *msg = [gwUtil.response objectForKey:@"msg"];
        if ( inBackground == NO )
            alert(@"Ошибка",@"Ошибка отправки запроса %@",msg);
        netlog(@"Failed to sending location to server: %@\n",msg != nil?msg:@"unexpected");
    }

    
    [self initUpdateInterval];
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
        
    if ( isUpdating == NO ) {
        return;
    }
    
    if ( locationCount == 0  ) {
        firstUpdate = [[NSDate date] timeIntervalSince1970];
        lastLocation = newLocation;
    } else {
        if ( newLocation.horizontalAccuracy < lastLocation.horizontalAccuracy ) 
            lastLocation = newLocation;
    }
    
    locationCount++;
    
    netlog(@"%d | Updating location %@\n",locationCount,[lastLocation description]);
    
    if ( isFirstStart == YES ) {
        [self sendLocation];
        isFirstStart = NO;
        isUpdating = NO;
        [self.eventSink updateStats:lastLocation updateView:YES];
    }
}


- (void) initUpdateInterval {
    updateInterval = [gwUtil getFrequency:beaconID];
    if ( updateInterval <= 0 ) updateInterval = 10; // минут
    updateInterval *= 60;
    //updateInterval = 30;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    netlog(@"applicationWillEnterForeground\n");
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    [uDef setBool:NO forKey:@"Background"];
    [uDef synchronize];
    [self.locMgr stopUpdatingLocation];
    
    if ( locationCount > 0 ) {
        [self.eventSink updateStats:lastLocation updateView:NO];
        [self sendLocation];
    }
    // что б выйти из фонового цикла
    inBackground = NO;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    [uDef setBool:NO forKey:@"Background"];
    [uDef synchronize];
   
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
