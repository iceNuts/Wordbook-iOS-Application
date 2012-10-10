//
//  QuizChoiceButton.h
//  LangL
//
//  Created by king bill on 12-5-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuizChoiceButton : UIButton {
    UILabel *wordText;
    UIImageView *correctMark;
    int isCorrect;
}

@property(nonatomic,retain) UILabel *wordText;
@property(nonatomic,retain) UIImageView *correctMark;
@property int isCorrect;
- (void)SetWordText:(NSString *)text;
- (void)SetIndexLabel:(NSInteger)index;
- (void)ResetToDef;
- (void)SetImageByCorrect;
@end
