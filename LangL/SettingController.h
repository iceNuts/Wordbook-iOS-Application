//
//  SettingController.h
//  LangL
//
//  Created by bill on 12-8-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingController : UIViewController<UITableViewDelegate, UITableViewDataSource>{
    UITableView *settingView;
}


@property (nonatomic, retain) UITableView *settingView;

@end
