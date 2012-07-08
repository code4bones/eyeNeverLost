//
//  main.m
//  eyeNeverLost
//
//  Created by Snow Leopard User on 04/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "eyeAppDelegate.h"
#import "NetLog/NetLog.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        [NetLog setupFromBundle];
        netlog(@"eyeNeverLost started...\n");
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([eyeAppDelegate class]));
    }
}
