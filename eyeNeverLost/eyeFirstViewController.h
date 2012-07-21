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

@interface eyeFirstViewController : UIViewController<MBProgressHUDDelegate,UITextFieldDelegate,EventSinkDelegate>

{
    UITextField *txtLogin;
    UITextField *txtPassword;
    NSString    *strBeaconID;
    UIButton *btnSelectBeacon;
    UIButton *btnLink;
    UIActionSheet *actionSheet;
    NSMutableArray *arBeacon;
    UISegmentedControl *segMode;
    UILabel *lbVersion;
    UILabel *lbPhone;
    UILabel *lbMode;
    UILabel *lbInterval;
    UISwitch *onOff;
    int nBeaconIdx;
    id<EventSinkDelegate> eventSink;
    UIActivityIndicatorView *acivityInd;
    MBProgressHUD *HUD;
}

@property (strong,retain) UIActivityIndicatorView *activityInd;
@property (strong,retain) id eventSink;
@property (strong,retain) IBOutlet UISegmentedControl *segMode;
@property (strong,retain) IBOutlet UILabel*  lbMode;
@property (strong,retain) IBOutlet UIButton* btnLink;
@property (strong,retain) IBOutlet UILabel *lbPhone;
@property (strong,retain) IBOutlet UILabel *lbVersion;
@property (strong,retain) IBOutlet UIButton *btnSelectBeacon;
@property (strong,retain) IBOutlet UITextField *txtLogin;
@property (strong,retain) IBOutlet UITextField *txtPassword;
@property (strong,retain) IBOutlet UISwitch *onOff;
@property (strong,retain) NSString *strBeaconID;
@property (strong,retain) IBOutlet UILabel *lbInterval;
@property (strong,retain) UIActionSheet *actionSheet;

-(id)init;
-(IBAction) onSelectBeacon:(id)sender;
-(IBAction) onActivateChanged:(id)sender;
-(IBAction) onLinkClicked:(id)sender;
-(IBAction) onLocationModeChanged:(id)sender;

-(void)startTracking;
-(void)stopTracking;

@end





