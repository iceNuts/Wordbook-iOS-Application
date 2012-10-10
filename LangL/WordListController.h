//
//  WordListController.h
//  LangL
//
//  Created by king bill on 11-9-7.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WordListController : UIViewController<UITableViewDelegate, UITableViewDataSource>{
    UITableView *wordListView;
    UIActivityIndicatorView *loadingIcon;
    bool initLoad;
}

@property (nonatomic, retain) UITableView *wordListView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingIcon;
@property bool initLoad;
@end

