//
//  PhaseSelectionController.m
//  LangL
//
//  Created by king bill on 11-8-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "PhaseSelectionController.h"
#import "LangLAppDelegate.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"

@implementation PhaseSelectionController
@synthesize loadingHint;
@synthesize currTitle;
@synthesize headerView;
@synthesize totalWords;
@synthesize familiarityArr;
@synthesize familiarityView;

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
    NSDictionary *reqDict = [NSDictionary dictionaryWithObjectsAndKeys:
                             mainDelegate.CurrWordBookID, @"wordBookID",                     
                             [NSString stringWithFormat:@"%d", mainDelegate.CurrPhaseIdx], @"phaseIdx",                         
                             mainDelegate.CurrUserID, @"userID",
                             nil];
   
    [headerView setImage:[[UIImage imageNamed:@"bg_item_title.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:5.0]];
    //RPC JSON
    NSString* reqString = [NSString stringWithString:[reqDict JSONRepresentation]];    
    NSURL *url = [NSURL URLWithString:@"http://www.langlib.com/webservices/mobile/ws_mobilewordbook.asmx/GetPhaseStatistics"];
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"]; 
    [request addRequestHeader:@"Content-Type" value:@"application/json"];    
    [request appendPostData:[reqString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setCompletionBlock:^{
        loadingHint.hidden = YES;
        NSString *responseString = [request responseString];
        NSDictionary* responseDict = [responseString JSONValue];
        NSDictionary *statDict = (NSDictionary *) [responseDict objectForKey:@"d"];

       
        NSArray *array = [[NSArray alloc] initWithObjects:
                          [NSNumber numberWithInteger:[[statDict objectForKey:@"Familarity1"] integerValue]],
                          [NSNumber numberWithInteger:[[statDict objectForKey:@"Familarity2"] integerValue]],
                          [NSNumber numberWithInteger:[[statDict objectForKey:@"Familarity3"] integerValue]],
                          [NSNumber numberWithInteger:[[statDict objectForKey:@"Familarity4"] integerValue]],
                          [NSNumber numberWithInteger:[[statDict objectForKey:@"Familarity5"] integerValue]],                         
                          nil];
        self.familiarityArr = array;
        [array release];
        NSInteger total = 0;
        for (NSNumber *fCount in familiarityArr) {
            total = total + [fCount integerValue];
        }
        totalWords.textColor = [UIColor colorWithRed:255.0/255.0 green:160.0/255.0 blue:0.0/255.0 alpha:1];
        totalWords.text = [NSString stringWithFormat:@"%d", total];

        familiarityView = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, 320, 280) style:UITableViewStylePlain];
        familiarityView.delegate = self;
        familiarityView.dataSource = self;
        [self.view addSubview:self.familiarityView];
        
        familiarityView.separatorColor = [UIColor clearColor];  
        familiarityView.backgroundColor = [UIColor clearColor];
        familiarityView.opaque = NO;
        familiarityView.backgroundView = nil;
    }];
    [request setFailedBlock:^{
        loadingHint.text = @"";
        LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
        [mainDelegate showNetworkFailed];
    }];
    [request startAsynchronous];
    self.title = @"阶段学习情况";
    currTitle.text = [NSString stringWithFormat: @"%@词汇书第%d阶段", [mainDelegate GetDictNameByType:mainDelegate.CurrDictType], mainDelegate.CurrPhaseIdx + 1];  
}
     
- (void)viewDidUnload
{
    [self setLoadingHint:nil];
    [self setTotalWords:nil];
    [self setCurrTitle:nil];
    [self setHeaderView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 38;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
     
    UIImageView *familiarityIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_star_green.png"]];
    familiarityIcon.frame = CGRectMake(15, 4, 26, 26);
    [cell.contentView addSubview: familiarityIcon];
    [familiarityIcon release];
    
    UILabel *familiarityLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 4, 26, 26)];
    familiarityLabel.textColor = [UIColor orangeColor];
    familiarityLabel.backgroundColor = [UIColor clearColor];
    familiarityLabel.font = [UIFont systemFontOfSize:11];
    familiarityLabel.text = [NSString stringWithFormat:@"%d", indexPath.row + 1];
    familiarityLabel.textAlignment = UITextAlignmentCenter;
    [cell.contentView addSubview: familiarityLabel];
    [familiarityLabel release];
    
    UILabel *hint2 = [[UILabel alloc] initWithFrame:CGRectMake(45, 9, 210, 20)];
    hint2.textColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1];
 
    hint2.font = [UIFont systemFontOfSize:15];
    hint2.backgroundColor = [UIColor clearColor];    
    switch (indexPath.row) {
        case 0:
            hint2.text = [NSString stringWithFormat: @"%d级熟练度单词(%@)总数:", indexPath.row + 1,  @"形同陌路"];
            break;
        case 1:
            hint2.text = [NSString stringWithFormat: @"%d级熟练度单词(%@)总数:", indexPath.row + 1,  @"似曾相识"];            
            break;
        case 2:
            hint2.text = [NSString stringWithFormat: @"%d级熟练度单词(%@)总数:", indexPath.row + 1,  @"半生不熟"];            
            break;
        case 3:
            hint2.text = [NSString stringWithFormat: @"%d级熟练度单词(%@)总数:", indexPath.row + 1,  @"一见如故"];            
            break;
        case 4:
            hint2.text = [NSString stringWithFormat: @"%d级熟练度单词(%@)总数:", indexPath.row + 1,  @"刻骨铭心"];            
            break;
        default:
            break;
    }
    [cell.contentView addSubview: hint2];
    [hint2 release];
  
    UILabel *hint1 = [[UILabel alloc] initWithFrame:CGRectMake(255, 9, 60, 20)];
    hint1.textColor = [UIColor whiteColor];
    hint1.text = [[familiarityArr objectAtIndex:indexPath.row] stringValue];
    hint1.font = [UIFont systemFontOfSize:16];
    hint1.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview: hint1];
    [hint1 release];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}


- (void)dealloc {
    [familiarityArr release];
    [familiarityView release];
    [loadingHint release];
    [totalWords release];
    [currTitle release];
    [headerView release];
    [super dealloc];
}

@end
