//
//  Toast.m
//  eyeNeverLost
//
//  Created by Snow Leopard User on 17/08/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Toast.h"


@implementation Toast 

-(id)init {
    self = [super init];
    return self;
    
}

+(void)showProgress:(NSString*)title message:(NSString*)msg executionBlock:(dispatch_block_t)block completionBlock:(dispatch_block_t)completion {
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *hud;

    hud = [[MBProgressHUD alloc] initWithWindow:window];
    hud.labelText = title;
    hud.detailsLabelText = msg;
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.animationType = MBProgressHUDAnimationZoom;
    [window addSubview:hud];
    [hud showAnimated:YES whileExecutingBlock:block completionBlock:completion];
}

+(void)showMessage:(NSString*)title message:(NSString*)msg {

    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *hud;
    hud = [[MBProgressHUD alloc] initWithWindow:window];
    hud.labelText = title;
    hud.detailsLabelText = msg;
    hud.mode = MBProgressHUDModeText;
    [window addSubview:hud];
    [hud show:YES];
    [hud hide:YES afterDelay:1.5 block:^{ 
    }];
}

+ (void) message:(NSString*) title formatStr:(NSString*) fmtStr,... {
	va_list argList;
	va_start(argList,fmtStr);
	NSString *message = [[NSString alloc] initWithFormat:fmtStr arguments:argList]; 
	va_end(argList);
    [Toast showMessage:title message:message];
}

@end
