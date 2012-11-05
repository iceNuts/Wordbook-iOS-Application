//
//  SocialAuthorize.m
//  LangL
//
//  Created by Zeng Li on 10/30/12.
//
//

#import "SocialAuthorize.h"

@implementation SocialAuthorize
- (void)authorize:(Authorize *)authorize didSucceedWithAccessToken:(NSString *)accessToken userID:(NSString *)userID expiresIn:(NSInteger)seconds{
		
	[[authorize webView] hide:YES];

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
			return;
		}
		
		NSDate* expire = [[NSDate date] dateByAddingTimeInterval:seconds];
		
		NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
		NSString *dateString = [dateFormatter stringFromDate:expire];
		[dateFormatter release];
		
		NSDictionary *reqDict = [NSDictionary dictionaryWithObjectsAndKeys:
								 dateString,@"expDate", accessToken,@"tokenKey",
								 [authorize snsType],@"tokenType",
								 nil];
		
		NSLog(@"%@", reqDict);
		
		//RPC JSON
		NSString* reqString = [NSString stringWithString:[reqDict JSONRepresentation]];
		NSURL *url = [NSURL URLWithString:@"http://www.langlib.com/webservices/mobile/ws_mobileutils.asmx/UpdateTokenKey"];
		__block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
		[request addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"];
		[request addRequestHeader:@"Content-Type" value:@"application/json"];
		[request appendPostData:[reqString dataUsingEncoding:NSUTF8StringEncoding]];
		[request setRequestMethod:@"POST"];
		[request startAsynchronous];

	}];
    [request startAsynchronous];
}

- (void)authorize:(Authorize *)authorize didFailWithError:(NSError *)error{
	[[authorize webView] hide:YES];
	LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];
	[mainDelegate showNetworkFailed];
}
@end

