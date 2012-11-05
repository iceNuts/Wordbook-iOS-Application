//
//  AboutController.m
//  LangL
//
//  Created by king bill on 11-9-6.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "AboutController.h"
#import "LoginController.h"
#import <QuartzCore/QuartzCore.h>

@implementation AboutController
@synthesize scrollView;

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

const CGFloat kScrollObjHeight  = 460.0;
const CGFloat kScrollObjWidth   = 320.0;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *recognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)]; 

    [self.view addGestureRecognizer:recognizer]; 
    [recognizer release];
    
    [scrollView setBackgroundColor:[UIColor blackColor]];
    [scrollView setCanCancelContentTouches:NO];
    scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    scrollView.clipsToBounds = YES;        // default is NO, we want to restrict drawing within our scrollview
    scrollView.scrollEnabled = YES;
    
    // pagingEnabled property default is NO, if set the scroller will stop or snap at each photo
    // if you want free-flowing scroll, don't set this property.
    scrollView.pagingEnabled = YES;
    
    // load all the images from our bundle and add them to the scroll view
    NSUInteger i;
    for (i = 1; i <= 3; i++)
    {
        NSString *imageName = [NSString stringWithFormat:@"welcome_%d.png", i];
        UIImage *image = [UIImage imageNamed:imageName];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        
        // setup each frame to a default height and width, it will be properly placed when we call "updateScrollList"
        CGRect rect = imageView.frame;
        rect.size.height = kScrollObjHeight;
        rect.size.width = kScrollObjWidth;
        imageView.frame = rect;
        imageView.tag = i;  // tag our images for later use when we place them in serial fashion
        [scrollView addSubview:imageView];        
        [imageView release];
    }
    [self layoutScrollImages]; 
}

- (void)layoutScrollImages
{
    UIImageView *view = nil;
    NSArray *subviews = [scrollView subviews];
    
    // reposition all image subviews in a horizontal serial fashion
    CGFloat curXLoc = 0;
    for (view in subviews)
    {
        if ([view isKindOfClass:[UIImageView class]] && view.tag > 0)
        {
            CGRect frame = view.frame;
            frame.origin = CGPointMake(curXLoc, 0);
            view.frame = frame;
            
            curXLoc += (kScrollObjWidth);
        }
    }
    
    // set the content size so it can be scrollable
    [scrollView setContentSize:CGSizeMake((3 * kScrollObjWidth), [scrollView bounds].size.height)];
}

-(void)handleTapFrom:(UITapGestureRecognizer *)recognizer{ 
    [self.delegate aboutController: self];
	
	//Pop alert view for share
	SocialAlert* alertDelegate = [[SocialAlert alloc] init];
	UIAlertView* alert = [[UIAlertView alloc]
						  initWithTitle:@"提示" message:@"恭喜您成功安装了朗播词汇书，将这个消息告诉朋友？" delegate:alertDelegate cancelButtonTitle:@"取消" otherButtonTitles:@"好的", nil];
	[alert show];
	[alert release];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [scrollView release];
    [super dealloc];
}

@end
