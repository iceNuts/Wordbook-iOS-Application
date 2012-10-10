//
//  ConfigTaskParamController.h
//  LangL
//
//  Created by king bill on 11-9-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfigTaskParamController : UIViewController<UITableViewDelegate, UITableViewDataSource>{
    UITableView *selectTaskView; 
}

@property (nonatomic, retain) UITableView *selectTaskView;

@end
