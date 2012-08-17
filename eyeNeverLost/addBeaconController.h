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
#import "Toast.h"
#import "EventSinkDelegate.h"

@interface addBeaconController : UIViewController<UITextFieldDelegate> {
    UIButton *btnAdd;
    UITextField *txtName;
    UIButton *btnCancel;
    id<EventSinkDelegate> eventSink;
    
}

@property(strong,retain) id eventSink;
@property(strong,retain) IBOutlet UIButton *btnCancel;
@property(strong,retain) IBOutlet UIButton *btnAdd;
@property(strong,retain) IBOutlet UITextField *txtName;

-(IBAction) onAdd:(id)sender;
-(IBAction) onCancel:(id)sender;

@end
