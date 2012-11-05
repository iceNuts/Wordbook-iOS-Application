//
//  Authorize.h
//  LangL
//
//  Created by Zeng Li on 10/31/12.
//
//

#import <Foundation/Foundation.h>
#import "AuthorizeWebViewDelegate.h"
#import "AuthorizeView.h"
#import "WBRequest.h"
#import "AuthorizeDelegate.h"
#import "WBSDKGlobal.h"

@interface Authorize : NSObject<AuthorizeWebViewDelegate, WBRequestDelegate>{
	NSString    *appKey;
    NSString    *appSecret;
    
    NSString    *redirectURI;
    
    WBRequest   *request;
    
    UIViewController *rootViewController;
	
	id<AuthorizeDelegate> delegate;

}

@property (nonatomic, retain) NSString *appKey;
@property (nonatomic, retain) NSString *appSecret;
@property (nonatomic, retain) NSString *redirectURI;
@property (nonatomic, retain) WBRequest *request;
@property (nonatomic, assign) UIViewController *rootViewController;
@property (nonatomic, assign) id<AuthorizeDelegate> delegate;
@property (nonatomic, retain) NSString* snsCodeUrl;
@property (nonatomic, retain) NSString* snsAccessTokenUrl;
@property (nonatomic, retain) NSString* snsType;
@property (nonatomic, retain) AuthorizeView* webView;

- (id)initWithAppKey:(NSString *)theAppKey appSecret:(NSString *)theAppSecret;

- (void)startAuthorize;


@end
