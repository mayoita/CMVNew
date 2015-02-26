//
//  CMVPokerHourMain.h
//  Casinò di Venezia
//
//  Created by Massimo Moro on 15/09/14.
//  Copyright (c) 2014 Casinò di Venezia SPA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMVCloseButton.h"
#import <Parse/Parse.h>
#import "CMVSwipeTableViewCell.h"
#import "CMVPokerHourCellNew.h"
#import "CMVArrowSx.h"
#import "CMVArrow.h"
#import "CMVPokerHourSlitViewController.h"
#import "CMVSharedButton.h"

@interface CMVPokerHourMain : UIViewController <UITableViewDataSource, UITableViewDelegate,SubstitutableDetailViewControllerPoker,AAShareBubblesDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *nomeTorneo;

@property (nonatomic, strong) UIBarButtonItem *navigationPaneBarButtonItem;
@property (weak, nonatomic) IBOutlet UITextView *noteGenerali;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet CMVCloseButton *closeButton;
@property (weak, nonatomic) IBOutlet CMVArrowSx *arrowSx;
@property (weak, nonatomic) IBOutlet CMVArrow *arrowDx;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (strong,nonatomic)NSArray *dataSourceItems;
@property (strong,nonatomic)PFObject *dataSourceItemsWithRules;
@property (weak, nonatomic) IBOutlet UIImageView *swipeHelper;

@property (weak, nonatomic) IBOutlet CMVSharedButton *shareButton;
@property (weak, nonatomic) IBOutlet UILabel *contactUs;

@property(strong,nonatomic)CMVSwipeTableViewCell *cell;

-(void)selectedTournament:(PFObject *)newTournament office:(int)currentOffice;

@end
