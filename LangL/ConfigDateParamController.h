//
//  ConfigDateParamController.h
//  LangL
//
//  Created by king bill on 11-9-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfigDateParamController : UIViewController<UITableViewDelegate, UITableViewDataSource>{
    UITableView *selectDateView; 
    NSDateFormatter *dateFormatter;
    NSDate *currDate;
    NSString *beginDateStr;
}

@property (nonatomic, retain) UITableView *selectDateView;
@property (nonatomic, retain) NSDate *currDate;
@property (nonatomic, retain) NSString *beginDateStr;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;

@end
