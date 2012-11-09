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
@synthesize mapView,tbTop,actionSheet,lbTitle,eventSink;
@synthesize btnCenterSelf,btnCenterBeacon,btnCenterAll;
@synthesize routeLine,polylineView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        gw = [[ GatewayUtil alloc]init];

        self.title = @"КАРТА";
        mapView.showsUserLocation = YES;
        beaconObj = nil;
        bShowRoute = NO;
        baloonMode = 2;
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated {    // Called when the view is about to made visible. 
    if ( beaconObj == nil ) {
        beaconObj = [eventSink getCurrentBeacon];
        if ( beaconObj != 0 ) {
            netlog(@"viewWillAppear with beacon =  %@\n",beaconObj.name);
            [self onRefreshBuddie:nil];
        } else {
            netlog(@"viewWillAppear without beacon !\n");
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    netlog(@"did apperar\n");
}

-(NSMutableArray*)getBeacons:(id)sender {
    
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    NSString *sLogin    = [uDef stringForKey:@"Login"];
    NSString *sPassword = [uDef stringForKey:@"Password"];
    return [gw getBeaconList:sLogin password:sPassword];
}

-(void)beaconSelected:(BeaconObj*)beacon {
    beaconObj = beacon;
    [self onRefreshBuddie: nil];               
}

-(IBAction) onCenterSelf:(id)sender {
    netlog(@"Centering on self\n");
    // self location
    CLLocationCoordinate2D coord = mapView.userLocation.location.coordinate;
    [mapView setCenterCoordinate:coord zoomLevel:15 animated:YES];     
    baloonMode = 0;
    [self showBaloon:baloonMode];
}

-(IBAction) onCenterBeacon:(id)sender {
    netlog(@"Centering on beacon\n");
    if ( beaconObj != nil ) {
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([beaconObj.latitude doubleValue],[beaconObj.longitude doubleValue]);
        [mapView setCenterCoordinate:coord zoomLevel:15 animated:YES];     

        baloonMode = 1;
        [self showBaloon:baloonMode];
    }
    //onRefreshBuddie:(id)sender
    //baloonMode = 1;
    //[self onRefreshBuddie:beaconObj];
    //[self showBaloon:baloonMode];

}

-(IBAction) onCenterAll:(id)sender {
    
    bShowRoute = !bShowRoute;
    [btnCenterAll setSelected:bShowRoute];

    if ( bShowRoute != YES ) {
        NSArray *overlays = [self.mapView overlays];
        [self.mapView removeOverlays:overlays];
        return;
    }
    
    
    CLLocationCoordinate2D coordinateArray[2];
    coordinateArray[0] = mapView.userLocation.coordinate; //CLLocationCoordinate2DMake(lat1, lon1); 
    if ( beaconObj != nil )
        coordinateArray[1] = CLLocationCoordinate2DMake([beaconObj.latitude doubleValue],[beaconObj.longitude doubleValue]);
    else
        coordinateArray[1] = mapView.userLocation.coordinate;
        
    self.routeLine = [MKPolyline polylineWithCoordinates:coordinateArray count:2];
    [self.mapView setVisibleMapRect:[self.routeLine boundingMapRect]]; //If you want the route to be visible
    
    [self.mapView addOverlay:self.routeLine];

    baloonMode = 2;
    [self showBaloon:baloonMode];
    
}


-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay 
{
    if ( overlay == self.routeLine ) {
        if ( self.polylineView == nil ) {
            self.polylineView = [[MKPolylineView alloc] initWithPolyline:self.routeLine];
            self.polylineView.fillColor = [UIColor redColor];
            self.polylineView.strokeColor = [UIColor redColor];
            self.polylineView.lineDashPhase = 10;
            NSArray* array = [NSArray arrayWithObjects:[NSNumber numberWithInt:20], [NSNumber numberWithInt:20], nil];
            self.polylineView.lineDashPattern = array;
            self.polylineView.lineWidth = 5;           
            
        }
        return self.polylineView;
    } else {
        MKCircleView* circleView = [[MKCircleView alloc] initWithOverlay:overlay];
        circleView.fillColor = [UIColor blueColor];
        circleView.strokeColor = [UIColor redColor];
        circleView.lineWidth = 0.5;
        circleView.alpha = 0.1;
        return circleView;
    }
    return nil;
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation 
{
    MKPinAnnotationView *annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
    MKPointAnnotation *pta = annotation;
    if ( pta.coordinate.latitude == self.mapView.userLocation.coordinate.latitude && 
        pta.coordinate.longitude == self.mapView.userLocation.coordinate.longitude ) 
    {
        annView.pinColor = MKPinAnnotationColorRed;
        pta.title = @"Мое местоположение";
    } else {
        pta.title = [NSString stringWithFormat:@"%@ // %@",beaconObj.name,beaconObj.date];
        pta.subtitle = beaconObj.status;
        annView.pinColor = MKPinAnnotationColorGreen;
    }
    
    annView.animatesDrop = NO;
    annView.canShowCallout = YES;
    annView.calloutOffset = CGPointMake(0, 0);
    [annView setSelected:YES animated:YES];
    return annView;
}

-(void)showBeacon:(BeaconObj*)beacon {
   
    if ( beacon == nil ) {
        NSString *msg = [gw.response objectForKey:@"msg"];
        alert(@"Внимание!",@"%@",msg);
        return;
    }
    beaconObj.latitude = beacon.latitude;
    beaconObj.longitude = beacon.longitude;
    beaconObj.accuracy = beacon.accuracy;
    beaconObj.date = beacon.date;
    beaconObj.status = beacon.status;
    
    lbTitle.text = [NSString stringWithFormat:@"%@ // %@",beaconObj.name,beacon.date];
    
    NSMutableArray *annotationsToRemove = [[NSMutableArray alloc] initWithArray: mapView.annotations]; 

    // remove from annotaons to remove list the user location
    [annotationsToRemove removeObject: mapView.userLocation]; 
    [mapView removeAnnotations: annotationsToRemove];
    
    NSMutableArray *overlaysToRemove = [[NSMutableArray alloc] initWithArray: mapView.overlays]; 
    [mapView removeOverlays: overlaysToRemove];
    
    
    CLLocationCoordinate2D coord; 
    coord.latitude =  [beacon.latitude doubleValue];
    coord.longitude = [beacon.longitude doubleValue];
    double accuracy = [beacon.accuracy doubleValue];
    
    MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
    annotationPoint.coordinate = coord;
    annotationPoint.title = beacon.name;
    annotationPoint.subtitle = [NSString stringWithFormat:@"%@ // %@",beacon.status,beacon.date];
    
    
    [mapView addAnnotation:annotationPoint]; 
    
    //[mapView setSelectedAnnotations:[mapView annotations]];
    [self showBaloon:baloonMode];
    // иногда в базу попадает отриц, хз что это такое...
    if ( accuracy > 0 ) {
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:coord radius:accuracy];
        [mapView addOverlay:circle];
    }
    
    
    CLLocationCoordinate2D centerCoord = coord; 
    [mapView setCenterCoordinate:centerCoord zoomLevel:15 animated:YES];    
}

-(void)showBaloon:(int)idx {
    NSMutableArray *arr = [[NSMutableArray alloc] init];//WithArray: mapView.annotations]; 
    MKUserLocation *user = [mapView userLocation];
    NSMutableArray *all =  [[NSMutableArray alloc] initWithArray:[mapView annotations]];
    NSMutableArray *toShow;
    if ( idx == 0 ) // user
    {
        [arr addObject:user];
        toShow = arr;
    } else if ( idx == 1 ) // beacon 
    {
        [all removeObject:user];
        toShow = all;
    } else 
    { // both
        toShow = all;
        
    }
    [mapView setSelectedAnnotations:toShow];
}

-(IBAction) onRefreshBuddie:(id)sender {
    
    __block BeaconObj *beacon;
    
    exec_progress(@"Запрос положения",@"Получение последнего местоположения с сервера",^{
        beacon = [gw getLastBeaconLocation:beaconObj.uid];
    },^{
        [self showBeacon:beacon];
    });
}

-(IBAction) onSelectBuddie:(id)sender {

    // Выбор маячины
	eyeSelectBeaconController *selectBeacon = [[eyeSelectBeaconController alloc] initWithNibName:@"eyeSelectBeaconController" isMap:YES];
	
    selectBeacon.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
 	selectBeacon.dataSource = self;
 	
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
