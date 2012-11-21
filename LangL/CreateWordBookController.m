//
//  CreateWordBookController.m
//  LangL
//
//  Created by king bill on 11-9-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "CreateWordBookController.h"
#import "SBJson.h"
#import "ASIHTTPRequest.h"
#import "LangLAppDelegate.h"
#import "ConfigDateParamController.h"
#import "CreateWordBookParams.h"
#import "ConfigSortParamController.h"
#import "ConfigTestTypeParamController.h"
#import "ConfigTaskParamController.h"
#import "CommonButton.h"
#import "NavigationButton.h"

@implementation CreateWordBookController

@synthesize createParaView;
@synthesize loadingAlert;
@synthesize dateFormatter;

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
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];   
    CreateWordBookParams *params = [[CreateWordBookParams alloc] init];
    mainDelegate.createParams = params;
    [params release];
    
    createParaView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 230) style:UITableViewStylePlain];
    
    createParaView.delegate = self;
    createParaView.dataSource = self;
    [self.view addSubview:self.createParaView];      
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    self.dateFormatter = formatter;
    [formatter release];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];    
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat : @"yyyy-MM-dd"]; 
    self.title = @"创建词汇书";
    createParaView.separatorColor = [UIColor clearColor];
    createParaView.backgroundColor = [UIColor clearColor];
    createParaView.opaque = NO;
    createParaView.backgroundView = nil;     
    /*
    CommonButton *btnCreate = [[CommonButton alloc] init];    
    [btnCreate setTitle:@"创建词汇书" forState:UIControlStateNormal];    
    [btnCreate addTarget:self action:@selector(btnCreateWbTouched)
       forControlEvents:UIControlEventTouchUpInside];
    btnCreate.frame = CGRectMake(200, 230, 100, 40);
    [self.view addSubview:btnCreate];
    [btnCreate release];
    */
    
    NavigationButton *btnCreate = [[NavigationButton alloc] init];    
    [btnCreate setTitle:@"创 建" forState:UIControlStateNormal]; 
    
    [btnCreate addTarget:self action:@selector(btnCreateWbTouched) forControlEvents:UIControlEventTouchUpInside];     
    //定制自己的风格的  UIBarButtonItem
    UIBarButtonItem* createButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnCreate]; 
    [self.navigationItem  setRightBarButtonItem:createButtonItem]; 
    [createButtonItem release]; 
    [btnCreate release]; 

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.toolbarHidden = YES; 
    [createParaView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [dateFormatter release];
    [loadingAlert release];
    [createParaView release];
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
    return 52;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    UIImageView *splitter = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_item.png"]];
    [splitter setFrame: CGRectMake(0, 50, 320, 2)];
    [cell.contentView addSubview: splitter];
    [splitter release];
    
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1];
    cell.textLabel.textColor = [UIColor whiteColor];
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"词汇书类型";
            cell.detailTextLabel.text = [mainDelegate GetDictNameByType: mainDelegate.createParams.testType];
            break;
        case 1:
            cell.textLabel.text = @"开始日期";
            cell.detailTextLabel.text = [dateFormatter stringFromDate:mainDelegate.createParams.beginDate];
            break;
        case 2:
            cell.textLabel.text = @"排序方式";
            switch (mainDelegate.createParams.sortType) {
                case 0:
                    cell.detailTextLabel.text = @"字母正序";
                    break;
                case 1:
                    cell.detailTextLabel.text = @"字母逆序";
                    break;    
                case 2:
                    cell.detailTextLabel.text = @"考试频率";
                    break;
                case 3:
                    cell.detailTextLabel.text = @"随机";
                    break;
                default:
                    break;
            }
            break;
        case 3:
            cell.textLabel.text = @"每日任务量";
            switch (mainDelegate.createParams.listCountPerDay) {
                case 2:
                    cell.detailTextLabel.text = @"较少(200单词)";
                    break;
                case 3:
                    cell.detailTextLabel.text = @"中等(300单词)";
                    break;
                case 4:
                    cell.detailTextLabel.text = @"较多(400单词)";
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    switch (indexPath.row) {
        case 0:  
        {
            ConfigTestTypeParamController *configController = [[ConfigTestTypeParamController alloc] initWithNibName:@"ConfigTestTypeParamController" bundle:nil];   
            [self.navigationController pushViewController:configController animated:YES];
            [configController release];  
            break;
        }
        case 1:
        {
            ConfigDateParamController *configController = [[ConfigDateParamController alloc] initWithNibName:@"ConfigDateParamController" bundle:nil];   
            [self.navigationController pushViewController:configController animated:YES];
            [configController release];  
            break;     
        }
        case 2:  
        {
            ConfigSortParamController *configController = [[ConfigSortParamController alloc] initWithNibName:@"ConfigSortParamController" bundle:nil];   
            [self.navigationController pushViewController:configController animated:YES];
            [configController release];  
            break;
        }
        case 3:  
        {
            ConfigTaskParamController *configController = [[ConfigTaskParamController alloc] initWithNibName:@"ConfigTaskParamController" bundle:nil];   
            [self.navigationController pushViewController:configController animated:YES];
            [configController release];  
            break;
        }
        default:
            break;
    }
}


- (void)btnCreateWbTouched {

    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
    if (mainDelegate.createParams.testType < 0)
    {
        UIAlertView *alert = [[UIAlertView alloc]//
                              initWithTitle:@"提示"
                              message:@"请先选择一种词汇书类型"
                              delegate:self
                              cancelButtonTitle:@"确定"
                              otherButtonTitles:nil];
        
        [alert show];
        [alert release]; 
        return;
    }
    [self showLoadingAlert];
	
	
	NSArray *StoreFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *DoucumentsDirectiory = [StoreFilePath objectAtIndex:0];
    NSString *filePath = [DoucumentsDirectiory stringByAppendingPathComponent:@"LangLibWordBookConfig.plist"];
	
	NSDictionary* userInfo = [[NSDictionary alloc] initWithContentsOfFile:filePath];
	
	NSString* email = [userInfo objectForKey:@"UserMail"];
	NSString* password = [userInfo objectForKey:@"UserPwd"];
    
	//login first
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
    [request setCompletionBlock:^{
		//upload Token
		NSString *responseString = [request responseString];
		NSDictionary* responseDict = [responseString JSONValue];
		NSString* responseText = (NSString *) [responseDict objectForKey:@"d"];
		NSString* responseTag = [responseText substringWithRange:NSMakeRange(0,4)];
		
		if(![responseTag isEqualToString:@"SUCC"]){
			[self hideLoadingAlert];
			LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];
			[mainDelegate showNetworkFailed];
			return;
		}
		
		NSDictionary *reqDict = [NSDictionary dictionaryWithObjectsAndKeys:
								 [NSString stringWithFormat:@"%d", mainDelegate.createParams.testType], @"testType",
								 [NSString stringWithFormat:@"%d", mainDelegate.createParams.sortType], @"sortType",
								 [NSString stringWithFormat:@"%d", mainDelegate.createParams.listCountPerDay], @"listCountDaily",
								 [dateFormatter stringFromDate: mainDelegate.createParams.beginDate], @"beginDate",
								 nil];
		
		
		NSString* reqString = [NSString stringWithString:[reqDict JSONRepresentation]];
		NSURL *url = [NSURL URLWithString:@"http://www.langlib.com/webservices/mobile/ws_mobilewordbook.asmx/CreateWordBook"];
		
		__block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
		[request addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"];
		[request addRequestHeader:@"Content-Type" value:@"application/json"];
		[request appendPostData:[reqString dataUsingEncoding:NSUTF8StringEncoding]];
		[request setCompletionBlock:^{
			NSString *responseString = [request responseString];
			NSDictionary* responseDict = [responseString JSONValue];
			[self hideLoadingAlert];
			
			NSString *responseText = [responseDict objectForKey:@"d"];
			NSString* responseTag = [responseText substringWithRange:NSMakeRange(0,4)];
						
			if ([responseTag compare:@"SUCC"] == NSOrderedSame)
			{
				[mainDelegate.WordBookList addObject: [NSDictionary dictionaryWithObjectsAndKeys:
													   [NSString stringWithFormat:@"%d", mainDelegate.createParams.testType], @"DictType",
													   @"0", @"IsPaid",
													   @"1", @"SubCount",
													   [responseText substringFromIndex: 5], @"WordBookID",
													   nil]
				 ];
				//Pop alert view for share
//				SocialAlert* alertDelegate = [[SocialAlert alloc] init];
//				UIAlertView* alert = [[UIAlertView alloc]
//									  initWithTitle:@"提示" message:@"恭喜您成功创建一本词汇书，将这个消息告诉朋友？" delegate:alertDelegate cancelButtonTitle:@"取消" otherButtonTitles:@"好的", nil];
//				[alert show];
//				[alert release];
				
				[self.navigationController popViewControllerAnimated:YES];
			}
			else
			{
				UIAlertView *alert = [[UIAlertView alloc]//
									  initWithTitle:@"提示"
									  message: responseText
									  delegate:self
									  cancelButtonTitle:@"确定"
									  otherButtonTitles:nil];
				
				[alert show];
				[alert release];
			}
		}];
		[request setFailedBlock:^{
			[self hideLoadingAlert];
			LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];
			[mainDelegate showNetworkFailed];
		}];
		[request startAsynchronous];		
	}];
	[request startAsynchronous];
}

- (IBAction)btnCancelTouched:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)showLoadingAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"处理中,请稍候..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    [alert show];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.center = CGPointMake(alert.bounds.size.width / 2, alert.bounds.size.height - 50);
    [indicator startAnimating];
    [alert addSubview:indicator];
    [indicator release];     
    self.loadingAlert = alert;
    [alert release];
}

-(void)hideLoadingAlert
{
    [loadingAlert dismissWithClickedButtonIndex:0 animated:YES];
}

@end
