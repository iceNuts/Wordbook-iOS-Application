//
//  ScheduleController.m
//  LangL
//
//  Created by king bill on 11-8-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ScheduleController.h"
#import "SBJson.h"
#import "ASIHTTPRequest.h"
#import "LangLAppDelegate.h"
#import "DailyListExController.h"
#import "PhaseSelectionController.h"
#import "NavigateToNextButton.h"

@implementation ScheduleController

@synthesize scheduleView;
@synthesize hasPaid;
@synthesize loadingIcon;
@synthesize currDateStr;

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

-(void)loadView
{
    [super loadView];
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    //if has phase data, don't need to reload
	
	mainDelegate.ScheduleList = nil;
	
	NSArray *StoreFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *DoucumentsDirectiory = [StoreFilePath objectAtIndex:0];
	NSString *bookDir = [DoucumentsDirectiory stringByAppendingPathComponent:mainDelegate.CurrWordBookID];
	NSString *phaseDir = [bookDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%d",mainDelegate.CurrPhaseIdx]];
	NSString *filePath = [phaseDir stringByAppendingPathComponent:@"LangLibWordBookPhaseInfo.plist"];
	
	mainDelegate.ScheduleList = [NSMutableArray arrayWithContentsOfFile:filePath];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg_main_green.png"]];
    self.view.backgroundColor = background;
    [background release];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    NSTimeZone *timeZone = [NSTimeZone localTimeZone];    
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat : @"yyyy-MM-dd"];
    currDateStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow: 0.0]];
    [currDateStr retain];
    [formatter release];  
    
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
	
	if(mainDelegate.ScheduleList == nil){
		NSDictionary *reqDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 mainDelegate.CurrUserID, @"userID",
                                 mainDelegate.CurrWordBookID, @"wordBookID",
                                 [NSString stringWithFormat:@"%d", mainDelegate.CurrPhaseIdx], @"phaseIdx",
                                 nil];
        
		NSString* reqString = [NSString stringWithString:[reqDict JSONRepresentation]];    
		NSURL *url = [NSURL URLWithString:@"http://www.langlib.com/webservices/mobile/ws_mobilewordbook.asmx/ListSchedule"];
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
		[request addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"]; 
		[request addRequestHeader:@"Content-Type" value:@"application/json"];    
		[request appendPostData:[reqString dataUsingEncoding:NSUTF8StringEncoding]];
		[request setDelegate:self];
		[request startAsynchronous];
	}else{
		[loadingIcon stopAnimating];
		scheduleView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 410)];
		
		scheduleView.delegate = self;
		scheduleView.dataSource = self;
		[self.view addSubview:self.scheduleView];
		
		scheduleView.separatorColor = [UIColor clearColor];
		scheduleView.backgroundColor = [UIColor clearColor];
		scheduleView.opaque = NO;
		scheduleView.backgroundView = nil;
		
		UIBarButtonItem *statButton = [[UIBarButtonItem alloc] initWithTitle:@"状态" style:UIBarButtonItemStylePlain target:self action:@selector(btnViewStat)];
		self.navigationItem.rightBarButtonItem = statButton;
		[statButton release];
		
		NavigateToNextButton *btnViewStat = [[NavigateToNextButton alloc] init];
		[btnViewStat setTitle:@"  统 计" forState:UIControlStateNormal];
		
		[btnViewStat addTarget:self action:@selector(btnViewStat) forControlEvents:UIControlEventTouchUpInside];
		//定制自己的风格的  UIBarButtonItem
		UIBarButtonItem* viewStatButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnViewStat];
		[self.navigationItem  setRightBarButtonItem:viewStatButtonItem];
		[viewStatButtonItem release];
		[btnViewStat release];
	}
    
    hasPaid = false;
    for (NSDictionary *wordBook in mainDelegate.WordBookList) {
        if ([wordBook objectForKey:@"WordBookID"] == mainDelegate.CurrWordBookID)
        {
            if ([[wordBook objectForKey:@"IsPaid"] integerValue] == 1)
                hasPaid = YES;
            else
				hasPaid = NO;
            break;            
        }
    }
    self.title = [mainDelegate GetDictNameByType:mainDelegate.CurrDictType];
}


- (void)requestFinished:(ASIHTTPRequest *)request
{
    [loadingIcon stopAnimating];
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];   
    // Use when fetching text data
    NSString *responseString = [request responseString];
    NSDictionary* responseDict = [responseString JSONValue];
    
    
    mainDelegate.ScheduleList = (NSMutableArray *) [responseDict objectForKey:@"d"];
   
    //write phase data to plist
	NSArray *StoreFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *DoucumentsDirectiory = [StoreFilePath objectAtIndex:0];
	NSString *bookDir = [DoucumentsDirectiory stringByAppendingPathComponent:mainDelegate.CurrWordBookID];
	NSString *phaseDir = [bookDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%d",mainDelegate.CurrPhaseIdx]];
	
	//create phaseDir
	NSError *error;
	if (![[NSFileManager defaultManager] fileExistsAtPath:phaseDir]){
		[[NSFileManager defaultManager] createDirectoryAtPath: phaseDir withIntermediateDirectories:YES attributes:nil error:&error];
    }
	
	NSString *filePath = [phaseDir stringByAppendingPathComponent:@"LangLibWordBookPhaseInfo.plist"]; 	
	[mainDelegate.ScheduleList writeToFile:filePath atomically: YES];
				
    scheduleView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 410)];
    
    scheduleView.delegate = self;
    scheduleView.dataSource = self;
    [self.view addSubview:self.scheduleView];  
    
    scheduleView.separatorColor = [UIColor clearColor];  
    scheduleView.backgroundColor = [UIColor clearColor];
    scheduleView.opaque = NO;
    scheduleView.backgroundView = nil;
    
    UIBarButtonItem *statButton = [[UIBarButtonItem alloc] initWithTitle:@"状态" style:UIBarButtonItemStylePlain target:self action:@selector(btnViewStat)];          
    self.navigationItem.rightBarButtonItem = statButton;
    [statButton release];
    
    NavigateToNextButton *btnViewStat = [[NavigateToNextButton alloc] init];    
    [btnViewStat setTitle:@"  统 计" forState:UIControlStateNormal]; 
    
    [btnViewStat addTarget:self action:@selector(btnViewStat) forControlEvents:UIControlEventTouchUpInside];     
    //定制自己的风格的  UIBarButtonItem
    UIBarButtonItem* viewStatButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnViewStat]; 
    [self.navigationItem  setRightBarButtonItem:viewStatButtonItem]; 
    [viewStatButtonItem release]; 
    [btnViewStat release]; 
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [loadingIcon stopAnimating];
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
    [mainDelegate showNetworkFailed];
}


-(void) btnViewStat 
{
    PhaseSelectionController *detailViewController = [[PhaseSelectionController alloc] initWithNibName:@"PhaseSelectionController" bundle:nil];
    
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}

- (void)viewDidUnload
{
    [self setLoadingIcon:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];     
    return mainDelegate.ScheduleList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    UIImageView *splitter = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_item.png"]];
    [splitter setFrame: CGRectMake(0, 64, 310, 2)];
    [cell.contentView addSubview: splitter];
    [splitter release];
        
    cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_item.png"]] autorelease];
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];
    NSDictionary *dict = [mainDelegate.ScheduleList objectAtIndex: indexPath.row];
    
    
    UILabel *hint1 = [[UILabel alloc] initWithFrame:CGRectMake(60, 3, 100, 30)];
    hint1.textColor = [UIColor colorWithRed:255.0/255.0 green:215.0/255.0 blue:125.0/255.0 alpha:1];
    hint1.text = [dict valueForKey:@"CDate"];;
    hint1.font = [UIFont systemFontOfSize:15];
    hint1.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview: hint1];
    [hint1 release];
      
    if ((hasPaid) || (indexPath.row <= 1))
    {
        int total = 0;
        int complete = 0;
        for (NSDictionary *singleList in [dict objectForKey:@"NL"]) {
            if ([[singleList objectForKey:@"LID"] integerValue] != 0)
            {
                if ([[singleList objectForKey:@"C"] boolValue] == true)
                    complete++;
                total++;
            }
            
        }
        for (NSDictionary *singleList in [dict objectForKey:@"OL"]) {
            if ([[singleList objectForKey:@"LID"] integerValue] != 0)
            {
                if ([[singleList objectForKey:@"C"] boolValue] == true)
                    complete++;
                total++;
            }
            
        }
        

        
        if (complete == total)
        {
            UIImageView *iconImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_datebook_finish.png"]];
            [iconImage setFrame: CGRectMake(10, 8, 40, 46)];
            [cell.contentView addSubview: iconImage];
            [iconImage release];
 
            UILabel *hint2 = [[UILabel alloc] initWithFrame:CGRectMake(60, 30, 150, 20)];
            hint2.textColor = [UIColor greenColor];
            hint2.text = @"已完成";
            hint2.font = [UIFont systemFontOfSize:13];
            hint2.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview: hint2];
            [hint2 release];
        }        
        else 
        {
            if ([currDateStr compare:[dict valueForKey:@"CDate"]] == NSOrderedSame)
            {
                UIImageView *iconImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_datebook_open.png"]];
                [iconImage setFrame: CGRectMake(10, 8, 40, 46)];
                [cell.contentView addSubview: iconImage];
                [iconImage release];                 
            }
            else
            {
                UIImageView *iconImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_datebook.png"]];
                [iconImage setFrame: CGRectMake(10, 8, 40, 46)];
                [cell.contentView addSubview: iconImage];
                [iconImage release];  
            }
            
            UILabel *hint2 = [[UILabel alloc] initWithFrame:CGRectMake(60, 30, 150, 20)];
            hint2.textColor = [UIColor colorWithRed:255.0/255.0 green:160.0/255.0 blue:0.0/255.0 alpha:1];
            hint2.text = @"未完成";
            hint2.font = [UIFont systemFontOfSize:13];
            hint2.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview: hint2];
            [hint2 release];            
        }        
        if ([currDateStr compare:[dict valueForKey:@"CDate"]] == NSOrderedSame)
        {
            UIImageView *todayImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_redmark_today.png"]];
            [todayImage setFrame: CGRectMake(150, 5, 65, 30)];
            [cell.contentView addSubview: todayImage];
            [todayImage release];          
        }
        UIImageView *disclosureImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"ico_arrow.png"]];
        [disclosureImage setFrame: CGRectMake(280, 20, 20, 24)];
        [cell.contentView addSubview: disclosureImage];
        [disclosureImage release];
    }
    else
    {
        UILabel *hint2 = [[UILabel alloc] initWithFrame:CGRectMake(60, 30, 150, 20)];
        hint2.textColor = [UIColor colorWithRed:255.0/255.0 green:160.0/255.0 blue:0.0/255.0 alpha:1];
        hint2.text = @"未完成";
        hint2.font = [UIFont systemFontOfSize:13];
        hint2.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview: hint2];
        [hint2 release];    
        
        UIImageView *iconImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_datebook.png"]];
        [iconImage setFrame: CGRectMake(10, 8, 40, 46)];
        [cell.contentView addSubview: iconImage];
        [iconImage release];  
        
        UIImageView *disclosureImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"ico_lock.png"]];
        [disclosureImage setFrame: CGRectMake(280, 20, 20, 24)];
        [cell.contentView addSubview: disclosureImage];
        [disclosureImage release];
        
    }



    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((hasPaid) || (indexPath.row <= 1))
    {
        LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
    
        NSDictionary *dict = [mainDelegate.ScheduleList objectAtIndex: indexPath.row];
        mainDelegate.CurrItemIdx = [[dict valueForKey:@"Idx"]  integerValue];
    
        DailyListExController *detailViewController = [[DailyListExController alloc] initWithNibName:@"DailyListExController" bundle:nil];
    
        [self.navigationController pushViewController:detailViewController animated:YES];
        [detailViewController release];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]//
                              initWithTitle:@"提示"
                              message:@"你需要购买后方可使用此词汇书的完整功能"
                              delegate:self
                              cancelButtonTitle:@"确定"
                              otherButtonTitles:nil];
        
        [alert show];
        [alert release];  
    }
}


- (void)dealloc {    
    [scheduleView release];
    [loadingIcon release];
    [super dealloc];
}
@end
