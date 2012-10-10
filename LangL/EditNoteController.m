//
//  EditNoteController.m
//  LangL
//
//  Created by king bill on 11-8-20.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "EditNoteController.h"
#import "LangLAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "CommonButton.h"
#import "NavigateToNextButton.h"
#import "NavigateToPrevButton.h"
#import "NavigationButton.h"
@implementation EditNoteController

@synthesize delegate;
@synthesize txtWordNote;


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
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg_main_green.png"]];
    self.view.backgroundColor = background;
    [background release];
    
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
    // NSLog([mainDelegate.CurrWordIdx stringValue]);
    NSDictionary *currWord = [mainDelegate.WordList objectAtIndex:mainDelegate.CurrWordIdx];
    txtWordNote.text = [currWord objectForKey:@"UN"];
    
    NavigationButton *btnConfirm = [[NavigationButton alloc] init];    
    [btnConfirm setTitle:@"保 存" forState:UIControlStateNormal]; 
    
    [btnConfirm addTarget:self action:@selector(confirmNote) forControlEvents:UIControlEventTouchUpInside];  
    btnConfirm.frame = CGRectMake(255, 2, 60, 38);
    [self.view addSubview: btnConfirm];
    [btnConfirm release];
    
    NavigateToPrevButton *btnCancel = [[NavigateToPrevButton alloc] init];    
    [btnCancel setTitle:@"取 消  " forState:UIControlStateNormal]; 
    
    [btnCancel addTarget:self action:@selector(cancelNote) forControlEvents:UIControlEventTouchUpInside];     
    btnCancel.frame = CGRectMake(5, 2, 60, 38);
    [self.view addSubview: btnCancel];
    [btnCancel release];
  
    [txtWordNote becomeFirstResponder];
}

- (void)viewDidUnload
{
    [self setTxtWordNote:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{ 
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {    
    [theTextField resignFirstResponder];    
    return YES;
}

- (void)dealloc {
    [txtWordNote release];
    [super dealloc];
}

- (void)confirmNote {
    [txtWordNote resignFirstResponder];
    [self.delegate editNoteController:self SaveNewNote:txtWordNote.text];
}

- (void)cancelNote {
    [txtWordNote resignFirstResponder];
    [self.delegate editNoteController:self SaveNewNote:nil];

}
@end
