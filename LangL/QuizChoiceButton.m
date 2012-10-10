//
//  QuizChoiceButton.m
//  LangL
//
//  Created by king bill on 12-5-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "QuizChoiceButton.h"

@implementation QuizChoiceButton
@synthesize wordText;
@synthesize isCorrect;
@synthesize correctMark;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
            
        wordText = [[UILabel alloc] initWithFrame: CGRectMake(25, 10, 225, 25)];
        wordText.textColor = [UIColor whiteColor];
        wordText.font = [UIFont systemFontOfSize:18]; 
        wordText.backgroundColor = [UIColor clearColor];
        [self addSubview: wordText];
     
        correctMark = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@""]];
        correctMark.frame = CGRectMake(250, 10, 25, 25);
        [self addSubview: correctMark];        

        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)SetIndexLabel:(NSInteger)index
{
    
    UILabel* indexLabel = [[UILabel alloc] initWithFrame: CGRectMake(5, 10, 25, 25)];
    indexLabel.text = [NSString stringWithFormat:@"%d.", index];
    indexLabel.textColor = [UIColor whiteColor];
    indexLabel.font = [UIFont systemFontOfSize:18]; 
    indexLabel.backgroundColor = [UIColor clearColor];
    [self addSubview: indexLabel];
    [indexLabel release];
    
    self.tag = index;
}


- (void)SetWordText:(NSString *)text
{
    wordText.text = text;    
}

- (void)ResetToDef
{
    [correctMark setImage:[UIImage imageNamed:@""]];
   /* UIImage *image1 = [UIImage imageNamed:@"butn_normal.png"];
    UIImage *stretchImage1 =         
    [image1 stretchableImageWithLeftCapWidth:14.0 topCapHeight:0.0];*/
    [self setBackgroundImage:[UIImage imageNamed:@"butn_QuizNormal.png"] forState:  UIControlStateNormal];
    self.alpha = 1;
}

- (void)SetImageByCorrect
{
    if (isCorrect == 1)
    {
      [correctMark setImage:[UIImage imageNamed:@"ico_correct.png"]];
     /*     UIImage *image1 = [UIImage imageNamed:@"butn_correct.png"];
        UIImage *stretchImage1 =         
        [image1 stretchableImageWithLeftCapWidth:14.0 topCapHeight:0.0];*/
        [self setBackgroundImage:[UIImage imageNamed:@"butn_QuizSelect.png"] forState:  UIControlStateNormal];
    }
    else 
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:1.0];
        self.alpha = 0;
        [UIView commitAnimations];
    }
}



@end
