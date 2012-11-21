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
	downloadQueue = nil;
	downloadRequest = nil;
	
	LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];
	
	//Initialize User Info xml, if not exist, then download it
	
	NSArray *StoreFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *DoucumentsDirectiory = [StoreFilePath objectAtIndex:0];
	NSString *filePath = [DoucumentsDirectiory stringByAppendingPathComponent:@"download_mark.plist"];
	NSDictionary* dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
	if([dict objectForKey: [NSString stringWithFormat:@"%d",mainDelegate.CurrDictType]] == nil){
		NSMutableDictionary *old_dict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
		if(nil == old_dict){
			old_dict = [[NSMutableDictionary alloc] initWithCapacity:0];
		}
		[old_dict setObject:@"0" forKey:[NSString stringWithFormat:@"%d",mainDelegate.CurrDictType]];
		[old_dict writeToFile:filePath atomically:YES];
		if(old_dict)
			[old_dict release];
		mp3done = NO;
	}else if([[dict objectForKey: [NSString stringWithFormat:@"%d",mainDelegate.CurrDictType]] isEqualToString:@"0"]){
		mp3done = NO;
	}else{
		mp3done = YES;
	}
	if(dict)
		[dict release];
	//Draw custom tableview
	mainDelegate.PhaseCount = mainDelegate.CurrPhaseIdx + 1;
	
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg_main_green.png"]];
    self.view.backgroundColor = background;
	if(background)
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

//	//Button for subscribing notifications
//	NavigationButton *btnNotification = [[NavigationButton alloc] init];
//	[btnNotification setTitle:@"提 醒" forState:UIControlStateNormal];
//    [btnNotification addTarget:self action:@selector(subscribeNotification) forControlEvents:UIControlEventTouchUpInside];
//    //定制自己的风格的  UIBarButtonItem
//    UIBarButtonItem* notificationBtnItem = [[UIBarButtonItem alloc] initWithCustomView:btnNotification];
//    [self.navigationItem  setRightBarButtonItem:notificationBtnItem];
//    [notificationBtnItem release];
//    [btnNotification release];
	
    [loadingIcon stopAnimating];
}

- (void)subscribeNotification{
	
	notifyViewController = [[notificationTestViewController alloc] initWithNibName:@"notificationViewController" bundle:nil];
	[notifyViewController setDelegate:self];
	[self presentModalViewController:notifyViewController animated:YES];
}

-(void) notificationViewWillCancel{
	[notifyViewController dismissModalViewControllerAnimated:YES];
}
-(void) notificationViewWillConfirm{
	
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[super dealloc];
	if(myTableView)
		[myTableView release];
	[notifyViewController release];
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
	NSString *dbDir = [bookDir stringByAppendingString:@".db"];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:dbDir] && mp3done)
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
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	
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
	NSString *dbDir = [bookDir stringByAppendingString:@".db"];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:dbDir]){
		//Judge if its size is zero
		NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:dbDir error:nil];
		
		NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
		long long fileSize = [fileSizeNumber longLongValue];
				
		if(0 == fileSize){
			[[NSFileManager defaultManager] removeItemAtPath:dbDir error:nil];
		}
		
	}
		
	if(indexPath.row ==mainDelegate.PhaseCount && (![[NSFileManager defaultManager] fileExistsAtPath:dbDir] || mp3done == NO)){
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
		
		UILabel *hint1 = [[UILabel alloc] initWithFrame:CGRectMake(110, 45, 240, 30)];
		hint1.textColor = [UIColor lightTextColor];
		hint1.font = [UIFont systemFontOfSize:13];
		hint1.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview: hint1];
		if(hint1)
			[hint1 release];
		
		NSMutableString* tmp = [bookIcon mutableCopy];
		NSRange range = [bookIcon rangeOfString:@"."];
		
		if(!hasPaid){
			cell.userInteractionEnabled = NO;
			hint1.text = @"购买后支持离线背诵单词";
			[tmp insertString:@"_none" atIndex: range.location];
		}else{
			cell.userInteractionEnabled = YES;
			if(isDownloading)
				hint1.text = @"点击取消下载";
			else{
				if([[NSFileManager defaultManager] fileExistsAtPath:dbDir] && mp3done == NO){
					hint1.text = @"下载离线音频";
					[tmp insertString:@"_voice" atIndex: range.location];
				}else{
					hint1.text = @"下载离线词库和音频";
					[tmp insertString:@"_all" atIndex: range.location];
				}
			}
		}
		bookIcon = [tmp copy];
		
		UIImageView *iconImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed: bookIcon]];
		[iconImage setFrame: CGRectMake(10, 10, 80, 80)];
		[cell.contentView addSubview: iconImage];
		if(iconImage)
			[iconImage release];
		downloadCell = cell;
		return  cell;
	}
    
    UIImageView *splitter = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_item.png"]];
    [splitter setFrame: CGRectMake(0, 102, 320, 2)];
    [cell.contentView addSubview: splitter];
	if(splitter)
		[splitter release];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_item.png"]];
	
    UIImageView *iconImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_book_addnew_n.png"]];
	[iconImage setFrame: CGRectMake(10, 10, 80, 80)];
	[cell.contentView addSubview: iconImage];
	if(iconImage)
		[iconImage release];
	UILabel *hint1 = [[UILabel alloc] initWithFrame:CGRectMake(110, 20, 150, 30)];
	hint1.textColor = [UIColor whiteColor];
	hint1.text = [@"阶段" stringByAppendingString: [NSString stringWithFormat:@"%d", (indexPath.row+1)]];
	hint1.font = [UIFont systemFontOfSize:14];
	hint1.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview: hint1];
	if(hint1)
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
	if(hint2)
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
	if(detailViewController)
		[detailViewController release];
}

- (IBAction)showDownloadActionSheet:(id)sender{
	LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];
	NSArray *StoreFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *DoucumentsDirectiory = [StoreFilePath objectAtIndex:0];
	NSString *bookDir = [DoucumentsDirectiory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", mainDelegate.CurrDictType]];
	NSString *dbDir = [bookDir stringByAppendingString:@".db"];
	UIActionSheet *downloadInfoSheet;
	if([[NSFileManager defaultManager] fileExistsAtPath:dbDir] && mp3done == NO){
		downloadInfoSheet = [[UIActionSheet alloc] initWithTitle:@"下载选项" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"下载离线音频(大约15M)",nil];
	}else{
		downloadInfoSheet = [[UIActionSheet alloc] initWithTitle:@"下载选项" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"仅词汇(大约5MB)",@"词汇＋音频(大约20MB)",nil];
	}
	downloadInfoSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[downloadInfoSheet showInView:self.view];
	if(downloadInfoSheet)
		[downloadInfoSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];
	NSArray *StoreFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *DoucumentsDirectiory = [StoreFilePath objectAtIndex:0];
	NSString *bookDir = [DoucumentsDirectiory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", mainDelegate.CurrDictType]];
	NSString *dbDir = [bookDir stringByAppendingString:@".db"];
	
	if((buttonIndex == 2 && ![[NSFileManager defaultManager] fileExistsAtPath:dbDir]) || ([[NSFileManager defaultManager] fileExistsAtPath:dbDir] && buttonIndex == 1))
		return;
	if(buttonIndex == 0){
		//Download words only
		if([[NSFileManager defaultManager] fileExistsAtPath:dbDir])
			isDataWithMusic = YES;
		else
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
				if(downloadProgress)
					[downloadProgress release];
				downloadProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
				downloadProgress.progress = 0.0;
				downloadProgress.frame = CGRectMake(110, 30, 150, 30);
				if(downloadProgress)
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
	//download user data
	for(int i = 0; i < mainDelegate.PhaseCount; i++){
		//write phase data to plist
		NSArray *StoreFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *DoucumentsDirectiory = [StoreFilePath objectAtIndex:0];
		NSString *bookDir = [DoucumentsDirectiory stringByAppendingPathComponent:mainDelegate.CurrWordBookID];
		NSString *phaseDir = [bookDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%d",i]];
		NSString *filePath = [phaseDir stringByAppendingPathComponent:@"LangLibWordBookPhaseInfo.plist"];
		//Filter & Write to a plist
		NSString *phaseUserDataDir = [phaseDir stringByAppendingPathComponent:@"LangLibPhaseUserData.plist"];
		NSString *uploadUserDataDir = [phaseDir stringByAppendingPathComponent:@"uploadUserData.plist"];
		
		if([[NSFileManager defaultManager] fileExistsAtPath:filePath] && [[NSFileManager defaultManager] fileExistsAtPath:phaseUserDataDir]){
			continue;
		}
		
		NSDictionary *reqDict = [NSDictionary dictionaryWithObjectsAndKeys:
								 mainDelegate.CurrUserID, @"userID",
								 mainDelegate.CurrWordBookID, @"wordBookID",
								 [NSString stringWithFormat:@"%d", i], @"phaseIdx",
								 nil];
		
		NSString* reqString = [NSString stringWithString:[reqDict JSONRepresentation]];
		NSURL *url = [NSURL URLWithString:@"http://www.langlib.com/webservices/mobile/ws_mobilewordbook.asmx/ListSchedule"];
		__block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
		[request addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"];
		[request addRequestHeader:@"Content-Type" value:@"application/json"];
		[request appendPostData:[reqString dataUsingEncoding:NSUTF8StringEncoding]];
		[request setDelegate:self];
		[request setCompletionBlock:^{
			LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];
			// Use when fetching text data
			NSString *responseString = [request responseString];
			NSDictionary* responseDict = [responseString JSONValue];
			
			
			mainDelegate.ScheduleList = (NSMutableArray *) [responseDict objectForKey:@"d"];
			
			//create phaseDir
			NSError *error;
			if (![[NSFileManager defaultManager] fileExistsAtPath:phaseDir]){
				[[NSFileManager defaultManager] createDirectoryAtPath: phaseDir withIntermediateDirectories:YES attributes:nil error:&error];
			}
			
			//Compare then set the value
			NSMutableArray* oldScheduleList;
			if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
				//load file and update the value for ScheduleList
				oldScheduleList = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
				for(NSDictionary* oldData in oldScheduleList){
					for(NSMutableDictionary* newData in mainDelegate.ScheduleList){
						if([[newData objectForKey:@"CDate"] isEqualToString:[oldData objectForKey:@"CDate"]]){
							NSMutableArray* newCompleteArray = [newData objectForKey:@"NL"];
							NSArray* oldCompleteArray = [oldData objectForKey:@"NL"];
							//compare
							for(NSMutableDictionary* newCompleteDict in newCompleteArray){
								for(NSDictionary* oldCompleteDict in oldCompleteArray){
									if(([oldCompleteDict objectForKey:@"LID"] == [newCompleteDict objectForKey:@"LID"]) && ([[oldCompleteDict objectForKey:@"C"] boolValue] != [[newCompleteDict objectForKey:@"C"] boolValue])){
										[newCompleteDict setValue:[NSNumber numberWithBool:YES] forKey:@"C"];
										break;
									}
								}
							}
							//Switch to OL
							newCompleteArray = [newData objectForKey:@"OL"];
							oldCompleteArray = [oldData objectForKey:@"OL"];
							for(NSMutableDictionary* newCompleteDict in newCompleteArray){
								for(NSDictionary* oldCompleteDict in oldCompleteArray){
									if(([oldCompleteDict objectForKey:@"LID"] == [newCompleteDict objectForKey:@"LID"]) && ([[oldCompleteDict objectForKey:@"C"] boolValue] != [[newCompleteDict objectForKey:@"C"] boolValue])){
										[newCompleteDict setValue:[NSNumber numberWithBool:YES] forKey:@"C"];
										break;
									}
								}
							}
							break;
						}
					}
				}
			}
			[mainDelegate.ScheduleList writeToFile:filePath atomically: YES];
		}];
		[request startAsynchronous];
		
		//2 fetch familarity data
		NSDictionary *reqDict2 = [NSDictionary dictionaryWithObjectsAndKeys:
								  mainDelegate.CurrUserID, @"userID",
								  mainDelegate.CurrWordBookID, @"dictID",
								  [NSString stringWithFormat:@"%d", i], @"phaseIdx",
								  nil];
		
		NSString* reqString2 = [NSString stringWithString:[reqDict2 JSONRepresentation]];
		NSURL *url2 = [NSURL URLWithString:@"http://www.langlib.com/webservices/mobile/ws_mobilewordbook.asmx/FetchAllWordInfo"];
		__block ASIHTTPRequest *request2 = [ASIHTTPRequest requestWithURL:url2];
		[request2 addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"];
		[request2 addRequestHeader:@"Content-Type" value:@"application/json"];
		[request2 appendPostData:[reqString2 dataUsingEncoding:NSUTF8StringEncoding]];
		[request2 setCompletionBlock:^{
			NSString *responseString = [request2 responseString];
			NSDictionary* responseDict = [responseString JSONValue];
			NSMutableArray* newUserData = (NSMutableArray*)[responseDict objectForKey:@"d"];
			//Modify some keys
			NSMutableArray* modifiedUserData = [[NSMutableArray alloc] init];
			for(NSMutableDictionary* dict in newUserData){
				NSMutableDictionary* tmpDict = [[NSMutableDictionary alloc] init];
				[tmpDict setObject:[dict objectForKey:@"F"] forKey:@"F"];
				[tmpDict setObject:[dict objectForKey:@"L"] forKey:@"LID"];
				[tmpDict setObject:[dict objectForKey:@"W"] forKey:@"WID"];
				[modifiedUserData addObject:tmpDict];
				if(tmpDict)
					[tmpDict release];
			}
			if([[NSFileManager defaultManager] fileExistsAtPath:uploadUserDataDir]){
				NSArray* toUploadData = [[NSArray alloc] initWithContentsOfFile:uploadUserDataDir];
				for(NSDictionary* upload in toUploadData){
					for(NSMutableDictionary* toModify in modifiedUserData){
						if([[toModify objectForKey:@"WID"] isEqualToString:[upload objectForKey:@"W"]]){
							[toModify setValue:[upload objectForKey:@"F"] forKey:@"F"];
						}
					}
				}
			}
			[modifiedUserData writeToFile:phaseUserDataDir atomically:YES];
			if(modifiedUserData)
				[modifiedUserData release];
		}];
		[request2 setFailedBlock:^{
			[loadingIcon stopAnimating];
		}];
		[request2 startAsynchronous];
	}
	
	//if isDownloading, disable other UI interaction;
	if(isDataWithMusic){
		//Music + Words
		NSString* downloadFilePath;
		//Example
		downloadFilePath = [NSString stringWithFormat:@"http://www.langlib.com/mobiledb/%d.zip",mainDelegate.CurrDictType];
		NSURL *url = [NSURL URLWithString: downloadFilePath];
		NSArray *StoreFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *DoucumentsDirectiory = [StoreFilePath objectAtIndex:0];
		NSString *bookDir = [DoucumentsDirectiory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", mainDelegate.CurrDictType]];
		NSString *dbDir = [bookDir stringByAppendingString:@".db"];
		NSString *dbZipDir = [bookDir stringByAppendingString:@".zip"];
		//Don't need to download
		if([[NSFileManager defaultManager] fileExistsAtPath:dbDir]){
			[self performSelector:@selector(fetchMp3Data)];
			return;
		}
		downloadRequest = [ASIHTTPRequest requestWithURL:url];
		[downloadRequest setDownloadDestinationPath:dbZipDir];
		[downloadRequest setCompletionBlock:^{
			//unzip zip to db
			ZipArchive *zipArchive = [[ZipArchive alloc] init];
			if([[NSFileManager defaultManager] fileExistsAtPath:dbZipDir]){
				[zipArchive UnzipOpenFile:dbZipDir];
				[zipArchive UnzipFileTo:DoucumentsDirectiory overWrite:YES];
				[zipArchive UnzipCloseFile];
				if(zipArchive)
					[zipArchive release];
				[[NSFileManager defaultManager] removeItemAtPath:dbZipDir error:nil];
				[self performSelector:@selector(fetchMp3Data)];
			}
			[downloadRequest release];
			downloadRequest = nil;
		}];
		[downloadRequest setFailedBlock:^{
			isDownloading = NO;
			[mainDelegate showNetworkFailed];
			[myTableView reloadData];
			[downloadRequest clearDelegatesAndCancel];
			[downloadRequest release];
			downloadRequest = nil;
		}];
		[downloadRequest startAsynchronous];
	}else{
		//Words ONLY
		NSString* downloadFilePath;
		//Example
		downloadFilePath = [NSString stringWithFormat:@"http://www.langlib.com/mobiledb/%d.zip",mainDelegate.CurrDictType];
		NSURL *url = [NSURL URLWithString: downloadFilePath];
		//assume db.dir
		NSArray *StoreFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *DoucumentsDirectiory = [StoreFilePath objectAtIndex:0];
		NSString *bookDir = [DoucumentsDirectiory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", mainDelegate.CurrDictType]];
		NSString *dbZipDir = [bookDir stringByAppendingString:@".zip"];
		downloadRequest = [ASIHTTPRequest requestWithURL:url];
		[downloadRequest setDownloadDestinationPath:dbZipDir];
		[downloadRequest setDownloadProgressDelegate: downloadProgress];
		[downloadRequest setCompletionBlock:^{
			//Done then reload tableview
			//Set downloadCell nil
			//Release downloadProgress
			//Reset isDownloading
			isDownloading = NO;
			downloadCell = nil;
			//Notify user successful
			[mainDelegate showDownloadSuccess];
			//unzip zip to db
			if([[NSFileManager defaultManager] fileExistsAtPath:dbZipDir]){
				ZipArchive *zipArchive = [[ZipArchive alloc] init];
				[zipArchive UnzipOpenFile:dbZipDir];
				[zipArchive UnzipFileTo:DoucumentsDirectiory overWrite:YES];
				[zipArchive UnzipCloseFile];
				if(zipArchive)
					[zipArchive release];
				[[NSFileManager defaultManager] removeItemAtPath:dbZipDir error:nil];
			}
			[myTableView reloadData];
			[downloadRequest release];
			downloadRequest = nil;
		}];
		[downloadRequest setFailedBlock:^{
			isDownloading = NO;
			[mainDelegate showNetworkFailed];
			[myTableView reloadData];
			[downloadRequest clearDelegatesAndCancel];
			[downloadRequest release];
			downloadRequest = nil;
		}];
		[downloadRequest startAsynchronous];
	}
}

- (void)fetchMp3Data{
	if(downloadQueue){
		[downloadQueue release];
		downloadQueue = nil;
	}
	downloadQueue = [ASINetworkQueue queue];
	[downloadQueue setDelegate: self];
	[downloadQueue setDownloadProgressDelegate:downloadProgress];
	[downloadQueue setQueueDidFinishSelector:@selector(downloadQueueFinished)];
	//If one file failed, cancel all operations
	[downloadQueue setRequestDidFailSelector:@selector(downloadQueueFailed:)];
	[downloadQueue setShouldCancelAllRequestsOnFailure:NO];
	//fetch mp3 data
	LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];
	NSArray *StoreFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *DoucumentsDirectiory = [StoreFilePath objectAtIndex:0];
	NSString *bookDir = [DoucumentsDirectiory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", mainDelegate.CurrDictType]];
	NSString *dbDir = [bookDir stringByAppendingString:@".db"];
	sqlite3* database;
	sqlite3_stmt *statement;
	if (sqlite3_open([dbDir UTF8String], &database)==SQLITE_OK) {
		const char *selectSql="select WordProto from WordMain";
		if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK) {
		}
		while (sqlite3_step(statement)==SQLITE_ROW) {
			NSString *WordProto=[[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
			//Create request&Add to queue
			NSString* mp3string = [NSString stringWithFormat:@"http://www.langlib.com/voice/%@/%@.mp3",[WordProto substringToIndex:1], [[WordProto stringByReplacingOccurrencesOfString:@"*" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
			NSURL* mp3url = [NSURL URLWithString:mp3string];
			//create mp3 path
			NSArray *StoreFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *DoucumentsDirectiory = [StoreFilePath objectAtIndex:0];
			NSString *bookmp3 = [DoucumentsDirectiory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", mainDelegate.CurrDictType]];
			[[NSFileManager defaultManager] createDirectoryAtPath:bookmp3 withIntermediateDirectories:YES attributes:nil error:nil];
			NSString *mp3dir = [bookmp3 stringByAppendingPathComponent:[WordProto stringByAppendingString:@".mp3"]];
			if(![[NSFileManager defaultManager] fileExistsAtPath:mp3dir]){
				ASIHTTPRequest *mp3Request = [ASIHTTPRequest requestWithURL:mp3url];
				[mp3Request setDownloadDestinationPath:mp3dir];
				[downloadQueue addOperation:mp3Request];
			}
		}
		//Assume mp3done = YES;
		mp3done = YES;
		[downloadQueue go];
		sqlite3_close(database);
	}

}

- (void)stopDownloadData{
	if(downloadRequest){
		if([downloadRequest respondsToSelector:@selector(clearDelegatesAndCancel)]){
			if(![downloadRequest complete])
				[downloadRequest clearDelegatesAndCancel];
		}
	}
	if(isDataWithMusic){
		mp3done = NO;
		downloadCanceled = YES;
		if(downloadQueue){
			if([downloadQueue respondsToSelector:@selector(cancelAllOperations)])
				[downloadQueue cancelAllOperations];
		}
	}
}

- (void)downloadQueueFinished{
	
	[downloadQueue cancelAllOperations];
	[downloadQueue release];
	downloadQueue = nil;
	
	LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];
	if(mp3done == NO && isDownloading){
		isDownloading = NO;
		[mainDelegate showNetworkFailed];
		//write to plist to mark not done for mp3
		NSArray *StoreFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *DoucumentsDirectiory = [StoreFilePath objectAtIndex:0];
		NSString *filePath = [DoucumentsDirectiory stringByAppendingPathComponent:@"download_mark.plist"];
		NSDictionary* dict = [[NSDictionary alloc] initWithObjects:[[NSArray alloc] initWithObjects:@"0", nil] forKeys: [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%d", mainDelegate.CurrDictType], nil]];
		[dict writeToFile:filePath atomically:YES];
		if(dict)
			[dict release];
		if(downloadCanceled){
			downloadCanceled = NO;
			[mainDelegate showNetworkFailed];
		}
		[myTableView reloadData];
		return;
	}else if(isDownloading && mp3done == YES){
		isDownloading = NO;
		downloadCell = nil;
		//Notify user successful
		[mainDelegate showDownloadSuccess];
		mp3done = YES;
		//write to plist to mark done for mp3
		NSArray *StoreFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *DoucumentsDirectiory = [StoreFilePath objectAtIndex:0];
		NSString *filePath = [DoucumentsDirectiory stringByAppendingPathComponent:@"download_mark.plist"];
		NSDictionary* dict = [[NSDictionary alloc] initWithObjects:[[NSArray alloc] initWithObjects:@"1", nil] forKeys: [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%d", mainDelegate.CurrDictType], nil]];
		[dict writeToFile:filePath atomically:YES];
		if(dict)
			[dict release];
		[myTableView reloadData];
	}
}

- (void)downloadQueueFailed: (ASIHTTPRequest *)request{
	if(!request.error.code == ASIUnableToCreateRequestErrorType){
		mp3done = NO;
	}
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
