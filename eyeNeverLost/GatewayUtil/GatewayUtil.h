//
//  GatewayUtil.h
//  
//
//  Created by Snow Leopard User on 04/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#import "../NetLog/NetLog.h"
#import "../TBXML/TBXML-Headers/TBXML.h"
#import "../TBXML/TBXML-Headers/TBXML+HTTP.h"

#include <netinet/in.h>

enum kLocationModes {
 kGPS = 1,
 kGSM, 
 kHYBRID = 3
};

@interface BeaconObj : NSObject {
    NSString *name;
    NSString *uid;
    NSString  *date;
    NSNumber *latidude;
    NSNumber *longitude;
    NSString *status;
    NSNumber *accuracy;
    
}
@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *uid;
@property (nonatomic,retain) NSNumber *latitude;
@property (nonatomic,retain) NSNumber *longitude;
@property (nonatomic,retain) NSString   *date;
@property (nonatomic,retain) NSString *status;
@property (nonatomic,retain) NSNumber *accuracy;

+(BeaconObj*) createWithString:(NSString*)src;
+(BeaconObj*) createWithLocationString:(NSString*)src;
@end

// http helpers
@interface GatewayUtil : NSObject {
    NSMutableDictionary *response;
    NSString *deviceID;
}

@property(nonatomic,retain) NSMutableDictionary* response;
@property(nonatomic,retain) NSString *deviceID;

-(id)init;

-(BOOL) Authorization:(NSString *)login password:(NSString*)pass beaconID:(NSString*)beaconID;
-(NSMutableArray*)getBeaconList:(NSString *)login password:(NSString*)pass;
-(int)getFrequency:(NSString*)deviceID;
-(BOOL)saveLocation:(NSString*)beaconID longitude:(float)lng latitude:(float)lat precision:(float)prec status: (NSString*)stat date:(NSDate*)when error:(NSString**)error; 
-(NSMutableArray*)getSeatMates:(NSString*)beaconID;
-(BeaconObj*)getLastBeaconLocation:(NSString*)beaconID;
-(BOOL)sendOfflineFile:(NSString*)offlineFile;
-(BeaconObj*)addBeacon:(NSString*)login password:(NSString*)pass beaconName:(NSString*)name;
-(BOOL)notifySimChanged:(NSString*)beaconID simInfo:(CTCarrier*)ct changed:(BOOL)chng;
-(BeaconObj*)fastRegistration:(NSString*)sLogin password:(NSString*)sPassword beaconName:(NSString*)sName;

// Utility / Common
-(TBXMLElement*) xmlGetElement:(NSString*)sName parentNode:(TBXMLElement*)parent;
-(BOOL) sendRequest:(NSString*)sURL;
-(BOOL) sendRequestWithActivity:(NSString*)sURL;
-(NSMutableArray*) beaconParseResponse:(NSString *)srcStr outList:(NSMutableArray *)list;
+ (BOOL) isConnected;
+ (int) getBatteryLevel;
+ (BOOL) checkGPS;

@end






