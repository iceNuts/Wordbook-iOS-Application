//
//  ViewWordController.h
//  LangL
//
//  Created by king bill on 11-8-17.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditNoteController.h"
#import "GoToWordController.h"
#import "AVFoundation/AVAudioPlayer.h"
#import "sqlite3.h"

@interface ViewWordController : UIViewController<EditNoteModalDelegate, UIAlertViewDelegate> {
    UILabel *wordProto;
    UILabel *wordMeaning;
    UIButton *btnViewPrevWord;
    UIWebView *wordSymbol;
    UIWebView *extraData;
    NSMutableString *exampleSenHtml;
    NSMutableString *englishExpHtml;
    NSString *htmlPrefix;
    AVAudioPlayer *player;
    bool isPlaying;
    UIButton *btnShowCHN;
    UIButton *btnShowEngExp;
    UIButton *btnShowExpSen;
    UIButton *btnEditNote;
    UIButton *btnViewNextWord;
    UIButton *btnF0;
    UIButton *btnF1;
    UIButton *btnF2;
    UIButton *btnF3;
    UIButton *btnF4;
    UILabel *lblFamiliarityName;
    UIView *topView;
    BOOL listStatusMarked;
}
@property BOOL listStatusMarked;
@property (nonatomic, retain) IBOutlet UIView *topView;
@property (nonatomic, retain) IBOutlet UIWebView *wordSymbol;
- (IBAction)btnPlaySoundTouched:(id)sender;
@property (nonatomic, retain) IBOutlet UIButton *btnShowCHN;
- (IBAction)btnShowCHNTouched:(id)sender;
@property (nonatomic, retain) IBOutlet UIButton *btnShowEngExp;
- (IBAction)btnShowEngExpTouched:(id)sender;
@property (nonatomic, retain) IBOutlet UIButton *btnShowExpSen;
- (IBAction)btnShowExpSenTouched:(id)sender;
@property (nonatomic, retain) IBOutlet UIButton *btnEditNote;
- (IBAction)btnEditNoteTouched:(id)sender;
- (IBAction)btnViewPrevWordTouched:(id)sender;
@property (nonatomic, retain) IBOutlet UIButton *btnViewNextWord;
- (IBAction)btnViewNextWordTouched:(id)sender;
@property (nonatomic, retain) IBOutlet UIButton *btnF0;
@property (nonatomic, retain) IBOutlet UIButton *btnF1;
@property (nonatomic, retain) IBOutlet UIButton *btnF2;
@property (nonatomic, retain) IBOutlet UIButton *btnF3;
@property (nonatomic, retain) IBOutlet UIButton *btnF4;
- (IBAction)btnFamiliarityChanged:(id)sender;
@property (nonatomic, retain) IBOutlet UILabel *lblFamiliarityName;

@property (nonatomic, retain) IBOutlet UILabel *wordMeaning;
@property (nonatomic, retain) IBOutlet UIButton *btnViewPrevWord;
@property (nonatomic, retain) IBOutlet UILabel *wordProto;
-(void) DisplayCurrWord;

@property (nonatomic, retain) IBOutlet UIWebView *extraData;

@property (nonatomic, retain) NSMutableString *exampleSenHtml;
@property (nonatomic, retain) NSMutableString *englishExpHtml;
@property (nonatomic, retain) NSString *htmlPrefix;
@property (nonatomic, retain) AVAudioPlayer *player;
- (void)SetFamiliarityStar:(NSInteger)familiarity ;
@property bool isPlaying;
@end
