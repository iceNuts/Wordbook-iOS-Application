//
//  LoginController.h
//  LangL
//
//  Created by king bill on 11-8-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomizedCheckBox.h"
#import "CommonButton.h"
#import "AboutController.h"
#import "NavigateToNextButton.h"

@interface LoginController : UIViewController <UITextFieldDelegate, ShowAboutDelegate> {
    UITextField *textField;   
    UITextField *userpwd; 
    bool forceLogin;
    CustomizedCheckBox *ckbAutoLogin;
    CommonButton *btnLogin;    
    UIActivityIndicatorView *loadingHint;    
}


- (void)btnLoginTouched;
- (void)loadSettings;
- (void)btnRegisterTouched;
- (void)showAbout;
- (void)DoLogin:(NSString *)email UserPwd:(NSString *)password;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingHint;

@property (nonatomic, retain) IBOutlet UITextField *textField;
@property (nonatomic, retain) CommonButton *btnLogin;
@property bool forceLogin;
@property (nonatomic, retain) IBOutlet UITextField *userpwd;
@property (nonatomic, retain) CustomizedCheckBox *ckbAutoLogin;
@end
