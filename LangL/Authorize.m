//
//  Authorize.m
//  LangL
//
//  Created by Zeng Li on 10/31/12.
//
//

#import "Authorize.h"

@interface Authorize(Private)
- (void)dismissModalViewController;
- (void)requestAccessTokenWithAuthorizeCode:(NSString *)code;
@end

@implementation Authorize

@synthesize appKey;
@synthesize appSecret;
@synthesize redirectURI;
@synthesize request;
@synthesize rootViewController;
@synthesize delegate;
@synthesize snsCodeUrl;
@synthesize snsAccessTokenUrl;
@synthesize snsType;
@synthesize webView;

#pragma mark - WBAuthorize Life Circle

- (id)initWithAppKey:(NSString *)theAppKey appSecret:(NSString *)theAppSecret
{
    if ((self = [super init]) != 0 )
    {
        self.appKey = theAppKey;
        self.appSecret = theAppSecret;
    }
    
    return self;
}

- (void)dealloc
{
    [appKey release], appKey = nil;
    [appSecret release], appSecret = nil;
    
    [redirectURI release], redirectURI = nil;
    
    [request setDelegate:nil];
    [request disconnect];
    [request release], request = nil;
    
    rootViewController = nil;
    delegate = nil;
    
	[webView release], webView = nil;
    [super dealloc];
}

#pragma mark - WBAuthorize Private Methods

- (void)dismissModalViewController
{
    [rootViewController dismissModalViewControllerAnimated:YES];
}

//通过获得的code来获得accessToken来获得调用借口权限
- (void)requestAccessTokenWithAuthorizeCode:(NSString *)code
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							appKey, @"client_id",
							appSecret, @"client_secret",
							@"authorization_code", @"grant_type",
							code, @"code",
							redirectURI, @"redirect_uri",
							 nil];
	
    [request disconnect];
	if([[self snsType] isEqualToString:@"sinaweibo"] || [[self snsType] isEqualToString:@"renren"]){
		self.request = [WBRequest requestWithURL:snsAccessTokenUrl
								  httpMethod:@"POST"
									  params:params
								postDataType:kWBRequestPostDataTypeNormal
							httpHeaderFields:nil
									delegate:self];
	}else if([[self snsType] isEqualToString:@"qqweibo"]){
		self.request = [WBRequest requestWithURL:snsAccessTokenUrl
									  httpMethod:@"GET"
										  params:params
									postDataType:kWBRequestPostDataTypeNormal
								httpHeaderFields:nil
										delegate:self];
	}
    [request connect];
}


#pragma mark - WBAuthorize Public Methods

- (void)startAuthorize
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:appKey, @"client_id",
							@"code", @"response_type",
							redirectURI, @"redirect_uri",
							@"mobile", @"display", nil];
	
	if([[self snsType] isEqualToString:@"renren"]){
		[params setObject:@"status_update" forKey:@"scope"];
	}
	
    NSString *urlString = [WBRequest serializeURL:snsCodeUrl
                                           params:params
                                       httpMethod:@"GET"];
    
     webView = [[AuthorizeView alloc] init];
	[webView setDelegate:self];
    [webView loadRequestWithURL:[NSURL URLWithString:urlString]];
	[webView show:YES];
}

#pragma mark - WBAuthorizeWebViewDelegate Methods

- (void)authorizeWebView:(AuthorizeView *)webView didReceiveAuthorizeCode:(NSString *)code
{	
	if([[self snsType] isEqualToString:@"qqweibo"]){
		NSRange end = [code rangeOfString:@"&"];
		NSString* openID = [code copy];
		code = [code substringToIndex:end.location];
		
		NSRange open_id = [openID rangeOfString:@"openid="];
		openID = [openID substringFromIndex:open_id.location];
		NSRange and1 = [openID rangeOfString:@"&"];
		openID = [[openID substringToIndex:and1.location] substringFromIndex:7];
		
		//save to file
		NSArray *StoreFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *DoucumentsDirectiory = [StoreFilePath objectAtIndex:0];
		NSString *filePath = [DoucumentsDirectiory stringByAppendingPathComponent:@"LangLibWordBookConfig.plist"];
		
		NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
		[userInfo setObject:openID forKey:@"qqweibo"];
		[userInfo writeToFile:filePath atomically:YES];
	}
    // if not canceled
    if (![code isEqualToString:@"21330"])
    {
        [self requestAccessTokenWithAuthorizeCode:code];
    }
}

#pragma mark - WBRequestDelegate Methods

- (void)request:(WBRequest *)theRequest didFinishLoadingWithResult:(id)result
{
    BOOL success = NO;
    if ([result isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dict = (NSDictionary *)result;
        
        NSString *token = [dict objectForKey:@"access_token"];
        NSString *userID = [dict objectForKey:@"uid"];
        NSInteger seconds = [[dict objectForKey:@"expires_in"] intValue];
        
		if([[self snsType] isEqualToString:@"sinaweibo"]){
			success = token && userID;
		}else if([[self snsType] isEqualToString:@"renren"]){
			success = token && seconds;
		}
        
		if (success && [delegate respondsToSelector:@selector(authorize:didSucceedWithAccessToken:userID:expiresIn:)])
        {
            [delegate authorize:self didSucceedWithAccessToken:token userID:userID expiresIn:seconds];
        }
    }else if([result isKindOfClass:[NSString class]]){
		//qqweibo
		//process to get accessToken and more
		NSRange begin_token = [result rangeOfString:@"access_token="];
		NSRange begin_expire = [result rangeOfString:@"expires_in="];
		
		if(begin_token.location == NSNotFound || begin_expire.location == NSNotFound){
			NSError *error = [NSError errorWithDomain:kWBSDKErrorDomain
												 code:kWBErrorCodeSDK
											 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d", kWBSDKErrorCodeAuthorizeError]
																				  forKey:kWBSDKErrorCodeKey]];
			[delegate authorize:self didFailWithError:error];
		}
		
		NSRange e1 = [result rangeOfString:@"="];
		
		NSString* accessToken = [[result substringToIndex:begin_expire.location-1] substringFromIndex:(e1.location)+1];
		NSString* expireEx = [result substringFromIndex:begin_expire.location];
		NSRange e2 = [expireEx rangeOfString:@"="];
		NSRange and2 = [expireEx rangeOfString:@"&"];
		
		NSString* expire = [[expireEx substringToIndex:and2.location] substringFromIndex:(e2.location)+1];
		
		if ([delegate respondsToSelector:@selector(authorize:didSucceedWithAccessToken:userID:expiresIn:)])
        {
            [delegate authorize:self didSucceedWithAccessToken:accessToken userID:nil expiresIn:[expire intValue]];
        }
		return;
	}
    
    // should not be possible
    if (!success && [delegate respondsToSelector:@selector(authorize:didFailWithError:)])
    {
        NSError *error = [NSError errorWithDomain:kWBSDKErrorDomain
                                             code:kWBErrorCodeSDK
                                         userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d", kWBSDKErrorCodeAuthorizeError]
                                                                              forKey:kWBSDKErrorCodeKey]];
        [delegate authorize:self didFailWithError:error];
    }
}

- (void)request:(WBRequest *)theReqest didFailWithError:(NSError *)error
{
    if ([delegate respondsToSelector:@selector(authorize:didFailWithError:)])
    {
        [delegate authorize:self didFailWithError:error];
    }
}

@end
