//
//  LangLAppDelegate.m
//  LangL
//
//  Created by king bill on 11-8-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "LangLAppDelegate.h"
#import "LoginController.h"


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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity: 100];
    self.filteredArr = arr;
        
    LoginController *aLoginController = [[LoginController alloc]
                                         initWithNibName:@"LoginController" bundle:nil];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:aLoginController];     
    navigationController.delegate = self;
    aLoginController.forceLogin = YES;
    self.window.rootViewController = navigationController;
    
    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bg_header.png"] forBarMetrics:UIBarMetricsDefault];
    }
    [aLoginController release];    // Override point for customization after application launch.
    [navigationController release];
    [self.window makeKeyAndVisible];  
    self.NeedReloadSchedule = NO;
    self.QuizListID = 0;
    return YES;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
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
    /*
    CGRect frame = CGRectMake(60, 0, 200, 44);
    UILabel* label = [[[UILabel alloc] initWithFrame:frame] autorelease];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:110.0/255.0 green:170.0/255.0 blue:110.0/255.0 alpha:1];
    //The two lines below are the only ones that have changed
    label.text = viewController.title;
    viewController.navigationItem.titleView = label;   
     */
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
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
            return [NSString stringWithString: @"四级"];
        case 1:
            return [NSString stringWithString: @"六级"];          
        case 2:
            return [NSString stringWithString: @"高考"];    
        case 3:
            return [NSString stringWithString: @"考研"];    
        case 4:
            return [NSString stringWithString: @"TOEFL"];
        case 5:
            return [NSString stringWithString: @"GRE"];
        case 6:
            return [NSString stringWithString: @"IELTS"];
        case 7:
            return [NSString stringWithString: @"商务英语"];
        case 8:
            return [NSString stringWithString: @"GMAT"];
        case 9:
            return [NSString stringWithString: @"SAT"];
        case 10:
            return [NSString stringWithString: @"新GRE-句子填空"];
        case 11:
            return [NSString stringWithString: @"新GRE-文章阅读"];
        case 12:
            return [NSString stringWithString: @"新GRE(综合)"];
        case 13:
            return [NSString stringWithString: @"四级(2012版)"];     
        case 14:
            return [NSString stringWithString: @"考研(2013版)"];  
        default:
            return [NSString stringWithString: @"(请选择)"];
    }
}

-(NSString *)GetFamiliarityName:(NSInteger) familiarity
{
    switch (familiarity) {
        case 0:
            return [NSString stringWithString:@"形同陌路"];
        case 1:
            return [NSString stringWithString:@"似曾相识"];
        case 2:
            return [NSString stringWithString:@"半生不熟"];
        case 3:
            return [NSString stringWithString:@"一见如故"];
        case 4:
            return [NSString stringWithString:@"刻骨铭心"];            
        default:
            return [NSString stringWithString:@""];
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

@end
