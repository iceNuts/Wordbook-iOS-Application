//
//  notificationTestViewController.m
//  LangL
//
//  Created by Zeng Li on 11/20/12.
//
//

#import "notificationTestViewController.h"

@interface notificationTestViewController ()

@end

@implementation notificationTestViewController

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg_main_green.png"]];
    self.view.backgroundColor = background;
    [background release];
	
    NavigationButton *btnConfirm = [[NavigationButton alloc] init];
    [btnConfirm setTitle:@"确 定" forState:UIControlStateNormal];
    
    [btnConfirm addTarget:self action:@selector(btnConfirmSelectTouched) forControlEvents:UIControlEventTouchUpInside];
    btnConfirm.frame = CGRectMake(255, 2, 60, 38);
    [self.view addSubview: btnConfirm];
    [btnConfirm release];
    
    NavigateToPrevButton *btnCancel = [[NavigateToPrevButton alloc] init];
    [btnCancel setTitle:@"取 消  " forState:UIControlStateNormal];
    
    [btnCancel addTarget:self action:@selector(btnCancelSelectTouched) forControlEvents:UIControlEventTouchUpInside];
    btnCancel.frame = CGRectMake(5, 2, 60, 38);
    [self.view addSubview: btnCancel];
	
	//Picker View
	self.timePicker.datePickerMode = UIDatePickerModeCountDownTimer;
	
    [btnCancel release];
}

-(void) btnCancelSelectTouched{
	[delegate notificationViewWillCancel];
}

-(void) btnConfirmSelectTouched{
	[delegate notificationViewWillConfirm];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
	[_popHeader release];
	[_notificationSwitch release];
	[_hintLabel1 release];
	[_hintTextView1 release];
	[_timePicker release];
	[_hintTextView2 release];
	[_headerLabel release];
	[_timePicker release];
	[super dealloc];
}
- (void)viewDidUnload {
	[self setPopHeader:nil];
	[self setNotificationSwitch:nil];
	[self setHintLabel1:nil];
	[self setHintTextView1:nil];
	[self setTimePicker:nil];
	[self setHintTextView2:nil];
	[self setHeaderLabel:nil];
	[self setTimePicker:nil];
	[super viewDidUnload];
}
@end
