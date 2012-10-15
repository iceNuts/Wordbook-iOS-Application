//
//  PhaseController.h
//  LangL
//
//  Created by Zeng Li on 10/11/12.
//
//

#import <UIKit/UIKit.h>
#import "LangLAppDelegate.h"
#import "EGORefreshTableHeaderView.h"
#import "ScheduleController.h"
#import "Three20/Three20.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "sqlite3.h"
#import "ZipArchive.h"


@interface PhaseController : UIViewController<UITableViewDelegate, UITableViewDataSource,UIActionSheetDelegate>{
	UITableView *myTableView;
	UIActivityIndicatorView *loadingIcon;
	UITableViewCell* downloadCell;
	UIProgressView* downloadProgress;
	BOOL isDownloading;
	BOOL isDataWithMusic;
	BOOL downloadCanceled;
	ASIHTTPRequest *downloadRequest;
	ASINetworkQueue *downloadQueue;
	BOOL mp3done;
}
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingIcon;
- (IBAction)showDownloadActionSheet:(id)sender;
- (void)bounceOutAnimationStopped;
- (void)downloadData;
- (void)stopDownloadData;
- (void)downloadQueueFinished;
- (void)downloadQueueFailed:(ASIHTTPRequest *)request;
- (void)fetchMp3Data;
@end
