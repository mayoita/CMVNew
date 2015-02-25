//
//  CMVAppDelegate.h
//  Casinò di Venezia
//
//
//  Created by Massimo Moro on 25/10/13.
//  Copyright (c) 2013 Casinò di Venezia SPA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CMVEventKitController.h"
#import <Parse/Parse.h>


@interface CMVAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (nonatomic, readonly) int networkStatus;
@property (nonatomic, strong)CMVEventKitController *eventKit;

@property(strong,nonatomic)UIStoryboard *storyboard;
@property (strong, nonatomic) id<GAITracker> tracker;


- (BOOL)isParseReachable;
-(void)proximityMonitoring:(NSUserDefaults *)aDefaults;
-(void)venicerRegionMonitoring:(NSUserDefaults *)aDefaults;
@end
