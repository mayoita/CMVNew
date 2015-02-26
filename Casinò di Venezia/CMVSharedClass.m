//
//  CMVSharedClass.m
//  Casinò di Venezia
//
//  Created by Massimo Moro on 18/02/14.
//  Copyright (c) 2014 Casinò di Venezia SPA. All rights reserved.
//

#import "CMVSharedClass.h"
#import <Parse/Parse.h>
#import "CMVAppDelegate.h"
#import <Bolts/Bolts.h>

@implementation CMVSharedClass
BOOL loadedE = 0;
BOOL loadedT = 0;



-(NSMutableArray *)retrieveObjects:(NSString *)className eventType:(int)eventChar office:(int)officeLocation tableView:(UITableView *)myTableView {
    
    PFQuery *query = [PFQuery queryWithClassName:className];
    
    // Pin PFQuery results
    if ([[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        if (!loadedE) {
            NSArray *objects = [query findObjects]; // Online PFQuery results
            [PFObject pinAllInBackground:objects];
            loadedE = 1;
        }
       
    }
    [query fromLocalDatastore];
    
    NSArray *eventStrings = [CMVSharedClass eventTypeStrings];
    NSArray *officeString = [CMVSharedClass officeTypeString];
    NSString *eventType = eventStrings[eventChar];
    NSString *officeType = officeString[officeLocation];
    if (!([className  isEqual: @"Poker"] || [className  isEqual: @"Tournaments"])) {
        [query whereKey:@"eventType" containsString:eventType];
    }
    
    [query whereKey:@"office" equalTo:officeType];
    [query orderByDescending:@"StartDate"];
    
    NSMutableArray *allObjects = [NSMutableArray array];
    

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {

            if ([allObjects count] == 0) {
                
                [allObjects addObjectsFromArray:objects];
                [myTableView reloadData];
            }
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
   
    return allObjects;
}

-(NSMutableArray *)retrieveSlotsEvents:(NSString *)className eventType:(int)eventChar carousel:(iCarousel *) myCaraousel{
    
    
    PFQuery *query = [PFQuery queryWithClassName:className];
    
    if ([[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        if (!loadedT) {
            NSArray *objects = [query findObjects]; // Online PFQuery results
            [PFObject pinAllInBackground:objects];
             loadedT = 1;
        }
        
    }
    
    
    [query fromLocalDatastore];

    NSArray *eventStrings = [CMVSharedClass eventTypeStrings];
    NSString *eventType = eventStrings[eventChar];
   
    
    [query whereKey:@"eventType" containsString:eventType];
    [query whereKey:@"isSlotsEvents" equalTo:[NSNumber numberWithBool:YES]];
    [query orderByDescending:@"StartDate"];
    
    NSMutableArray *allObjects = [NSMutableArray array];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {

            if ([allObjects count] == 0) {
                
                [allObjects addObjectsFromArray:objects];
 
            }
            [myCaraousel reloadData];
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    return allObjects;
}

+ (NSArray *)eventTypeStrings
{
    return @[@"E",@"A",@"T"];
}

+ (NSArray *)officeTypeString
{
    return @[@"VE",@"CN"];
}
@end
