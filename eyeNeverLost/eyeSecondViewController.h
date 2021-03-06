//
//  eyeSecondViewController.h
//  eyeNeverLost
//
//  Created by Snow Leopard User on 04/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventSinkDelegate.h"
#import "NetLog/NetLog.h"

@interface eyeSecondViewController : UIViewController<EventSinkDelegate,UITextFieldDelegate>
{
    UILabel *lbLatitude;
    UILabel *lbLongitude;
    UILabel *lbAccuracy;
    UILabel *lbTime;
    UILabel *lbCount;
    UILabel *lbInterval;
    NSDateFormatter *dateFormatter;
    UITextField *txtStatus;
    int nUpdateCount;
    CLLocation *clLocation;
}


@property (strong,retain) CLLocation *clLocation;
@property (strong,retain) IBOutlet UITextField *txtStatus;
@property (strong,retain) IBOutlet UILabel *lbLatitude;
@property (strong,retain) IBOutlet UILabel *lbLongitude;
@property (strong,retain) IBOutlet UILabel *lbAccuracy;
@property (strong,retain) IBOutlet UILabel *lbTime;
@property (strong,retain) IBOutlet UILabel *lbCount;
@property (strong,retain) IBOutlet UILabel *lbInterval;


-(void) update:(id)obj;

@end
