//
//  EventSinkDelegate.h
//  eyeNeverLost
//
//  Created by Snow Leopard User on 05/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "GatewayUtil/GatewayUtil.h"

@protocol EventSinkDelegate <NSObject>
@optional

-(void)controlLocation:(BOOL)doStart;
-(void)updateStats:(CLLocation*)loc;

//@required
-(NSMutableArray*) getBeacons:(UIPickerView*)pickerView;
-(void) beaconSelected:(BeaconObj*)beaconObj;
-(NSString*)getStatusString;

@end
