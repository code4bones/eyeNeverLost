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

@interface eyeMapViewController : UIViewController<EventSinkDelegate,MKMapViewDelegate> {

    MKMapView *mapView;
    UIToolbar *tbTop;  
    UIActionSheet *actionSheet;        
    UILabel *lbTitle;
}


@property (strong,retain) IBOutlet UILabel *lbTitle;
@property (strong,retain) IBOutlet UIActionSheet *actionSheet;
@property (strong,retain) IBOutlet MKMapView *mapView;
@property (strong,retain) IBOutlet UIToolbar *tbTop;

-(IBAction) onSelectBuddie:(id)sender;
-(IBAction) onRefreshBuddie:(id)sender;
    
@end
