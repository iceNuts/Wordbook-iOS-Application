//
//  AuthorizeView.m
//  LangL
//
//  Created by Zeng Li on 10/30/12.
//
//

#import "AuthorizeView.h"

@interface AuthorizeView (Private)
- (void)bounceOutAnimationStopped;
- (void)bounceInAnimationStopped;
- (void)bounceNormalAnimationStopped;
- (void)allAnimationsStopped;
- (void)hideAndCleanUp;
@end

@implementation AuthorizeView

@synthesize delegate;

#pragma mark Actions

- (void)onCloseButtonTouched:(id)sender
{
    [self hide:YES];
}

- (id)init{
	if ((self = [super initWithFrame:CGRectMake(0, 0, 320, 480)]) != 0 )
    {
        // background settings
        [self setBackgroundColor:[UIColor clearColor]];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        
        // add the panel view
        panelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        [panelView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.55]];
        [[panelView layer] setMasksToBounds:NO]; // very important
        [[panelView layer] setCornerRadius:10.0];
        [self addSubview:panelView];
        
        // add the conainer view
        containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        [[containerView layer] setBorderColor:[UIColor colorWithRed:0. green:0. blue:0. alpha:0.7].CGColor];
        [[containerView layer] setBorderWidth:1.0];
        
        
        // add the web view
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(5, 20, 310, 470)];
		webView.userInteractionEnabled = YES;
		[webView setDelegate:self];
		[containerView addSubview:webView];
        
        [panelView addSubview:containerView];
        
        indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [indicatorView setCenter:CGPointMake(160, 240)];
        [self addSubview:indicatorView];
		
		//add cancel button
		cancelBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		cancelBtn.frame = CGRectMake(140, 400, 50, 40);
		cancelBtn.userInteractionEnabled = YES;
		[cancelBtn addTarget:self action:@selector(onCloseButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
		[cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
		[self addSubview:cancelBtn];
    }
    return self;
}

- (void)dealloc
{
    [panelView release], panelView = nil;
    [containerView release], containerView = nil;
    [webView release], webView = nil;
    [indicatorView release], indicatorView = nil;
    
    [super dealloc];
}

#pragma mark - WBAuthorizeWebView Public Methods

- (void)loadRequestWithURL:(NSURL *)url
{
    NSURLRequest *request =[NSURLRequest requestWithURL:url
                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                        timeoutInterval:30.0];
    [webView loadRequest:request];
}

#pragma mark Animations

- (void)bounceOutAnimationStopped
{
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.13];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounceInAnimationStopped)];
    [panelView setAlpha:0.8];
	[panelView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9)];
	[UIView commitAnimations];
}

- (void)bounceInAnimationStopped
{
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.13];
    [UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounceNormalAnimationStopped)];
    [panelView setAlpha:1.0];
	[panelView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0)];
	[UIView commitAnimations];
}

- (void)bounceNormalAnimationStopped
{
    [self allAnimationsStopped];
}

- (void)allAnimationsStopped
{
    // nothing shall be done here
}

#pragma mark Dismiss

- (void)hideAndCleanUp
{
	[self removeFromSuperview];
}

- (void)show:(BOOL)animated
{    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
	if (!window)
    {
		window = [[UIApplication sharedApplication].windows objectAtIndex:0];
	}
  	[window addSubview:self];
    
    if (animated)
    {
        [panelView setAlpha:0];
        CGAffineTransform transform = CGAffineTransformIdentity;
        [panelView setTransform:CGAffineTransformScale(transform, 0.3, 0.3)];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(bounceOutAnimationStopped)];
        [panelView setAlpha:0.5];
        [panelView setTransform:CGAffineTransformScale(transform, 1.1, 1.1)];
        [UIView commitAnimations];
    }
    else
    {
        [self allAnimationsStopped];
    }
    
}

- (void)hide:(BOOL)animated
{
	if (animated)
    {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(hideAndCleanUp)];
		[self setAlpha:0];
		[UIView commitAnimations];
	}
    [self hideAndCleanUp];
}

#pragma mark - UIWebViewDelegate Methods

- (void)webViewDidStartLoad:(UIWebView *)aWebView
{
	[indicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
	[indicatorView stopAnimating];
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error
{
    [indicatorView stopAnimating];
	[self hide:YES];
	LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];
	[mainDelegate showNetworkFailed];
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSRange range = [request.URL.absoluteString rangeOfString:@"code="];
    	
	NSRange error = [request.URL.absoluteString rangeOfString:@"error=login_denied"];
		
	if(error.location != NSNotFound){
		[self hide:YES];
		return NO;
	}
	
    if (range.location != NSNotFound)
    {
        NSString *code = [request.URL.absoluteString substringFromIndex:range.location + range.length];
        
        if ([delegate respondsToSelector:@selector(authorizeWebView:didReceiveAuthorizeCode:)])
        {
            [delegate authorizeWebView:self didReceiveAuthorizeCode:code];
        }
    }
    
    return YES;
}
@end
