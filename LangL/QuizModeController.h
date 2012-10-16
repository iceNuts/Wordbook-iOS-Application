//
//  QuizModeController.h
//  LangL
//
//  Created by king bill on 12-5-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuizChoiceButton.h"
#import "AVFoundation/AVAudioPlayer.h"
#import "sqlite3.h"

@interface QuizModeController : UIViewController<UIAlertViewDelegate>{
    NSDictionary *quizDict;
    NSTimer *timer;
    float currTimerCount;
    AVAudioPlayer *player;
    bool isPlaying;
    bool timerEnabled;
    BOOL listStatusMarked;
}

@property BOOL listStatusMarked;
@property (retain, nonatomic) IBOutlet UIButton *btnViewPrevWord;
@property (retain, nonatomic) IBOutlet UIButton *btnViewNextWord;
@property float currTimerCount;
- (IBAction)btnNextWord:(id)sender;
- (IBAction)btnPrevWord:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *lblWordProto;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingHint;

@property (nonatomic, retain) NSDictionary *quizDict;
@property (nonatomic, retain) NSTimer *timer;
@property (retain, nonatomic) IBOutlet UILabel *lblCurrFamiliarity;
@property (retain, nonatomic) IBOutlet UIView *choiceContainer;

@property (retain, nonatomic) IBOutlet UILabel *lblTimer;

@property (retain, nonatomic) IBOutlet UIButton *btnF0;
@property (retain, nonatomic) IBOutlet UIButton *btnF1;
@property (retain, nonatomic) IBOutlet UIButton *btnF2;
@property (retain, nonatomic) IBOutlet UIButton *btnF3;
@property (retain, nonatomic) IBOutlet UIButton *btnF4;
@property (nonatomic, retain) AVAudioPlayer *player;
@property bool isPlaying;
@property bool timerEnabled;
- (IBAction)btnFamiliarityChanged:(id)sender;
-(void) DisplayCurrWord;
- (void)SetFamiliarityStar:(NSInteger)familiarity;
- (IBAction)btnPlaySoundTouched:(id)sender;


@end
