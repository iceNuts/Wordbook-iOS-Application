//
//  PhaseSelectionController.h
//  LangL
//
//  Created by king bill on 11-8-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PhaseSelectionController : UIViewController<UITableViewDelegate, UITableViewDataSource>{
    UITableView *familiarityView;
    NSArray *familiarityArr;
    UILabel *loadingHint;
    UILabel *beginDate;
    UILabel *endDate;
    UILabel *totalWords;
    UILabel *currTitle;
    UIImageView *headerView;
}
@property (nonatomic, retain) UITableView *familiarityView;
@property (nonatomic, retain) NSArray *familiarityArr;
@property (nonatomic, retain) IBOutlet UILabel *loadingHint;
@property (nonatomic, retain) IBOutlet UILabel *currTitle;
@property (nonatomic, retain) IBOutlet UIImageView *headerView;

@property (nonatomic, retain) IBOutlet UILabel *totalWords;

@end
