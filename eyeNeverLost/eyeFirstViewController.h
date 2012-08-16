//
//  eyeFirstViewController.h
//  eyeNeverLost
//
//  Created by Snow Leopard User on 04/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "EventSinkDelegate.h"
#import "NetLog/NetLog.h"
#import "MBProgressHUD/MBProgressHUD.h"
#import "eyeSelectBeaconController.h"
#import "addBeaconController.h"
#import "fastRegistrationController.h"

@interface eyeFirstViewController : UIViewController<MBProgressHUDDelegate,UITextFieldDelegate,EventSinkDelegate>

{
    UITextField *txtLogin;
    UITextField *txtPassword;
    NSString    *strBeaconID;
    UIButton *btnActivate;
    UIButton *btnLink;
    UIButton *btnRegister;
    UIActionSheet *actionSheet;
    NSMutableArray *arBeacon;
    UILabel *lbVersion;
    UILabel *lbLogin;
    int nBeaconIdx;
    id<EventSinkDelegate> eventSink;
    UIActivityIndicatorView *acivityInd;
    MBProgressHUD *HUD;
}

@property (strong,retain) UIActivityIndicatorView *activityInd;
@property (strong,retain) id eventSink;
@property (strong,retain) IBOutlet UIButton* btnRegister;
@property (strong,retain) IBOutlet UIButton* btnLink;
@property (strong,retain) IBOutlet UILabel *lbVersion;
@property (strong,retain) IBOutlet UIButton *btnActivate;
@property (strong,retain) IBOutlet UITextField *txtLogin;
@property (strong,retain) IBOutlet UITextField *txtPassword;
@property (strong,retain) NSString *strBeaconID;
@property (strong,retain) IBOutlet UILabel *lbLogin;
@property (strong,retain) UIActionSheet *actionSheet;

-(id)init;
-(IBAction) onActivate:(id)sender;
-(IBAction) onLinkClicked:(id)sender;
-(IBAction) onRegisterBeacon;


-(void)startTracking;
-(void)stopTracking;
-(void)setStateLabel;

@end





