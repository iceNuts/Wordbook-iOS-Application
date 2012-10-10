//
//  RegisterController.h
//  LangL
//
//  Created by king bill on 11-9-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterController : UIViewController<UITextFieldDelegate> {
    UITextField *txtEMail;
    UITextField *txtPassword;
    UITextField *txtRepPwd;
    UIActivityIndicatorView *loadingHint;
    UITextField *txtUserName;
    UIButton *btnRegister;
}

@property (nonatomic, retain) IBOutlet UITextField *txtEMail;
@property (nonatomic, retain) IBOutlet UITextField *txtPassword;
@property (nonatomic, retain) IBOutlet UITextField *txtRepPwd;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingHint;

@property (nonatomic, retain) IBOutlet UITextField *txtUserName;
@property (nonatomic, retain) UIButton *btnRegister;

@end
