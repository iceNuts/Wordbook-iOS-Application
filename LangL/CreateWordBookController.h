//
//  CreateWordBookController.h
//  LangL
//
//  Created by king bill on 11-9-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateWordBookController : UIViewController<UITableViewDelegate, UITableViewDataSource>{
    UITableView *createParaView;
    UIAlertView *loadingAlert;
    NSDateFormatter *dateFormatter;
}

@property (nonatomic, retain) UITableView *createParaView;
@property (nonatomic, retain) UIAlertView *loadingAlert;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;

-(void)showLoadingAlert;
-(void)hideLoadingAlert;

@end
