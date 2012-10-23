//
//  QuizModeController.m
//  LangL
//
//  Created by king bill on 12-5-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "QuizModeController.h"
#import "LangLAppDelegate.h"
#import "SBJson.h"
#import "ASIHTTPRequest.h"
#import "QuizChoiceButton.h"

@implementation QuizModeController
@synthesize btnViewPrevWord;
@synthesize btnViewNextWord;
@synthesize lblCurrFamiliarity;
@synthesize choiceContainer;
@synthesize lblTimer;
@synthesize btnF0;
@synthesize btnF1;
@synthesize btnF2;
@synthesize btnF3;
@synthesize btnF4;
@synthesize lblWordProto;
@synthesize loadingHint;
@synthesize quizDict;
@synthesize timer;
@synthesize currTimerCount;
@synthesize isPlaying;
@synthesize player;
@synthesize timerEnabled;
@synthesize listStatusMarked;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg_main_green.png"]];
    self.view.backgroundColor = background;
    [background release];
    
    QuizChoiceButton* choice1 = [[QuizChoiceButton alloc] initWithFrame:CGRectMake(10, 15, 280, 40)];
    QuizChoiceButton* choice2 = [[QuizChoiceButton alloc] initWithFrame:CGRectMake(10, 62, 280, 40)];
    QuizChoiceButton* choice3 = [[QuizChoiceButton alloc] initWithFrame:CGRectMake(10, 109, 280, 40)];
    QuizChoiceButton* choice4 = [[QuizChoiceButton alloc] initWithFrame:CGRectMake(10, 156, 280, 40)];
    QuizChoiceButton* choice5 = [[QuizChoiceButton alloc] initWithFrame:CGRectMake(10, 203, 280, 40)];
    [choice1 SetIndexLabel:1];
    [choice2 SetIndexLabel:2];
    [choice3 SetIndexLabel:3];
    [choice4 SetIndexLabel:4];
    [choice5 SetIndexLabel:5];
    [choice1 setHidden:YES];
    [choice2 setHidden:YES];
    [choice3 setHidden:YES];
    [choice4 setHidden:YES];
    [choice5 setHidden:YES];
    [choice5 SetWordText: @"我不知道"];
    [choiceContainer addSubview:choice1];
    [choiceContainer addSubview:choice2];
    [choiceContainer addSubview:choice3];
    [choiceContainer addSubview:choice4];
    [choiceContainer addSubview:choice5];
    
    [choice1 addTarget:self action: @selector(choiceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [choice2 addTarget:self action: @selector(choiceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [choice3 addTarget:self action: @selector(choiceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [choice4 addTarget:self action: @selector(choiceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [choice5 addTarget:self action: @selector(choiceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [choice1 release];
    [choice2 release];
    [choice3 release];
    [choice4 release];
    [choice5 release]; 
    lblTimer.textColor = [UIColor colorWithRed:255.0/255.0 green:246.0/255.0 blue:113.0/255.0 alpha:1];
    [lblTimer setHidden:YES];
    [lblWordProto setHidden:YES];
    lblWordProto.textColor = [UIColor colorWithRed:255.0/255.0 green:170.0/255.0 blue:0.0/255.0 alpha:1];

    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
    
    timerEnabled = NO;
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(onTimer) userInfo:nil repeats:YES]; 
    
    if (mainDelegate.QuizListID != mainDelegate.CurrListID)
    {    
        id wordIDs[mainDelegate.WordList.count];
        for (int x = 0; x < mainDelegate.WordList.count; x++)
            wordIDs[x] = [NSString stringWithString: [[mainDelegate.WordList objectAtIndex: x] objectForKey:@"WID"]];
        NSArray *wordIDArr = [NSArray arrayWithObjects:wordIDs count:mainDelegate.WordList.count];
				
		NSArray *StoreFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *DoucumentsDirectiory = [StoreFilePath objectAtIndex:0];
		NSString *bookDir = [DoucumentsDirectiory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", mainDelegate.CurrDictType]];
		NSString *dbDir = [bookDir stringByAppendingString:@".db"];
		
		mainDelegate.QuizList = [[NSMutableArray alloc] init];
		
		for(NSString* wordID in wordIDArr){
			NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
			//fetch data in db
			if([[NSFileManager defaultManager] fileExistsAtPath:dbDir]){
				sqlite3* database;
				sqlite3_stmt *statement;
				if (sqlite3_open([dbDir UTF8String], &database)==SQLITE_OK){
					NSString *tmp = [[@"'" stringByAppendingString:wordID] stringByAppendingString:@"'"];
					const char *selectSql= [[@"select * from QuizMode where WordID=" stringByAppendingString:tmp] cStringUsingEncoding:NSUTF8StringEncoding];
					if (sqlite3_prepare_v2(database, selectSql, -1, &statement, nil)==SQLITE_OK) {
					}
					while (sqlite3_step(statement)==SQLITE_ROW){
						//set dict & add it to array
						NSString *WordProto = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
						NSInteger WbType = mainDelegate.CurrDictType;
						NSInteger CorrectIdx;
						//now randomly sort words
						NSMutableArray *SubChoice = [[NSMutableArray alloc] init];
						int j = fabs(arc4random()%12);
						int hash[][4]={{2,3,4,5},{3,4,2,5},{5,4,3,2},{3,2,4,5},{4,2,5,3},{2,3,5,4},{5,2,4,3},{2,3,5,4},{2,5,3,4},{4,2,3,5},{5,3,2,4},{3,4,5,2},{2,5,4,3}};
						//put meaning into SubChoice
						for(int i = 0; i < 4; i++){
							NSString *mean = [[NSString alloc] initWithCString:(char *)sqlite3_column_text(statement, hash[j][i]) encoding:NSUTF8StringEncoding];
							[SubChoice addObject:mean];
							if(hash[j][i] == 2){
								CorrectIdx = i;
							}
						}
						[dict setObject:WordProto forKey:@"WordProto"];
						[dict setObject:[NSString stringWithFormat:@"%d",WbType] forKey:@"WbType"];
						[dict setObject:wordID forKey:@"WordID"];
						[dict setObject:SubChoice forKey:@"SubChoice"];
						[dict setObject:[NSString stringWithFormat:@"%d", CorrectIdx] forKey:@"CorrectIdx"];
						
					}
				}
				[mainDelegate.QuizList addObject:dict];
			}
		}
				
		mainDelegate.QuizListID = mainDelegate.CurrListID;
		[loadingHint stopAnimating];
		[self DisplayCurrWord];
	}
    else{
        [loadingHint stopAnimating];
        [self DisplayCurrWord];
    }
    
    listStatusMarked = NO;
    NSDictionary *singleDay = [mainDelegate.ScheduleList objectAtIndex:mainDelegate.CurrItemIdx - 1];    
    for (NSDictionary *singleList in [singleDay objectForKey:@"OL"])
    {
        if ([[singleList objectForKey:@"LID"] integerValue] == mainDelegate.CurrListID)
        {
            listStatusMarked = [[singleList objectForKey:@"C"] integerValue] == 1;
            break;
            
        }
    }
    for (NSDictionary *singleList in [singleDay objectForKey:@"NL"])
    {
        if ([[singleList objectForKey:@"LID"] integerValue] == mainDelegate.CurrListID)
        {
            listStatusMarked = [[singleList objectForKey:@"C"] integerValue] == 1;
            break;
            
        }
    }    
    
    UIImage *prevWordImage = [UIImage imageNamed:@"butn_arrow_left.png"];
    UIImageView *prevWordImageView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 2, 20, 24)];
    [prevWordImageView setImage:prevWordImage];
    UILabel *prevWordLabel = [[UILabel alloc] initWithFrame: CGRectMake(25, 0, 50, 24)];
    [prevWordLabel setText:@"上一词"];
    [prevWordLabel setFont:[UIFont systemFontOfSize:14]];
    prevWordLabel.textColor = [UIColor whiteColor];
    prevWordLabel.backgroundColor = [UIColor clearColor];
    [btnViewPrevWord addSubview:prevWordLabel];
    [btnViewPrevWord addSubview:prevWordImageView];
    [prevWordLabel release];
    [prevWordImageView release];
    
    UIImage *prevPressedImage = [UIImage imageNamed:@"butn_dot_press.png"];    
    // Make a stretchable image from the original image
    UIImage *stretchPressedImage =      
    [prevPressedImage stretchableImageWithLeftCapWidth:13.0 topCapHeight:8.0];
    [btnViewPrevWord setBackgroundImage:stretchPressedImage forState: UIControlStateHighlighted];
    
    UIImage *nextWordImage = [UIImage imageNamed:@"butn_arrow_right.png"];
    UIImageView *nextWordImageView = [[UIImageView alloc] initWithFrame:CGRectMake(77, 2, 20, 24)];
    [nextWordImageView setImage:nextWordImage];
    UILabel *nextWordLabel = [[UILabel alloc] initWithFrame: CGRectMake(25, 0, 50, 24)];
    [nextWordLabel setText:@"下一词"];
    [nextWordLabel setFont:[UIFont systemFontOfSize:14]];
    nextWordLabel.textColor = [UIColor whiteColor];
    nextWordLabel.backgroundColor = [UIColor clearColor];
    [btnViewNextWord addSubview:nextWordLabel];
    [btnViewNextWord addSubview:nextWordImageView];
    [nextWordLabel release];
    [nextWordImageView release];
    [btnViewNextWord setBackgroundImage:stretchPressedImage forState: UIControlStateHighlighted];
  
    
    UISwipeGestureRecognizer* leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    leftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [choiceContainer addGestureRecognizer:leftRecognizer];
    [leftRecognizer release];
    
    UISwipeGestureRecognizer* rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [choiceContainer addGestureRecognizer:rightRecognizer];
    [rightRecognizer release];

}

-(void) DisplayCurrWord
{
    timerEnabled = NO;
    [lblWordProto setHidden:NO];
    [lblTimer setHidden:NO];
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];     
    NSDictionary *currWord = [mainDelegate.WordList objectAtIndex: [[mainDelegate.filteredArr objectAtIndex: mainDelegate.CurrWordIdx] integerValue]];
    NSString *wordID = [currWord objectForKey:@"WID"];
    for (int i = 0; i <= mainDelegate.QuizList.count - 1; i ++)
    {
        quizDict = [mainDelegate.QuizList objectAtIndex:i];
        if ([wordID  isEqualToString:[quizDict objectForKey:@"WordID"]])
        {
            break;        
        }    
    }
      
    lblWordProto.text = [quizDict objectForKey:@"WordProto"];

    int correctIdx = [[quizDict objectForKey:@"CorrectIdx"] intValue];
    for (NSInteger i = 1; i <= 5; i ++)
    {
        QuizChoiceButton *currbutton = (QuizChoiceButton *)[choiceContainer viewWithTag:i];
        [currbutton setHidden:NO];
        [currbutton ResetToDef];
        if (correctIdx + 1 == currbutton.tag)
            currbutton.isCorrect = YES;
        else currbutton.isCorrect = NO;
        
        if (i <= 4)
            [currbutton SetWordText: [[quizDict objectForKey:@"SubChoice"] objectAtIndex: i - 1]];
    }    
    
    int familiarity = [[currWord objectForKey:@"F"] intValue];    
    [self SetFamiliarityStar:familiarity];  
    self.title = [NSString stringWithFormat:@"List %d(%d/%d)", mainDelegate.CurrListID, mainDelegate.CurrWordIdx + 1, mainDelegate.filteredArr.count];
    currTimerCount = 0;
    timerEnabled = YES;
    if (mainDelegate.AutoVoice)
        [self btnPlaySoundTouched:nil];
}

- (void)onTimer
{
    if (timerEnabled)
    {
        currTimerCount = currTimerCount + 0.1;
        lblTimer.text = [NSString stringWithFormat:@"%.1f", currTimerCount];    
    }
}

- (void)SetFamiliarityStar:(NSInteger)familiarity {
    [btnF0 setImage:[UIImage imageNamed:@"ico_star.png"] forState:UIControlStateNormal];
    if (familiarity >= 1)
        [btnF1 setImage:[UIImage imageNamed:@"ico_star.png"] forState:UIControlStateNormal];        
    else [btnF1 setImage:[UIImage imageNamed:@"ico_star_none.png"] forState:UIControlStateNormal];         
    if (familiarity >= 2)
        [btnF2 setImage:[UIImage imageNamed:@"ico_star.png"] forState:UIControlStateNormal];        
    else [btnF2 setImage:[UIImage imageNamed:@"ico_star_none.png"] forState:UIControlStateNormal];   
    if (familiarity >= 3)
        [btnF3 setImage:[UIImage imageNamed:@"ico_star.png"] forState:UIControlStateNormal];        
    else [btnF3 setImage:[UIImage imageNamed:@"ico_star_none.png"] forState:UIControlStateNormal];   
    if (familiarity >= 4)
        [btnF4 setImage:[UIImage imageNamed:@"ico_star.png"] forState:UIControlStateNormal];        
    else [btnF4 setImage:[UIImage imageNamed:@"ico_star_none.png"] forState:UIControlStateNormal];  
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
    lblCurrFamiliarity.text = [mainDelegate GetFamiliarityName:familiarity];
}


- (IBAction)btnFamiliarityChanged:(id)sender {
    NSInteger familiarity = ((UIButton *)sender).tag;
    [self SetFamiliarityStar:familiarity];
    
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
    NSDictionary *currWord = [mainDelegate.WordList objectAtIndex: [[mainDelegate.filteredArr objectAtIndex: mainDelegate.CurrWordIdx] integerValue]];
    [currWord setValue: [NSNumber numberWithInteger: familiarity] forKey:@"F"];
    NSDictionary *reqDict = [NSDictionary dictionaryWithObjectsAndKeys:
                             mainDelegate.CurrWordBookID, @"wordBookID",
                             [NSString stringWithFormat:@"%d", familiarity], @"targetFamilarity",
                             [NSString stringWithFormat:@"%d", mainDelegate.CurrDictType], @"dictType",
                             [currWord objectForKey:@"RID"], @"dbRowID",
                             nil];
    
    //RPC JSON
    NSString* reqString = [NSString stringWithString:[reqDict JSONRepresentation]];    
    NSURL *url = [NSURL URLWithString:@"http://www.langlib.com/webservices/mobile/ws_mobilewordbook.asmx/ChangeFamiliarity"];
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"]; 
    [request addRequestHeader:@"Content-Type" value:@"application/json"];    
    [request appendPostData:[reqString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setCompletionBlock:^{
        
    }];
    [request setFailedBlock:^{
        LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
        [mainDelegate showNetworkFailed];
    }];
    [request startAsynchronous];

}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer*)recognizer {    
    // 触发手勢事件后，在这里作些事情
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight)
        [self btnPrevWord:nil];
    else [self btnNextWord:nil];
    //    [self.view removeGestureRecognizer:recognizer];
}

-(IBAction) choiceButtonClicked:(id)sender
{
    
    QuizChoiceButton *button = (QuizChoiceButton *)sender;
   
    if (button.isCorrect == 1)
    {
        LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
        timerEnabled = NO;
        if (mainDelegate.AutoFamiliarity)
        {
            if (currTimerCount <= 1.2)
                [self btnFamiliarityChanged: btnF3];
            else if (currTimerCount <= 2.0)
                [self btnFamiliarityChanged: btnF2];
            else if (currTimerCount <= 3.2)
                [self btnFamiliarityChanged: btnF1];
            else [self btnFamiliarityChanged: btnF0];
        }
        for (NSInteger i = 1; i <= 5; i ++)
        {
            if (button.tag != i)
                [[choiceContainer viewWithTag:i] setHidden:YES];
        }
        [button SetImageByCorrect]; 
    
        if (mainDelegate.AutoNextWord)
        {
            [self btnNextWord:nil];
        }
    }
    else if (button.tag == 5)
    {
        timerEnabled = NO;
        [self btnFamiliarityChanged: btnF0];
        for (NSInteger i = 1; i <= 4; i ++)
        {
            QuizChoiceButton *currbutton = (QuizChoiceButton *)[choiceContainer viewWithTag:i];
            if (currbutton.isCorrect != 1)
                [currbutton setHidden:YES];
            else [currbutton SetImageByCorrect];
        }        
    }
    else
    {
        [button SetImageByCorrect];
    }
}

- (void)viewDidUnload
{
    [self setLblCurrFamiliarity:nil];
    [self setBtnF0:nil];
    [self setBtnF1:nil];
    [self setBtnF2:nil];
    [self setBtnF3:nil];
    [self setBtnF4:nil];
    [self setLblWordProto:nil];
    [self setChoiceContainer:nil];
    [self setLblTimer:nil];
    [self setBtnViewPrevWord:nil];
    [self setBtnViewNextWord:nil];
    [self setLoadingHint:nil];
    [self setPlayer:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)btnNextWord:(id)sender {
    
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];  
    
    if (mainDelegate.CurrWordIdx == mainDelegate.filteredArr.count - 1)
    {
        UIAlertView *alert = [[UIAlertView alloc]//
                              initWithTitle:@"提示"
                              message:@"本单元已结束，要返回当日计划吗？"
                              delegate:self
                              cancelButtonTitle:@"确定"
                              otherButtonTitles:@"取消",nil];
        alert.tag = 1;
        [alert show];
        [alert release];
        
        return;
    }
    mainDelegate.CurrWordIdx++;
    
    if ((!listStatusMarked) && (mainDelegate.CurrWordIdx == mainDelegate.filteredArr.count - 1))
    {   
        NSDictionary *singleDay = [mainDelegate.ScheduleList objectAtIndex:mainDelegate.CurrItemIdx - 1];
        
        for (NSDictionary *singleList in [singleDay objectForKey:@"OL"])
        {
            if ([[singleList objectForKey:@"LID"] integerValue] == mainDelegate.CurrListID)
            {
                [singleList setValue: [NSNumber numberWithInt: 1] forKey:@"C"]; 
                break;
                
            }
        }
        for (NSDictionary *singleList in [singleDay objectForKey:@"NL"])
        {
            if ([[singleList objectForKey:@"LID"] integerValue] == mainDelegate.CurrListID)
            {
                [singleList setValue: [NSNumber numberWithInt: 1] forKey:@"C"]; 
                break;
                
            }
        }     
        mainDelegate.NeedReloadSchedule = YES;
        NSDictionary *reqDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSString stringWithFormat:@"%d", mainDelegate.CurrItemIdx], @"scheduleItemIndex",
                                 [NSString stringWithFormat:@"%d", mainDelegate.CurrListID], @"listID",
                                 [NSString stringWithFormat:@"%@", @"true"], @"selected",
                                 mainDelegate.CurrWordBookID, @"wordBookID",
                                 [NSString stringWithFormat:@"%d", mainDelegate.CurrPhaseIdx], @"subWbIdx",
                                 mainDelegate.CurrUserID, @"userID",
                                 nil];
        
        //RPC JSON
        NSString* reqString = [NSString stringWithString:[reqDict JSONRepresentation]];    
        
        NSURL *url = [NSURL URLWithString:@"http://www.langlib.com/webservices/mobile/ws_mobilewordbook.asmx/MarkListStudyCompleted"];
        __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [request addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"]; 
        [request addRequestHeader:@"Content-Type" value:@"application/json"];    
        [request appendPostData:[reqString dataUsingEncoding:NSUTF8StringEncoding]];
        [request setCompletionBlock:^{               
            
        }];
        [request setFailedBlock:^{
            
        }];
        [request startAsynchronous];
    }
    [self DisplayCurrWord];
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {  
    if (alertView.tag == 1)
    {        
        if (buttonIndex == 0)
        {
            [self.navigationController popToViewController:[self.navigationController.viewControllers  objectAtIndex:self.navigationController.viewControllers.count - 4] animated:YES];
        }
        else 
        {
            
        }
    }
}  

- (IBAction)btnPrevWord:(id)sender {
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
    if (mainDelegate.CurrWordIdx == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc]//
                              initWithTitle:@"提示"
                              message:@"这已经是本单元的第一个单词了"
                              delegate:self
                              cancelButtonTitle:@"确定"
                              otherButtonTitles:nil];
        alert.tag = 0;
        [alert show];
        [alert release];
        return;
    }
    mainDelegate.CurrWordIdx--;
    [self DisplayCurrWord];
}

- (IBAction)btnPlaySoundTouched:(id)sender 
{
    if (isPlaying) return;
    isPlaying = YES;
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
    NSString *currWordProto = [[mainDelegate.WordList objectAtIndex: [[mainDelegate.filteredArr objectAtIndex: mainDelegate.CurrWordIdx] integerValue]] objectForKey:@"W"];
    	
	NSArray *StoreFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *DoucumentsDirectiory = [StoreFilePath objectAtIndex:0];
	NSString *bookmp3 = [DoucumentsDirectiory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", mainDelegate.CurrDictType]];
	[[NSFileManager defaultManager] createDirectoryAtPath:bookmp3 withIntermediateDirectories:YES attributes:nil error:nil];
	NSString *mp3dir = [bookmp3 stringByAppendingPathComponent:[currWordProto stringByAppendingString:@".mp3"]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:mp3dir];
	
    if (self.player.retainCount > 0)
        [player release];
    
    if (fileExists)
    {
        NSError *error;
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL
                                                               fileURLWithPath:mp3dir] error:&error];
        [player play];        
    }
    else
    {
        NSError *error;
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.langlib.com/voice/%@/%@.mp3", [currWordProto substringToIndex:1], [[currWordProto stringByReplacingOccurrencesOfString:@"*" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]];
        
        NSData *soundData = [NSData dataWithContentsOfURL:url];
        [soundData writeToFile:mp3dir atomically:YES];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL
                                                               fileURLWithPath:mp3dir] error:&error];
        [player play];
    }
    isPlaying = NO;
}


- (void)dealloc {
    [timer release];
    if (player.retainCount > 1)
        [player release];
    [lblCurrFamiliarity release];
    [btnF0 release];
    [btnF1 release];
    [btnF2 release];
    [btnF3 release];
    [btnF4 release];
    [lblWordProto release];
    [choiceContainer release];
    [lblTimer release];
    [btnViewPrevWord release];
    [btnViewNextWord release];
    [loadingHint release];
    [super dealloc];
}


@end
