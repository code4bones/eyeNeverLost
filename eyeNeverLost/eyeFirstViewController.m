//
//  eyeFirstViewController.m
//  eyeNeverLost
//
//  Created by Snow Leopard User on 04/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "eyeFirstViewController.h"
#import "GatewayUtil/GatewayUtil.h"
#import "Toast.h"

@implementation eyeFirstViewController
@synthesize txtLogin,txtPassword,strBeaconID,btnActivate;
@synthesize actionSheet,lbVersion;
@synthesize eventSink,btnLink;
@synthesize activityInd;
@synthesize lbLogin,btnRegister;

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
        self.title = @"АКТИВАЦИЯ";
        
        NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
        
        BOOL isActive = [uDef boolForKey:@"Active"];
        if ( isActive == YES ) {
            netlog(@"Already Active");
        } else {
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
        
        [uDef synchronize];
        }
        [GatewayUtil getBatteryLevel];
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
}

/*
 метод-делегат для получения списка телефонов для UIPickerView
 вызывается из вспомогательного класса выбора телефонов eyeSelectBeaconView
 */
-(NSMutableArray*)getBeacons:(id)obj {
    
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    NSString *sLogin = [uDef stringForKey:@"Login"];
    NSString *sPassword = [uDef stringForKey:@"Password"];
    
    
    GatewayUtil *gw = [[GatewayUtil alloc] init];
    arBeacon = [gw getBeaconList:sLogin password:sPassword];
    
    if ( [arBeacon count] == 0 ) {
        toast(@"Ошибка",@"У Вас нет зарегестрированных телефонов...");
        return nil;
    }
        
        
    return arBeacon;
}

/*
 делегат, дергается когда в eyeSelectBeaconView был выбран телефон
 устанавливаем флаг активации и остальные параметры телефона в NSUserDefauts
 */
-(void)beaconSelected:(BeaconObj*)beaconObj {
    
    [self dismissModalViewControllerAnimated:YES];

    // хуячим свойтва
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    [uDef setValue:beaconObj.name forKey:@"beaconName"];
    [uDef setValue:beaconObj.uid  forKey:@"beaconID"];
        
    [uDef synchronize];
        
    // вызвать  
    [self startTracking];
}

/*
 Вызывает eyeSelectBeaconView для выбора активного телефона
 */
-(IBAction) onActivate:(id)sender {
    
    NSString *sLogin = [txtLogin text];
    NSString *sPassword = [txtPassword text];
    
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    
    if ( sLogin.length == 0 ) {
    toast(@"Введите логин...",@"");
        return;
    }
    if ( sPassword.length == 0 ) {
        toast(@"Введите пароль...",@"");	
        return;
    }
    
    if ( [GatewayUtil checkGPS] == NO )
        return;
    
    [uDef setValue:sLogin forKey:@"Login"];
    [uDef setValue:sPassword forKey:@"Password"];
    [uDef synchronize];

    BOOL fActive = [uDef boolForKey:@"Active"];
    if ( fActive ==YES )
    {
        [self stopTracking];
    } else {
    
        __block BOOL fOk;
        GatewayUtil *gw = [[GatewayUtil alloc] init];
        
        exec_progress(@"",@"",^{
            // проверка на существавание пользователя
            fOk =[gw Authorization:sLogin password:sPassword beaconID:nil];
        },^{
            if ( fOk == NO ) {
                NSString *msg = [gw.response objectForKey:@"msg"];
                if ( msg == nil ) msg = @"";
                toast(@"Ошибка",@"Ошибка авторизации...\n%@",msg);
            } else {
                // Выбор маячины
                eyeSelectBeaconController *selectBeacon = [[eyeSelectBeaconController alloc] initWithNibName:@"eyeSelectBeaconController" isMap:NO];
                selectBeacon.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                selectBeacon.dataSource = self;
                selectBeacon.hudView = self.view;
                [self presentModalViewController:selectBeacon animated:YES];
            }
        });
    }
}


-(void)registrationComplete:(BeaconObj*)beacon {

    [self dismissModalViewControllerAnimated:YES];
    
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    
    alert(@"Успешно",@"Информация о местоположении доступна в ЛК по адресу http://cabeenet.tygdenakarte.ru");
    
        
    txtLogin.text = [uDef stringForKey:@"Login"];
    txtPassword.text = [uDef stringForKey:@"Password"];
    [self beaconSelected:beacon];
}

-(IBAction)onRegisterBeacon {
    
    if ( [GatewayUtil checkGPS] == NO ) {
        return;
    }
    
    fastRegistrationController *fastRegistration = [[fastRegistrationController alloc] initWithNibName:@"fastRegistrationController" bundle:nil];
    fastRegistration.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    fastRegistration.eventSink = self;
    fastRegistration.modalPresentationStyle = UIModalPresentationPageSheet;

    [self presentModalViewController:fastRegistration animated:YES];
}

-(BeaconObj*)getCurrentBeacon {
    BeaconObj *obj = [[BeaconObj alloc]init];
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    obj.uid = [uDef stringForKey:@"beaconID"];
    obj.name = [uDef stringForKey:@"beaconName"];
    return obj;
}

/*
 Начинаем мониторить позицию
 */
-(void) startTracking {
    
    GatewayUtil *gw = [[GatewayUtil alloc]init];

    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    NSString *sLogin    = [uDef stringForKey:@"Login"];
    NSString *sPassword = [uDef stringForKey:@"Password"];
    NSString *beaconID  = [uDef stringForKey:@"beaconID"];
    
    [uDef setBool:NO forKey:@"Active"];
    [uDef synchronize];
    
    __block BOOL fOk = NO;
    exec_progress(@"Запуск Сервиса",@"",^{
        fOk = [gw Authorization:sLogin password:sPassword beaconID:beaconID];
    },^{
        
        if ( fOk == YES ) {
            // отсылаем запрос на вкючение мониторинга в eyeAppDelegate
            [self.eventSink controlLocation:YES];
            [self setStateLabel];
            [self.eventSink selectTab:1];
            toast(@"Успешно",@"Информация о местоположении доступна в ЛК по адресу http://cabeenet.tygdenakarte.ru");

            
        } else {
            NSString *msg = [gw.response objectForKey:@"msg"];
            NSString *rc  = [gw.response objectForKey:@"rc"];
            if ( msg == nil ) msg = rc;
            alert(@"Ошибка",@"Ошибка активации",@"%@",msg);                                                
        }
    });
}


-(void) stopTracking {
    netlog(@"Deactivate tracking...\n");
    
 
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    NSString *sLogin    = [uDef stringForKey:@"Login"];
    NSString *sPassword = [uDef stringForKey:@"Password"];
    __block BOOL fOk;
    
    GatewayUtil *gw = [[GatewayUtil alloc]init];
    
    exec_progress(@"Деактивация",@"",^{
   // Активация выбранного телефона
        fOk = [gw Authorization:sLogin password:sPassword beaconID:nil];
    },^{
	    if ( fOk == YES ) {
            // отсылаем запрос на выкючение мониторинга в eyeAppDelegate
            [self.eventSink controlLocation:NO];
            [self setStateLabel];
        } else {
            NSString *msg = [gw.response objectForKey:@"msg"];
            //if ( msg == nil )
              //  msg = [NSString stringWithFormat:@"%@",[gw.response objectForKey:@"rc"]];
            toast(@"Ошибка деактивации",@"%@",msg);                                                
        }
    });
    
    
}

- (void)setStateLabel {
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    NSString *sLabel;
    NSString *sTitle;
    
    BOOL fActive = [uDef boolForKey:@"Active"];
    if ( fActive == NO ) {
        sLabel = @"Логин";
        sTitle = @"Активировать";
        self.title = @"АКТИВАЦИЯ";
    } else {
        self.title = @"ДЕАКТИВАЦИЯ";
        NSString *sName  = [uDef stringForKey:@"beaconName"];
        sLabel = [NSString stringWithFormat:@"Логин / %@ - %@",sName,fActive == YES?@"Активирован":@"Деактивирован"]; 
        sTitle = fActive == YES?@"Деактивировать":@"Активировать";
    }
    [txtLogin setText:@""];
    [txtPassword setText:@""];
    [btnActivate setTitle:sTitle forState:0];
    [lbLogin setText:sLabel];
    [btnRegister setHidden:fActive];
     
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *sVersion = [info objectForKey:@"Version"];
    lbVersion.text = sVersion;

    [self setStateLabel];



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
