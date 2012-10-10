//
//  DailyListExController.h
//  LangL
//
//  Created by king bill on 11-8-20.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DailyListExController : UIViewController<UITableViewDelegate, UITableViewDataSource>{
    UITableView *dailyListView;
    NSDictionary *dailyListDict;
}

@property (nonatomic, retain) UITableView *dailyListView;
@property (nonatomic, retain) NSDictionary *dailyListDict;

@end