//
//  AuthorizeWebViewDelegate.h
//  LangL
//
//  Created by Zeng Li on 10/31/12.
//
//

#import <Foundation/Foundation.h>

@class AuthorizeView;

@protocol AuthorizeWebViewDelegate <NSObject>
- (void)authorizeWebView:(AuthorizeView *)webView didReceiveAuthorizeCode:(NSString *)code;
@end
