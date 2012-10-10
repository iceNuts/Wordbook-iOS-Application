//
//  ConfigDateParamController.m
//  LangL
//
//  Created by king bill on 11-9-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ConfigDateParamController.h"
#import "CreateWordBookController.h"
#import "LangLAppDelegate.h"

@implementation ConfigDateParamController

@synthesize selectDateView;
@synthesize dateFormatter;
@synthesize currDate;
@synthesize beginDateStr;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"bg_main_green.png"]]; 
    selectDateView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 250)];
    
    selectDateView.delegate = self;
    selectDateView.dataSource = self;
    [self.view addSubview:self.selectDateView];      
    
    selectDateView.separatorColor = [UIColor clearColor];
    selectDateView.backgroundColor = [UIColor clearColor];
    selectDateView.opaque = NO;
    selectDateView.backgroundView = nil;      
    
    self.currDate = [NSDate dateWithTimeIntervalSinceNow: 0.0];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    self.dateFormatter = formatter;
    [formatter release];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];    
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat : @"yyyy-MM-dd"]; 
    
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
    self.beginDateStr = [dateFormatter stringFromDate: mainDelegate.createParams.beginDate];
    self.title = @"选择开始日期";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [beginDateStr release];
    [currDate release];
    [selectDateView release];
    [super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 62;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
   
    
    UIImageView *splitter = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_item.png"]];
    [splitter setFrame: CGRectMake(0, 60, 320, 2)];
    [cell.contentView addSubview: splitter];
    [splitter release];
    
    cell.textLabel.font = [UIFont fontWithName:@"宋体" size:15];
    cell.detailTextLabel.font = [UIFont fontWithName:@"宋体" size:13];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1];
    cell.textLabel.textColor = [UIColor whiteColor];
    NSString *dateStr;
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"今天";
            dateStr = [dateFormatter stringFromDate:currDate];
            break;
        case 1:
            cell.textLabel.text = @"明天";
            dateStr = [dateFormatter stringFromDate:[currDate dateByAddingTimeInterval: 86400]];
            break;    
        case 2:
            cell.textLabel.text = @"后天";
            dateStr = [dateFormatter stringFromDate:[currDate dateByAddingTimeInterval: 86400 * 2]];
            break; 
        case 3:
            cell.textLabel.text = @"一周后";
            dateStr = [dateFormatter stringFromDate:[currDate dateByAddingTimeInterval: 86400 * 6]];
            break; 
        default:
            dateStr = @"";
            break;
    }
    cell.detailTextLabel.text = dateStr;
    if ([beginDateStr compare: dateStr] == NSOrderedSame)
    {
        UIImageView *selectedImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"ico_mark_finishlist.png"]];
        [selectedImage setFrame: CGRectMake(280, 15, 27, 27)];
        [cell.contentView addSubview: selectedImage];
        [selectedImage release];
    }
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
    
    switch (indexPath.row) {
        case 0:            
            mainDelegate.createParams.beginDate = [NSDate dateWithTimeInterval:0 sinceDate: currDate];
            break;
        case 1:
            mainDelegate.createParams.beginDate = [currDate dateByAddingTimeInterval: 86400];
            break;    
        case 2:
            mainDelegate.createParams.beginDate = [currDate dateByAddingTimeInterval: 86400 * 2];
            break; 
        case 3:
            mainDelegate.createParams.beginDate = [currDate dateByAddingTimeInterval: 86400 * 6];
            break; 
        default:
            break;
    }
    
    self.beginDateStr = [dateFormatter stringFromDate: mainDelegate.createParams.beginDate];
    [selectDateView reloadData];
}


@end
