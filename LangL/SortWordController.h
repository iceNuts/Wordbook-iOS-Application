//
//  SortWordController.h
//  LangL
//
//  Created by king bill on 11-9-7.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectWordSortDelegate;

@interface SortWordController : UIViewController<UITableViewDelegate, UITableViewDataSource>{
    UITableView *sortTypeView;
    NSArray *sortTypeArr;
    NSInteger currSortType;
    bool showUnfamilarWord;
    id <SelectWordSortDelegate> delegate;
    UIImageView *popHeader;
}

@property (nonatomic, retain) UITableView *sortTypeView;
@property (nonatomic, retain) NSArray *sortTypeArr;
@property NSInteger currSortType;
@property bool showUnfamilarWord;

@property (nonatomic, assign) id  delegate;
@property (nonatomic, retain) IBOutlet UIImageView *popHeader;

@end




@protocol SelectWordSortDelegate

- (void) sortWordController:(SortWordController *)sortWordController hasSelectSort:(bool) flag;

@end