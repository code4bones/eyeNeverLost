//
//  UDPLog.h
//  eyeSMS
//
//  Created by pete on 04/06/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CFNetwork/CFNetwork.h>

@interface NetLog : NSObject {

}

+(void)setupFromBundle;
+(void)setup:(NSString*)loggerHost loggerPort:(int)logPort protoTCP:(BOOL)isTCP;
+(void)log:(NSString*)formatString,...;
+(void)send:(NSData*) data; 
+ (void) alert:(NSString*) fmtStr,...;
+ (void) alert2:(NSString*) title formatStr:(NSString*) fmtStr,...;
+(void) debugPID;

@end

#define alert(title,...) [NetLog alert2:title formatStr:__VA_ARGS__]
#define netlog_alert(...) [NetLog alert:__VA_ARGS__]
#define netlog(...) [NetLog log:__VA_ARGS__]
#define netsend(data) [NetLog send:data]