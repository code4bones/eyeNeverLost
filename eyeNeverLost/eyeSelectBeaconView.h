//
//  eyeSelectBeaconView.h
//  eyeNeverLost
//
//  Created by Snow Leopard User on 07/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventSinkDelegate.h"
#import "MBProgressHUD/MBProgressHUD.h"

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@interface eyeSelectBeaconView : UIView<UIActionSheetDelegate,
UIPickerViewDelegate,UIPickerViewDataSource> {
    UIActionSheet *actionSheet;
    NSMutableArray *arBeacon;
    id<EventSinkDelegate> dataSource;
    int nBeaconIdx;
    UIPickerView *pickerView;
    MBProgressHUD *HUD;
}

//-(void)fetchBeacons;
- (id)initWithFrameAndDataSource:(CGRect)frame dataSource:(id)dataSrc;

@property (strong,retain) UIActionSheet *actionSheet;
@property (strong,retain) id dataSource;

@end
