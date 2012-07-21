//
//  eyeSelectBeaconController.h
//  eyeNeverLost
//
//  Created by Snow Leopard User on 21/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventSinkDelegate.h"
#import "MBProgressHUD/MBProgressHUD.h"

@interface eyeSelectBeaconController : UIViewController<UITableViewDelegate>	
{
    NSMutableArray *arBeacon;
    BeaconObj *currentBeacon;
    id<EventSinkDelegate> dataSource;
    MBProgressHUD *HUD;
    UITableView *tbView;
    UIToolbar *toolBar; 
    UIView *hudView;
}

@property (strong,retain) UIView *hudView;
@property (strong,retain) IBOutlet UIToolbar* toolBar;
@property (strong,retain) IBOutlet UITableView* tbView;
@property (strong,retain) id dataSource;

-(IBAction)onToolbarButtonClicked:(id)sender;

@end
