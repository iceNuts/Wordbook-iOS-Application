//
//  WordListController.m
//  LangL
//
//  Created by king bill on 11-9-7.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WordListController.h"
#import "LangLAppDelegate.h"
#import "SBJson.h"
#import "ASIHTTPRequest.h"
#import "ViewWordController.h"
#import "SortWordController.h"
#import "Foundation/NSSortDescriptor.h"
#import "NavigateToNextButton.h"
#import "WordListCell.h"

@implementation WordListController
@synthesize loadingIcon;
@synthesize wordListView;
@synthesize  initLoad;
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
    initLoad = YES;
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
    self.title = [NSString stringWithFormat:@"List %d", mainDelegate.CurrListID];
	
	//Read the data to a list
	mainDelegate.WordList = nil;
	NSArray *StoreFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *DoucumentsDirectiory = [StoreFilePath objectAtIndex:0];
	NSString *bookDir = [DoucumentsDirectiory stringByAppendingPathComponent:mainDelegate.CurrWordBookID];
	NSString *phaseDir = [bookDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", mainDelegate.CurrPhaseIdx]];
	NSString *wordlistDir = [[phaseDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", mainDelegate.CurrListID]] stringByAppendingString:@".plist"];
	mainDelegate.WordList = [[NSMutableArray alloc] initWithContentsOfFile:wordlistDir];
	
	//if not exist, try reading book xml
		
	if(mainDelegate.WordList == nil){
		//0: init   1: asc  2: desc   3;fam asc  4 fam desc  5: random
		mainDelegate.CurrSortType = 0;
		
		NSDictionary *reqDict = [NSDictionary dictionaryWithObjectsAndKeys:
								 mainDelegate.CurrWordBookID, @"wordBookID",
								 @"4", @"familiarity",
								 @"4", @"sortType",
								 [NSString stringWithFormat:@"%d", mainDelegate.CurrPhaseIdx], @"phaseIdx",
								 [NSString stringWithFormat:@"%d", mainDelegate.CurrListID], @"listID",
								 [NSString stringWithFormat:@"%d", mainDelegate.CurrDictType], @"dictType",
								 mainDelegate.CurrUserID, @"userID",
								 nil];
		
		
		//RPC JSON
		NSString* reqString = [NSString stringWithString:[reqDict JSONRepresentation]];
		NSURL *url = [NSURL URLWithString:@"http://www.langlib.com/webservices/mobile/ws_mobilewordbook.asmx/ListWords"];
		
		__block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
		[request addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"];
		[request addRequestHeader:@"Content-Type" value:@"application/json"];
		[request appendPostData:[reqString dataUsingEncoding:NSUTF8StringEncoding]];
		[request setCompletionBlock:^{
			[loadingIcon stopAnimating];
			NSString *responseString = [request responseString];
			NSDictionary* responseDict = [responseString JSONValue];
			mainDelegate.WordList = (NSMutableArray *) [responseDict objectForKey:@"d"];
			
			//Write the data to a list
			NSArray *StoreFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *DoucumentsDirectiory = [StoreFilePath objectAtIndex:0];
			NSString *bookDir = [DoucumentsDirectiory stringByAppendingPathComponent:mainDelegate.CurrWordBookID];
			NSString *phaseDir = [bookDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", mainDelegate.CurrPhaseIdx]];
			[[NSFileManager defaultManager] createDirectoryAtPath:phaseDir withIntermediateDirectories:YES attributes:nil error:nil];
			NSString *wordlistDir = [[phaseDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", mainDelegate.CurrListID]] stringByAppendingString:@".plist"];
			[mainDelegate.WordList writeToFile:wordlistDir atomically:YES];
			mainDelegate.CurrWordIdx = 0;
			int totalWords = mainDelegate.WordList.count;
			[mainDelegate.filteredArr removeAllObjects];
			for (int i = 0; i <= totalWords - 1; i++) {
				[mainDelegate.filteredArr addObject: [NSNumber numberWithInt: i]];
			}
			mainDelegate.enableFilter = NO;
			wordListView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 415)];
			wordListView.delegate = self;
			wordListView.dataSource = self;
			[self.view addSubview:self.wordListView];
			
			wordListView.separatorColor = [UIColor clearColor];
			wordListView.backgroundColor = [UIColor clearColor];
			wordListView.opaque = NO;
			wordListView.backgroundView = nil;
			[loadingIcon stopAnimating];
		}];
		[request setFailedBlock:^{
			[loadingIcon stopAnimating];
			LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];
			[mainDelegate showNetworkFailed];
		}];
		[request startAsynchronous];
	}else{
		[loadingIcon stopAnimating];
		mainDelegate.CurrWordIdx = 0;
		int totalWords = mainDelegate.WordList.count;
		[mainDelegate.filteredArr removeAllObjects];
		for (int i = 0; i <= totalWords - 1; i++) {
			[mainDelegate.filteredArr addObject: [NSNumber numberWithInt: i]];
		}
		mainDelegate.enableFilter = NO;
		wordListView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 415)];
		wordListView.delegate = self;
		wordListView.dataSource = self;
		[self.view addSubview:self.wordListView];
		
		wordListView.separatorColor = [UIColor clearColor];
		wordListView.backgroundColor = [UIColor clearColor];
		wordListView.opaque = NO;
		wordListView.backgroundView = nil;
	}
    NavigateToNextButton *btnSort = [[NavigateToNextButton alloc] init];
    [btnSort setTitle:@"  排 序" forState:UIControlStateNormal];
    [btnSort addTarget:self action:@selector(btnSelectSortTouched) forControlEvents:UIControlEventTouchUpInside];
    //定制自己的风格的  UIBarButtonItem
    UIBarButtonItem* sortButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnSort];
    [self.navigationItem  setRightBarButtonItem:sortButtonItem]; 
    [sortButtonItem release]; 
    [btnSort release];  
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.toolbarHidden = YES; 
    if (!initLoad)
        [self.wordListView reloadData];
    initLoad = NO;
}

- (void)viewDidUnload
{
    [self setLoadingIcon:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



- (void)sortWordController:(SortWordController *)sortWordController hasSelectSort:(bool)flag  {    
    if (flag) {  
        [self.wordListView reloadData];
    } 
    [sortWordController dismissModalViewControllerAnimated:YES];    
}

-(void) btnSelectSortTouched 
{
    SortWordController *sortWordController = [[SortWordController alloc]
                                              initWithNibName:@"SortWordController" bundle:nil];
    
    sortWordController.delegate = self;   
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
    sortWordController.currSortType = mainDelegate.CurrSortType;
    sortWordController.showUnfamilarWord = mainDelegate.enableFilter;
    // Create the navigation controller and present it modally.
    [self presentModalViewController:sortWordController animated:YES];
    [sortWordController release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
    return mainDelegate.filteredArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{   
    
    static NSString *CellIdentifier = @"Cell";
    WordListCell *cell = (WordListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[WordListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_item.png"]] autorelease];
    } 
    
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];
    NSDictionary *word = [mainDelegate.WordList objectAtIndex: [[mainDelegate.filteredArr objectAtIndex:indexPath.row] integerValue]];   
    
    
    cell.familiarityLabel.text = [NSString stringWithFormat:@"%d", [[word objectForKey:@"F"] integerValue] + 1];       
    cell.wordLabel.text = [word objectForKey:@"W"];   
    cell.expLabel.text = [word objectForKey:@"CN"]; 
    [cell.familiarityLabel setOpaque:NO];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
    mainDelegate.CurrWordIdx = indexPath.row;
    ViewWordController *detailViewController = [[ViewWordController alloc] initWithNibName:@"ViewWordController" bundle:nil];
    
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];   
    
}

- (void)dealloc {
    [wordListView release];
    [loadingIcon release];
    [super dealloc];
}
@end
