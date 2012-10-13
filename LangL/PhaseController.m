//
//  PhaseController.m
//  LangL
//
//  Created by Zeng Li on 10/11/12.
//
//

#import "PhaseController.h"
#import "SBJson.h"
#import "ASIHTTPRequest.h"

@interface PhaseController ()

@end

@implementation PhaseController

@synthesize loadingIcon;

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
	
	isDownloading = NO;
	downloadProgress = nil;
	downloadCell = nil;
	
	//Draw custom tableview
	LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];
	mainDelegate.PhaseCount = mainDelegate.CurrPhaseIdx + 1;
	
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg_main_green.png"]];
    self.view.backgroundColor = background;
    [background release];
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 410)];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    myTableView.separatorColor = [UIColor clearColor];
    [self.view addSubview: myTableView];
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.opaque = NO;
    myTableView.backgroundView = nil;
    self.navigationController.toolbarHidden = YES;
    self.title = @"阶段列表";
    [loadingIcon stopAnimating];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];
	NSArray *StoreFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *DoucumentsDirectiory = [StoreFilePath objectAtIndex:0];
	NSString *bookDir = [DoucumentsDirectiory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", mainDelegate.CurrDictType]];
	NSString *dbDir = [bookDir stringByAppendingString:@".pdf"];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:dbDir])
		return mainDelegate.PhaseCount;
    return mainDelegate.PhaseCount+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 103;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	downloadCell = nil;
    static NSString *CellIdentifier = @"Cell";
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	
	//If not downloaded & bought, show this at the end of page
	BOOL hasPaid = false;
    for (NSDictionary *wordBook in mainDelegate.WordBookList) {
        if ([wordBook objectForKey:@"WordBookID"] == mainDelegate.CurrWordBookID)
        {
            if ([[wordBook objectForKey:@"IsPaid"] integerValue] == 1)
                hasPaid = YES;
            else
				hasPaid = NO;
            break;
        }
    }
	NSArray *StoreFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *DoucumentsDirectiory = [StoreFilePath objectAtIndex:0];
	NSString *bookDir = [DoucumentsDirectiory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", mainDelegate.CurrDictType]];
	NSString *dbDir = [bookDir stringByAppendingString:@".pdf"];
	
	if(indexPath.row ==mainDelegate.PhaseCount && ![[NSFileManager defaultManager] fileExistsAtPath:dbDir]){
		NSString *bookIcon;
		int dictType = mainDelegate.CurrDictType;
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
		
		UILabel *hint1 = [[UILabel alloc] initWithFrame:CGRectMake(110, 45, 240, 30)];
		hint1.textColor = [UIColor lightTextColor];
		hint1.font = [UIFont systemFontOfSize:13];
		hint1.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview: hint1];
		[hint1 release];
		
		if(!hasPaid){
			cell.userInteractionEnabled = NO;
			hint1.text = @"购买后支持离线背诵单词";
		}else{
			cell.userInteractionEnabled = YES;
			if(isDownloading)
				hint1.text = @"点击取消下载";
			else
				hint1.text = @"下载离线词库";
		}
		downloadCell = cell;
		return  cell;
	}
    
    UIImageView *splitter = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_item.png"]];
    [splitter setFrame: CGRectMake(0, 102, 320, 2)];
    [cell.contentView addSubview: splitter];
    [splitter release];
    cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_item.png"]] autorelease];
	
    UIImageView *iconImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_book_addnew_n.png"]];
	[iconImage setFrame: CGRectMake(10, 10, 80, 80)];
	[cell.contentView addSubview: iconImage];
	[iconImage release];
	UILabel *hint1 = [[UILabel alloc] initWithFrame:CGRectMake(110, 20, 150, 30)];
	hint1.textColor = [UIColor whiteColor];
	hint1.text = [@"阶段" stringByAppendingString: [NSString stringWithFormat:@"%d", (indexPath.row+1)]];
	hint1.font = [UIFont systemFontOfSize:14];
	hint1.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview: hint1];
	[hint1 release];
	UILabel *hint2 = [[UILabel alloc] initWithFrame:CGRectMake(110, 40, 150, 30)];
	hint2.textColor = [UIColor lightTextColor];
	if((mainDelegate.PhaseCount - 1) == indexPath.row)
		hint2.text = @"未完成";
	else
		hint2.text = @"已完成";
	hint2.font = [UIFont systemFontOfSize:13];
	hint2.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview: hint2];
	[hint2 release];
	
	return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];
	if(indexPath.row == mainDelegate.PhaseCount){
		if(isDownloading){
			//Cancel download
			isDownloading = !isDownloading;
			[self performSelector:@selector(stopDownloadData)];
			if(downloadProgress){
				downloadProgress.progress = 0.0;
				downloadProgress.hidden = YES;
				[downloadProgress release];
				[myTableView reloadData];
			}
			return;
		}
		//Noting but start downloading / show actionsheet
		[self performSelector:@selector(showDownloadActionSheet:)];
		
		return;
	}
	//Get into Schedule view
    mainDelegate.NeedReloadSchedule = NO;
    mainDelegate.CurrPhaseIdx = indexPath.row;	
	
	//ScheduleController should load phase data according to CurrPhaseIdx
	ScheduleController *detailViewController = [[ScheduleController alloc] initWithNibName:@"ScheduleController" bundle:nil];
	
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
}

- (IBAction)showDownloadActionSheet:(id)sender{
	UIActionSheet *downloadInfoSheet = [[UIActionSheet alloc] initWithTitle:@"下载选项" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"仅词汇(大约5MB)",@"词汇＋音频(大约20MB)",nil];
	downloadInfoSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[downloadInfoSheet showInView:self.view];
	[downloadInfoSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	
	if(buttonIndex == 2)
		return;
	if(buttonIndex == 0){
		//Download words only
		isDataWithMusic = NO;
	}else{
		//Download mp3+words
		isDataWithMusic = YES;
	}
	isDownloading = !isDownloading;
	[myTableView reloadData];
}

//Get notified for reload finish
-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];
    if([indexPath row] == mainDelegate.PhaseCount){
		if(isDownloading){
			if(downloadCell){
				downloadProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
				downloadProgress.progress = 0.0;
				downloadProgress.frame = CGRectMake(110, 30, 150, 30);
				[downloadCell.contentView addSubview:downloadProgress];							
			}
			//Start download
			[mainDelegate showDownloadInfo];
			[self performSelector:@selector(downloadData)];
		}
    }
}

- (void)downloadData{
	LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];
	//if isDownloading, disable other UI interaction;
	if(isDataWithMusic){
		//Music + Words
		[downloadQueue cancelAllOperations];
		downloadQueue = [ASINetworkQueue queue];
		[downloadQueue setDelegate: self];
		[downloadQueue setDownloadProgressDelegate:downloadProgress];
		[downloadQueue setQueueDidFinishSelector:@selector(downloadQueueFinished)];
		//If one file failed, cancel all operations
		[downloadQueue setRequestDidFailSelector:@selector(downloadQueueFailed)];
		//Add http requests into downloadQueue
		
		//Words
		NSString* downloadFilePath;
		//Example
		downloadFilePath = @"http://www.udel.edu/CSC/pdf/NurseResumes.pdf";
		NSURL *url = [NSURL URLWithString: downloadFilePath];
		NSArray *StoreFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *DoucumentsDirectiory = [StoreFilePath objectAtIndex:0];
		NSString *bookDir = [DoucumentsDirectiory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", mainDelegate.CurrDictType]];
		NSString *dbDir = [bookDir stringByAppendingString:@".pdf"];
		ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:url];
		[request setDownloadDestinationPath:dbDir];
		[downloadQueue addOperation:request];
//		//Music
//		[[NSFileManager defaultManager] createDirectoryAtPath:bookDir withIntermediateDirectories:YES attributes:nil error:nil];
//		NSString *currWordProto = [[mainDelegate.WordList objectAtIndex: [[mainDelegate.filteredArr objectAtIndex: mainDelegate.CurrWordIdx] integerValue]] objectForKey:@"W"];
//		url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.langlib.com/voice/%@/%@.mp3", [currWordProto substringToIndex:1], [[currWordProto stringByReplacingOccurrencesOfString:@"*" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]];
//
		[downloadQueue go];
	}else{
		//Words ONLY
		NSString* downloadFilePath;
		//Example
		downloadFilePath = @"http://www.udel.edu/CSC/pdf/NurseResumes.pdf";
		NSURL *url = [NSURL URLWithString: downloadFilePath];
		//assume db.dir
		NSArray *StoreFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *DoucumentsDirectiory = [StoreFilePath objectAtIndex:0];
		NSString *bookDir = [DoucumentsDirectiory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", mainDelegate.CurrDictType]];
		NSString *dbDir = [bookDir stringByAppendingString:@".pdf"];
		downloadRequest = [ASIHTTPRequest requestWithURL:url];
		[downloadRequest setDownloadDestinationPath:dbDir];
		[downloadRequest setDownloadProgressDelegate: downloadProgress];
		[downloadRequest setCompletionBlock:^{
			//Done then reload tableview
			//Set downloadCell nil
			//Release downloadProgress
			//Reset isDownloading
			isDownloading = NO;
			downloadCell = nil;
			if(downloadProgress)
				[downloadProgress release];
			//Notify user successful
			[mainDelegate showDownloadSuccess];
			[myTableView reloadData];
		}];
		[downloadRequest setFailedBlock:^{
			isDownloading = NO;
			[mainDelegate showNetworkFailed];
			[myTableView reloadData];
		}];
		[downloadRequest startAsynchronous];
	}
}

- (void)stopDownloadData{
	if(isDataWithMusic){
		[downloadQueue cancelAllOperations];
		[downloadQueue release];
	}else{
		[downloadRequest clearDelegatesAndCancel];
		[downloadRequest release];
	}
}

- (void)downloadQueueFinished{
	LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];
	if(isDownloading){
		isDownloading = NO;
		downloadCell = nil;
		if(downloadProgress)
			[downloadProgress release];
		//Notify user successful
		[mainDelegate showDownloadSuccess];
		[myTableView reloadData];
	}
}

- (void)downloadQueueFailed{
	LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];
	isDownloading = NO;
	[downloadQueue cancelAllOperations];
	[mainDelegate showNetworkFailed];
	[myTableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
