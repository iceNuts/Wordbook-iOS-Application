//
//  RegisterController.m
//  LangL
//
//  Created by king bill on 11-9-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "RegisterController.h"
#import "LoginController.h"
#import "SBJson.h"
#import "ASIHTTPRequest.h"
#import "CommonButton.h"

@implementation RegisterController
@synthesize txtEMail;
@synthesize txtPassword;
@synthesize txtRepPwd;
@synthesize loadingHint;
@synthesize txtUserName;
@synthesize btnRegister;

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
    self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"bg_main_green.png"]]; 
    txtPassword.secureTextEntry = true;  
    txtRepPwd.secureTextEntry = true; 
    
    btnRegister = [[CommonButton alloc] init];        
    [btnRegister setTitle:@"免费注册" forState:UIControlStateNormal];
    
    [btnRegister addTarget:self action:@selector(btnRegisterTouched)
       forControlEvents:UIControlEventTouchUpInside];
    btnRegister.frame = CGRectMake(200, 180, 100, 40);
    [self.view addSubview:btnRegister];
    [btnRegister release];
    
    self.title = @"注册新用户";
}

- (void)viewDidUnload
{
    [self setTxtEMail:nil];
    [self setTxtUserName:nil];
    [self setTxtPassword:nil];
    [self setTxtRepPwd:nil];
    [self setBtnRegister:nil];
    [self setLoadingHint:nil];
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
    [txtEMail release];
    [txtUserName release];
    [txtPassword release];
    [txtRepPwd release];
    [loadingHint release];
    [super dealloc];
}

- (void)btnRegisterTouched {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
    
    if (![emailTest evaluateWithObject: txtEMail.text])
    {
        UIAlertView *alert = [[UIAlertView alloc]//
                              initWithTitle:@"警告"
                              message:@"请输入一个合法的邮件地址"
                              delegate:self
                              cancelButtonTitle:@"确定"
                              otherButtonTitles:nil];
        
        [alert show];
        [alert release];
        return;
    }
    if ([txtUserName.text compare: @""] == NSOrderedSame)
    {
        UIAlertView *alert = [[UIAlertView alloc]//
                              initWithTitle:@"警告"
                              message:@"请填写用户名称"
                              delegate:self
                              cancelButtonTitle:@"确定"
                              otherButtonTitles:nil];
        
        [alert show];
        [alert release]; 
        return;
    }
    if ([txtPassword.text compare: @""] == NSOrderedSame)
    {
        UIAlertView *alert = [[UIAlertView alloc]//
                              initWithTitle:@"警告"
                              message:@"请填写密码"
                              delegate:self
                              cancelButtonTitle:@"确定"
                              otherButtonTitles:nil];
        
        [alert show];
        [alert release]; 
        return;
    }
    if ([txtPassword.text compare: txtRepPwd.text] != NSOrderedSame)
    {
        UIAlertView *alert = [[UIAlertView alloc]//
                              initWithTitle:@"警告"
                              message:@"请确认两次输入的密码是一致的"
                              delegate:self
                              cancelButtonTitle:@"确定"
                              otherButtonTitles:nil];
        
        [alert show];
        [alert release]; 
        return;
    }
    NSString *valCode = [NSString stringWithFormat:@"%@%@%@", 
                         [txtEMail.text substringToIndex:1],
                         @"M",
                         [txtPassword.text substringToIndex:1]];
    NSDictionary *reqDict = [NSDictionary dictionaryWithObjectsAndKeys:
                             txtEMail.text, @"userMail",
                             txtPassword.text, @"userPwd",
                             txtUserName.text, @"userName",
                             @"M", @"sex",
                             valCode, @"valCode",
                             nil];
    [loadingHint startAnimating];
    btnRegister.enabled = NO;
    NSString* reqString = [NSString stringWithString:[reqDict JSONRepresentation]];    
    NSURL *url = [NSURL URLWithString:@"http://www.langlib.com/webservices/mobile/WS_MobileUtils.asmx/UserRegister"];
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"]; 
    [request addRequestHeader:@"Content-Type" value:@"application/json"];    
    [request appendPostData:[reqString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setCompletionBlock:^{
        NSString *responseString = [request responseString];
        NSDictionary* responseDict = [responseString JSONValue];
        NSString* responseText = (NSString *) [responseDict objectForKey:@"d"];
        NSLog(@"%@", responseString);
        NSString* responseTag = [responseText substringWithRange:NSMakeRange(0,4)];
        
        if(![responseTag isEqualToString:@"SUCC"]){
            UIAlertView *alert = [[UIAlertView alloc]//
                                  initWithTitle:@"警告"
                                  message: responseText
                                  delegate:self
                                  cancelButtonTitle:@"确定"
                                  otherButtonTitles:nil];
            
            [alert show];
            [alert release];
            
            btnRegister.enabled = YES;
            [loadingHint stopAnimating];
        }
        else
        {
            NSArray *StoreFilePath            =    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *DoucumentsDirectiory =    [StoreFilePath objectAtIndex:0];
            NSString *filePath                =    [DoucumentsDirectiory stringByAppendingPathComponent:@"LangLibWordBookConfig.plist"];
            
            NSMutableDictionary* plistDict = [[NSMutableDictionary alloc] initWithCapacity:3];
            
            [plistDict setObject:txtEMail.text forKey:@"UserMail"];
            [plistDict setObject:txtPassword.text forKey:@"UserPwd"];
            [plistDict setObject:[NSNumber numberWithBool: NO] forKey:@"AutoLogin"];
            [plistDict writeToFile:filePath atomically: YES];     
            [plistDict release];   
            btnRegister.enabled = YES;
            [loadingHint stopAnimating];
            [self.navigationController popViewControllerAnimated:YES];
            
        }
        

        
    }];
    [request setFailedBlock:^{
        [loadingHint stopAnimating];
        btnRegister.enabled = YES;
    }];
    [request startAsynchronous];        

}

@end
