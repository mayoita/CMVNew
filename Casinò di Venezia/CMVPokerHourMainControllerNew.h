//
//  CMVPokerHourMainControllerNew.h
//  Casinò di Venezia
//
//  Created by Massimo Moro on 22/01/14.
//  Copyright (c) 2014 Casinò di Venezia SPA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollapseClick.h"
#import "CMVSwipeTableViewCell.h"
#import "CMVPokerHourSlitViewController.h"

@interface CMVPokerHourMainControllerNew : UIViewController <CollapseClickDelegate, UITableViewDataSource, UITableViewDelegate, SubstitutableDetailViewControllerPoker>

@property (weak, nonatomic) IBOutlet CollapseClick *myCollapseClick;
@property (strong,nonatomic)NSArray *dataSourceItems;
@property(strong,nonatomic)CMVSwipeTableViewCell *cell;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

/// SubstitutableDetailViewController
@property (nonatomic, strong) UIBarButtonItem *navigationPaneBarButtonItem;

-(void)selectedTournament:(NSArray *)newTournament;

@end
