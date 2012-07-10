//
//  eyeSelectBeaconView.m
//  eyeNeverLost
//
//  Created by Snow Leopard User on 07/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "eyeSelectBeaconView.h"
#import "GatewayUtil/GatewayUtil.h"
#import "NetLog/NetLog.h"

@implementation eyeSelectBeaconView
@synthesize actionSheet,dataSource;


- (id)initWithFrameAndDataSource:(CGRect)frame dataSource:(id)dataSrc;
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Выберете Телефон" 
                                                           delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Готово",nil];
        
        sheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        CGRect pickerFrame = CGRectMake(0, 100, 320, 200);
        pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
        pickerView.showsSelectionIndicator = YES;
        pickerView.dataSource = self;
        pickerView.delegate = self;
        [sheet addSubview:pickerView];
        
        [sheet showInView:self];
        
        [UIView beginAnimations:nil context:nil];
        [sheet setBounds:CGRectMake(0, 0, 320, 450)];//615
        [UIView commitAnimations];
        self.actionSheet = sheet; 
        self.dataSource = dataSrc;

	    HUD = [[MBProgressHUD alloc] initWithView:sheet.superview];
        HUD.labelText = @"Подождите";
        HUD.detailsLabelText = @"Идет обработка данных...";
        HUD.mode = MBProgressHUDModeText; //Determinate;//MBProgressHUDModeAnnularDeterminate;
        HUD.removeFromSuperViewOnHide = NO;
        [sheet.superview addSubview:HUD];
        
    }
    return self;
}

- (void)didMoveToSuperview {
    [HUD showAnimated:NO whileExecutingBlock:^{ 
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        arBeacon = [self.dataSource getBeacons:pickerView];
        if ( arBeacon != nil ) {
            netlog(@"got mates %d\n",[arBeacon count]);
        } else {
            alert(@"Внимание !",@"Нет данных !");
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } completionBlock: ^{
        [HUD hide:YES];
        if ( arBeacon != nil ) {
            [pickerView reloadAllComponents];
        }
    }];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    BeaconObj *obj = [arBeacon objectAtIndex:nBeaconIdx];
    //[HUD showAnimated:NO whileExecutingBlock:^{ 
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [self.dataSource beaconSelected:obj];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self removeFromSuperview];

    /*    
} completionBlock: ^{
        [HUD hide:YES];
        [self removeFromSuperview];
    }];*/
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [arBeacon count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    BeaconObj *obj = [arBeacon objectAtIndex:row];
    return obj.name;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    nBeaconIdx = row;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
