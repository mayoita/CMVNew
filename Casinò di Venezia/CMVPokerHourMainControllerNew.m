//
//  CMVPokerHourMainControllerNew.m
//  Casinò di Venezia
//
//  Created by Massimo Moro on 22/01/14.
//  Copyright (c) 2014 Casinò di Venezia SPA. All rights reserved.
//

#import "CMVPokerHourMainControllerNew.h"
#import "CMVPokerHourViewController.h"
#import "CMVPokerHourCell.h"
#define cellIdentifier @"PokerHourCell"
#define ROW_HEIGHT 40

#define indexOfTitle 3
#define numberOfTournamentAttributes 4
#define numberOfTitleElements 4
//#define numberOfFooterElement 0
#define indexOfTournamentTitle 1

@interface CMVPokerHourMainControllerNew ()
@property (strong,nonatomic)NSMutableArray *arrayOfTableViewController;

@end

@implementation CMVPokerHourMainControllerNew

int numberOfTournamentsInADay;
float tableHeightNew=0;

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.myCollapseClick openCollapseClickCellAtIndex:0 animated:NO];
    
}


-(void)createView {
    
    int i;
    self.arrayOfTableViewController = [[NSMutableArray alloc] init];
    //for (i = 0; i < ([self.dataSourceItems count] - numberOfTitleElements)-numberOfFooterElement; i++) {
    for (i = 0; i < ([self.dataSourceItems count] - numberOfTitleElements); i++) {
        
        int delta=0;
        CMVPokerHourViewController *tableViewController=[[CMVPokerHourViewController alloc] init];
        
        tableViewController.tableView.delegate=self;
        tableViewController.tableView.dataSource=self;
        
        //bad solution for adjust iPAd Landscape size iOS 7.0
        UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
        
        if (iPAD && ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight)) && (self.view.bounds.size.width == 768.0f) ) {
            delta = 33;
            
        } else if (iPAD && ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight)) && (self.view.bounds.size.width == 748.0f)) {
            //for iPad iOS 6.0
            delta = 33;
        }
#warning Problem is here
        UIView *contentView=[[UIView alloc] initWithFrame:CGRectMake(delta, 0, self.view.frame.size.width, [self calculateHeightForTableView:i])];
        
        [contentView addSubview:tableViewController.tableView];
        tableViewController.tableView.frame=contentView.frame;
        [self.arrayOfTableViewController addObject:contentView];
    }
}

-(float)calculateHeightForTableView:(int) index {
    float height=0;
    
    numberOfTournamentsInADay=[self.dataSourceItems[index + numberOfTitleElements] count] - numberOfTournamentAttributes;
    height=height + ROW_HEIGHT*numberOfTournamentsInADay+HeightForHeader;
  
    return height;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"Number of Row in Section: %i", self.dataSourceItems.count - numberOfTitleElements);
    return self.dataSourceItems.count - numberOfTitleElements ;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = cellIdentifier;
    
    UITableViewCell *cell=[[UITableViewCell alloc] init];
    NSLog(@"Path.row: %i", indexPath.row);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    tableHeightNew=tableHeightNew+[self tournamentHeightForRowAtIndexPath:indexPath];
    return [self tournamentHeightForRowAtIndexPath:indexPath];
}

-(CGFloat)tournamentHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    numberOfTournamentsInADay=[self.dataSourceItems[indexPath.row + numberOfTitleElements] count] - numberOfTournamentAttributes;
    NSLog(@"Height: %i", ROW_HEIGHT*numberOfTournamentsInADay+HeightForHeader);
    return ROW_HEIGHT*numberOfTournamentsInADay+HeightForHeader;
    
}

-(int)numberOfCellsForCollapseClick {
    
    //return self.dataSourceItems.count - numberOfTitleElements - numberOfFooterElement ;
    return self.dataSourceItems.count - numberOfTitleElements ;
    
}

-(NSString *)titleForCollapseClickAtIndex:(int)index {
    
    return self.dataSourceItems[index + numberOfTitleElements][indexOfTitle];
}

-(UIView *)viewForCollapseClickContentViewAtIndex:(int)index {
    
    return self.arrayOfTableViewController[index];
    
}


// Optional Methods

-(UIColor *)colorForCollapseClickTitleViewAtIndex:(int)index {
    return [UIColor colorWithRed:223/255.0f green:47/255.0f blue:51/255.0f alpha:1.0];
}


-(UIColor *)colorForTitleLabelAtIndex:(int)index {
    return [UIColor colorWithWhite:1.0 alpha:0.85];
}

-(UIColor *)colorForTitleArrowAtIndex:(int)index {
    return [UIColor colorWithWhite:0.0 alpha:0.25];
}

-(void)didClickCollapseClickCellAtIndex:(int)index isNowOpen:(BOOL)open {
    //NSLog(@"%d and it's open:%@", index, (open ? @"YES" : @"NO"));
}


#pragma mark - TextField Delegate for Demo
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)selectedTournament:(NSArray *)newTournament {
    if (_dataSourceItems != newTournament) {
        _dataSourceItems = newTournament;
        [self createView];
        self.myCollapseClick.CollapseClickDelegate = self;
        [self.myCollapseClick reloadCollapseClick];
    }
}
- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark SubstitutableDetailViewController

// -------------------------------------------------------------------------------
//	setNavigationPaneBarButtonItem:
//  Custom implementation for the navigationPaneBarButtonItem setter.
//  In addition to updating the _navigationPaneBarButtonItem ivar, it
//  reconfigures the toolbar to either show or hide the
//  navigationPaneBarButtonItem.
// -------------------------------------------------------------------------------
- (void)setNavigationPaneBarButtonItem:(UIBarButtonItem *)navigationPaneBarButtonItem
{
    if ((navigationPaneBarButtonItem != _navigationPaneBarButtonItem) || navigationPaneBarButtonItem==nil) {
        if (navigationPaneBarButtonItem)
            [self.toolbar setItems:[NSArray arrayWithObject:navigationPaneBarButtonItem] animated:NO];
        else
            [self.toolbar setItems:nil animated:NO];
        //self.toolbar.hidden=YES;
    }
}


// Example of change content view frame and then update collapseClick layout.
//- (IBAction)buttonClicked:(id)sender {
//    self.viewController.frame = CGRectMake(0, 0, self.viewController.frame.size.width, self.viewController.frame.size.height + 50);
//    [self.myCollapseClick setNeedsLayout];
//}


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self createView];
    self.myCollapseClick.CollapseClickDelegate = self;
    [self.myCollapseClick reloadCollapseClick];
}
@end
