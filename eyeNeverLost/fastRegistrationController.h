//
//  fastRegistrationController.h
//  eyeNeverLost
//
//  Created by Snow Leopard User on 16/08/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetLog/NetLog.h"
#import "GatewayUtil/GatewayUtil.h"
#import "MBProgressHUD/MBProgressHUD.h"
#import "EventSinkDelegate.h"

@interface fastRegistrationController : UIViewController<UITextFieldDelegate,MBProgressHUDDelegate> {
    UITextField *txtLogin;
    UITextField *txtPassword;
    UITextField *txtPassword2;
    UITextField *txtName;
    UIButton    *btnLink;
    UIButton    *btnRegister;
    UIButton    *btnCancel;
    UISwitch    *swAccept;
    MBProgressHUD *HUD;
    id<EventSinkDelegate> eventSink;
}


@property (strong,nonatomic) IBOutlet UITextField *txtLogin;
@property (strong,nonatomic) IBOutlet UITextField *txtPassword;
@property (strong,nonatomic) IBOutlet UITextField *txtPassword2;
@property (strong,nonatomic) IBOutlet UITextField *txtName;
@property (strong,nonatomic) IBOutlet UIButton    *btnLink;
@property (strong,nonatomic) IBOutlet UIButton    *btnRegister;
@property (strong,nonatomic) IBOutlet UIButton    *btnCancel;
@property (strong,nonatomic) IBOutlet UISwitch    *swAccept;
@property (strong,nonatomic) id eventSink;

-(IBAction) onLink:(id)seneder;
-(IBAction) onRegister:(id)sender;
-(IBAction) onAcceptChanged:(id)sender;
-(IBAction) onCancel:(id)sender;

-(void)moveView:(BOOL)moveUp;
-(BOOL)checkValue:(UITextField*)textField value:(NSString**)val message:(NSString*)msg;

@end
