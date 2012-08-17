//
//  Toast.h
//  eyeNeverLost
//
//  Created by Snow Leopard User on 17/08/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD/MBProgressHUD.h"

@interface Toast : NSObject {
}


-(id)init;

+(void)showMessage:(NSString*)title message:(NSString*)msg;
+ (void) message:(NSString*) title formatStr:(NSString*) fmtStr,...;
+(void)showProgress:(NSString*)title message:(NSString*)msg executionBlock:(dispatch_block_t)block completionBlock:(dispatch_block_t)completion;


#define toast(title,...) [Toast message:title formatStr:__VA_ARGS__]
#define exec_progress(title,msg,block,completion) [Toast showProgress:title message:msg executionBlock:block completionBlock:completion]


@end

/*
 dispatch_queue_t q = dispatch_queue_create("load",NULL);
 dispatch_async(q,^{
 
 arBeacon = [self.dataSource getBeacons:nil];
 
 dispatch_sync(dispatch_get_main_queue(),^{
 if ( arBeacon != nil && [arBeacon count] > 0 ) {
 [tbView reloadData];
 NSIndexPath *np = [NSIndexPath indexPathForRow:0 inSection:0];
 [tbView selectRowAtIndexPath:np animated:NO scrollPosition:UITableViewScrollPositionNone];
 currentBeacon = [arBeacon objectAtIndex:0];
 } else {
 alert(@"Информация",@"Нет зарегистрированных телефонов...");
 }
 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
 [HUD show:NO];
 });
 });
 dispatch_release(q);
 */
