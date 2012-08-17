//
//  eyeSelectBeaconController.m
//  eyeNeverLost
//
//  Created by Snow Leopard User on 21/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "eyeSelectBeaconController.h"

@implementation eyeSelectBeaconController
@synthesize tbView,toolBar,dataSource,hudView;


//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
- (id)initWithNibName:(NSString *)nibNameOrNil isMap:(BOOL)mapMode
{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        isMapMode = mapMode;
    }
    return self;
}

-(void)beaconAdded:(BeaconObj*)beacon sender:(id)obj {
    [self.dataSource beaconSelected:beacon];
}

-(IBAction)onAddBeacon:(id)sender {
    netlog(@"select - Adding beacon\n");
    addBeaconController *addBeacon = [[addBeaconController alloc] initWithNibName:@"addBeaconController" bundle:nil];
    addBeacon.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    addBeacon.eventSink = self; 
    [self presentModalViewController:addBeacon animated:YES];
}

-(IBAction)onBeaconSelected:(id)sender {
    [self.dataSource beaconSelected:currentBeacon];
    if ( isMapMode == YES )
        [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)onCancel:(id)seneder {
    [self dismissModalViewControllerAnimated:YES];
}

// tell our table how many rows it will have, in 	our case the size of our menuList
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [arBeacon count];
}

// tell our table what kind of cell to use and its title for the given row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *kCellIdentifier = @"MyIdentifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	BeaconObj *beaconObj = [arBeacon objectAtIndex:indexPath.row];
	cell.textLabel.text = beaconObj.name;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	//UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    currentBeacon = [arBeacon objectAtIndex:indexPath.row];
    //cell.accessoryType = UITableViewCellAccessoryCheckmark;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Ваши телефоны";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 64.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {             // Default 
    return 1;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {

}

- (void)viewDidAppear:(BOOL)animated {    // Called when the view is about to made visible. 
    [super viewWillAppear:animated];

    netlog(@"Selecting beacons...\n");
    
    HUD = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
    HUD.labelText = @"Подождите";
    HUD.detailsLabelText = @"Идет обработка данных...";
    HUD.mode = MBProgressHUDModeText; //Determinate;//MBProgressHUDModeAnnularDeterminate;
    HUD.delegate = self;
    [self.view.window addSubview:HUD];
    [HUD showAnimated:YES whileExecutingBlock:^{ 
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        arBeacon = [self.dataSource getBeacons:nil];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } completionBlock: ^{
        [HUD removeFromSuperview];
        if ( arBeacon != nil && [arBeacon count] > 0 ) {
            [tbView reloadData];
            NSIndexPath *np = [NSIndexPath indexPathForRow:0 inSection:0];
            [tbView selectRowAtIndexPath:np animated:NO scrollPosition:UITableViewScrollPositionNone];
            currentBeacon = [arBeacon objectAtIndex:0];
        } else {
            alert(@"Информация",@"Нет зарегистрированных телефонов...");
        }
    }];	    

    
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
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ( isMapMode == NO )
        return;
    
    UIBarButtonItem *item;
    NSMutableArray *items  = [[toolBar items] mutableCopy]; 
    item = (UIBarButtonItem*)[items objectAtIndex:0];
    item.title = @"Выбрать";

    [items removeObjectAtIndex:1];
    [toolBar setItems:items];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
