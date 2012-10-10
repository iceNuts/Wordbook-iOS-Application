//
//  WBListController.m
//  LangL
//
//  Created by king bill on 11-8-15.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WBListController.h"
#import "SBJson.h"
#import "ASIHTTPRequest.h"
#import "ScheduleController.h"
#import "LangLAppDelegate.h"
#import "LoginController.h"
#import "AboutController.h"
#import "CommonButton.h"
#import "CreateWordBookController.h"
#import <StoreKit/StoreKit.h>  
#import "SettingController.h"

@implementation WBListController
@synthesize myTableView;
@synthesize loadingAlert;

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
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 310, 410)];
    myTableView.delegate = self;
    myTableView.dataSource = self;    
    myTableView.separatorColor = [UIColor clearColor];
    [self.view addSubview: myTableView];    
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.opaque = NO;
    myTableView.backgroundView = nil;        
    self.navigationController.toolbarHidden = YES;
    self.title = @"我的词汇书"; 
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];  
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];
    if ([mainDelegate.CurrUserID isEqualToString:@"O10060826"])
    {
        UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"提示"    
                                            message:@"你目前处于体验状态，如需正式使用，请点击[返回]后登录或注册个人专属账户"                                                           
                                            delegate:nil 
                                            cancelButtonTitle:NSLocalizedString(@"关闭",nil)
                                            otherButtonTitles:nil];   
        
        [alerView show];   
        [alerView release];   
    }
    
    UIBarButtonItem *statButton = [[UIBarButtonItem alloc] initWithTitle:@"状态" style:UIBarButtonItemStylePlain target:self action:@selector(btnViewStat)];          
    self.navigationItem.rightBarButtonItem = statButton;
    [statButton release];
    
    NavigateToNextButton *btnViewStat = [[NavigateToNextButton alloc] init];    
    [btnViewStat setTitle:@"  设 置" forState:UIControlStateNormal]; 
    
    [btnViewStat addTarget:self action:@selector(btnGoSettingTouched) forControlEvents:UIControlEventTouchUpInside];     
    //定制自己的风格的  UIBarButtonItem
    UIBarButtonItem* goSettingButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnViewStat]; 
    [self.navigationItem  setRightBarButtonItem:goSettingButtonItem]; 
    [goSettingButtonItem release]; 
    [btnViewStat release]; 
}


-(void) btnGoSettingTouched 
{
    SettingController *settingController = [[SettingController alloc] initWithNibName:@"SettingController" bundle:nil];
        
    [self.navigationController pushViewController:settingController animated:YES];
    [settingController release];
}

-(void) btnCreateWordBookTouched:(id)sender 
{
    LoginController *loginController=[[LoginController alloc] initWithNibName:@"LoginController" bundle:nil];   
    self.view.window.rootViewController=loginController; 
    [loginController release];
}


- (void)aboutController:(AboutController *)aboutController
{
    [aboutController dismissModalViewControllerAnimated:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [myTableView reloadData];     
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {    
    [myTableView release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 103;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];
    return (mainDelegate.WordBookList.count + 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];
    if (indexPath.row == mainDelegate.WordBookList.count)
        CellIdentifier = @"LastCell";    
    else CellIdentifier = @"Cell";  
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];    
    
    UIImageView *splitter = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_item.png"]];
    [splitter setFrame: CGRectMake(0, 102, 320, 2)];
    [cell.contentView addSubview: splitter];
    [splitter release];
    cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_item.png"]] autorelease];
  
    
    if (indexPath.row == mainDelegate.WordBookList.count)
    {
        UIImageView *iconImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_book_addnew_n.png"]];
        [iconImage setFrame: CGRectMake(10, 10, 80, 80)];
        [cell.contentView addSubview: iconImage];
        [iconImage release];
        UILabel *hint1 = [[UILabel alloc] initWithFrame:CGRectMake(110, 20, 150, 30)];
        hint1.textColor = [UIColor whiteColor];
        hint1.text = @"创建新词汇书";
        hint1.font = [UIFont systemFontOfSize:14];
        hint1.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview: hint1];
        [hint1 release];
        UILabel *hint2 = [[UILabel alloc] initWithFrame:CGRectMake(110, 40, 150, 30)];
        hint2.textColor = [UIColor lightTextColor];
        hint2.text = @"亲身体验网络学习的魅力";
        hint2.font = [UIFont systemFontOfSize:13];
        hint2.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview: hint2];
        [hint2 release];
        
        return cell;
    }    

    NSMutableDictionary *dict = [mainDelegate.WordBookList objectAtIndex: indexPath.row];
    NSString *bookIcon;
    int dictType = [[dict valueForKey:@"DictType"] intValue];
    switch (dictType) {
        case 0:
            bookIcon = @"ico_book_cet4.png";
            break;
        case 1:
            bookIcon = @"ico_book_cet6.png";
            break;  
        case 2:
            bookIcon = @"ico_book_gaokao.png";
            break;
        case 3:
            bookIcon = @"ico_books_kaoyan.png";
            break;
        case 4:
            bookIcon = @"ico_books_toefl.png";
            break;
        case 5:
            bookIcon = @"ico_books_gre.png";
            break;
        case 6:
            bookIcon = @"ico_books_ielts.png";
            break;
        case 8:
            bookIcon = @"ico_books_gmat.png";
            break;
        case 9:
            bookIcon = @"ico_books_sat.png";
            break;
        case 7:
            bookIcon = @"ico_book_business.png";
            break;
        case 10:
            bookIcon = @"ico_books_gre_1.png";
            break;
        case 11:
            bookIcon = @"ico_books_gre_2.png";
            break;
        case 12:
            bookIcon = @"ico_books_gre_3.png";
            break;
        case 13:
            bookIcon = @"ico_book_cet4.png";
            break;
        case 14:
            bookIcon = @"ico_books_kaoyan.png";
            break;
        default:
            bookIcon = @"ico_books.png";
            break;
    }
    
    UIImageView *iconImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed: bookIcon]];
    [iconImage setFrame: CGRectMake(10, 10, 80, 80)];
    [cell.contentView addSubview: iconImage];
    [iconImage release];
    
    UILabel *hint1 = [[UILabel alloc] initWithFrame:CGRectMake(110, 5, 170, 30)];
    hint1.textColor = [UIColor colorWithRed:255.0/255.0 green:215.0/255.0 blue:125.0/255.0 alpha:1];
    hint1.text = [NSString stringWithFormat:@"%@", [mainDelegate GetDictNameByType:dictType]];
    hint1.font = [UIFont systemFontOfSize:15];
    hint1.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview: hint1];
    [hint1 release];
    
    UILabel *hint2 = [[UILabel alloc] initWithFrame:CGRectMake(110, 30, 150, 30)];
    hint2.textColor = [UIColor lightTextColor];
    hint2.text = [NSString stringWithFormat:@"当前阶段: %@", [dict valueForKey:@"SubCount"]];
    hint2.font = [UIFont systemFontOfSize:12];
    hint2.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview: hint2];
    [hint2 release];
          
    if ([[dict valueForKey:@"IsPaid"] intValue] == 0)
    {
        CommonButton *btnBuy = [[CommonButton alloc] init];   
        NSInteger bookVal = 0;
        for (int i = 0; i <= mainDelegate.ProductPriceArr.count - 1; i ++)
        {
            if (dictType == [[[mainDelegate.ProductPriceArr objectAtIndex:i] objectForKey:@"DictType"] intValue])
            {
                bookVal = [[[mainDelegate.ProductPriceArr objectAtIndex:i] objectForKey:@"RMBVal"] integerValue] / 10;
                break;
            }
        }
        [btnBuy setTitle: [NSString stringWithFormat: @"购买(%d元)", bookVal] forState:UIControlStateNormal];
        btnBuy.tag = indexPath.row;
        [btnBuy addTarget:self action:@selector(buyProduct:) forControlEvents:UIControlEventTouchUpInside];
        btnBuy.frame = CGRectMake(110, 65, 120, 30);
        [cell.contentView addSubview: btnBuy];
        [btnBuy release];    
    }
    else        
    {
        UILabel *hint3 = [[UILabel alloc] initWithFrame:CGRectMake(110, 45, 120, 30)];
        hint3.textColor = [UIColor lightTextColor];
        if ([[dict valueForKey:@"IsPaid"] intValue] == 1) 
            hint3.text = @"产品状态: 正式版";
        else hint3.text = @"产品状态: 试用版";
        hint3.font = [UIFont systemFontOfSize:12];
        hint3.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview: hint3];
        [hint3 release];
        
        
        UILabel *hint4 = [[UILabel alloc] initWithFrame:CGRectMake(110, 60, 150, 30)];
        hint4.textColor = [UIColor lightTextColor];    
        hint4.font = [UIFont systemFontOfSize:12];
        if ([[dict valueForKey:@"IsPaid"] intValue] == 1) 
        {
            hint4.text = @"有效期限: 永久使用";
        }
        else
        {
            hint4.text = @"有效期限: 体验阶段";
        }
        hint4.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview: hint4];
        [hint4 release];        
    }
    
    UIImageView *disclosureImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"ico_arrow.png"]];
    [disclosureImage setFrame: CGRectMake(280, 40, 20, 24)];
    [cell.contentView addSubview: disclosureImage];
    [disclosureImage release];

    return cell;
}

-(void)buyProduct:(id)sender {      
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    if ([mainDelegate.CurrUserID isEqualToString:@"O10060826"])
    {
        UIAlertView *alerView2 =  [[UIAlertView alloc] initWithTitle:@"提示"    
                                                             message:@"体验账户下无法购买词汇书，请点击[返回]后 或注册自己的账号"                                                         
                                                            delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil];   
        
        [alerView2 show];   
        [alerView2 release];     
        return;
    }
    
    mainDelegate.CurrDictType = [[[mainDelegate.WordBookList objectAtIndex: ((UIButton *)sender).tag] objectForKey:@"DictType"] integerValue];
    mainDelegate.CurrWordBookID = [[mainDelegate.WordBookList objectAtIndex: ((UIButton *)sender).tag] objectForKey:@"WordBookID"];
    if ([SKPaymentQueue canMakePayments]) {    
        NSArray *product = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"WB_%d", mainDelegate.CurrDictType],nil];     
        NSSet *nsset = [NSSet setWithArray:product];   
        SKProductsRequest *request=[[SKProductsRequest alloc] initWithProductIdentifiers: nsset];   
        request.delegate=self;   
        [request start];   
        [product release];  
    }   
    else   
    {             
        UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"Alert"    
                                                            message:@"You can‘t purchase in app store"                                                           
                                                           delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil];   
        
        [alerView show];   
        [alerView release];   
        
    }   
}

-(bool)CanMakePay   
{   
    return [SKPaymentQueue canMakePayments];   
}  

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{   
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];    

    SKPayment *payment = [SKPayment paymentWithProductIdentifier:[NSString stringWithFormat:@"WB_%d", mainDelegate.CurrDictType]];   

    [[SKPaymentQueue defaultQueue] addPayment:payment];     
    [request autorelease];  
}

//弹出错误信息   
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{      
    UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert",NULL) message:[error localizedDescription]                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"Close",nil) otherButtonTitles:nil];   
    [alerView show];   
    [alerView release];   
}  

-(void) requestDidFinish:(SKRequest *)request    
{   
    
}   

-(void) PurchasedTransaction: (SKPaymentTransaction *)transaction{    
    NSArray *transactions =[[NSArray alloc] initWithObjects:transaction, nil];   
    [self paymentQueue:[SKPaymentQueue defaultQueue] updatedTransactions:transactions];   
    [transactions release];   
}    

//<SKPaymentTransactionObserver> 千万不要忘记绑定，代码如下：   
//----监听购买结果   
//[[SKPaymentQueue defaultQueue] addTransactionObserver:self];   

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions//交易结果   
{   
    for (SKPaymentTransaction *transaction in transactions)   
    {   
        switch (transaction.transactionState)   
        {    
            case SKPaymentTransactionStatePurchased://交易完成    
            {
                [self completeTransaction:transaction];   
                NSString* jsonObjectString = [self encode:(uint8_t *)transaction.transactionReceipt.bytes
                                                   length:transaction.transactionReceipt.length];
                
                LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
                
                NSDictionary *reqDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                         mainDelegate.CurrWordBookID, @"dictID",
                                         mainDelegate.CurrUserID, @"userID",
                                         @"", @"productID",
                                         @"", @"receipt",
                                         [NSString stringWithString:@"0"], @"inSandBox",
                                         nil];
                
                //RPC JSON
                NSString* reqString = [NSString stringWithString:[reqDict JSONRepresentation]];    
                NSURL *url = [NSURL URLWithString:@"http://www.langlib.com/webservices/mobile/WS_MobileUtils.asmx/VerifyReceipt"];
                __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                [request addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"]; 
                [request addRequestHeader:@"Content-Type" value:@"application/json"];    
                [request appendPostData:[reqString dataUsingEncoding:NSUTF8StringEncoding]];
                [request setCompletionBlock:^{
                           
                }];
                [request setFailedBlock:^{            
                    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
                    [mainDelegate showNetworkFailed];
                }];
                [request startAsynchronous];  
                UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"提示"    
                                                                    message:@"购买成功，你已可使用词汇书的全部功能"                                                         
                                                                   delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil];   
                
                [alerView show];   
                [alerView release];  
     
                for (int i = 0; i <= mainDelegate.WordBookList.count - 1; i ++)
                {
                    if ([mainDelegate.CurrWordBookID isEqualToString: [[mainDelegate.WordBookList objectAtIndex: i] objectForKey:@"WordBookID"]])
                        [[mainDelegate.WordBookList objectAtIndex: i] setObject: [NSNumber numberWithInt: 1] forKey: @"IsPaid"];
                }
                [myTableView reloadData];
                
                break;    

            }
            case SKPaymentTransactionStateFailed://交易失败    
                [self failedTransaction:transaction];   
                UIAlertView *alerView2 =  [[UIAlertView alloc] initWithTitle:@"提示"    
                                                                     message:@"未成功购买此词汇书。"                                                         
                                                                    delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil];   
                
                [alerView2 show];   
                [alerView2 release];   
                break;               
            case SKPaymentTransactionStatePurchasing:      //商品添加进列表    
                break;   
            default:   
                break;   
        }   
    }   
}   

- (void) completeTransaction: (SKPaymentTransaction *)transaction  
{       
    NSString *product = transaction.payment.productIdentifier;   
      
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];   
    
}   

- (NSString *)encode:(const uint8_t *)input length:(NSInteger)length {
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData *data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t *output = (uint8_t *)data.mutableBytes;
    
    for (NSInteger i = 0; i < length; i += 3) {
        NSInteger value = 0;
        for (NSInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger index = (i / 3) * 4;
        output[index + 0] =                    table[(value >> 18) & 0x3F];
        output[index + 1] =                    table[(value >> 12) & 0x3F];
        output[index + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[index + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
}

//记录交易   
-(void)recordTransaction{   
    
}   

//处理下载内容   
-(void)provideContent{   
       
}   

- (void) failedTransaction: (SKPaymentTransaction *)transaction{   
 
    if (transaction.error.code != SKErrorPaymentCancelled)   
    {   
    }   
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];   
    
    
}   

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
    if (indexPath.row == mainDelegate.WordBookList.count)
    {
        CreateWordBookController *createNewController = [[CreateWordBookController alloc] initWithNibName:@"CreateWordBookController" bundle:nil];
        
        [self.navigationController pushViewController:createNewController animated:YES];
        [createNewController release];    
        return;    
    }
    mainDelegate.NeedReloadSchedule = NO;
    NSDictionary *dict = [mainDelegate.WordBookList objectAtIndex: indexPath.row];
    mainDelegate.CurrWordBookID = [dict valueForKey:@"WordBookID"];
    mainDelegate.CurrPhaseIdx = [[dict valueForKey:@"SubCount"]  integerValue];
    mainDelegate.CurrPhaseIdx = mainDelegate.CurrPhaseIdx - 1;
    mainDelegate.CurrDictType = [[dict valueForKey:@"DictType"]  integerValue];

     
    ScheduleController *detailViewController = [[ScheduleController alloc] initWithNibName:@"ScheduleController" bundle:nil];

    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];

}

-(void)showLoadingAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"处理中,请稍候..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];    
    [alert show];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.center = CGPointMake(loadingAlert.bounds.size.width / 2, loadingAlert.bounds.size.height - 50);
    [indicator startAnimating];
    [alert addSubview:indicator];
    [indicator release];     
    self.loadingAlert = alert;
    [alert release];
}

-(void)hideLoadingAlert
{
    [loadingAlert dismissWithClickedButtonIndex:0 animated:YES];
}

@end
