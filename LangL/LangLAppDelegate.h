//
//  LangLAppDelegate.h
//  LangL
//
//  Created by king bill on 11-8-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreateWordBookParams.h"

@class LoginController;

@interface LangLAppDelegate : NSObject <UIApplicationDelegate, UINavigationControllerDelegate>
{
    NSString *CurrUserID;
    NSString *CurrWordBookID;
    NSInteger CurrPhaseIdx;
    NSInteger QuizListID;
    NSInteger CurrDictType;
    NSInteger CurrItemIdx;
    NSInteger CurrListID;
    NSInteger CurrWordIdx;
    bool NeedReloadSchedule;
    NSMutableArray* ScheduleList;
    NSMutableArray* WordList;
    NSMutableArray* WordBookList;
    NSMutableArray* QuizList;
    NSInteger CurrSortType;
    NSMutableArray* filteredArr;
    bool enableFilter;
    CreateWordBookParams *createParams;
    NSArray *ProductPriceArr;
    bool AutoVoice;
    bool AutoNextWord;
    bool AutoFamiliarity;
}
@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) LoginController *loginController;
@property (nonatomic, retain) NSString *CurrUserID;
@property (nonatomic, retain) NSString *CurrWordBookID;
@property (nonatomic, retain) NSArray *ProductPriceArr;
@property NSInteger CurrPhaseIdx;
@property NSInteger CurrItemIdx;
@property NSInteger CurrListID;
@property NSInteger CurrDictType;
@property NSInteger CurrWordIdx;
@property NSInteger CurrSortType;
@property NSInteger QuizListID;
@property bool NeedReloadSchedule;
@property bool enableFilter;
@property (nonatomic, retain)  NSMutableArray* ScheduleList;
@property (nonatomic, retain)  NSMutableArray* WordList;
@property (nonatomic, retain)  NSMutableArray* WordBookList;
@property (nonatomic, retain)  NSMutableArray* filteredArr;
@property (nonatomic, retain)  NSMutableArray* QuizList;
@property (nonatomic, retain)  CreateWordBookParams* createParams;
@property bool AutoVoice;
@property bool AutoNextWord;
@property bool AutoFamiliarity;
-(NSString *)GetDictNameByType:(NSInteger) dictType;
-(NSString *)GetFamiliarityName:(NSInteger) familiarity;
-(void)showNetworkFailed;
@end
