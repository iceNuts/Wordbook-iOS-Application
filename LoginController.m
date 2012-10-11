//
//  LoginController.m
//  LangL
//
//  Created by king bill on 11-8-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "LoginController.h"
#import "SBJson.h"
#import "ASIHTTPRequest.h"
#import "WBListController.h"
#import "LangLAppDelegate.h"
#import "RegisterController.h"
#import "CommonButton.h"
#import "NavigateToNextButton.h"
#import "NavigateToPrevButton.h"
#import "AboutController.h"
#import "HintButton.h"

@interface LoginController () 

@end

@implementation UINavigationBar (CustomImage)

+ (void) setupIos5PlusNavBarImage
{
    if ([UINavigationBar respondsToSelector: @selector(appearance)])
    {
        [[UINavigationBar appearance] setBackgroundImage: [UIImage imageNamed: @"bg_header.png"] forBarMetrics: UIBarMetricsDefault];
    }
}

- (void) drawRect: (CGRect) rect
{
    UIImage* img = [UIImage imageNamed: @"bg_header.png"];
    [img drawInRect: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}
@end

@implementation LoginController

@synthesize loadingHint;
@synthesize textField;
@synthesize btnLogin;
@synthesize userpwd;
@synthesize forceLogin;

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
    
    userpwd.secureTextEntry = true;  
    //background
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg_main_green.png"]];
    self.view.backgroundColor = background;
    [background release];
 
    //btnlogin
    btnLogin = [[CommonButton alloc] init];    
    [btnLogin setTitle:@"登  录" forState:UIControlStateNormal];
    
    [btnLogin addTarget:self action:@selector(btnLoginTouched)
             forControlEvents:UIControlEventTouchUpInside];
    btnLogin.frame = CGRectMake(200, 120, 100, 40);
    [self.view addSubview:btnLogin];
    [btnLogin release];
       
    HintButton *btnAbout = [[HintButton alloc] init];    
    [btnAbout setTitle:@"" forState:UIControlStateNormal]; 
    
    [btnAbout addTarget:self action:@selector(showAbout) forControlEvents:UIControlEventTouchUpInside];     
    //定制自己的风格的  UIBarButtonItem
    UIBarButtonItem* showAboutButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnAbout]; 
    [self.navigationItem  setLeftBarButtonItem:showAboutButtonItem]; 
    [showAboutButtonItem release]; 
    [btnAbout release]; 
    
    
    
    NavigateToNextButton *btnRegister = [[NavigateToNextButton alloc] init];    
    [btnRegister setTitle:@"  注 册" forState:UIControlStateNormal]; 
    
    [btnRegister addTarget:self action:@selector(btnRegisterTouched) forControlEvents:UIControlEventTouchUpInside];     
    //定制自己的风格的  UIBarButtonItem
    UIBarButtonItem* registerButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnRegister]; 
    [self.navigationItem  setRightBarButtonItem:registerButtonItem]; 
    [registerButtonItem release]; 
    [btnRegister release]; 
    
    //header button
        
    self.navigationController.toolbarHidden = YES;
    self.title = @"朗播网词汇书";
   
    
    NSArray *StoreFilePath            =    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *DoucumentsDirectiory =    [StoreFilePath objectAtIndex:0];
    NSString *filePath                =    [DoucumentsDirectiory stringByAppendingPathComponent:@"LangLibWordBookConfig.plist"];
    
    NSMutableDictionary* plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    NSString *savedMail = [plistDict objectForKey:@"UserMail"];
    NSString *savedPwd = [plistDict objectForKey:@"UserPwd"];
    if ([savedMail compare:@""] != NSOrderedSame)
    {
        textField.text = savedMail;
        userpwd.text = savedPwd;             
    }
    [plistDict release];
    [self loadSettings];
}

-(void)loadSettings
{
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];
    NSArray *StoreFilePath            =    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *DoucumentsDirectiory =    [StoreFilePath objectAtIndex:0];
    NSString *filePath                =    [DoucumentsDirectiory stringByAppendingPathComponent:@"LangLibWbSetting.plist"];
    
    NSMutableDictionary* settingDict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    
    if (settingDict.count == 0)
    {
        
        NSMutableDictionary* newValueDict = [[NSMutableDictionary alloc] initWithCapacity:3];
        
        [newValueDict setObject:[NSNumber numberWithBool: NO] forKey:@"AutoVoice"];
        [newValueDict setObject:[NSNumber numberWithBool: NO] forKey:@"AutoNextWord"];
        [newValueDict setObject:[NSNumber numberWithBool: YES] forKey:@"AutoFamiliarity"];
        [newValueDict writeToFile:filePath atomically: YES];     
        [newValueDict release];    
        
        mainDelegate.AutoVoice = NO;
        mainDelegate.AutoNextWord = NO;
        mainDelegate.AutoFamiliarity = YES;
    }
    else {
        mainDelegate.AutoVoice = [[settingDict objectForKey:@"AutoVoice"] boolValue];
        mainDelegate.AutoNextWord = [[settingDict objectForKey:@"AutoNextWord"] boolValue];
        mainDelegate.AutoFamiliarity = [[settingDict objectForKey:@"AutoFamiliarity"] boolValue];
    }
    
    [settingDict release];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	//If login view appears, user must login
	NSArray *StoreFilePath            =    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *DoucumentsDirectiory =    [StoreFilePath objectAtIndex:0];
	NSString *filePath                =    [DoucumentsDirectiory stringByAppendingPathComponent:@"LangLibWordBookConfig.plist"];
	
	NSMutableDictionary* plistDict = [[NSMutableDictionary alloc] initWithCapacity:3];

	[plistDict setObject:@"0" forKey:@"UserID"];
	[plistDict writeToFile:filePath atomically: YES];
	[plistDict release];
	self.forceLogin = NO;
}

- (void)viewDidUnload
{
    [self setTextField:nil];
    [self setUserpwd:nil];
    [self setLoadingHint:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if ((theTextField == self.textField)  || (theTextField == self.userpwd)){
        [theTextField resignFirstResponder];
    }
    return YES;
}

- (void)aboutController:(AboutController *)aboutController {
    [self dismissModalViewControllerAnimated:NO];
}


- (void)showAbout {
    

        AboutController *aboutController = [[AboutController alloc]
                                            initWithNibName:@"AboutController" bundle:nil];
        
        aboutController.delegate = self;    
        // Create the navigation controller and present it modally.
        [self presentModalViewController:aboutController animated: NO];
        [aboutController release];    
        
   
}

- (void)tryWordBook  {
    [self DoLogin: @"tiyan@langlib.com" UserPwd: @"888888"];    
}


- (void)btnLoginTouched {
    
    [textField resignFirstResponder];
	[userpwd resignFirstResponder];

    if ((textField.text == @"") || (userpwd.text == @"")) {
        UIAlertView *alert = [[UIAlertView alloc]//
                              initWithTitle:@"警告"
                              message:@"请输入邮箱及密码后再登录"
                              delegate:self
                              cancelButtonTitle:@"确定"
                              otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }
    
    btnLogin.enabled = NO;
	[loadingHint startAnimating];

    [self DoLogin: textField.text UserPwd:userpwd.text];
}

- (void)DoLogin:(NSString *)email UserPwd:(NSString *)password {
    NSDictionary *reqDict = [NSDictionary dictionaryWithObjectsAndKeys:
                             email, @"userMail",
                             password, @"userPwd",
                             @"iPhone", @"clientTag",
                             nil];
	//RPC JSON
	NSString* reqString = [NSString stringWithString:[reqDict JSONRepresentation]];    
    NSURL *url = [NSURL URLWithString:@"http://www.langlib.com/webservices/mobile/ws_mobileutils.asmx/UserLoginByWordBook"];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"]; 
    [request addRequestHeader:@"Content-Type" value:@"application/json"];    
    [request appendPostData:[reqString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    [request startAsynchronous];
    
}

- (void)btnRegisterTouched {
    RegisterController *regController=[[RegisterController alloc] initWithNibName:@"RegisterController" bundle:nil];
    [self.navigationController pushViewController:regController animated:YES];
    
    [regController release];

}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    
    // Use when fetching text data
    NSString *responseString = [request responseString];
    NSDictionary* responseDict = [responseString JSONValue];
    NSString* responseText = (NSString *) [responseDict objectForKey:@"d"];
    NSString* responseTag = [responseText substringWithRange:NSMakeRange(0,4)];

    if(![responseTag isEqualToString:@"SUCC"]){
        UIAlertView *alert = [[UIAlertView alloc]//
                          initWithTitle:@"警告"
                          message:@"你输入的邮箱或密码不正确"
                          delegate:self
                          cancelButtonTitle:@"确定"
                          otherButtonTitles:nil];
    
        [alert show];
        [alert release];
        btnLogin.enabled = YES;
        [loadingHint stopAnimating];
    }
    else {
        LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];
        mainDelegate.CurrUserID = [responseText substringWithRange:NSMakeRange(5,9)];
        mainDelegate.isWordFirstAppear = NO;
        NSDictionary *reqDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 mainDelegate.CurrUserID, @"userID",
                                 nil];
        
		NSArray *StoreFilePath            =    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *DoucumentsDirectiory =    [StoreFilePath objectAtIndex:0];
		NSString *filePath                =    [DoucumentsDirectiory stringByAppendingPathComponent:@"LangLibWordBookConfig.plist"];
		
		NSMutableDictionary* plistDict = [[NSMutableDictionary alloc] initWithCapacity:3];
				
		[plistDict setObject:textField.text forKey:@"UserMail"];
		[plistDict setObject:userpwd.text forKey:@"UserPwd"];
		[plistDict setObject:mainDelegate.CurrUserID forKey:@"UserID"];
		[plistDict setObject: [NSNumber numberWithInteger:1] forKey:@"AboutShown"];
		[plistDict writeToFile:filePath atomically: YES];
		[plistDict release];
		
        //RPC JSON
        NSString* reqString = [NSString stringWithString:[reqDict JSONRepresentation]];    
        NSURL *url = [NSURL URLWithString:@"http://www.langlib.com/webservices/mobile/ws_mobilewordbook.asmx/ListWordBook"];
        __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [request addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"]; 
        [request addRequestHeader:@"Content-Type" value:@"application/json"];    
        [request appendPostData:[reqString dataUsingEncoding:NSUTF8StringEncoding]];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary* responseDict = [responseString JSONValue];            
            mainDelegate.WordBookList = (NSMutableArray *) [responseDict objectForKey:@"d"];   
             
            NSURL *url1 = [NSURL URLWithString:@"http://www.langlib.com/webservices/mobile/ws_mobileutils.asmx/ListWordbookProduct"];
            __block ASIHTTPRequest *request1 = [ASIHTTPRequest requestWithURL:url1];
            [request1 addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"]; 
            [request1 addRequestHeader:@"Content-Type" value:@"application/json"]; 
            [request1 setRequestMethod:@"POST"];
            [request1 setCompletionBlock:^{
                NSString *responseString1 = [request1 responseString];                
                NSDictionary* responseDict1 = [responseString1 JSONValue];
                [loadingHint stopAnimating];
                mainDelegate.ProductPriceArr = (NSArray *) [responseDict1 objectForKey:@"d"];
                btnLogin.enabled = YES;       
                
				//Write basic word book data into plist
				
				NSArray *StoreFilePath            =    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
				NSString *DoucumentsDirectiory =    [StoreFilePath objectAtIndex:0];
				NSString *filePath                =    [DoucumentsDirectiory stringByAppendingPathComponent:@"LangLibWordBookSimpleInfo.plist"]; //plist for simple word book data
				
				[mainDelegate.WordBookList writeToFile:filePath atomically: YES];
	
				//Save price data
				filePath = [DoucumentsDirectiory stringByAppendingPathComponent:@"LangLibWordBookPriceInfo.plist"];
				
				[[[NSMutableArray alloc] initWithArray:mainDelegate.ProductPriceArr] writeToFile:filePath atomically:YES];
				
                WBListController *wbController=[[WBListController alloc] initWithNibName:@"WBListController" bundle:nil];
                [self.navigationController pushViewController:wbController animated:YES];
                [wbController release];
            }];
            [request1 setFailedBlock:^{            
                LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
                [mainDelegate showNetworkFailed];
            }];
			
            [request1 startAsynchronous];
      
        }];
        [request setFailedBlock:^{            
            LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
            [mainDelegate showNetworkFailed];
        }];
        [request startAsynchronous];        
    }
}



- (void)requestFailed:(ASIHTTPRequest *)request
{    
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
    [mainDelegate showNetworkFailed];
 
    [loadingHint stopAnimating];
    btnLogin.enabled = YES;
}

#pragma mark NSURLConnectionDelegate methods


- (void)dealloc {
    [textField release];
    [userpwd release];
    [btnLogin release];
    [loadingHint release];
    [super dealloc];
}
@end 
