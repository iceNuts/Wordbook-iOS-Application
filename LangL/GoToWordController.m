//
//  GoToWordController.m
//  LangL
//
//  Created by king bill on 11-8-20.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "GoToWordController.h"

@implementation GoToWordController
@synthesize gotoIdx;
@synthesize delegate;

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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setGotoIdx:nil];
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
    if (theTextField == self.gotoIdx) {
        [theTextField resignFirstResponder];
    }
    return YES;
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string 
{
    /*  limit to only numeric characters  */
    NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    for (int i = 0; i < [string length]; i++) {
        unichar c = [string characterAtIndex:i];
        if ([myCharSet characterIsMember:c]) {
            return YES;
        }
    }
    
    /*  limit the users input to only 9 characters  */
    NSUInteger newLength = [gotoIdx.text length] + [string length] - range.length;
    return (newLength > 9) ? NO : YES;
}

- (IBAction)confirmGoTo:(id)sender {
    [gotoIdx resignFirstResponder];
    [self.delegate gotoWordController: self GoToWord: [self.gotoIdx.text integerValue]];
}

- (IBAction)cancelGoTo:(id)sender {
    [gotoIdx resignFirstResponder];
    [self.delegate gotoWordController: self GoToWord: 0];
}
- (void)dealloc {
    [gotoIdx release];
    [super dealloc];
}
@end
