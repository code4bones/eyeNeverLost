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
#import "addBeaconController.h"
#import "EventSinkDelegate.h"

@interface eyeSelectBeaconController : UIViewController<EventSinkDelegate,UITableViewDelegate,MBProgressHUDDelegate>	
{
    NSMutableArray *arBeacon;
    BeaconObj *currentBeacon;
    id<EventSinkDelegate> dataSource;
    MBProgressHUD *HUD;
    UITableView *tbView;
    UIToolbar *toolBar; 
    UIView *hudView;
    //NSOperationQueue *opQueue;
    BOOL isMapMode;
}

@property (strong,retain) UIView *hudView;
@property (strong,retain) IBOutlet UIToolbar* toolBar;
@property (strong,retain) IBOutlet UITableView* tbView;
@property (strong,retain) id dataSource;

- (id)initWithNibName:(NSString *)nibNameOrNil isMap:(BOOL)mapMode;
-(IBAction)onBeaconSelected:(id)sender;
-(IBAction)onAddBeacon:(id)sender;
-(IBAction)onCancel:(id)seneder;

@end
