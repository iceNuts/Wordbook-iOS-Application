//
//  ScheduleController.h
//  LangL
//
//  Created by king bill on 11-8-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface ScheduleController : UIViewController<UITableViewDelegate, UITableViewDataSource,EGORefreshTableHeaderDelegate>{
    UITableView *scheduleView;
    bool hasPaid;
    NSString *currDateStr;
    UIActivityIndicatorView *loadingIcon;
	EGORefreshTableHeaderView *_refreshHeaderView;
}

@property (nonatomic, retain) UITableView *scheduleView;
@property (nonatomic, retain) NSString *currDateStr;
@property (nonatomic) bool hasPaid;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingIcon;

@end
