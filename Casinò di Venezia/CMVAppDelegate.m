//
//  CMVAppDelegate.m
//  Casinò di Venezia
//
//  Created by Massimo Moro on 25/10/13.
//  Copyright (c) 2013 Casinò di Venezia SPA. All rights reserved.
//

#import "Reachability.h"
#import "CMVAppDelegate.h"
#import "UINavigationController+MHDismissModalView.h"
#import "CMVMapViewController.h"
#import "Helpshift.h"
#import "CMVLocalize.h"
#import "CMVEventKitController.h"
#import "MZModalViewController.h"
#import "MZFormSheetController.h"
#import "CMVPermissionForPushNotification.h"
#import "ChimpKit.h"
#import "CMVMainTabbarController.h"
#import "Helpshift.h"
#import "GAI.h"
#import <Parse/Parse.h>
#import <Bolts/Bolts.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <ParseCrashReporting/ParseCrashReporting.h>



#define SavedHTTPCookiesKey @"SavedHTTPCookies"
#define MAX_RADIUS  2300.0f

//TODO: Set 120 for publishing
//TODO: Voice speed for iOS 8
//TODO: Remove Spark
static int const kGaDispatchPeriod = 20;
static NSString *const kGaPropertyId = @"UA-42477250-3";

@interface CMVAppDelegate ()

@property (nonatomic)  CLLocationCoordinate2D region;
@property(nonatomic)float radius;
@property(nonatomic)float veniceRadius;
@property (strong, nonatomic)NSString *myObjectLocation;
@property(strong,nonatomic)PFInstallation *currentInstallation;
@property(strong,nonatomic)CLRegion *veniceRegion;
@property(strong,nonatomic)CLRegion *veniceRegion6;


@end

@implementation CMVAppDelegate
@synthesize locationManager = _locationManager;
@synthesize veniceRadius=_veniceRadius;
@synthesize currentInstallation=_currentInstallation;
BOOL loadedR = 0;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    //Helpshift
    [Helpshift installForApiKey:@"75b10c6c105e8bebefc95729c56e33ae" domainName:@"casinovenezia.helpshift.com" appID:@"casinovenezia_platform_20131218091253899-f3f796e2d4b9e99"];
    
    //Parse
    
    [Parse enableLocalDatastore];
    [Parse setApplicationId:@"yO3MBzW9liNCaiAfXWGb3NtZJ3VhXyy4Zh8rR5ck"
                  clientKey:@"KImYuYCrJ9j3IbDI3W2KtDXCXwmfqsRDCn5Em6A9"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [PFFacebookUtils initializeFacebook];
    [PFTwitterUtils initializeWithConsumerKey:@"iG8JhxkUYQS0liIzwtYQ" consumerSecret:@"DCT2PL3MbHCN0RV9cx5K7iTlSdKfimaEUB8cOBELOTc"];
    
    //Google Analitycs
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelError];
    [GAI sharedInstance].dispatchInterval = kGaDispatchPeriod;
    self.tracker = [[GAI sharedInstance] trackerWithTrackingId:kGaPropertyId];
    
    //Ask for permission
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"permissionForLocationAndNotification"]) {
        [[[NSUserDefaults standardUserDefaults] objectForKey:@"permissionForLocationAndNotification"] boolValue];
        [self permissionForPushNotification];
    }
    //tracking Pushes and App Opens
    [self trackingPushes:application options:launchOptions];
    
    [self checkLocationSrvicesEnabled];
    
    //Mail Chimp
   [[ChimpKit sharedKit] setApiKey:@"0746dc6bf1d0448814fe0e4148898870-us8"];
    
    _veniceRadius = MAX_RADIUS;
    
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString* preferredLang = [languages objectAtIndex:0];
    NSString *displayName=[preferredLang substringToIndex:2];
    
     _currentInstallation= [PFInstallation currentInstallation];

    [_currentInstallation addUniqueObject:displayName forKey:@"channels"];
    
    [_currentInstallation saveEventually];
  
    
    // Associate the device with a user
    if ([PFUser currentUser]) {
        _currentInstallation[@"user"] = [PFUser currentUser];
        [_currentInstallation saveEventually];
    }
    
    
    // Enable public read access by default, with any newly created PFObjects belonging to the current user
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    // Use Reachability to monitor connectivity
    [self monitorReachability];
    
    
    // Handle launching from a notification
    UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (locationNotification) {
        // Set icon badge number to zero
        application.applicationIconBadgeNumber = 0;
    
    }
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveEventually];
    }
    
    
    //Restore cookies
    NSData *cookiesData = [[NSUserDefaults standardUserDefaults] objectForKey:SavedHTTPCookiesKey];
    if (cookiesData) {
        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesData];
        for (NSHTTPCookie *cookie in cookies)
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }
    //Helpshift notifications
    if (launchOptions != nil) //Handle PushNotification when app is opened
    {
        NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (userInfo != nil && [[userInfo objectForKey:@"origin"] isEqualToString:@"helpshift"])
        {
          //  [[HelpshiftsharedInstance] handleRemoteNotification:userInfo withController:self.viewController];
        }
    }

    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Signo" size:10.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];

    return YES;
}

-(void)trackingPushes:(UIApplication *)application options:(NSDictionary *)launchOptions {
    if (application.applicationState != UIApplicationStateBackground) {
        // Track an app open here if we launch with a push, unless
        // "content_available" was used to trigger a background push (introduced
        // in iOS 7). In that case, we skip tracking here to avoid double
        // counting the app-open.
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }
}

-(void)checkLocationSrvicesEnabled {
    if (![CLLocationManager locationServicesEnabled]) {
        // location services is disabled, alert user
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Location Services", @"DisabledTitle")
                                                                        message:NSLocalizedString(@"Location services are off", @"DisabledMessage")
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
        [servicesDisabledAlert show];
    }
}


-(UIStoryboard *)storyboard {
    if (!_storyboard) {
       
        _storyboard=[UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
      
    }
    
    return _storyboard;
}

-(void)permissionForPushNotification {
    int status;
    if (!SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        status = [[[UIApplication sharedApplication] currentUserNotificationSettings] types];
    }else{
        status = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    }
    
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    if (((status == UIRemoteNotificationTypeNone) && (authStatus == kCLAuthorizationStatusNotDetermined)) || (authStatus == kCLAuthorizationStatusNotDetermined))
    {
        CMVPermissionForPushNotification *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"Push"];
        
        
        MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
        
        [[MZFormSheetBackgroundWindow appearance] setBackgroundBlurEffect:YES];
        [[MZFormSheetBackgroundWindow appearance] setBlurRadius:5.0];
        [[MZFormSheetBackgroundWindow appearance]setBackgroundColor:[UIColor clearColor]];
        
        formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromTop;
        formSheet.shadowRadius = 2.0;
        formSheet.shadowOpacity = 0.3;
        formSheet.shouldDismissOnBackgroundViewTap = NO;
        //formSheet.shouldCenterVerticallyWhenKeyboardAppears = YES;
        formSheet.presentedFormSheetSize = CGSizeMake(245, 350);
        formSheet.cornerRadius=0;
        
        if (iPAD) {
            formSheet.presentedFormSheetSize = CGSizeMake(490, 700);
        }
        
        [formSheet presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
            
        }];
    } else {
        [self regionMonitoring];
    }
    
}

-(CMVEventKitController *)eventKit {
    if (!_eventKit) {
        _eventKit=[[CMVEventKitController alloc] init];
    }
    return _eventKit;
}

-(float)radius {
    if (!_radius) {
       // _radius=200;
        PFQuery *query = [PFQuery queryWithClassName:@"Radius"];
        
        if (self.isParseReachable) {
            if (!loadedR) {
                NSArray *objects = [query findObjects]; // Online PFQuery results
                [PFObject pinAllInBackground:objects];
                loadedR = 1;
            }
            
        }
        [query fromLocalDatastore];
        [query getObjectInBackgroundWithId:@"ctwCyETQAM" block:^(PFObject *object, NSError *error) {
            _radius=[object[@"radius"] floatValue];
            if (_radius == 0) {
                _radius = 200;
            }
           
        }];
    }
    
    return _radius;
}

- (CLLocationManager *)locationManager {
	if ([CLLocationManager locationServicesEnabled] &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        if (_locationManager != nil) {

            return _locationManager;
         
        }
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        _locationManager.delegate = self;
        
	}
    
	return _locationManager;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if ([CLLocationManager locationServicesEnabled] &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        [self saveInstallationLocation];
      
        
    }

}

-(void)regionMonitoring {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObject:@"YES"
                                                            forKey:@"enableGeofencingNotification"];
    [defaults registerDefaults:appDefaults];
    [defaults synchronize];
    
    [self proximityMonitoring:defaults];
    [self venicerRegionMonitoring:defaults];
    
}

-(void)proximityMonitoring:(NSUserDefaults *)aDefaults {
 
    if ([aDefaults boolForKey:@"enableGeofencingNotification"]) {
        [self convenienceStartUpdateLocation];
        [self.locationManager  startMonitoringForRegion:[[CLCircularRegion alloc] initWithCenter:self.region radius:self.radius identifier:@"proximity"]];

    } else {
        [self.locationManager stopMonitoringForRegion:[[CLCircularRegion alloc] initWithCenter:self.region radius:self.radius identifier:@"proximity"]];
        
    }
   
}

-(void)convenienceStartUpdateLocation {
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

-(void)venicerRegionMonitoring:(NSUserDefaults *)aDefaults {
    
    if ([aDefaults boolForKey:@"enableGeofencingNotification"]) {
        
        [self convenienceStartUpdateLocation];
        self.veniceRegion=[[CLCircularRegion alloc] initWithCenter:self.region radius:_veniceRadius identifier:@"Venice"];

        [self.locationManager  startMonitoringForRegion:self.veniceRegion];

    } else {

        [self.locationManager stopMonitoringForRegion:self.veniceRegion];

        
    }
    
}



- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    static BOOL firstTime=TRUE;
    if(firstTime)
    {
        firstTime = FALSE;
        NSSet * monitoredRegions = self.locationManager.monitoredRegions;
        if(monitoredRegions)
        {
            [monitoredRegions enumerateObjectsUsingBlock:^(CLRegion *region,BOOL *stop)
             
             {
                 NSString *identifer = region.identifier;
                 if ([identifer isEqualToString:@"Venice"]) {
                     
                 
                 CLLocationCoordinate2D centerCoords =region.center;
                 CLLocationCoordinate2D currentCoords= CLLocationCoordinate2DMake(newLocation.coordinate.latitude,newLocation.coordinate.longitude);
                 CLLocationDistance radius = region.radius;
                 
                 NSNumber * currentLocationDistance =[self calculateDistanceInMetersBetweenCoord:currentCoords coord:centerCoords];
                 if([currentLocationDistance floatValue] < radius)
                 {
                     NSLog(@"Invoking didEnterRegion Manually for region: %@",identifer);
                     
                     //stop Monitoring Region temporarily
                     [self.locationManager stopMonitoringForRegion:self.veniceRegion];
                     
                     [self locationManager:self.locationManager didEnterRegion:self.veniceRegion];
                     //start Monitoing Region again.
                     [self.locationManager startMonitoringForRegion:region];
                 }
                 }
             }];
        }
        //Stop Location Updation, we dont need it now.
        [self.locationManager stopUpdatingLocation];
        
    }
}

- (NSNumber*)calculateDistanceInMetersBetweenCoord:(CLLocationCoordinate2D)coord1 coord:(CLLocationCoordinate2D)coord2 {
    NSInteger nRadius = 6371; // Earth's radius in Kilometers
    double latDiff = (coord2.latitude - coord1.latitude) * (M_PI/180);
    double lonDiff = (coord2.longitude - coord1.longitude) * (M_PI/180);
    double lat1InRadians = coord1.latitude * (M_PI/180);
    double lat2InRadians = coord2.latitude * (M_PI/180);
    double nA = pow ( sin(latDiff/2), 2 ) + cos(lat1InRadians) * cos(lat2InRadians) * pow ( sin(lonDiff/2), 2 );
    double nC = 2 * atan2( sqrt(nA), sqrt( 1 - nA ));
    double nD = nRadius * nC;
    // convert to meters
    return @(nD*1000);
}

-(void)saveInstallationLocation {
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:_locationManager.location.coordinate.latitude longitude:_locationManager.location.coordinate.longitude];
    _currentInstallation[@"Location"] = geoPoint;
    [_currentInstallation saveEventually];
   
}

-(CLLocationCoordinate2D)region {
    CLLocationCoordinate2D centre;
    centre.latitude = PALAZZO_LOREDAN_VENDRAMIN.latitude;
    centre.longitude = PALAZZO_LOREDAN_VENDRAMIN.longitude;
    _region=centre;
    return _region;
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Hi !", @"")
                                                        message:notification.alertBody
                                                       delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    // Set icon badge number to zero
    application.applicationIconBadgeNumber = 0;
}

// as a delegate to our UISplitViewController, block from hiding the master view controller for any orientation
- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
}


-(void)sendLocalNotification {
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = nil;
    //[localNotification setHasAction:YES];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.alertBody = NSLocalizedString(@"You are close to the Casinò !!!", @"");
    localNotification.soundName = @"coins4.caf";
    //localNotification.applicationIconBadgeNumber = 1;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}


-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    
    if ([region.identifier isEqualToString: @"proximity"]) {
        [self sendLocalNotification];
    } else {
        
            if (_currentInstallation[@"LeftVenice"]) {
                _currentInstallation[@"LeftVenice"] = @NO;
            }
            [self isInVenice];
        
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
   
        [self isInVenice];
        
    
}

-(void)isInVenice {
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:_locationManager.location.coordinate.latitude longitude:_locationManager.location.coordinate.longitude];
    _currentInstallation[@"Location"] = geoPoint;
    [_currentInstallation addUniqueObject:@"IsInVenice" forKey:@"channels"];
    [_currentInstallation saveEventually];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    if ([region.identifier isEqualToString: @"Venice"]) {
        _currentInstallation[@"LeftVenice"] = @YES;
        [_currentInstallation removeObject:@"IsInVenice" forKey:@"channels"];
        [_currentInstallation saveEventually];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    // Save cookies
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject:[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    [[NSUserDefaults standardUserDefaults] setObject:cookiesData
                                              forKey:SavedHTTPCookiesKey];

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"permissionForLocationAndNotification"] boolValue] == NO) {
    [self regionMonitoring];
    }
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
  
    [_currentInstallation setDeviceTokenFromData:newDeviceToken];
    [_currentInstallation addUniqueObject:@"Events" forKey:@"channels"];
    [_currentInstallation addUniqueObject:@"Slots" forKey:@"channels"];
    [_currentInstallation addUniqueObject:@"Poker" forKey:@"channels"];
    [_currentInstallation saveEventually];
    [[Helpshift sharedInstance] registerDeviceToken:newDeviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	if (error.code != 3010) { // 3010 is for the iPhone Simulator
        NSLog(@"Application failed to register for push notifications: %@", error);
	}
}




// ****************************************************************************
// App switching methods to support Facebook Single Sign-On.
// ****************************************************************************
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */

    if (_currentInstallation.badge != 0) {
        _currentInstallation.badge = 0;
        [_currentInstallation saveEventually];
    }
    
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    
    //https://developers.facebook.com/docs/ads-for-apps/mobile-app-ads/?locale=it_IT
    [FBSettings setDefaultAppID:@"724548800932026"];
    [FBAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    [[PFFacebookUtils session] close];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler
{
    
    //Success
    handler(UIBackgroundFetchResultNewData);
    if (application.applicationState == UIApplicationStateInactive) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if ([[userInfo objectForKey:@"origin"] isEqualToString:@"helpshift"]) {
      //  [[Helpshift sharedInstance] handleRemoteNotification:userInfo withController:self.viewController];
    }
    if (application.applicationState == UIApplicationStateInactive) {
        // The application was just brought from the background to the foreground,
        // so we consider the app as having been "opened by a push notification."
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}
-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"Background fetch started...");
    
    //---do background fetch here---
    // You have up to 30 seconds to perform the fetch
    
    BOOL downloadSuccessful = YES;
    
    if (downloadSuccessful) {
        //---set the flag that data is successfully downloaded---
        completionHandler(UIBackgroundFetchResultNewData);
        
    } else {
        //---set the flag that download is not successful---
        completionHandler(UIBackgroundFetchResultFailed);
    }
    
    NSLog(@"Background fetch completed...");
}




- (void)monitorReachability {
    Reachability *hostReach = [Reachability reachabilityWithHostname:@"api.parse.com"];
    
    hostReach.reachableBlock = ^(Reachability*reach) {
        _networkStatus = [reach currentReachabilityStatus];
        
        if ([self isParseReachable] && [PFUser currentUser]) {// && self.homeViewController.objects.count == 0) {
            // Refresh home timeline on network restoration. Takes care of a freshly installed app that failed to load the main timeline under bad network conditions.
            // In this case, they'd see the empty timeline placeholder and have no way of refreshing the timeline unless they followed someone.
            //[self.homeViewController loadObjects];
        }
    };
    
    hostReach.unreachableBlock = ^(Reachability*reach) {
        _networkStatus = [reach currentReachabilityStatus];
    };
    
    [hostReach startNotifier];
}

- (BOOL)isParseReachable {
    return self.networkStatus != NotReachable;
}
@end
