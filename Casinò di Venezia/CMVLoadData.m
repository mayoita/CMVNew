//
//  CMVLoadData.m
//  Casinò di Venezia
//
//  Created by Massimo Moro on 27/02/15.
//  Copyright (c) 2015 Casinò di Venezia SPA. All rights reserved.
//

#import "CMVLoadData.h"
#import <Parse/Parse.h>

@implementation CMVLoadData

-(void) fetchAllObjects {

    // if (parseReachable.isParseReachable() && (self.noteObjects.count == 0)) {
    //  PFObject.unpinAllObjectsInBackgroundWithBlock(nil)
    
    
     PFQuery *query = [PFQuery queryWithClassName:self.className];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
      
            [PFObject pinAllInBackground:objects block:nil ];
            [self fetchAllObjectsFromLocalDatastore];
            
        } else {
            
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    


}

-(void) fetchAllObjectsFromLocalDatastore {
    
   
     PFQuery *query = [PFQuery queryWithClassName:self.className];
    
    [query fromLocalDatastore];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
//            [PFObject pinAllInBackground:objects block:nil ];
//            [self fetchAllObjectsFromLocalDatastore];
            
        } else {
            
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
}

@end
