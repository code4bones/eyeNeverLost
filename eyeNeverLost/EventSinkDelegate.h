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
-(void)updateStats:(CLLocation*)loc updateView:(BOOL)updateView;

-(NSMutableArray*) getBeacons:(id)obj;
-(void) beaconSelected:(BeaconObj*)beaconObj;
-(NSString*)getStatusString;
-(void)addBeacon;
-(void)beaconAdded:(BeaconObj*)beacon sender:(id)obj;
-(void)registrationComplete:(BeaconObj*)beacon;
-(void)selectTab:(int)index;
-(BeaconObj*)getCurrentBeacon;

@end
