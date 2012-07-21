//
//  eyeMapViewController.m
//  eyeNeverLost
//
//  Created by Snow Leopard User on 06/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "eyeMapViewController.h"
#import "NetLog/NetLog.h"
#import "GatewayUtil/GatewayUtil.h"
#import "eyeSelectBeaconView.h"

@implementation eyeMapViewController
@synthesize mapView,tbTop,actionSheet,lbTitle;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Друг";
        
        mapView.showsUserLocation = NO;
   
        NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
        [uDef setValue:nil forKey:@"seatMateID"];
        [uDef setValue:nil forKey:@"seatMateName"];
        [uDef synchronize];
    }
    
    return self;
}

-(NSMutableArray*)getBeacons:(UIPickerView*)pickerView {
    
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    //NSString *beaconID  = [uDef stringForKey:@"beaconID"];
    NSString *sLogin    = [uDef stringForKey:@"Login"];
    NSString *sPassword = [uDef stringForKey:@"Password"];
    netlog(@"Fetching seatmates for %@/%@\n",sLogin,sPassword);
    GatewayUtil *gw = [[ GatewayUtil alloc]init];
    return [gw getBeaconList:sLogin password:sPassword];//[gw getSeatMates:beaconID];
}

-(void)beaconSelected:(BeaconObj*)beaconObj {
    
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    [uDef setValue:beaconObj.uid forKey:@"seatMateID"];
    [uDef setValue:beaconObj.name forKey:@"seatMateName"];
    [uDef synchronize];
    [self onRefreshBuddie: nil];               
}

-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay 
{
    MKCircleView* circleView = [[MKCircleView alloc] initWithOverlay:overlay];
    circleView.fillColor = [UIColor blueColor];
    circleView.strokeColor = [UIColor redColor];
    circleView.lineWidth = 0.5;
    circleView.alpha = 0.1;
    return circleView;
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
    MKPinAnnotationView *annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
    annView.pinColor = MKPinAnnotationColorGreen;
    annView.animatesDrop=TRUE;
    annView.canShowCallout = YES;
    annView.calloutOffset = CGPointMake(-5, 5);
    return annView;
}

-(IBAction) onRefreshBuddie:(id)sender {
    
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    NSString *seatMateID = [uDef stringForKey:@"seatMateID"];
    if ( seatMateID == nil )
        return;
    
    NSString *seatMateName = [uDef stringForKey:@"seatMateName"];
    
    GatewayUtil *gw = [[GatewayUtil alloc]init];
    BeaconObj *obj = [gw getLastBeaconLocation:seatMateID];
    if ( obj == nil ) {
        NSString *msg = [gw.response objectForKey:@"msg"];
        alert(@"Внимание",@"Нет записей о положении %@ ( %@ ) %@", seatMateName,seatMateID,msg == nil?@"":msg);
        return;
    }
    
    lbTitle.text = [NSString stringWithFormat:@"%@ // %@",seatMateName,obj.date];
    
    
    NSMutableArray *annotationsToRemove = [[NSMutableArray alloc] initWithArray: mapView.annotations]; 
    [annotationsToRemove removeObject: mapView.userLocation]; 
    [mapView removeAnnotations: annotationsToRemove];

    NSMutableArray *overlaysToRemove = [[NSMutableArray alloc] initWithArray: mapView.overlays]; 
    [mapView removeOverlays: overlaysToRemove];
    
    
    CLLocationCoordinate2D coord; 
    coord.latitude =  [obj.latitude doubleValue];
    coord.longitude = [obj.longitude doubleValue];
    double accuracy = [obj.accuracy doubleValue];
    
    MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
    annotationPoint.coordinate = coord;
    annotationPoint.title = seatMateName;
    annotationPoint.subtitle = [NSString stringWithFormat:@"%@ // %@",obj.status,obj.date];
    
    
    [mapView addAnnotation:annotationPoint]; 

    // иногда в базу попадает отрицательна, целочисленная точнонсть - хз что это такое...
    if ( accuracy > 0 ) {
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:coord radius:accuracy];
        [mapView addOverlay:circle];
    }
    
    
    CLLocationCoordinate2D centerCoord = coord; 
    [mapView setCenterCoordinate:centerCoord zoomLevel:15 animated:YES];    

    
}

-(IBAction) onSelectBuddie:(id)sender {

    
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    BOOL fLoggedIn = [uDef boolForKey:@"LoggedIn"];
    if ( fLoggedIn == NO ) {
        alert(@"Ошибка",@"Вы не авторизированны !");
        return;
    }
    
    // Выбор маячины
	eyeSelectBeaconController *selectBeacon = [[eyeSelectBeaconController alloc] initWithNibName:@"eyeSelectBeaconController" bundle:nil];
	
    selectBeacon.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    //UIModalTransitionStylePartialCurl;
    //UIModalTransitionStyleCrossDissolve;
    //UIModalTransitionStyleFlipHorizontal;
	selectBeacon.dataSource = self;
    selectBeacon.hudView = self.view;
	
	[self presentModalViewController:selectBeacon animated:YES];
}	


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
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
