//
//  eyeFirstViewController.m
//  eyeNeverLost
//
//  Created by Snow Leopard User on 04/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "eyeFirstViewController.h"
#import "GatewayUtil/GatewayUtil.h"
#import "eyeSelectBeaconView.h"

@implementation eyeFirstViewController
@synthesize txtLogin,txtPassword,strBeaconID,btnSelectBeacon;
@synthesize actionSheet,onOff,lbVersion,lbPhone;
@synthesize eventSink,btnLink,lbMode,segMode;

-(id)init {
    self = [super init];
    if ( self != nil ) {
        netlog(@"default init\n");
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.tabBarItem.image = [UIImage imageNamed:@"first"];
        //self.tabBarItem.title = @"СТАРТ";
        self.title = @"СТАРТ";
        
        NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
        // Запустили мониторинг позиции ?
        [uDef setBool:NO forKey:@"Active"];
        // выбрали активный телефон ?
        [uDef setBool:NO forKey:@"LoggedIn"];
        // имя телефона пользователя
        [uDef setValue:nil forKey:@"beaconName"];
        // идент телефона пользоватеья
        [uDef setValue:nil  forKey:@"beaconID"];
        // логинпароль
        [uDef setValue:nil forKey:@"Login"];
        [uDef setValue:nil  forKey:@"Password"];
        // режим - ушли в тень или нет
        [uDef setBool:NO forKey:@"Background"];
        
        // по умолчанию режим мониторинга берется из plist
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        NSString *sMode = [info objectForKey:@"LocationMode"];
        int nMode = kGPS;
        if ( sMode != nil ) {
            if ( [sMode isEqualToString:@"gsm"] )
                nMode = kGSM;
            else if ( [sMode isEqualToString:@"hybrid"] )
                nMode = kHYBRID;
        }
        
        // режим мониторинга ( изменяется переключателем из интерфейса )
        [uDef setInteger:nMode forKey:@"LocationMode"];
        [uDef setValue:sMode  forKey:@"LocationModeString"];
        [uDef synchronize];
    }
    return self;
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle

-(IBAction) onLinkClicked:(id)sender {
    NSString *sURL = [NSString stringWithFormat:@"http://%@",[btnLink currentTitle]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sURL]];
    netlog(@"Visiting the %@\n",sURL);
}

/*
 метод-делегат для получения списка телефонов для UIPickerView
 вызывается из вспомогательного класса выбора телефонов eyeSelectBeaconView
 */
-(NSMutableArray*)getBeacons {
    
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    NSString *sLogin = [uDef stringForKey:@"Login"];
    NSString *sPassword = [uDef stringForKey:@"Password"];
    
    // проверка на существавание пользователя
    GatewayUtil *gw = [[GatewayUtil alloc] init];
    if ( [gw Authorization:sLogin password:sPassword beaconID:nil] == NO ) {
        NSString *msg = [gw.response objectForKey:@"msg"];
        if ( msg == nil ) msg = @"";
        netlog_alert(@"Ошибка авторизации...\n%@",msg);
        return nil;
    }
    
    arBeacon = [gw getBeaconList:sLogin password:sPassword];
    
    if ( [arBeacon count] == 0 ) {
        netlog_alert(@"У Вас нет зарегестрированных телефонов...");
        return nil;
    }
    return arBeacon;
}

/*
 делегат, дергается когда в eyeSelectBeaconView был выбран телефон
 устанавливаем флаг активации и остальные параметры телефона в NSUserDefauts
 */
-(void)beaconSelected:(BeaconObj*)beaconObj {
    
    lbPhone.text = [NSString stringWithFormat:@"Телефон: %@ [ID:%@]",beaconObj.name,beaconObj.uid];
    
    // зачем-то получаем частоту обновления ( в коде она пока не юзается )
    GatewayUtil *gw = [[GatewayUtil alloc] init];
    int nInterval = [gw getFrequency:beaconObj.uid];
    if ( nInterval <= 0 )
        nInterval = 10; // минут

    // хуячим бикун в свойтва
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    [uDef setValue:beaconObj.name forKey:@"beaconName"];
    [uDef setValue:beaconObj.uid  forKey:@"beaconID"];
    [uDef setInteger:nInterval forKey:@"Interval"];
    // успешно выбрали телефон, считаем что мы активированы
    [uDef setBool:YES forKey:@"LoggedIn"];
    [uDef synchronize];
}

/*
 Вызывает eyeSelectBeaconView для выбора активного телефона
 */
-(IBAction) onSelectBeacon:(id)sender {
    
    NSString *sLogin = [txtLogin text];
    NSString *sPassword = [txtPassword text];
    
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    [uDef setValue:nil forKey:@"Login"];
    [uDef setValue:nil forKey:@"Password"];
    [uDef setBool:NO forKey:@"LoggedIn"];
    [uDef synchronize];
    
    if ( sLogin.length == 0 ) {
        netlog_alert(@"Введите логин...");
        return;
    }
    if ( sPassword.length == 0 ) {
        netlog_alert(@"Введите пароль...");
        return;
    }
    
    [uDef setValue:sLogin forKey:@"Login"];
    [uDef setValue:sPassword forKey:@"Password"];
    [uDef synchronize];
    
    // показываем вьюху для выбора телефона, будут вызваны делегаты getBeacons и beaconSelected 
    eyeSelectBeaconView *sb = [[eyeSelectBeaconView alloc] initWithFrameAndDataSource:CGRectMake(0,0,320,450) dataSource:self];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:sb];
}

/*
 Устанавливаем режим мониторинга ( GPS,GSM Hybrid )
 */
-(IBAction) onLocationModeChanged:(id)sender {
    // выбранный режим
    int nIdx = segMode.selectedSegmentIndex; 

    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    // режимы начинаются с 1
    [uDef setInteger:nIdx+1 forKey:@"LocationMode"];
    [uDef synchronize];
    
    NSString *sTitle = [segMode titleForSegmentAtIndex:nIdx]; 
    lbMode.text = sTitle;    
    [uDef setValue:sTitle forKey:@"LocationModeString"];
}

/*
 Начинаем мониторить позицию
 */
-(void) startTracking {
    netlog(@"Activating tracking...\n");
    
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    
    GatewayUtil *gw = [[GatewayUtil alloc]init];
    NSString *sLogin    = [uDef stringForKey:@"Login"];
    NSString *sPassword = [uDef stringForKey:@"Password"];
    NSString *beaconID  = [uDef stringForKey:@"beaconID"];
    
    // Активация выбранного телефона
    if ( [gw Authorization:sLogin password:sPassword beaconID:beaconID] == NO )
    {
        NSString *msg = [gw.response objectForKey:@"msg"];
        if ( msg == nil )
            msg = [NSString stringWithFormat:@"%@",[gw.response objectForKey:@"rc"]];
        netlog_alert(@"Ошибка Активации: %@",msg);                                                
        return;
    }
    
    // отсылаем запрос на вкючение мониторинга в eyeAppDelegate
    [self.eventSink controlLocation:YES];
    
    // нефиг ничего менять пока мониторим
    [btnSelectBeacon setEnabled:NO];
    [txtLogin setEnabled:NO];
    [txtPassword setEnabled:NO];
    [segMode setEnabled:NO];
}


-(void) stopTracking {
    netlog(@"Deactivate tracking...\n");
    // отсылаем запрос на выкючение мониторинга в eyeAppDelegate
    [self.eventSink controlLocation:NO];
    
    [btnSelectBeacon setEnabled:YES];
    [txtLogin setEnabled:YES];
    [txtPassword setEnabled:YES];
    [segMode setEnabled:YES];
}

/*
 Триггер включения-выключения мониторинга
 + проверка на валидность введенных логинпароля
 */
-(IBAction) onActivateChanged:(id)sender {
   
    if ( onOff.on == YES ) {
        NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
        if ( [uDef stringForKey:@"beaconID"] == nil ) {
            netlog_alert(@"Не выбран телефон...");
            onOff.on = NO;
        } else if ( [uDef stringForKey:@"Login"] == nil ) {
            netlog_alert(@"Введите логин...");
            onOff.on = NO;
        } else if ( [uDef stringForKey:@"Password"] == nil ) {
            netlog_alert(@"Введите пароль...");
            onOff.on = NO;
        }
        
        if ( onOff.on == YES )
            [self startTracking];
        
    } else {
        [self stopTracking];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *sVersion = [info objectForKey:@"Version"];
    lbVersion.text = sVersion;
    // Режим мониторинга по умолчанию
    lbMode.text = [info objectForKey:@"LocationMode"];    
    segMode.selectedSegmentIndex = [uDef integerForKey:@"LocationMode"] - 1;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	
    NSString *fieldName;
    NSString *fieldValue = [theTextField text];
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    
    if ( theTextField == txtLogin )
        fieldName = [NSString stringWithString:@"Login"];
    else if ( theTextField == txtPassword )
        fieldName = [NSString stringWithString:@"Password"];
    
    if ( [fieldValue length] == 0 )   
        [uDef setValue:nil forKey:fieldName];
    else
        [uDef setValue:fieldValue forKey:fieldName];
    
    [uDef synchronize];
    
	[theTextField resignFirstResponder];
    return YES;
}


@end
