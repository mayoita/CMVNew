//
//  CMVTournamentsViewZoomController.m
//  Casinò di Venezia
//
//  Created by Massimo Moro on 14/01/14.
//  Copyright (c) 2014 Casinò di Venezia SPA. All rights reserved.
//

#import "CMVTournamentsViewZoomController.h"

#import "CMVTournamentsViewController.h"
#import "CMVAppDelegate.h"
#import "CMVGameSplitViewController.h"
#import "CMVTournamentsViewController.h"
#import "CMVSharedClass.h"
#import <Parse/Parse.h>
#import "CMVEventKitShared.h"


#define ROW_HEIGHT 204
#define cellIdentifier @"CustomCell"
#define TOURNAMENT_IMAGE 0
#define TOURNAMENTS_INDEX 2
#define PARSE_CLASS_NAME @"Tournaments"

#define VE 0
#define CN 1

@interface CMVTournamentsViewZoomController ()
@property (nonatomic,strong)CMVDataClass *site;
@property(nonatomic)CGFloat rowHeight;

@property (strong, nonatomic) NSMutableDictionary *sections;
@property (strong, nonatomic) NSArray *sortedDays;
@property (strong, nonatomic) NSDateFormatter *sectionDateFormatter;
@property (strong, nonatomic) NSDateFormatter *cellDateFormatter;

@end

@implementation CMVTournamentsViewZoomController{
    NSDate *today;
    NSDate *nextDay;
    BOOL dayFound;
}

int Office;

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
    self.site=[CMVDataClass getInstance];
    

	
    [self.tableView registerNib:[UINib nibWithNibName:@"CMVCellView" bundle:nil] forCellReuseIdentifier:cellIdentifier];
    self.tableView.rowHeight = ROW_HEIGHT;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle =UITableViewCellSeparatorStyleNone ;
    
    // Makes the horizontal row seperator stretch the entire length of the table view
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
    //Delegate for iPad split controller
    self.tournamentDelegate=(CMVTournamentsViewController *)[self.splitViewController.viewControllers lastObject];
    //for iPhone
    if (!self.tournamentDelegate) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        CMVTournamentsViewController *tournamentDetail = [storyboard instantiateViewControllerWithIdentifier:@"TournamentViewController"];
        self.tournamentDelegate=tournamentDetail;
    }
   // [self setOffice];
   
    
    if (iPAD) {
        // on iPad only, don't clear the selection (we are displaying in a split view on iPad)
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BK_PokerHour.png"]];
        self.clearsSelectionOnViewWillAppear = NO;
        // default by selecting the first row
        //[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
      
        self.mainTabBarController = (CMVMainTabbarController *)self.tabBarController;
        int tabNumber = (int)[self.mainTabBarController selectedIndex];
        
        UISplitViewController *splitVC = [[self navigationController] splitViewController];
        int index = (int)[self.mainTabBarController.viewControllers indexOfObjectIdenticalTo:splitVC];
        
        if ( tabNumber == index || tabNumber == -1) {
            [self.mainTabBarController setCenterButtonDelegate:self];
        }
        
    }
    
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
   // NSDate *endDate = [self dateByAddingYears:1 toDate:startDate];
    
    
    for (PFObject *event in _tournament)
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

-(NSMutableDictionary *)sections {
    if (_sections) {
        return _sections;
    }
    if (_tournament.count > 0) {
        _sections=[NSMutableDictionary dictionary];
        [self createDateSort];
    }
    
    
    return _sections;
}

#pragma mark - Center button delegate
-(void)centerButtonAction:(UIButton *)sender {
    
    [self setOffice];
    
}

-(void)viewDidAppear:(BOOL)animated {
    
    if (iPAD) {
        [self.mainTabBarController setCenterButtonDelegate:self];
    }
    
  //  [self setOffice];
}

-(void)setOffice {
    CMVSharedClass *shared=[[CMVSharedClass alloc] init];
    if (self.site.location == VENEZIA) {
        Office=CN;
        _sections=nil;
        self.tournament=[shared retrieveObjects:PARSE_CLASS_NAME eventType:TOURNAMENTS_INDEX office:Office tableView:self.tableView];
        [self.myScrollSliding changeTextColor:BRAND_GREEN_COLOR];
        self.tabBarController.tabBar.tintColor=BRAND_GREEN_COLOR;
    } else {
        Office=VE;
        _sections=nil;
        self.tournament=[shared retrieveObjects:PARSE_CLASS_NAME eventType:TOURNAMENTS_INDEX office:Office tableView:self.tableView];
        [self.myScrollSliding changeTextColor:[UIColor redColor]];
        self.tabBarController.tabBar.tintColor=BRAND_RED_COLOR;
    }
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
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

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    CMVSwipeTableViewCell *cell = (CMVSwipeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    //Cell set up
    NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:indexPath.section];
    NSArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
    if (dateRepresentingThisDay == today || dateRepresentingThisDay == nextDay) {
        if (!dayFound) {
            [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            dayFound =TRUE;
        }
    }
    
    PFObject *event=[eventsOnThisDay objectAtIndex:indexPath.row];
    
    static NSDateFormatter *formatter = nil;
    if (formatter == nil) {
        NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"EEEE dd, MMMM" options:0
                                                                  locale:[NSLocale currentLocale]];
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:formatString];
    }

    //Show default image
    PFFile *imageFile=event[@"ImageTournament"];
    if (([imageFile isKindOfClass:[NSNull class]]) || (imageFile == nil)) {
    
        cell.picture.image = [UIImage imageNamed:@"TournamentCellBackground.png"];
        cell.labelForPoker.hidden=NO;
        cell.dateForPoker.hidden=NO;
       
    } else {
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
         
            cell.picture.image=[UIImage imageWithData:data];
            cell.snapshoot = [self captureView:cell];
        }    ];
        cell.labelForPoker.hidden=YES;
        cell.dateForPoker.hidden=YES;
    }
    cell.readDescription.hidden=YES;

    cell.dateForPoker.layer.shadowOpacity = 0.5;
    cell.dateForPoker.layer.shadowRadius = 0.3;
    cell.dateForPoker.layer.shadowOffset = CGSizeMake(1.0, -1.0);
    cell.dateForPoker.font=AECHE(20);
    cell.dateForPoker.textColor=[UIColor whiteColor];
    
    cell.labelForPoker.layer.shadowOpacity = 0.5;
    cell.labelForPoker.layer.shadowRadius = 0.3;
    cell.labelForPoker.layer.shadowOffset = CGSizeMake(1.0, -1.0);
    cell.labelForPoker.font=AECHE(21);
    cell.labelForPoker.textColor=[UIColor colorWithRed:0.980 green:0.627 blue:0.000 alpha:1.000];
    cell.labelForPoker.text=@"POKER HOUR CA'NOGHERA";
    

    cell.delegate = self;
    //Settings for iPAD sharing even
   
    cell.labelForPoker.text=[event objectForKey:@"TournamentName"];
    cell.eventName.text=[event objectForKey:@"TournamentName"];
    cell.eventURL = [event objectForKey:@"TournamentURL"];
    cell.startDate =[event objectForKey:@"StartDate"];
    cell.endDate =[event objectForKey:@"EndDate"];
    cell.dateForPoker.text = [self formatStartEndDate:[event objectForKey:@"StartDate"] andEnd:[event objectForKey:@"EndDate"]];
    cell.eventDescription.text=event[@"TournamentDescription"];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(CMVSwipeTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.snapshoot = [self captureView:cell];
}



- (UIImage *)captureView:(UIView *)view {
    //CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect screenRect = view.bounds;
    
    UIGraphicsBeginImageContext(screenRect.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    CGContextFillRect(ctx, screenRect);
    
    [view.layer renderInContext:ctx];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(NSString *)formatStartEndDate:(NSDate *)start andEnd:(NSDate *)end {
    NSString *mystring;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"d" options:0
                                                              locale:[NSLocale currentLocale]];
    
    [dateFormatter setDateFormat:formatString];
    NSString *myNewFormatDate = [dateFormatter stringFromDate:start];
    NSString *formatEndString = [NSDateFormatter dateFormatFromTemplate:@"dMMMM" options:0
                                                                 locale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:formatEndString];
    NSString *myEndDate =[dateFormatter stringFromDate:end];
    
    mystring = [NSString stringWithFormat:NSLocalizedString(@"FROM %@ to %@",nil), myNewFormatDate, myEndDate];
    return mystring.uppercaseString;
}

#pragma mark - SWTableViewDelegate

- (void)swippableTableViewCell:(CMVSwipeTableViewCell *)cell
didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    
    switch (index) {
        case 0:
            [self shareButtonPress:@"TwitterSharingTournament"];
            [self initWithSocial:SLServiceTypeTwitter andCell:cell];
            break;
        case 1:
        {
            [self shareButtonPress:@"FacebookSharingTournament"];
            [self initWithSocial:SLServiceTypeFacebook andCell:cell];
            break;
        }
        case 2:{
            [self shareButtonPress:@"CalendarSharingTournament"];
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
    
    if (![type  isEqual: @"CalendarSharingTournament"]) {
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
        [composeViewController addImage:cell.snapshoot];
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


-(void)tapTableViewCell:(CMVSwipeTableViewCell *)cell {
    
    [self tableView:self.tableView didSelectRowAtIndexPath:[self.tableView indexPathForCell:cell]];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CMVAppDelegate *appDelegate=(CMVAppDelegate *)[UIApplication sharedApplication].delegate;
    UIStoryboard *storyboard =appDelegate.storyboard;
    
    // Get a reference to the DetailViewManager.
    // DetailViewManager is the delegate of our split view.
    CMVGameSplitViewController *detailViewManager = (CMVGameSplitViewController *)self.splitViewController.delegate;
    
    CMVSwipeTableViewCell *cell = (CMVSwipeTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    
    if (iPHONE) {
        [self configureDetailItemForRow:indexPath viewController:self.tournamentDelegate withCell:cell];
        [self presentViewController:self.tournamentDelegate animated:YES completion:nil];
        
    }else {
        
        CMVTournamentsViewController *presentingViewController=  [storyboard instantiateViewControllerWithIdentifier:@"SingleTournament"];
        
        [self configureDetailItemForRow:indexPath viewController:presentingViewController withCell:cell];
        
        detailViewManager.detailViewController = presentingViewController;
        
    }
}

- (void)configureDetailItemForRow:(NSIndexPath *)indexPath viewController:(CMVTournamentsViewController *)viewController withCell:cell {
    
    
    if (viewController) {
        if ([_tournament count] != 0) {
            NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:indexPath.section];
            NSArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
            [viewController selectedTournament:[eventsOnThisDay objectAtIndex:indexPath.row]];
            viewController.cell=cell;
        }
        
    }
    
}





@end
