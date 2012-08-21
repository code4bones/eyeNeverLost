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
        gw = [[ GatewayUtil alloc]init];

        self.title = @"КАРТА";
        
        //mapView.showsUserLocation = NO;
   
        //NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
        //[uDef setValue:nil forKey:@"seatMateID"];
        //[uDef setValue:nil forKey:@"seatMateName"];
        //[uDef synchronize];
    }
    
    return self;
}

-(NSMutableArray*)getBeacons:(id)sender {
    
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    NSString *sLogin    = [uDef stringForKey:@"Login"];
    NSString *sPassword = [uDef stringForKey:@"Password"];
    return [gw getBeaconList:sLogin password:sPassword];
}

-(void)beaconSelected:(BeaconObj*)beacon {
    
    NSUserDefaults *uDef = [NSUserDefaults standardUserDefaults];
    beaconObj = beacon;
    //[uDef setValue:beaconObj.uid forKey:@"seatMateID"];
    //[uDef setValue:beaconObj.name forKey:@"seatMateName"];
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

-(void)showBeacon:(BeaconObj*)beacon {
   
    mapView.showsUserLocation = NO;

    if ( beacon == nil ) {
        NSString *msg = [gw.response objectForKey:@"msg"];
        toast(@"Внимание",@"Нет записей о положении %@ ( %@ ) %@", beaconObj.name,beaconObj.uid,msg == nil?@"":msg);
        return;
    }
    
    lbTitle.text = [NSString stringWithFormat:@"%@ // %@",beaconObj.name,beacon.date];
    
    
    NSMutableArray *annotationsToRemove = [[NSMutableArray alloc] initWithArray: mapView.annotations]; 
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
    
    // иногда в базу попадает отрицательна, целочисленная точнонсть - хз что это такое...
    if ( accuracy > 0 ) {
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:coord radius:accuracy];
        [mapView addOverlay:circle];
    }
    
    
    CLLocationCoordinate2D centerCoord = coord; 
    [mapView setCenterCoordinate:centerCoord zoomLevel:15 animated:YES];    
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
