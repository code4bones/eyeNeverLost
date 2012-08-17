//
//  fastRegistrationController.m
//  eyeNeverLost
//
//  Created by Snow Leopard User on 16/08/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "fastRegistrationController.h"

@implementation fastRegistrationController
@synthesize txtLogin,txtPassword,txtPassword2,txtName,btnRegister,btnLink,swAccept,btnCancel;
@synthesize eventSink;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        /*
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
         */
    }
    return self;
}

-(BOOL)checkValue:(UITextField*)textField value:(NSString**)val message:(NSString*)msg {
    
    *val = [NSString stringWithString:[textField text]];
    if ( [*val length] == 0 ) {
        alert(@"Ошибка",@"Не заполнено поле %@",msg);
        return NO;
    }
    return YES;
}

-(IBAction) onLink:(id)seneder {
    NSString *sURL = @"http://www.tygdenakarte.ru/oferta.html";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sURL]];
}

-(IBAction) onRegister:(id)sender {
    NSString *sLogin;
    NSString *sPassword;
    NSString *sPassword2;
    NSString *sName;

    if ( [self checkValue:txtLogin value:&sLogin message:@"Логин"] == NO )
        return;
    if ( [self checkValue:txtPassword value:&sPassword message:@"Пароль"] == NO )
        return;
    if ( [self checkValue:txtPassword2 value:&sPassword2 message:@"Повторный пароль"] == NO )
        return;
    if ( [self checkValue:txtName value:&sName message:@"Имя телефона"] == NO )
        return;
        
    if ( [ sPassword compare:sPassword2 ] != 0 ) {
        alert(@"Ошибка",@"Пароли не совпадают");
        return;
    }

    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    [uDef setValue:sLogin forKey:@"Login"];
    [uDef setValue:sPassword forKey:@"Password"];
    [uDef setValue:sName forKey:@"beaconName"];
    [uDef synchronize];
    
    GatewayUtil *gw = [[GatewayUtil alloc]init];
    
    __block BeaconObj *beacon;
    HUD = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
    HUD.labelText = @"Подождите";
    HUD.detailsLabelText = @"Идет обработка данных...";
    HUD.mode = MBProgressHUDModeText; //Determinate;//MBProgressHUDModeAnnularDeterminate;
    HUD.delegate = self;
    [self.view.window addSubview:HUD];
    [HUD showAnimated:YES whileExecutingBlock:^{ 
        beacon = [gw fastRegistration:sLogin password:sPassword beaconName:sName];
    } completionBlock:^{
        [HUD removeFromSuperview];
        if ( beacon == nil ) alert(@"Ошибка",@"Ошибка регистрации %@",[gw.response objectForKey:@"msg"]);
        else  
            [self.eventSink registrationComplete:beacon];
    }];
}

-(IBAction) onAcceptChanged:(id)sender {
    [btnRegister setEnabled:[swAccept isOn]];
}

-(IBAction) onCancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	
    
    [theTextField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [btnRegister setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [swAccept setOn:NO];
    [btnRegister setEnabled:NO];
    
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

#define VIEWPORT_SIZE 320  
#define KEYBOARD_HEIGHT 215  
#define TOOLBAR_HEIGHT 44  
#define KEYBOARD_TRANSITION_DURATION 0.3

-(void)moveView:(BOOL)moveUp {

    CGRect rect = self.view.frame;

    netlog(@"Origin %d\n",rect.origin.y);
           
    if ( moveUp == YES ) {
        rect.origin.y -= 215;
        rect.size.height += 215;
    } else {
        rect.origin.y += 215;
        rect.size.height -= 215;
    }
    
    [UIView beginAnimations:nil context:nil];  
	[UIView setAnimationDuration:KEYBOARD_TRANSITION_DURATION];  
    self.view.frame = rect;
	[UIView commitAnimations];	

}

- (void)textFieldDidBeginEditing:(UITextField *)textField {           
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone)
        return;
    if ( textField == txtName ) {
        [self moveView:YES];
    } else {
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {          // return YES to allow 
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone)
        return YES;
    
    if ( textField == txtName ) {
        [self moveView:NO];
    } else {
    }
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)note {
}

- (void)keyboardWillHide:(NSNotification *)note {
}
	

@end
