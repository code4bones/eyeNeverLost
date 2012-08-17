//
//  addBeaconController.m
//  eyeNeverLost
//
//  Created by Snow Leopard User on 15/08/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "addBeaconController.h"

@implementation addBeaconController
@synthesize btnAdd,txtName,btnCancel,eventSink;

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
    
    __block BeaconObj *beacon;
    
    exec_progress(@"Добавление телефона",@"",^{ 
        beacon = [gw addBeacon:sLogin password:sPassword beaconName:sName]; 
    } , ^{
        if ( beacon == nil )
            alert(@"Ошибка",@"%@",[gw.response objectForKey:@"msg"]);
        [self.eventSink beaconAdded:beacon sender:self]; 
    });
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
