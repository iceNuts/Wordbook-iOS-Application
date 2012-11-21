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
	NSString *tmp = [NSString stringWithFormat:@"%d",mainDelegate.CurrDictType];
	NSString *dbDir = [[DoucumentsDirectiory stringByAppendingPathComponent:tmp]  stringByAppendingString:@".db"];
	
	//check time to see if need to refresh
	NSDictionary* fileData = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
	NSDate* fileDate = [fileData objectForKey:NSFileModificationDate];
	NSDate* today = [NSDate date];
	//1 less than 3h 2 db exist or must fetch online
	if (![[[today dateByAddingTimeInterval:-(60*60*3)] earlierDate:fileDate] isEqualToDate:fileDate] && [[NSFileManager defaultManager] fileExistsAtPath:dbDir]) {
        //file is less than 3 hours old, use this file.
		mainDelegate.ScheduleList = [NSMutableArray arrayWithContentsOfFile:filePath];	
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg_main_green.png"]];
    self.view.backgroundColor = background;
	if(background)
		[background release];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    NSTimeZone *timeZone = [NSTimeZone localTimeZone];    
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat : @"yyyy-MM-dd"];
    currDateStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow: 0.0]];
    [currDateStr retain];
	if(formatter)
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
		
		//Add pull to refresh header
		if(_refreshHeaderView == nil){
			EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.scheduleView.bounds.size.height, self.view.frame.size.width, self.scheduleView.bounds.size.height)];
			view.delegate = self;
			[self.scheduleView addSubview:view];
			_refreshHeaderView = view;
			[view release];
		}
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

-(void) viewDidAppear:(BOOL)animated{
	[scheduleView reloadData];
	
	if(isAllFinished){
		LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];
		NSArray *StoreFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *DoucumentsDirectiory = [StoreFilePath objectAtIndex:0];
		NSString *bookDir = [DoucumentsDirectiory stringByAppendingPathComponent:mainDelegate.CurrWordBookID];
		NSString *phaseDir = [bookDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%d",mainDelegate.CurrPhaseIdx]];
		NSString *filePath = [phaseDir stringByAppendingPathComponent:@"show"];
		if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]){
			//Pop alert view for share
//			SocialAlert* alertDelegate = [[SocialAlert alloc] init];
//			UIAlertView* alert = [[UIAlertView alloc]
//								  initWithTitle:@"提示" message:@"恭喜您完成了本阶段练习，将这个消息告诉朋友？" delegate:alertDelegate cancelButtonTitle:@"取消" otherButtonTitles:@"好的", nil];
//			[alert show];
//			[alert release];
			
			[[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
		}
	}
}


- (void)requestFinished:(ASIHTTPRequest *)request
{
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
	//Compare then set the value
	NSMutableArray* oldScheduleList;
	if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
		//load file and update the value for ScheduleList
		oldScheduleList = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
		for(NSDictionary* oldData in oldScheduleList){
			for(NSMutableDictionary* newData in mainDelegate.ScheduleList){
				if([[newData objectForKey:@"CDate"] isEqualToString:[oldData objectForKey:@"CDate"]]){
					NSMutableArray* newCompleteArray = [newData objectForKey:@"NL"];
					NSArray* oldCompleteArray = [oldData objectForKey:@"NL"];
					//compare 
					for(NSMutableDictionary* newCompleteDict in newCompleteArray){
						for(NSDictionary* oldCompleteDict in oldCompleteArray){
							if(([oldCompleteDict objectForKey:@"LID"] == [newCompleteDict objectForKey:@"LID"]) && ([[oldCompleteDict objectForKey:@"C"] boolValue] != [[newCompleteDict objectForKey:@"C"] boolValue])){
								[newCompleteDict setValue:[NSNumber numberWithBool:YES] forKey:@"C"];
								//Upload the result
								NSDictionary *reqDict = [NSDictionary dictionaryWithObjectsAndKeys:
														  [newData objectForKey:@"Idx"], @"scheduleItemIndex",
														 [newCompleteDict objectForKey:@"LID"], @"listID",
														 [NSString stringWithFormat:@"%@", @"true"], @"selected",
														 mainDelegate.CurrWordBookID, @"wordBookID",
														 [NSString stringWithFormat:@"%d", mainDelegate.CurrPhaseIdx], @"subWbIdx",
														 mainDelegate.CurrUserID, @"userID",
														 nil];
								//RPC JSON
								NSString* reqString = [NSString stringWithString:[reqDict JSONRepresentation]];
								
								NSURL *url = [NSURL URLWithString:@"http://www.langlib.com/webservices/mobile/ws_mobilewordbook.asmx/MarkListStudyCompleted"];
								__block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
								[request addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"];
								[request addRequestHeader:@"Content-Type" value:@"application/json"];
								[request appendPostData:[reqString dataUsingEncoding:NSUTF8StringEncoding]];
								[request startAsynchronous];
								break;
							}
						}
					}
					//Switch to OL
					newCompleteArray = [newData objectForKey:@"OL"];
					oldCompleteArray = [oldData objectForKey:@"OL"];
					for(NSMutableDictionary* newCompleteDict in newCompleteArray){
						for(NSDictionary* oldCompleteDict in oldCompleteArray){
							if(([oldCompleteDict objectForKey:@"LID"] == [newCompleteDict objectForKey:@"LID"]) && ([[oldCompleteDict objectForKey:@"C"] boolValue] != [[newCompleteDict objectForKey:@"C"] boolValue])){
								[newCompleteDict setValue:[NSNumber numberWithBool:YES] forKey:@"C"];
								//Upload the result
								NSDictionary *reqDict = [NSDictionary dictionaryWithObjectsAndKeys:
														 [newData objectForKey:@"Idx"], @"scheduleItemIndex",
														 [newCompleteDict objectForKey:@"LID"], @"listID",
														 [NSString stringWithFormat:@"%@", @"true"], @"selected",
														 mainDelegate.CurrWordBookID, @"wordBookID",
														 [NSString stringWithFormat:@"%d", mainDelegate.CurrPhaseIdx], @"subWbIdx",
														 mainDelegate.CurrUserID, @"userID",
														 nil];
								//RPC JSON
								NSString* reqString = [NSString stringWithString:[reqDict JSONRepresentation]];
								
								NSURL *url = [NSURL URLWithString:@"http://www.langlib.com/webservices/mobile/ws_mobilewordbook.asmx/MarkListStudyCompleted"];
								__block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
								[request addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"];
								[request addRequestHeader:@"Content-Type" value:@"application/json"];
								[request appendPostData:[reqString dataUsingEncoding:NSUTF8StringEncoding]];
								[request startAsynchronous];
								break;
							}
						}
					}
					break;
				}
			}
		}
	}
	
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
	
	//Add pull to refresh heaer if db exist
	NSString *tmp = [NSString stringWithFormat:@"%d",mainDelegate.CurrDictType];
	NSString *dbDir = [[DoucumentsDirectiory stringByAppendingPathComponent:tmp]  stringByAppendingString:@".db"];
	if(_refreshHeaderView == nil && [[NSFileManager defaultManager] fileExistsAtPath:dbDir]){
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.scheduleView.bounds.size.height, self.view.frame.size.width, self.scheduleView.bounds.size.height)];
		view.delegate = self;
		[self.scheduleView addSubview:view];
		_refreshHeaderView = view;
		[view release];
	}
    
    NavigateToNextButton *btnViewStat = [[NavigateToNextButton alloc] init];
    [btnViewStat setTitle:@"  统 计" forState:UIControlStateNormal]; 
    
    [btnViewStat addTarget:self action:@selector(btnViewStat) forControlEvents:UIControlEventTouchUpInside];     
    //定制自己的风格的  UIBarButtonItem
    UIBarButtonItem* viewStatButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnViewStat]; 
    [self.navigationItem  setRightBarButtonItem:viewStatButtonItem]; 
    [viewStatButtonItem release]; 
    [btnViewStat release];
	//Rrefresh user data;
	[self performSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:)];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [loadingIcon stopAnimating];
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];
	
	NSArray *StoreFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *DoucumentsDirectiory = [StoreFilePath objectAtIndex:0];
	NSString *bookDir = [DoucumentsDirectiory stringByAppendingPathComponent:mainDelegate.CurrWordBookID];
	NSString *phaseDir = [bookDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%d",mainDelegate.CurrPhaseIdx]];
	NSString *filePath = [phaseDir stringByAppendingPathComponent:@"LangLibWordBookPhaseInfo.plist"];
	
	mainDelegate.ScheduleList = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
	
	if(mainDelegate.ScheduleList && [mainDelegate.ScheduleList count]){
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
	}else{
		[mainDelegate showNetworkFailed];
	}
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
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    UIImageView *splitter = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_item.png"]];
    [splitter setFrame: CGRectMake(0, 64, 310, 2)];
    [cell.contentView addSubview: splitter];
    [splitter release];
        
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_item.png"]];
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
        
		isAllFinished = NO;
        
        if (complete == total)
        {
            UIImageView *iconImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_datebook_finish.png"]];
            [iconImage setFrame: CGRectMake(10, 8, 40, 46)];
            [cell.contentView addSubview: iconImage];
			if(iconImage)
				[iconImage release];
 
            UILabel *hint2 = [[UILabel alloc] initWithFrame:CGRectMake(60, 30, 150, 20)];
            hint2.textColor = [UIColor greenColor];
            hint2.text = @"已完成";
            hint2.font = [UIFont systemFontOfSize:13];
            hint2.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview: hint2];
			if(hint2)
				[hint2 release];
			isAllFinished = YES;
        }
        else 
        {
            if ([currDateStr compare:[dict valueForKey:@"CDate"]] == NSOrderedSame)
            {
                UIImageView *iconImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_datebook_open.png"]];
                [iconImage setFrame: CGRectMake(10, 8, 40, 46)];
                [cell.contentView addSubview: iconImage];
				if(iconImage)
					[iconImage release];
            }
            else
            {
                UIImageView *iconImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_datebook.png"]];
                [iconImage setFrame: CGRectMake(10, 8, 40, 46)];
                [cell.contentView addSubview: iconImage];
				if(iconImage)
					[iconImage release];  
            }
            
            UILabel *hint2 = [[UILabel alloc] initWithFrame:CGRectMake(60, 30, 150, 20)];
            hint2.textColor = [UIColor colorWithRed:255.0/255.0 green:160.0/255.0 blue:0.0/255.0 alpha:1];
            hint2.text = @"未完成";
			isAllFinished = NO;
            hint2.font = [UIFont systemFontOfSize:13];
            hint2.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview: hint2];
			if(hint2)
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
		isAllFinished = NO;
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

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	//1 refresh schedule view
	LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];
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
	[request setCompletionBlock:^{
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
		//Compare then set the value
		NSMutableArray* oldScheduleList;
		if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
			//load file and update the value for ScheduleList
			oldScheduleList = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
			for(NSDictionary* oldData in oldScheduleList){
				for(NSMutableDictionary* newData in mainDelegate.ScheduleList){
					if([[newData objectForKey:@"CDate"] isEqualToString:[oldData objectForKey:@"CDate"]]){
						NSMutableArray* newCompleteArray = [newData objectForKey:@"NL"];
						NSArray* oldCompleteArray = [oldData objectForKey:@"NL"];
						//compare
						for(NSMutableDictionary* newCompleteDict in newCompleteArray){
							for(NSDictionary* oldCompleteDict in oldCompleteArray){
								if(([oldCompleteDict objectForKey:@"LID"] == [newCompleteDict objectForKey:@"LID"]) && ([[oldCompleteDict objectForKey:@"C"] boolValue] != [[newCompleteDict objectForKey:@"C"] boolValue])){
									[newCompleteDict setValue:[NSNumber numberWithBool:YES] forKey:@"C"];
									//Upload the result
									NSDictionary *reqDict = [NSDictionary dictionaryWithObjectsAndKeys:
															 [newData objectForKey:@"Idx"], @"scheduleItemIndex",
															 [newCompleteDict objectForKey:@"LID"], @"listID",
															 [NSString stringWithFormat:@"%@", @"true"], @"selected",
															 mainDelegate.CurrWordBookID, @"wordBookID",
															 [NSString stringWithFormat:@"%d", mainDelegate.CurrPhaseIdx], @"subWbIdx",
															 mainDelegate.CurrUserID, @"userID",
															 nil];
									//RPC JSON
									NSString* reqString = [NSString stringWithString:[reqDict JSONRepresentation]];
									
									NSURL *url = [NSURL URLWithString:@"http://www.langlib.com/webservices/mobile/ws_mobilewordbook.asmx/MarkListStudyCompleted"];
									__block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
									[request addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"];
									[request addRequestHeader:@"Content-Type" value:@"application/json"];
									[request appendPostData:[reqString dataUsingEncoding:NSUTF8StringEncoding]];
									[request startAsynchronous];
									break;
								}
							}
						}
						//Switch to OL
						newCompleteArray = [newData objectForKey:@"OL"];
						oldCompleteArray = [oldData objectForKey:@"OL"];
						for(NSMutableDictionary* newCompleteDict in newCompleteArray){
							for(NSDictionary* oldCompleteDict in oldCompleteArray){
								if(([oldCompleteDict objectForKey:@"LID"] == [newCompleteDict objectForKey:@"LID"]) && ([[oldCompleteDict objectForKey:@"C"] boolValue] != [[newCompleteDict objectForKey:@"C"] boolValue])){
									[newCompleteDict setValue:[NSNumber numberWithBool:YES] forKey:@"C"];
									//Upload the result
									NSDictionary *reqDict = [NSDictionary dictionaryWithObjectsAndKeys:
															 [newData objectForKey:@"Idx"], @"scheduleItemIndex",
															 [newCompleteDict objectForKey:@"LID"], @"listID",
															 [NSString stringWithFormat:@"%@", @"true"], @"selected",
															 mainDelegate.CurrWordBookID, @"wordBookID",
															 [NSString stringWithFormat:@"%d", mainDelegate.CurrPhaseIdx], @"subWbIdx",
															 mainDelegate.CurrUserID, @"userID",
															 nil];
									//RPC JSON
									NSString* reqString = [NSString stringWithString:[reqDict JSONRepresentation]];
									
									NSURL *url = [NSURL URLWithString:@"http://www.langlib.com/webservices/mobile/ws_mobilewordbook.asmx/MarkListStudyCompleted"];
									__block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
									[request addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"];
									[request addRequestHeader:@"Content-Type" value:@"application/json"];
									[request appendPostData:[reqString dataUsingEncoding:NSUTF8StringEncoding]];
									[request startAsynchronous];
									break;
								}
							}
						}
						break;
					}
				}
			}
		}
		[mainDelegate.ScheduleList writeToFile:filePath atomically: YES];
		[self.scheduleView reloadData];
	}];
	[request setFailedBlock:^{
		[mainDelegate showNetworkFailed];
	}];
	[request startAsynchronous];
	//2 fetch familarity data
	NSDictionary *reqDict2 = [NSDictionary dictionaryWithObjectsAndKeys:
							 mainDelegate.CurrUserID, @"userID",
							 mainDelegate.CurrWordBookID, @"dictID",
							 [NSString stringWithFormat:@"%d", mainDelegate.CurrPhaseIdx], @"phaseIdx",
							 nil];
	
	NSString* reqString2 = [NSString stringWithString:[reqDict2 JSONRepresentation]];
	NSURL *url2 = [NSURL URLWithString:@"http://www.langlib.com/webservices/mobile/ws_mobilewordbook.asmx/FetchAllWordInfo"];
    __block ASIHTTPRequest *request2 = [ASIHTTPRequest requestWithURL:url2];
	[request2 addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"];
	[request2 addRequestHeader:@"Content-Type" value:@"application/json"];
	[request2 appendPostData:[reqString2 dataUsingEncoding:NSUTF8StringEncoding]];
	[request2 setCompletionBlock:^{
		NSString *responseString = [request2 responseString];
		NSDictionary* responseDict = [responseString JSONValue];
		[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.scheduleView];
		//Filter & Write to a plist
		NSArray *StoreFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *DoucumentsDirectiory = [StoreFilePath objectAtIndex:0];
		NSString *bookDir = [DoucumentsDirectiory stringByAppendingPathComponent:mainDelegate.CurrWordBookID];
		NSString *phaseDir = [bookDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", mainDelegate.CurrPhaseIdx]];
		NSString *phaseUserDataDir = [phaseDir stringByAppendingPathComponent:@"LangLibPhaseUserData.plist"];
		NSString *uploadUserDataDir = [phaseDir stringByAppendingPathComponent:@"uploadUserData.plist"];
		NSMutableArray* newUserData = (NSMutableArray*)[responseDict objectForKey:@"d"];
		//Modify some keys
		NSMutableArray* modifiedUserData = [[NSMutableArray alloc] init];
		for(NSMutableDictionary* dict in newUserData){
			NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
			[tmpDict setObject:[dict objectForKey:@"F"] forKey:@"F"];
			[tmpDict setObject:[dict objectForKey:@"L"] forKey:@"LID"];
			[tmpDict setObject:[dict objectForKey:@"W"] forKey:@"WID"];
			[modifiedUserData addObject:tmpDict];
			if(tmpDict)
				[tmpDict release];
		}
		if([[NSFileManager defaultManager] fileExistsAtPath:uploadUserDataDir]){
			NSArray* toUploadData = [[NSArray alloc] initWithContentsOfFile:uploadUserDataDir];
			for(NSDictionary* upload in toUploadData){
				for(NSMutableDictionary* toModify in modifiedUserData){
					if([[toModify objectForKey:@"WID"] isEqualToString:[upload objectForKey:@"W"]]){
						[toModify setValue:[upload objectForKey:@"F"] forKey:@"F"];
					}
				}
			}
		}
		[modifiedUserData writeToFile:phaseUserDataDir atomically:YES];
		[loadingIcon stopAnimating];
		if(modifiedUserData)
			[modifiedUserData release];
	}];
	[request2 setFailedBlock:^{
		[loadingIcon stopAnimating];
	}];
	[request2 startAsynchronous];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return NO; // should return if data source model is reloading
	
}
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
	
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}



- (void)dealloc {
	if(scheduleView)
		[scheduleView release];
    [loadingIcon release];
    [super dealloc];
}
@end
