//
//  WBListController.h
//  LangL
//
//  Created by king bill on 11-8-15.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h> 
#import "PhaseController.h"
#import "EGORefreshTableHeaderView.h"
#import "Authorize.h"
#import "SocialAuthorize.h"

//test
#import "testViewController.h"

//Add new pull to refresh feature

@interface WBListController : UIViewController<UITableViewDelegate, UITableViewDataSource, SKProductsRequestDelegate,SKPaymentTransactionObserver, EGORefreshTableHeaderDelegate>{
    UITableView *myTableView;
	EGORefreshTableHeaderView *_refreshHeaderView;	
}

@property (nonatomic, retain) UITableView *myTableView;
@property (nonatomic, retain) UIAlertView *loadingAlert;
-(void)recordTransaction;
-(void)provideContent;
- (void) completeTransaction: (SKPaymentTransaction *)transaction ;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;
- (NSString *)encode:(const uint8_t *)input length:(NSInteger)length;


-(void)showLoadingAlert;
-(void)hideLoadingAlert;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end