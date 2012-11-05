//
//  AuthorizeView.h
//  LangL
//
//  Created by Zeng Li on 10/30/12.
//
//

#import <UIKit/UIKit.h>
#import "AuthorizeWebViewDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "LangLAppDelegate.h"

@interface AuthorizeView : UIView<UIWebViewDelegate>{
	UIView *panelView;
    UIView *containerView;
    UIActivityIndicatorView *indicatorView;
	UIWebView *webView;
	UIButton* cancelBtn;
	id<AuthorizeWebViewDelegate> delegate;
}

@property (nonatomic, assign) id<AuthorizeWebViewDelegate> delegate;

- (void)loadRequestWithURL:(NSURL *)url;

- (void)show:(BOOL)animated;

- (void)hide:(BOOL)animated;

- (void)onCloseButtonTouched:(id)sender;

@end
