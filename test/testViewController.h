//
//  testViewController.h
//  LangL
//
//  Created by Zeng Li on 11/1/12.
//
//

#import <UIKit/UIKit.h>
#import "Authorize.h"
#import "SocialAuthorize.h"
#import "WBRequest.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <CommonCrypto/CommonDigest.h>

@interface testViewController : UIViewController<WBRequestDelegate>{

	IBOutlet UIButton* qqBtn;
	IBOutlet UIButton* weiboBtn;
	IBOutlet UIButton* renrenBtn;
	
	IBOutlet UIButton* sendBtn;
	
	IBOutlet UIButton *cancelBtn;
	
	UIWindow *wd;
}

-(void) weiboLogin;
-(void) qqLogin;
-(void) renrenLogin;

-(void) send;

-(void) cancel;

- (NSString *)getIPAddress;

-(void) show:(BOOL) animated;

@end
