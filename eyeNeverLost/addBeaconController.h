//
//  addBeaconController.h
//  eyeNeverLost
//
//  Created by Snow Leopard User on 15/08/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetLog/NetLog.h"
#import "GatewayUtil.h"
#import "MBProgressHUD/MBProgressHUD.h"

@interface addBeaconController : UIViewController<UITextFieldDelegate,MBProgressHUDDelegate> {
    UIButton *btnAdd;
    UISwitch *swAccept;
    UITextField *txtName;
    UIButton *btnInfo;
    UIButton *btnCancel;
    MBProgressHUD *HUD;
    
}

@property(strong,retain) IBOutlet UIButton *btnCancel;
@property(strong,retain) IBOutlet UIButton *btnAdd;
@property(strong,retain) IBOutlet UIButton *btnInfo;
@property(strong,retain) IBOutlet UISwitch *swAccept;
@property(strong,retain) IBOutlet UITextField *txtName;

-(IBAction) onAdd:(id)sender;
-(IBAction) onInfo:(id)sender;
-(IBAction) onAccept:(id)sender;
-(IBAction) onCancel:(id)sender;

@end
