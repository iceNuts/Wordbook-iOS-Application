//
//  ConfigSortParamController.h
//  LangL
//
//  Created by king bill on 11-9-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfigSortParamController : UIViewController<UITableViewDelegate, UITableViewDataSource>{
    UITableView *selectSortView; 
}

@property (nonatomic, retain) UITableView *selectSortView;

@end
