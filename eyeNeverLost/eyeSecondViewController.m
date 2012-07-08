//
//  eyeSecondViewController.m
//  eyeNeverLost
//
//  Created by Snow Leopard User on 04/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "eyeSecondViewController.h"
#import "NetLog/NetLog.h"
#import "GatewayUtil/GatewayUtil.h"

@implementation eyeSecondViewController

@synthesize lbLatitude,lbLongitude,lbAccuracy,lbTime,lbCount;
@synthesize lbInterval,txtStatus,clLocation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.title = NSLocalizedString(@"Second", @"Second");
        //self.tabBarItem.image = [UIImage imageNamed:@"second"];
        //self.tabBarItem.title = @"
        self.title = @"СТАТУС";
        self.clLocation = nil;
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];    
    
        nUpdateCount = 0;
    }
    return self;
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) controlLocation:(BOOL)onOff {
   if ( onOff == NO )
       return;
    
    nUpdateCount = 0;	
}
- (NSString*)getStatusString {
    return [self.txtStatus text];
}

- (void) updateStats:(CLLocation*)loc {
    self.clLocation = loc;
    nUpdateCount++;
    [self update:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    
	[theTextField resignFirstResponder];
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self update:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) update:(id)obj {

    if ( self.clLocation == nil )
        return;
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    NSString *sLat  = [NSString stringWithFormat:@"%.8f",self.clLocation.coordinate.latitude];
    NSString *sLng  = [NSString stringWithFormat:@"%.8f",self.clLocation.coordinate.longitude];
    NSString *sAcc  = [NSString stringWithFormat:@"%.2f м.",self.clLocation.horizontalAccuracy];
    NSString *sDate = [dateFormatter stringFromDate:self.clLocation.timestamp];
    NSString *sCount= [NSString stringWithFormat:@"%d",nUpdateCount];
    NSString *sInterval = [NSString stringWithFormat:@"%d мин.",[def integerForKey:@"Interval"]];
    
    self.lbLatitude.text = sLat;
    self.lbLongitude.text = sLng;
    self.lbAccuracy.text = sAcc;
    self.lbTime.text = sDate;
    self.lbCount.text = sCount;
    self.lbInterval.text = sInterval;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
