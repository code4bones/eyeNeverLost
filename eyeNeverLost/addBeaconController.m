//
//  addBeaconController.m
//  eyeNeverLost
//
//  Created by Snow Leopard User on 15/08/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "addBeaconController.h"

@implementation addBeaconController
@synthesize btnAdd,btnInfo,swAccept,txtName,btnCancel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(IBAction) onAdd:(id)sender {
    GatewayUtil *gw = [[GatewayUtil alloc]init];
   
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    NSString *sLogin = [uDef stringForKey:@"Login"];
    NSString *sPassword = [uDef stringForKey:@"Password"];
    NSString *sName = [txtName text];      
    
    if ( [sName length] <= 0 ) {
        alert(@"Ошибка",@"Введите имя пользователя...");
        return;
    }
    __block BOOL fOk;
    HUD = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
    HUD.labelText = @"Подождите";
    HUD.detailsLabelText = @"Идет обработка данных...";
    HUD.mode = MBProgressHUDModeText; //Determinate;//MBProgressHUDModeAnnularDeterminate;
    HUD.delegate = self;
    [self.view.window addSubview:HUD];
    [HUD showAnimated:YES whileExecutingBlock:^{ 
        fOk = [gw addBeacon:sLogin password:sPassword beaconName:sName]; 
    } completionBlock:^{
        [HUD removeFromSuperview];
        if ( fOk == NO )
            alert(@"Ошибка",@"%@",[gw.response objectForKey:@"msg"]);
        else 
            alert(@"Инфо",@"Новый пользователь добавлен - %@",sName);
        [self dismissModalViewControllerAnimated:YES];
               
    }];
}

-(IBAction) onInfo:(id)sender {
    NSString *sURL = @"http://www.tygdenakarte.ru/oferta.html";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sURL]];
}

-(IBAction) onAccept:(id)sender {
    [btnAdd setEnabled:[swAccept isOn]];
}

-(IBAction) onCancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	
	[theTextField resignFirstResponder];
    return YES;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [btnAdd setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [swAccept setOn:NO];
    [btnAdd setEnabled:NO];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
