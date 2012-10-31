//
//  eyeMapViewController.h
//  eyeNeverLost
//
//  Created by Snow Leopard User on 06/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKMapView+ZoomLevel.h"
#import "EventSinkDelegate.h"
#import "eyeSelectBeaconController.h"
#import "Toast.h"

@interface eyeMapViewController : UIViewController<EventSinkDelegate,MKMapViewDelegate> {

    MKMapView *mapView;
    UIToolbar *tbTop;  
    UIActionSheet *actionSheet;        
    UILabel *lbTitle;
    UIButton *btnCenterSelf;
    UIButton *btnCenterBeacon;
    UIButton *btnCenterAll;
    BeaconObj* beaconObj;
    MKPolyline *routeLine;
    MKPolylineView *polylineView;
    GatewayUtil *gw;
    BOOL  bShowRoute;
    id<EventSinkDelegate> eventSink;
}

@property (strong,retain) id eventSink;
@property (strong,retain) IBOutlet UILabel *lbTitle;
@property (strong,retain) IBOutlet UIActionSheet *actionSheet;
@property (strong,retain) IBOutlet MKMapView *mapView;
@property (strong,retain) IBOutlet UIToolbar *tbTop;
@property (strong,retain) IBOutlet UIButton *btnCenterSelf;
@property (strong,retain) IBOutlet UIButton *btnCenterBeacon;
@property (strong,retain) IBOutlet UIButton *btnCenterAll;
@property (nonatomic,retain) MKPolyline *routeLine;
@property (nonatomic,retain) MKPolylineView *polylineView;


-(IBAction) onSelectBuddie:(id)sender;
-(IBAction) onRefreshBuddie:(id)sender;
-(IBAction) onCenterSelf:(id)sender;
-(IBAction) onCenterBeacon:(id)sender;
-(IBAction) onCenterAll:(id)sender;
-(void)showBeacon:(BeaconObj*)beacon;    

@end
