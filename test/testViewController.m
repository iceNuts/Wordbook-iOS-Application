//
//  testViewController.m
//  LangL
//
//  Created by Zeng Li on 11/1/12.
//
//

#import "testViewController.h"

@implementation testViewController

-(void) show:(BOOL) animated{
	wd = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	wd.screen = [UIScreen mainScreen];
	[wd setWindowLevel: UIWindowLevelAlert];
	
	id root = [[UIViewController alloc] init];
	
	[wd setRootViewController:root];
	
	[wd makeKeyAndVisible];
	
	[[wd rootViewController] presentModalViewController:self animated:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	[qqBtn addTarget:self action:@selector(qqLogin) forControlEvents:UIControlEventTouchUpInside];
	[weiboBtn addTarget:self action:@selector(weiboLogin) forControlEvents:UIControlEventTouchUpInside];
	[renrenBtn addTarget:self action:@selector(renrenLogin) forControlEvents:UIControlEventTouchUpInside];
	[sendBtn addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];
	[cancelBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
}

-(void) weiboLogin{
	Authorize* authorize = [[Authorize alloc] initWithAppKey:@"2617691066" appSecret:@"13c005d109297a1e189af46d3aaa1d15"];
	[authorize setSnsCodeUrl:@"https://api.weibo.com/oauth2/authorize"];
	[authorize setSnsAccessTokenUrl:@"https://api.weibo.com/oauth2/access_token"];
	[authorize setRedirectURI:@"http://"];
	[authorize setSnsType:@"sinaweibo"];
	SocialAuthorize* authorizeResult = [[SocialAuthorize alloc] init];
	[authorize setDelegate: authorizeResult];
	[authorize startAuthorize];
}

-(void)qqLogin{
	Authorize* authorize = [[Authorize alloc] initWithAppKey:@"801262651" appSecret:@"5e0ee8107aed3b226082123f442b1d30"];
	[authorize setSnsCodeUrl:@"https://open.t.qq.com/cgi-bin/oauth2/authorize"];
	[authorize setSnsAccessTokenUrl:@"https://open.t.qq.com/cgi-bin/oauth2/access_token"];
	[authorize setRedirectURI:@"http://www.langlib.com"];
	[authorize setSnsType:@"qqweibo"];
	SocialAuthorize* authorizeResult = [[SocialAuthorize alloc] init];
	[authorize setDelegate: authorizeResult];
	[authorize startAuthorize];
}

-(void)renrenLogin{
	Authorize* authorize = [[Authorize alloc] initWithAppKey:@"c274ddb5ab1e42d7952ff986dd13058b" appSecret:@"33cbd354f09d47f4a7c44e2f081a6b50"];
	[authorize setSnsCodeUrl:@"https://graph.renren.com/oauth/authorize"];
	[authorize setSnsAccessTokenUrl:@"https://graph.renren.com/oauth/token"];
	[authorize setRedirectURI:@"http://www.langlib.com"];
	[authorize setSnsType:@"renren"];
	SocialAuthorize* authorizeResult = [[SocialAuthorize alloc] init];
	[authorize setDelegate: authorizeResult];
	[authorize startAuthorize];
}

-(void) send{
	
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
			NSLog(@"Login Failed");
			return;
		}
		NSURL *url = [NSURL URLWithString:@"http://www.langlib.com/webservices/mobile/ws_mobileutils.asmx/ListSNSTokenKey"];
		__block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
		[request addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"];
		[request addRequestHeader:@"Content-Type" value:@"application/json"];
		[request setRequestMethod:@"POST"];
		[request setCompletionBlock:^{
			//process json
			NSDictionary* responseDict1 = [[request responseString] JSONValue];
			NSArray* tokens = (NSArray *) [responseDict1 objectForKey:@"d"];
			NSString* accessToken;
			for(NSString* tokenString in tokens){
				
				NSRange qq = [tokenString rangeOfString:@"qqweibo"];
				NSRange renren = [tokenString rangeOfString:@"renren"];
				NSRange sina = [tokenString rangeOfString:@"sinaweibo"];
				if(qq.location != NSNotFound){
										
					NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
					[params setObject:@"Halo" forKey:@"content"];
					[params setObject:@"json" forKey:@"format"];
					[params setObject:[self getIPAddress] forKey:@"clientip"];
					[params setObject:@"2.a" forKey:@"oauth_version"];
					[params setObject:@"801262651" forKey:@"oauth_consumer_key"];
					[params setObject:@"all" forKey:@"scope"];
					
					//read openid from file
					NSArray *StoreFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
					NSString *DoucumentsDirectiory = [StoreFilePath objectAtIndex:0];
					NSString *filePath = [DoucumentsDirectiory stringByAppendingPathComponent:@"LangLibWordBookConfig.plist"];
					
					NSDictionary* userInfo = [[NSDictionary alloc] initWithContentsOfFile:filePath];
					
					[params setObject:[userInfo objectForKey:@"qqweibo"] forKey:@"openid"];
					
					accessToken = [tokenString substringFromIndex:8];
					
					WBRequest* wbRequest = [WBRequest requestWithAccessToken:accessToken
															  url:@"https://open.t.qq.com/api/t/add"
													   httpMethod:@"POST"
														   params:params
													 postDataType:kWBRequestPostDataTypeNormal
												 httpHeaderFields:nil
														 delegate:self];
					
					[wbRequest connect];
					
				}else if(renren.location != NSNotFound){
					
					accessToken = [tokenString substringFromIndex:7];
					
					NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
					[params setObject:@"人人API做的太差了" forKey:@"status"];
					[params setObject:@"json" forKey:@"format"];
					[params setObject:@"status.set" forKey:@"method"];
					[params setObject:@"1.0" forKey:@"v"];
					
					NSString* sig;
					
					//Calculate sig
					NSString* tmp = [NSString stringWithFormat:@"access_token=%@format=jsonmethod=status.setstatus=%@v=1.033cbd354f09d47f4a7c44e2f081a6b50",accessToken,@"人人API做的太差了"];
					const char* preSig = [tmp UTF8String];
					
					unsigned char result[16];
					
					CC_MD5(preSig, strlen(preSig), result);
					
					sig = [NSString stringWithFormat:
					 @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
					 result[0], result[1], result[2], result[3],
					 result[4], result[5], result[6], result[7],
					 result[8], result[9], result[10], result[11],
					 result[12], result[13], result[14], result[15]
					 ];
					
					[params setObject:sig forKey:@"sig"];

					WBRequest* wbRequest = [WBRequest requestWithAccessToken:accessToken
																		 url:@"http://api.renren.com/restserver.do"
																  httpMethod:@"POST"
																	  params:params
																postDataType:kWBRequestPostDataTypeNormal
															httpHeaderFields:nil
																	delegate:self];
					
					[wbRequest connect];
					
					
				}else if(sina.location != NSNotFound){
					NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
					[params setObject:@"Halo" forKey:@"status"];
					accessToken = [tokenString substringFromIndex:10];
					WBRequest* wbRequest = [WBRequest requestWithAccessToken:accessToken
																 url:@"https://api.weibo.com/2/statuses/update.json"
														  httpMethod:@"POST"
															  params:params
														postDataType:kWBRequestPostDataTypeNormal
													httpHeaderFields:nil
															delegate:self];
					
					[wbRequest connect];
				}
			}
		}];
		[request startAsynchronous];
	}];
	[request startAsynchronous];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)cancel{
	[self dismissModalViewControllerAnimated:YES];
	[self release];
	[wd release];
}

#pragma mark - WBRequestDelegate Methods

- (void)request:(WBRequest *)request didFinishLoadingWithResult:(id)result
{
	NSRange renren = [request.url rangeOfString:@"renren"];
	NSRange qq = [request.url rangeOfString:@"qq"];
	NSRange weibo = [request.url rangeOfString:@"update.json"];
	
	if(renren.location != NSNotFound){
		[renrenBtn setTitle:@"RenRen!" forState:UIControlStateNormal];
	}else if(qq.location != NSNotFound){
		[qqBtn setTitle:@"QQ!" forState:UIControlStateNormal];
	}else if(weibo.location != NSNotFound){
		[weiboBtn setTitle:@"Weibo!" forState:UIControlStateNormal];
	}
}

- (void)request:(WBRequest *)request didFailWithError:(NSError *)error
{
	NSRange renren = [request.url rangeOfString:@"renren"];
	NSRange qq = [request.url rangeOfString:@"qq"];
	NSRange weibo = [request.url rangeOfString:@"update.json"];
	
	if(renren.location != NSNotFound){
		[renrenBtn setTitle:@"RenRen?" forState:UIControlStateNormal];
	}else if(qq.location != NSNotFound){
		[qqBtn setTitle:@"QQ?" forState:UIControlStateNormal];
	}else if(weibo.location != NSNotFound){
		[weiboBtn setTitle:@"Weibo?" forState:UIControlStateNormal];
	}
	NSLog(@"%@", error);
}

- (NSString *)getIPAddress {
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    NSString *wifiAddress = nil;
    NSString *cellAddress = nil;
	
    // retrieve the current interfaces - returns 0 on success
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            sa_family_t sa_type = temp_addr->ifa_addr->sa_family;
            if(sa_type == AF_INET || sa_type == AF_INET6) {
                NSString *name = [NSString stringWithUTF8String:temp_addr->ifa_name];
                NSString *addr = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]; // pdp_ip0
				
                if([name isEqualToString:@"en0"]) {
                    // Interface is the wifi connection on the iPhone
                    wifiAddress = addr;
                } else
					if([name isEqualToString:@"pdp_ip0"]) {
						// Interface is the cell connection on the iPhone
						cellAddress = addr;
					}
            }
            temp_addr = temp_addr->ifa_next;
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    NSString *addr = wifiAddress ? wifiAddress : cellAddress;
    return addr ? addr : @"0.0.0.0";
}
- (void)dealloc {
	[cancelBtn release];
	[super dealloc];
}
- (void)viewDidUnload {
	[cancelBtn release];
	cancelBtn = nil;
	[super viewDidUnload];
}
@end
