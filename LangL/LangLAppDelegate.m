//
//  LangLAppDelegate.m
//  LangL
//
//  Created by king bill on 11-8-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "LangLAppDelegate.h"
#import "LoginController.h"
#import "WBListController.h"


@implementation LangLAppDelegate

@synthesize window = _window;
@synthesize loginController=_loginController;
@synthesize CurrUserID;
@synthesize CurrWordBookID;
@synthesize  CurrPhaseIdx;
@synthesize  CurrItemIdx;
@synthesize CurrListID;
@synthesize CurrDictType;
@synthesize CurrWordIdx;
@synthesize  NeedReloadSchedule;
@synthesize  ScheduleList;
@synthesize  WordList;
@synthesize WordBookList;
@synthesize CurrSortType;
@synthesize filteredArr;
@synthesize enableFilter;
@synthesize createParams;
@synthesize ProductPriceArr;
@synthesize QuizList;
@synthesize QuizListID;
@synthesize AutoVoice;
@synthesize AutoNextWord;
@synthesize AutoFamiliarity;
@synthesize isWordFirstAppear;
@synthesize PhaseCount;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity: 100];
    self.filteredArr = arr;
        
	//If login, switch to word list directly
	NSArray *StoreFilePath            =    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *DoucumentsDirectiory	=    [StoreFilePath objectAtIndex:0];
    NSString *filePath                =    [DoucumentsDirectiory stringByAppendingPathComponent:@"LangLibWordBookConfig.plist"];
    
    NSMutableDictionary* plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    NSString *uid = [plistDict objectForKey:@"UserID"];
	UINavigationController *navigationController;
	
    if (![uid isEqualToString: @"0"] && uid){
		self.CurrUserID = uid;
		self.isWordFirstAppear = YES;
		WBListController *wbController=[[WBListController alloc] initWithNibName:@"WBListController" bundle:nil];
		navigationController = [[UINavigationController alloc] initWithRootViewController:wbController];
		[wbController release];
	}else{
		self.isWordFirstAppear = NO;
		LoginController *aLoginController = [[LoginController alloc]
											 initWithNibName:@"LoginController" bundle:nil];
		navigationController = [[UINavigationController alloc] initWithRootViewController:aLoginController];
		aLoginController.forceLogin = YES;
		[aLoginController release];   
	}
	
    navigationController.delegate = self;
    self.window.rootViewController = navigationController;
    
    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bg_header.png"] forBarMetrics:UIBarMetricsDefault];
    }
    [navigationController release];
    [self.window makeKeyAndVisible];  
    self.NeedReloadSchedule = NO;
    self.QuizListID = 0;
    return YES;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	
	if(isWordFirstAppear && [navigationController.viewControllers count] == 1){
		//Add log out button
		UIButton *myBackButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [myBackButton setFrame:CGRectMake(0,0,60,35)];
        UIImage *image = [UIImage imageNamed:@"butn_header_back_n.png"];
        UIImage *stretchImage =
        [image stretchableImageWithLeftCapWidth:15.0 topCapHeight:0.0];
		
        UIImage *image1 = [UIImage imageNamed:@"butn_header_back_p.png"];
        UIImage *stretchImage1 =
        [image1 stretchableImageWithLeftCapWidth:15.0 topCapHeight:0.0];
        
        [myBackButton setBackgroundImage: stretchImage forState:UIControlStateNormal];
        [myBackButton setBackgroundImage: stretchImage1 forState:UIControlStateSelected];
        [myBackButton setEnabled:YES];
        if (viewController.view.tag == 1001)
            [myBackButton setTitle:@"  确 定" forState:UIControlStateNormal];
        else [myBackButton setTitle:@"  返 回" forState:UIControlStateNormal];
        [myBackButton.titleLabel setFont: [UIFont boldSystemFontOfSize: 14]];
        myBackButton.titleLabel.textColor = [UIColor whiteColor];
        [myBackButton addTarget:self action:@selector(userLogout) forControlEvents:UIControlEventTouchUpInside];
        
        [myBackButton release];
        UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithCustomView:myBackButton];
        viewController.navigationItem.leftBarButtonItem = backButton;
		
        [backButton release];
	}
	
    if([navigationController.viewControllers count ] > 1) {
        
        UIButton *myBackButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [myBackButton setFrame:CGRectMake(0,0,60,35)];
        UIImage *image = [UIImage imageNamed:@"butn_header_back_n.png"];
        UIImage *stretchImage = 
        [image stretchableImageWithLeftCapWidth:15.0 topCapHeight:0.0];

        UIImage *image1 = [UIImage imageNamed:@"butn_header_back_p.png"];        
        UIImage *stretchImage1 =         
        [image1 stretchableImageWithLeftCapWidth:15.0 topCapHeight:0.0];
        
        [myBackButton setBackgroundImage: stretchImage forState:UIControlStateNormal];
        [myBackButton setBackgroundImage: stretchImage1 forState:UIControlStateSelected];
        [myBackButton setEnabled:YES];
        if (viewController.view.tag == 1001)
            [myBackButton setTitle:@"  确 定" forState:UIControlStateNormal];
        else [myBackButton setTitle:@"  返 回" forState:UIControlStateNormal];
        [myBackButton.titleLabel setFont: [UIFont boldSystemFontOfSize: 14]];
        myBackButton.titleLabel.textColor = [UIColor whiteColor];
        [myBackButton addTarget:viewController.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
        
        [myBackButton release];
        UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithCustomView:myBackButton];
        viewController.navigationItem.leftBarButtonItem = backButton;
   
        [backButton release];
    }
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
	//set background upload
	//get db directory
	NSArray *StoreFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *DoucumentsDirectiory = [StoreFilePath objectAtIndex:0];
	NSString *uploadQueueDir = [DoucumentsDirectiory stringByAppendingPathComponent:@"uploadQueue.plist"];
	if([[NSFileManager defaultManager] fileExistsAtPath:uploadQueueDir]){
		 bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
			//Stop uploading & do nothing
			[uploadQueue cancelAllOperations];
			[application endBackgroundTask:bgTask];
		}];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
			uploadQueue = [ASINetworkQueue queue];
			[uploadQueue setDelegate:self];
			[uploadQueue setQueueDidFinishSelector:@selector(uploadQueueFinished)];
			NSArray* queue = [[NSArray alloc] initWithContentsOfFile:uploadQueueDir];
			for(NSDictionary* dict in queue){
				NSString* uploadWordListDir = [[[DoucumentsDirectiory stringByAppendingPathComponent:[dict objectForKey:@"dictID"]] stringByAppendingPathComponent:[dict objectForKey:@"phaseIdx"]] stringByAppendingPathComponent:@"uploadUserData.plist"];
				if(![[NSFileManager defaultManager] fileExistsAtPath:uploadWordListDir]){
					continue;
				}
				NSArray* userData = [[NSArray alloc] initWithContentsOfFile:uploadWordListDir];
				NSDictionary *reqDict = [NSDictionary dictionaryWithObjectsAndKeys:
										 userData, @"wordList",
										 [dict objectForKey:@"dictID"], @"dictID",
										 [dict objectForKey:@"userID"], @"userID",
										 [dict objectForKey:@"phaseIdx"], @"phaseIdx",
										 nil];
				NSURL *url = [NSURL URLWithString:@"http://www.langlib.com/webservices/mobile/ws_mobilewordbook.asmx/FeedBackWordInfo"];
				NSString* reqString = [NSString stringWithString:[reqDict JSONRepresentation]];
				__block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
				[request addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"];
				[request addRequestHeader:@"Content-Type" value:@"application/json"];
				[request appendPostData:[reqString dataUsingEncoding:NSUTF8StringEncoding]];
				[request setCompletionBlock:^{
					[[NSFileManager defaultManager] removeItemAtPath:uploadWordListDir error:nil];
				}];
				NSLog(@"%@", request);
				[uploadQueue addOperation:request];
			}
			[uploadQueue go];
		});
	}
}

-(void) uploadQueueFinished{
	NSLog(@"Queue Finished");
	//Remove item in array
	NSArray *StoreFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *DoucumentsDirectiory = [StoreFilePath objectAtIndex:0];
	NSString *uploadQueueDir = [DoucumentsDirectiory stringByAppendingPathComponent:@"uploadQueue.plist"];
	NSMutableArray* queue = [[NSMutableArray alloc] initWithContentsOfFile:uploadQueueDir];
	NSMutableArray* new_queue = [[NSMutableArray alloc] init];
	for(NSDictionary* dict in queue){
		NSString* uploadWordListDir = [[[DoucumentsDirectiory stringByAppendingPathComponent:[dict objectForKey:@"dictID"]] stringByAppendingPathComponent:[dict objectForKey:@"phaseIdx"]] stringByAppendingPathComponent:@"uploadUserData.plist"];
		if([[NSFileManager defaultManager] fileExistsAtPath:uploadWordListDir]){
			[new_queue addObject:dict];
		}
	}
	[new_queue writeToFile:uploadQueueDir atomically:YES];
	[[UIApplication sharedApplication] endBackgroundTask:bgTask];
}

- (void)dealloc
{
    [QuizList release];
    [ProductPriceArr release];
    [createParams release];
    [filteredArr release];
    [CurrUserID release];
    [CurrWordBookID release];
    [ScheduleList release];
    [WordList release];
    [WordBookList release];
    [_loginController release];
    [_window release];

    [super dealloc];
}

-(NSString *)GetDictNameByType:(NSInteger) dictType
{
    switch (dictType) {
        case 0:
            return @"四级";
        case 1:
            return @"六级";
        case 2:
            return @"高考";    
        case 3:
            return @"考研";
        case 4:
            return @"TOEFL";
        case 5:
            return @"GRE";
        case 6:
            return @"IELTS";
        case 7:
            return @"商务英语";
        case 8:
            return @"GMAT";
        case 9:
            return @"SAT";
        case 10:
            return @"新GRE-句子填空";
        case 11:
            return @"新GRE-文章阅读";
        case 12:
            return @"新GRE(综合)";
        case 13:
            return @"四级(2012版)";     
        case 14:
            return @"考研(2013版)";  
        default:
            return @"(请选择)";
    }
}

-(NSString *)GetFamiliarityName:(NSInteger) familiarity
{
    switch (familiarity) {
        case 0:
            return @"形同陌路";
        case 1:
            return @"似曾相识";
        case 2:
            return @"半生不熟";
        case 3:
            return @"一见如故";
        case 4:
            return @"刻骨铭心";            
        default:
            return @"";
    }
}

-(void)showNetworkFailed
{
    UIAlertView *alert = [[UIAlertView alloc]//
                          initWithTitle:@"警告"
                          message:@"因为网络问题无法连接到服务器"
                          delegate:self
                          cancelButtonTitle:@"确定"
                          otherButtonTitles:nil];
    
    [alert show];
    [alert release];
}

-(void)showDownloadSuccess
{
	UIAlertView *alert = [[UIAlertView alloc]//
                          initWithTitle:nil
                          message:@"词库下载成功！"
                          delegate:self
                          cancelButtonTitle:@"好"
                          otherButtonTitles:nil];
    
    [alert show];
    [alert release];
}

-(void)showDownloadInfo
{
	UIAlertView *alert = [[UIAlertView alloc]//
                          initWithTitle:nil
                          message:@"词库下载过程中，请不要离开本页面或退出应用"
                          delegate:self
                          cancelButtonTitle:@"好"
                          otherButtonTitles:nil];
    
    [alert show];
    [alert release];
}

-(void)userLogout
{
	self.isWordFirstAppear = NO;
	LoginController *aLoginController = [[LoginController alloc]
										 initWithNibName:@"LoginController" bundle:nil];
	UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:aLoginController];
	aLoginController.forceLogin = YES;
	[aLoginController release];
	navigationController.delegate = self;
    self.window.rootViewController = navigationController;
    
    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bg_header.png"] forBarMetrics:UIBarMetricsDefault];
    }
    [navigationController release];
}
@end
