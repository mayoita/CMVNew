//
//  CMVSwipeTableViewCellController.m
//  Casinò di Venezia
//
//  Created by Massimo Moro on 28/10/13.
//  Copyright (c) 2013 Casinò di Venezia SPA. All rights reserved.
//

#import "CMVSwipeTableViewCellController.h"
#import "CMVSwipeTableViewCell.h"

#import "CMVEventSelectionDelegate.h"
#import "CMVInfoViewController.h"
#import "CMVAllEvents.h"
#import "CMVAppDelegate.h"
#import <Parse/Parse.h>
#import "CMVEventKitController.h"
#import "CMVSharedClass.h"
#import "RCHGestureGuide.h"
#import "CMVEventKitController.h"
#import "CMVLocalize.h"
#import <Parse/Parse.h>
#import <Bolts/Bolts.h>

#import "CMVEventKitShared.h"


#define cellIdentifier @"CustomCell"
#define PARSE_CLASS_NAME @"Events"
#define EVENTS_INDEX 0

#define VE @"VE"
#define CN @"CN"

@interface CMVSwipeTableViewCellController ()

@property (weak, nonatomic) UITableView *tableView;
@property (nonatomic,strong)CMVDataClass *site;
@property(nonatomic)CGFloat rowHeight;

@property (strong, nonatomic) NSMutableDictionary *sections;
@property (strong, nonatomic) NSArray *sortedDays;
@property (strong, nonatomic) NSDateFormatter *sectionDateFormatter;
@property (strong, nonatomic) NSDateFormatter *cellDateFormatter;



@end



@implementation CMVSwipeTableViewCellController {
    NSDate *today;
    NSDate *nextDay;
    BOOL dayFound;
    NSString *Office;
    NSMutableArray *storage;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    dayFound = FALSE;
    today = [self dateAtBeginningOfDayForDate:[self dateAtBeginningOfDayForDate:[NSDate date]]];
    
    if (iPAD) {
        self.rowHeight=203;
    } else {
        self.rowHeight=(203*self.view.frame.size.width)/320;
    }

    self.view.backgroundColor = [UIColor clearColor];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.site=[CMVDataClass getInstance];

    
   [self.tableView registerNib:[UINib nibWithNibName:@"CMVCellView" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    //Standard image size is 203x320
    self.tableView.rowHeight = self.rowHeight;
   
    
    // Makes the horizontal row seperator stretch the entire length of the table view
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
    //Delegate for iPad split controller
    self.eventDelegate=(CMVEventViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"EventDetails"];
    //for iPhone
    if (!self.eventDelegate) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        CMVEventViewController *eventDetail = [storyboard instantiateViewControllerWithIdentifier:@"EventViewControlleriPhone"];
        self.eventDelegate=eventDetail;
    }
  //  [self setOffice];
    
    
    
    if (iPAD) {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundGame.png"]];
 
        // on iPad only, don't clear the selection (we are displaying in a split view on iPad)
        self.clearsSelectionOnViewWillAppear = NO;    
        self.mainTabBarController = (CMVMainTabbarController *)self.tabBarController;
        int tabNumber = (int)[self.mainTabBarController selectedIndex];
        
        UISplitViewController *splitVC = [[self navigationController] splitViewController];
        int index = (int)[self.mainTabBarController.viewControllers indexOfObjectIdenticalTo:splitVC];
        
        if ( tabNumber == index || tabNumber == -1) {
            [self.mainTabBarController setCenterButtonDelegate:self];
        }
    }
    [self fetchAllObjectsFromLocalDatastore];
    [self fetchAllObjects];

    
}


- (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate
{
    // Use the user's current calendar and time zone
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [calendar setTimeZone:timeZone];
    
    // Selectively convert the date components (year, month, day) of the input date
    NSDateComponents *dateComps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:inputDate];
    
    // Set the time components manually
    [dateComps setHour:0];
    [dateComps setMinute:0];
    [dateComps setSecond:0];
    
    // Convert back
    NSDate *beginningOfDay = [calendar dateFromComponents:dateComps];
    return beginningOfDay;
}

- (NSDate *)dateByAddingYears:(NSInteger)numberOfYears toDate:(NSDate *)inputDate
{
    // Use the user's current calendar
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    [dateComps setYear:numberOfYears];
    
    NSDate *newDate = [calendar dateByAddingComponents:dateComps toDate:inputDate options:0];
    return newDate;
}

-(void)createDateSort {
    
    self.sectionDateFormatter = [[NSDateFormatter alloc] init];
    [self.sectionDateFormatter setDateStyle:NSDateFormatterLongStyle];
    [self.sectionDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    self.cellDateFormatter = [[NSDateFormatter alloc] init];
    [self.cellDateFormatter setDateStyle:NSDateFormatterNoStyle];
    [self.cellDateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSDate *now = [NSDate date];
    NSDate *startDate = [self dateAtBeginningOfDayForDate:now];
    //NSDate *endDate = [self dateByAddingYears:1 toDate:startDate];
    

    for (PFObject *event in _events)
    {
        // Reduce event start date to date components (year, month, day)
        NSDate *dateRepresentingThisDay = [self dateAtBeginningOfDayForDate:event[@"StartDate"]];
        
        // If we don't yet have an array to hold the events for this day, create one
        NSMutableArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
        if (eventsOnThisDay == nil) {
            eventsOnThisDay = [NSMutableArray array];
            
            // Use the reduced date as dictionary key to later retrieve the event list this day
            [_sections setObject:eventsOnThisDay forKey:dateRepresentingThisDay];
        }
        
        // Add the event to the list for this day
        [eventsOnThisDay addObject:event];
    }
    
    // Create a sorted list of days
    NSArray *unsortedDays = [self.sections allKeys];
  //  self.sortedDays = [unsortedDays sortedArrayUsingSelector:@selector(compare:)];
    NSSortDescriptor *sortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self" ascending: NO];
   // [unsortedDays sortedArrayUsingDescriptors:[NSArray arrayWithObject: sortOrder]];
    
    self.sortedDays = [unsortedDays sortedArrayUsingDescriptors:[NSArray arrayWithObject: sortOrder]];
    nextDay= [self nextDay];
}

-(NSDate *)nextDay {
    NSDate *min=today;
    for (NSDate *date in self.sortedDays) {
        
        if (date > today) {
            min = date;
        }
    }
    return min;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (iPHONE) {
        [self showGestureGuide];
      
//        CGRect sectionRect = [self.tableView rectForSection:3];
//        sectionRect.size.height = self.tableView.frame.size.height;
//        [self.tableView scrollRectToVisible:sectionRect animated:YES];
    }
    
    if (iPAD) {
        [self.mainTabBarController setCenterButtonDelegate:self];
    }
       // [self setOffice];
}



- (void)showGestureGuide
{;

    [RCHGestureGuide showGestures:@[ @[RCHGestureSwipeLeft,NSLocalizedString(@"Swipe to move between events", nil),[NSValue valueWithCGPoint:CGPointMake(250.f,75.f)],[NSValue valueWithCGPoint:CGPointMake(70.f,75.f)]],
                                     @[RCHGestureSwipeRightUp,NSLocalizedString(@"Swipe to reveal extra Menu", nil),[NSValue valueWithCGPoint:CGPointMake(10,self.view.frame.size.height/2 + 20)],[NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width/2,self.view.frame.size.height/2 + 20)]],
                                     @[RCHGestureTap,NSLocalizedString(@"Tap to open an event", nil),[NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width/2 + 10,200.f)]],
                                     @[RCHGestureSwipeLeft,NSLocalizedString(@"Swipe to share the event or add to your calendar", nil),[NSValue valueWithCGPoint:CGPointMake(240.f,200.f)],[NSValue valueWithCGPoint:CGPointMake(70.f,200.f)]],
                                     
                                     @[RCHGestureTapUp,NSLocalizedString(@"Tap to change location", nil),[NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width/2 + 20,self.view.frame.size.height + 30)]],
                                     ] forKey:@"Events"];
    
}


#pragma mark - Center button delegate
-(void)centerButtonAction:(UIButton *)sender {
    
    [self setOffice];
}

-(void)setOffice {
    CMVSharedClass *shared=[[CMVSharedClass alloc] init];
    if (self.site.location == VENEZIA) {
        Office=CN;
        _sections=nil;
        dayFound=FALSE;
        self.events =[self filterMyArray:self.events inOffice:Office];
        //self.events=[shared retrieveObjects:PARSE_CLASS_NAME eventType:EVENTS_INDEX office:Office tableView:self.tableView];
        [self.tableView reloadData];
        [self.myScrollSliding changeTextColor:BRAND_GREEN_COLOR];
        self.tabBarController.tabBar.tintColor=BRAND_GREEN_COLOR;
    } else {
        Office=VE;
        _sections=nil;
        dayFound=FALSE;
        self.events =[self filterMyArray:self.events inOffice:Office];
        //self.events=[shared retrieveObjects:PARSE_CLASS_NAME eventType:EVENTS_INDEX office:Office tableView:self.tableView];
        [self.tableView reloadData];
        [self.myScrollSliding changeTextColor:[UIColor redColor]];
        self.tabBarController.tabBar.tintColor=BRAND_RED_COLOR;
    }
}

-(NSArray *)filterMyArray:(NSMutableArray *)theArray inOffice:(NSString *)theOffice{
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"office == %@", theOffice];
    NSArray *helper=[storage filteredArrayUsingPredicate:pred];
    
    return helper;
    
}

-(NSMutableDictionary *)sections {
    if (_sections) {
        return _sections;
    }
    if (_events.count > 0) {
        _sections=[NSMutableDictionary dictionary];
        [self createDateSort];
    }
    
    
    return _sections;
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.sections count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:section];
    NSArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
    return [eventsOnThisDay count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:section];
    return [self.sectionDateFormatter stringFromDate:dateRepresentingThisDay];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.rowHeight;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    CGRect sectionRect = [tableView rectForSection:1];
//    sectionRect.size.height = tableView.frame.size.height;
//    [tableView scrollRectToVisible:sectionRect animated:YES];
    int lastRow =((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row;
    if([indexPath row] == 5){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    CMVSwipeTableViewCell *cell = (CMVSwipeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  
    if (self.events.count != 0) {
    //Cell set up
    static NSDateFormatter *formatter = nil;
    if (formatter == nil) {
        NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"EEEE dd, MMMM" options:0
                                                                  locale:[NSLocale currentLocale]];
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:formatString];
    }
    
    NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:indexPath.section];
    NSArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
        
        if (dateRepresentingThisDay == today || dateRepresentingThisDay == nextDay) {
            if (!dayFound) {
                [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                dayFound =TRUE;
            }
        }
    PFObject *event=[eventsOnThisDay objectAtIndex:indexPath.row];
   
    cell.labelDescription.hidden = YES;
    cell.readDescription.hidden =YES;
    cell.eventStartDate.text=[formatter stringFromDate:event[@"StartDate"]];
    cell.startDate=event[@"StartDate"];
    cell.endDate=event[@"EndDate"];
    cell.eventEndDate.text=[formatter stringFromDate:event[@"EndDate"]];
    [self localizeMemo:cell event:event];
    cell.eventURL=event[@"URL"];

    cell.talking=NO;
    
    //Show default image
    PFFile *imageFile=event[@"ImageName"];
    if (([imageFile isKindOfClass:[NSNull class]]) || (imageFile == nil)) {
        cell.eventPicture.image = [UIImage imageNamed:@"Test.png"];
        
    } else {
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            
          
            [cell.picture setImage:[UIImage imageWithData:data]];

           
        }    ];
    }
    cell.delegate = self;
    }
   
    
    return cell;
}

-(void)tapTableViewCell:(CMVSwipeTableViewCell *)cell {
    
    [self tableView:self.tableView didSelectRowAtIndexPath:[self.tableView indexPathForCell:cell]];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CMVAppDelegate *appDelegate=(CMVAppDelegate *)[UIApplication sharedApplication].delegate;
    UIStoryboard *storyboard =appDelegate.storyboard;
    CMVAllEvents *detailViewManager = (CMVAllEvents *)self.splitViewController.delegate;
    
    CMVSwipeTableViewCell *cell = (CMVSwipeTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [self configureDetailItemForRow:indexPath viewController:self.eventDelegate withCell:cell];
    
    if (iPHONE) {
        
        [self presentViewController:self.eventDelegate animated:YES completion:nil];
        
    } else {
        CMVEventViewController *presentingViewController=  [storyboard instantiateViewControllerWithIdentifier:@"EventDetails"];
        CMVSwipeTableViewCell *cell = (CMVSwipeTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        [self configureDetailItemForRow:indexPath viewController:presentingViewController withCell:cell];
        
        
        detailViewManager.detailViewController = self.eventDelegate;
    }
}

- (void)configureDetailItemForRow:(NSIndexPath *)indexPath viewController:(CMVEventViewController *)viewController withCell:cell {
    
    if ([_events count] != 0) {
        NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:indexPath.section];
        NSArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
        Events *selectedEvent=[eventsOnThisDay objectAtIndex:indexPath.row];
       // Events *selectedEvent = [_events objectAtIndex:row];
        if (_eventDelegate) {
            [_eventDelegate selectedEvent:selectedEvent];
            _eventDelegate.cell=cell;
        }
    }
}


-(void)localizeMemo:(CMVSwipeTableViewCell *)cell event:(PFObject *)event {
    cell.eventName.text =event[@"Name"];
    cell.eventDescription.text=event[@"Description"];
    switch ([CMVLocalize myDeviceLocaleIs]) {
        case IT :
            if (!(([event[@"memoIT"] isKindOfClass:[NSNull class]]) || (event[@"memoIT"] == nil) || ([event[@"memoIT"] isEqualToString:@""]))) {
                cell.eventMemo=event[@"memoIT"];
                cell.readDescription.hidden =NO;
            }
            if (!(([event[@"NameIT"] isKindOfClass:[NSNull class]]) || (event[@"NameIT"] == nil))) {
                cell.eventName.text = event[@"NameIT"];
            }
            if (!(([event[@"DescriptionIT"] isKindOfClass:[NSNull class]]) || (event[@"DescriptionIT"] == nil))) {
                cell.eventDescription.text = event[@"DescriptionIT"];
                
            }
            break;
        case DE :
            if (!(([event[@"memoDE"] isKindOfClass:[NSNull class]]) || (event[@"memoDE"] == nil) || ([event[@"memoDE"] isEqualToString:@""]))) {
                cell.eventMemo=event[@"memoDE"];
                cell.readDescription.hidden =NO;
            }
            if (!(([event[@"NameDE"] isKindOfClass:[NSNull class]]) || (event[@"NameDE"] == nil))) {
                cell.eventName.text = event[@"NameDE"];
            }
            if (!(([event[@"DescriptionDE"] isKindOfClass:[NSNull class]]) || (event[@"DescriptionDE"] == nil))) {
                cell.eventDescription.text = event[@"DescriptionDE"];
               
            }
            break;
        case FR :
            if (!(([event[@"memoFR"] isKindOfClass:[NSNull class]]) || (event[@"memoFR"] == nil) || ([event[@"memoFR"] isEqualToString:@""]))) {
                cell.eventMemo=event[@"memoFR"];
                cell.readDescription.hidden =NO;
            }
            if (!(([event[@"NameFR"] isKindOfClass:[NSNull class]]) || (event[@"NameFR"] == nil))) {
                cell.eventName.text = event[@"NameFR"];
            }
            if (!(([event[@"DescriptionFR"] isKindOfClass:[NSNull class]]) || (event[@"DescriptionFR"] == nil))) {
                cell.eventDescription.text = event[@"DescriptionFR"];
                
            }
            break;
        case ES :
            if (!(([event[@"memoES"] isKindOfClass:[NSNull class]]) || (event[@"memoES"] == nil) || ([event[@"memoES"] isEqualToString:@""]))) {
                cell.eventMemo=event[@"memoES"];
                cell.readDescription.hidden =NO;
            }
            if (!(([event[@"NameES"] isKindOfClass:[NSNull class]]) || (event[@"NameES"] == nil))) {
                cell.eventName.text = event[@"NameES"];
            }
            if (!(([event[@"DescriptionES"] isKindOfClass:[NSNull class]]) || (event[@"DescriptionES"] == nil))) {
                cell.eventDescription.text = event[@"DescriptionES"];
                
            }
            break;
        case RU  :
            if (!(([event[@"memoRU"] isKindOfClass:[NSNull class]]) || (event[@"memoRU"] == nil) || ([event[@"memoRU"] isEqualToString:@""]))) {
                cell.eventMemo=event[@"memoRU"];
                cell.readDescription.hidden =NO;
            }
            if (!(([event[@"NameRU"] isKindOfClass:[NSNull class]]) || (event[@"NameRU"] == nil))) {
                cell.eventName.text = event[@"NameRU"];
            }
            if (!(([event[@"DescriptionRU"] isKindOfClass:[NSNull class]]) || (event[@"DescriptionRU"] == nil))) {
                cell.eventDescription.text = event[@"DescriptionRU"];
                
            }
            break;
        case ZH:
            if (!(([event[@"memoZH"] isKindOfClass:[NSNull class]]) || (event[@"memoZH"] == nil) || ([event[@"memoZH"] isEqualToString:@""]))) {
                cell.eventMemo=event[@"memoZH"];
                cell.readDescription.hidden =NO;
            }
            if (!(([event[@"NameZH"] isKindOfClass:[NSNull class]]) || (event[@"NameZH"] == nil))) {
                cell.eventName.text = event[@"NameZH"];
            }
            if (!(([event[@"DescriptionZH"] isKindOfClass:[NSNull class]]) || (event[@"DescriptionZH"] == nil))) {
                cell.eventDescription.text = event[@"DescriptionZH"];
                
            }
            break;
        case EN:
            if (!(([event[@"memo"] isKindOfClass:[NSNull class]]) || (event[@"memo"] == nil) || ([event[@"memo"] isEqualToString:@""]))) {
                cell.eventMemo=event[@"memo"];
                cell.readDescription.hidden =NO;
            }
            cell.eventMemo=event[@"memo"];
            if (!(([event[@"Name"] isKindOfClass:[NSNull class]]) || (event[@"Name"] == nil))) {
                cell.eventName.text = event[@"Name"];
            }
            if (!(([event[@"Description"] isKindOfClass:[NSNull class]]) || (event[@"Description"] == nil))) {
                cell.eventDescription.text = event[@"Description"];
                
            }
            break;
            
        default:
            cell.eventMemo=event[@"memo"];
            cell.eventName.text =event[@"Name"];
            cell.eventDescription.text=event[@"Description"];
            
            break;
    }
}


#pragma mark - SWTableViewDelegate

- (void)swippableTableViewCell:(CMVSwipeTableViewCell *)cell
didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    
    
    switch (index) {
        case 0:
            [self shareButtonPress:@"TwitterSharingEvents"];
            [self initWithSocial:SLServiceTypeTwitter andCell:cell];
            break;
        case 1:
        {
            [self shareButtonPress:@"FacebookSharingEvents"];
            [self initWithSocial:SLServiceTypeFacebook andCell:cell];
            break;
        }
        case 2: {
            [self shareButtonPress:@"CalendarSharingEvents"];
            CMVEventKitShared *eks=[[CMVEventKitShared alloc] init];
            [eks setUpEvent:cell];
        }
            break;
        default:
            break;
    }
    
}
-(void)shareButtonPress:(NSString *)type{
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    if (![type  isEqual: @"CalendarSharingEvents"]) {
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"SHARING"
                                                              action:@"press"
                                                               label:type
                                                               value:nil] build]];
    } else {
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"REMINDER"
                                                          action:@"press"
                                                           label:type
                                                           value:nil] build]];
    }
    [tracker set:kGAIScreenName value:nil];
}
-(void)initWithSocial:(NSString *)service andCell:(CMVSwipeTableViewCell *)cell {
    if (![SLComposeViewController isAvailableForServiceType:service])
    {
        [self showUnavailableAlertForServiceType:service];
    }
    else
    {
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:service];
        [composeViewController addImage:cell.picture.image];
        [composeViewController addURL:[NSURL URLWithString:cell.eventURL]];
        NSString *initalTextString = cell.eventDescription.text;
        [composeViewController setInitialText:initalTextString];
        
        composeViewController.completionHandler = ^(SLComposeViewControllerResult result) {
            switch(result) {
                    //  This means the user cancelled without sending the Tweet
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Cancelled");
                    break;
                    //  This means the user hit 'Send'
                case SLComposeViewControllerResultDone:
                    [self shareButtonPress:service];
                    break;
            }
            
            //  dismiss the Tweet Sheet
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:NO completion:^{
                    NSLog(@"Tweet Sheet has been dismissed.");
                }];
            });
        };
        
        [self presentViewController:composeViewController animated:YES completion:nil];
    }
}

- (void)showUnavailableAlertForServiceType:(NSString *)serviceType
{
    NSString *serviceName = @"";
    
    if (serviceType == SLServiceTypeFacebook)
    {
        serviceName = @"Facebook";
    }
    else if (serviceType == SLServiceTypeTwitter)
    {
        serviceName = @"Twitter";
    }
    
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Account"
                              message:[NSString stringWithFormat:@"Please go to the device settings and add a %@ account in order to share through that service", serviceName]
                              delegate:nil
                              cancelButtonTitle:@"Close"
                              otherButtonTitles:nil];
    [alertView show];
}




- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

-(void) fetchAllObjects {
    
    // if (parseReachable.isParseReachable() && (self.noteObjects.count == 0)) {
    //  PFObject.unpinAllObjectsInBackgroundWithBlock(nil)
    
    
    PFQuery *query = [PFQuery queryWithClassName:PARSE_CLASS_NAME];
    
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
    
    
    PFQuery *query = [PFQuery queryWithClassName:PARSE_CLASS_NAME];
    
    [query fromLocalDatastore];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            storage = objects.mutableCopy;
            [self.tableView reloadData];
            //            [PFObject pinAllInBackground:objects block:nil ];
            //            [self fetchAllObjectsFromLocalDatastore];
            
        } else {
            
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
}


@end
