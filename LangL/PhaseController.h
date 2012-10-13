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

@interface PhaseController : UIViewController<UITableViewDelegate, UITableViewDataSource,UIActionSheetDelegate>{
	UITableView *myTableView;
	UIActivityIndicatorView *loadingIcon;
	UITableViewCell* downloadCell;
	UIProgressView* downloadProgress;
	BOOL isDownloading;
	BOOL isDataWithMusic;
	ASIHTTPRequest *downloadRequest;
	ASINetworkQueue *downloadQueue;
}
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingIcon;
- (IBAction)showDownloadActionSheet:(id)sender;
- (void)bounceOutAnimationStopped;
- (void)downloadData;
- (void)stopDownloadData;
- (void)downloadQueueFinished;
- (void)downloadQueueFailed;
@end
