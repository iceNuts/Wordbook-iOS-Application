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
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "sqlite3.h"
#import "ZipArchive.h"
#import "NavigationButton.h"
#import "notificationTestViewController.h"


@interface PhaseController : UIViewController<UITableViewDelegate, UITableViewDataSource,UIActionSheetDelegate, notificationViewControllerDelegate>{
	UITableView *myTableView;
	UIActivityIndicatorView *loadingIcon;
	UITableViewCell* downloadCell;
	UIProgressView* downloadProgress;
	BOOL isDownloading;
	BOOL isDataWithMusic;
	BOOL downloadCanceled;
	ASIHTTPRequest *downloadRequest;
	ASINetworkQueue *downloadQueue;
	id notifyViewController;
	BOOL mp3done;
}
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingIcon;
- (IBAction)showDownloadActionSheet:(id)sender;
- (void)downloadData;
- (void)stopDownloadData;
- (void)downloadQueueFinished;
- (void)downloadQueueFailed:(ASIHTTPRequest *)request;
- (void)fetchMp3Data;
- (void)subscribeNotification;
@end
