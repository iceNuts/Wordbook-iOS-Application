//
//  ViewWordController.m
//  LangL
//
//  Created by king bill on 11-8-17.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ViewWordController.h"
#import "LangLAppDelegate.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "EditNoteController.h"
#import "GoToWordController.h"
#import "AVFoundation/AVAudioPlayer.h"
#import "NavigateToNextButton.h"
#import "QuizModeController.h"

@implementation ViewWordController
@synthesize extraData;
@synthesize topView;
@synthesize wordSymbol;
@synthesize btnShowCHN;
@synthesize btnShowEngExp;
@synthesize btnShowExpSen;
@synthesize btnEditNote;
@synthesize btnViewNextWord;
@synthesize btnF0;
@synthesize btnF1;
@synthesize btnF2;
@synthesize btnF3;
@synthesize btnF4;
@synthesize lblFamiliarityName;
@synthesize wordMeaning;
@synthesize btnViewPrevWord;
@synthesize wordProto;
@synthesize exampleSenHtml;
@synthesize englishExpHtml;
@synthesize htmlPrefix;
@synthesize player;
@synthesize isPlaying;
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
    
    wordSymbol.opaque = NO;
    wordSymbol.backgroundColor = [UIColor clearColor];
    
    extraData.opaque = NO;
    extraData.backgroundColor = [UIColor clearColor];
      
    // Now load the image and create the image view
    UIImage *engExpImage = [UIImage imageNamed:@"ico_small_english.png"];
    UIImageView *engExpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 15, 20, 20)];
    [engExpImageView setImage:engExpImage];
    UILabel *engExpLabel = [[UILabel alloc] initWithFrame: CGRectMake(43, 15, 30, 20)];
    [engExpLabel setText:@"英释"];
    [engExpLabel setFont:[UIFont systemFontOfSize:12]];
    engExpLabel.textColor = [UIColor whiteColor];
    engExpLabel.backgroundColor = [UIColor clearColor];
    [btnShowEngExp addSubview:engExpLabel];
    [btnShowEngExp addSubview:engExpImageView];
    [engExpLabel release];
    [engExpImageView release];
    
    UIImage *expSenImage = [UIImage imageNamed:@"ico_small_sentence.png"];
    UIImageView *expSenImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 15, 20, 20)];
    [expSenImageView setImage:expSenImage];
    UILabel *expSenLabel = [[UILabel alloc] initWithFrame: CGRectMake(43, 15, 30, 20)];
    [expSenLabel setText:@"例句"];
    [expSenLabel setFont:[UIFont systemFontOfSize:12]];
    expSenLabel.textColor = [UIColor whiteColor];
    expSenLabel.backgroundColor = [UIColor clearColor];
    [btnShowExpSen addSubview:expSenLabel];
    [btnShowExpSen addSubview:expSenImageView];
    [expSenLabel release];
    [expSenImageView release];
    
    UIImage *editNoteImage = [UIImage imageNamed:@"ico_small_my.png"];
    UIImageView *editNoteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 15, 20, 20)];
    editNoteImageView.tag = 10;
    [editNoteImageView setImage:editNoteImage];
    UILabel *editNoteLabel = [[UILabel alloc] initWithFrame: CGRectMake(43, 15, 30, 20)];
    [editNoteLabel setText:@"注释"];
    [editNoteLabel setFont:[UIFont systemFontOfSize:12]];
    editNoteLabel.textColor = [UIColor whiteColor];
    editNoteLabel.backgroundColor = [UIColor clearColor];
    [btnEditNote addSubview:editNoteLabel];
    [btnEditNote addSubview:editNoteImageView];
    [editNoteLabel release];
    [editNoteImageView release];
    
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

    // Set the background to the stretchable image
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
    isPlaying = NO;
    for (id subview in extraData.subviews)
        if ([[subview class] isSubclassOfClass: [UIScrollView class]])
            ((UIScrollView *)subview).bounces = NO;
    self.htmlPrefix = @"<html> \n"
                                   "<head> \n"
                                   "<style type=\"text/css\"> \n"
                                   "body { \n"
                                   "font-size:13px; color: white; background-color:transparent;\n"
                                   "}\n"
                                    "b { \n"
                                    "font-weight: bold; padding: 0px 2px; \n"
                                    "}\n"
                                   "</style> \n"
                                   "</head> \n"
                                   "<body>%@</body> \n"
                                   "</html>";
       
    [extraData stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '30%'"];
    self.exampleSenHtml = [NSMutableString stringWithString: @""];
    self.englishExpHtml = [NSMutableString stringWithString: @""];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.toolbarHidden = YES;  
    
    wordProto.textColor = [UIColor colorWithRed:255.0/255.0 green:170.0/255.0 blue:0.0/255.0 alpha:1];
    wordMeaning.textColor = [UIColor colorWithRed:255.0/255.0 green:188.0/255.0 blue:50.0/255.0 alpha:1];
    
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
  
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
    [self DisplayCurrWord];
    
    UISwipeGestureRecognizer* leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    leftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [topView addGestureRecognizer:leftRecognizer];
    [leftRecognizer release];
    
    UISwipeGestureRecognizer* rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [topView addGestureRecognizer:rightRecognizer];
    [rightRecognizer release];
    
    NavigateToNextButton *btnMode = [[NavigateToNextButton alloc] init];    
    [btnMode setTitle:@"  模 式" forState:UIControlStateNormal];     
    [btnMode addTarget:self action:@selector(btnChangeModeTouched) forControlEvents:UIControlEventTouchUpInside];   
    UIBarButtonItem* modeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnMode]; 
    [self.navigationItem  setRightBarButtonItem:modeButtonItem]; 
    [modeButtonItem release]; 
    [btnMode release]; 
}

-(void) btnChangeModeTouched 
{

    QuizModeController *detailViewController = [[QuizModeController alloc] initWithNibName:@"QuizModeController" bundle:nil];
    
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];   

}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer*)recognizer {    
    // 触发手勢事件后，在这里作些事情
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight)
        [self btnViewPrevWordTouched:nil];
    else [self btnViewNextWordTouched:nil];
//    [self.view removeGestureRecognizer:recognizer];
}

-(void) DisplayCurrWord 
{
    [self.exampleSenHtml setString:(@"")];
    [self.englishExpHtml setString:(@"")];
    [extraData stringByEvaluatingJavaScriptFromString: @"document.body.innerHTML='';"];
    btnShowCHN.hidden = NO;
    [btnShowExpSen setBackgroundImage:nil forState:UIControlStateNormal];
    [btnShowEngExp setBackgroundImage:nil forState:UIControlStateNormal];
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
   // NSLog([mainDelegate.CurrWordIdx stringValue]);
    NSDictionary *currWord = [mainDelegate.WordList objectAtIndex: [[mainDelegate.filteredArr objectAtIndex: mainDelegate.CurrWordIdx] integerValue]];
    wordProto.text = [currWord objectForKey:@"W"];
    wordMeaning.text = [currWord objectForKey:@"CN"];
    wordMeaning.hidden = YES;
    [wordSymbol loadHTMLString: [NSString stringWithFormat:@"<html><body style='background-color: transparent'><span style='color: #ffd77d'>%@</span></body></html>", [currWord objectForKey:@"S"]]  baseURL:nil];    
    ;
    NSString *userNote = [currWord objectForKey:@"UN"];

    if (userNote.length == 0)
    {
        [((UIImageView *)[btnEditNote viewWithTag:10]) setImage:[UIImage imageNamed:@"ico_small_my.png"]];
    }
    else
    {
        [((UIImageView *)[btnEditNote viewWithTag:10]) setImage:[UIImage imageNamed:@"ico_small_myadd.png"]]; 
    }
    
    int familiarity = [[currWord objectForKey:@"F"] intValue];
    
    [self SetFamiliarityStar:familiarity];
    if (familiarity >= 3)
        [self btnShowCHNTouched:nil];
    self.title = [NSString stringWithFormat:@"List %d(%d/%d)", mainDelegate.CurrListID, mainDelegate.CurrWordIdx + 1, mainDelegate.filteredArr.count];
    
    if (mainDelegate.AutoVoice)
        [self btnPlaySoundTouched:nil];
}

- (void)gotoWordController:(GoToWordController *)gotoWordController GoToWord:(NSInteger)wordIdx {
    if (wordIdx) {  
        LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
        if (wordIdx < 1)
        {
            mainDelegate.CurrWordIdx = 0;
            [self DisplayCurrWord];            
        }
        else if (wordIdx > mainDelegate.filteredArr.count)
        {
            mainDelegate.CurrWordIdx = mainDelegate.filteredArr.count - 1;
            [self DisplayCurrWord];            
        }
        else
        {
            mainDelegate.CurrWordIdx = wordIdx - 1;
            [self DisplayCurrWord];
        }

    } 
    [gotoWordController dismissModalViewControllerAnimated:YES];
}

- (void)editNoteController:(EditNoteController *)editNoteController SaveNewNote:(NSString *)newNoteText {
    if (newNoteText) {  
        LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
        NSDictionary *currWord = [mainDelegate.WordList objectAtIndex: [[mainDelegate.filteredArr objectAtIndex: mainDelegate.CurrWordIdx] integerValue]];;
        [currWord setValue: newNoteText forKey:@"UN"];
        NSDictionary *reqDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [currWord objectForKey:@"RID"], @"dbRowID",
                                 newNoteText, @"note",
                                 [NSString stringWithFormat:@"%d", mainDelegate.CurrPhaseIdx], @"subWbIdx",
                                 [NSString stringWithFormat:@"%d", mainDelegate.CurrDictType], @"dictType",
                                 mainDelegate.CurrUserID, @"userID",
                                 mainDelegate.CurrWordBookID, @"wordBookID",                                 
                                 nil];
        
        //RPC JSON
        NSString* reqString = [NSString stringWithString:[reqDict JSONRepresentation]];    
        NSURL *url = [NSURL URLWithString:@"http://www.langlib.com/webservices/mobile/ws_mobilewordbook.asmx/SaveNoteEx"];
        
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
        if (newNoteText.length == 0)
        {
            [((UIImageView *)[btnEditNote viewWithTag:10]) setImage:[UIImage imageNamed:@"ico_small_my.png"]];
        }
        else
        {
            [((UIImageView *)[btnEditNote viewWithTag:10]) setImage:[UIImage imageNamed:@"ico_small_myadd.png"]]; 
        }
        
    } 
    [editNoteController dismissModalViewControllerAnimated:YES];
}

-(void) btnGotoWord:(id)sender 
{
    GoToWordController *gotoWordController = [[GoToWordController alloc]
                                          initWithNibName:@"GoToWordController" bundle:nil];
    
    gotoWordController.delegate = self;    
    // Create the navigation controller and present it modally.
    [self presentModalViewController:gotoWordController animated:YES];
    [gotoWordController release];
}

- (void)viewDidUnload
{
    [self setPlayer:nil];
    [self setWordProto:nil];
    [self setWordMeaning:nil];
    [self setWordSymbol:nil];
    [self setExtraData:nil];
    [self setBtnShowCHN:nil];
    [self setBtnShowEngExp:nil];
    [self setBtnShowExpSen:nil];
    [self setBtnEditNote:nil];
    [self setBtnViewPrevWord:nil];
    [self setBtnViewNextWord:nil];
    [self setBtnF0:nil];
    [self setBtnF1:nil];
    [self setBtnF2:nil];
    [self setBtnF3:nil];
    [self setBtnF4:nil];
    [self setLblFamiliarityName:nil];
    [self setTopView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    if (player.retainCount > 1)
        [player release];
    [htmlPrefix release];
    [englishExpHtml release];
    [exampleSenHtml release];
    [wordProto release];
    [wordMeaning release];
    [wordSymbol release];
    [extraData release];
    [btnShowCHN release];
    [btnShowEngExp release];
    [btnShowExpSen release];
    [btnEditNote release];
    [btnViewPrevWord release];
    [btnViewNextWord release];
    [btnF0 release];
    [btnF1 release];
    [btnF2 release];
    [btnF3 release];
    [btnF4 release];
    [lblFamiliarityName release];
    [topView release];
    [super dealloc];
}


- (IBAction)btnPlaySoundTouched:(id)sender 
{
    if (isPlaying) return;
    isPlaying = YES;
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
    NSString *currWordProto = [[mainDelegate.WordList objectAtIndex: [[mainDelegate.filteredArr objectAtIndex: mainDelegate.CurrWordIdx] integerValue]] objectForKey:@"W"];
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
        NSUserDomainMask, YES) objectAtIndex:0];

    NSString *mp3File = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3", currWordProto]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:mp3File]; 
    if (self.player.retainCount > 0)
        [player release];
    
    if (fileExists)
    {
        NSError *error;
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL
            fileURLWithPath:mp3File] error:&error]; 
        [player play];        
    }
    else
    {
        NSError *error;
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.langlib.com/voice/%@/%@.mp3", [currWordProto substringToIndex:1], [[currWordProto stringByReplacingOccurrencesOfString:@"*" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]];
  
        NSData *soundData = [NSData dataWithContentsOfURL:url];
        [soundData writeToFile:mp3File atomically:YES];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL
            fileURLWithPath:mp3File] error:&error];  
        [player play];
    }
    isPlaying = NO;
}

- (IBAction)btnShowCHNTouched:(id)sender {
    btnShowCHN.hidden = YES;
    wordMeaning.hidden = NO;
}

- (IBAction)btnShowEngExpTouched:(id)sender {
    [btnShowEngExp setBackgroundImage: [UIImage imageNamed:@"butn_select_circle.png"] forState:UIControlStateNormal];
    [btnShowExpSen setBackgroundImage:nil forState:UIControlStateNormal];
    if (![englishExpHtml isEqualToString:@""])
    {
        [extraData loadHTMLString: [NSString stringWithFormat:htmlPrefix, englishExpHtml] baseURL:nil];
        return;
    }
    
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
    NSDictionary *currWord = [mainDelegate.WordList objectAtIndex: [[mainDelegate.filteredArr objectAtIndex: mainDelegate.CurrWordIdx] integerValue]];
    
    NSDictionary *reqDict;
    NSURL *url;
    if ((mainDelegate.CurrDictType == 10) || (mainDelegate.CurrDictType == 11) || (mainDelegate.CurrDictType == 12))
    {
        reqDict = [NSDictionary dictionaryWithObjectsAndKeys:
                   [currWord objectForKey:@"WID"], @"wordID",
                   [NSString stringWithFormat:@"%d", mainDelegate.CurrDictType], @"dictType",                         
                   nil];     
        url = [NSURL URLWithString:@"http://www.langlib.com/webservices/mobile/ws_mobilewordbook.asmx/GetEngExpByWordEx"];
    }
    else
    {
        reqDict = [NSDictionary dictionaryWithObjectsAndKeys:
                   [currWord objectForKey:@"W"], @"wordProto",                        
                   nil];   
        url = [NSURL URLWithString:@"http://www.langlib.com/webservices/mobile/ws_mobilewordbook.asmx/GetEngExpByWord"];
    }
    
    
    //RPC JSON
    NSString* reqString = [NSString stringWithString:[reqDict JSONRepresentation]];    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"]; 
    [request addRequestHeader:@"Content-Type" value:@"application/json"];    
    [request appendPostData:[reqString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setCompletionBlock:^{
        NSString *responseString = [request responseString];
        NSDictionary* responseDict = [responseString JSONValue];
        NSArray* exampleSens = (NSArray *) [responseDict objectForKey:@"d"];
        
        int rowCounter = 0;
        for (NSDictionary* expSen in exampleSens) {
            rowCounter++;
            [self.englishExpHtml appendFormat:@"%d.(%@)%@", rowCounter, [expSen objectForKey:@"WordSpeech"], [expSen objectForKey:@"Explaination"]];            
            [self.englishExpHtml appendString:@"<br />"];      
        }       
        if ([self.englishExpHtml compare:@""] == NSOrderedSame)
            [self.englishExpHtml setString:@"(此单词没有英文解释)"];
        [extraData loadHTMLString: [NSString stringWithFormat:htmlPrefix, englishExpHtml] baseURL:nil];    
        
    }];
    [request setFailedBlock:^{
        LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
        [mainDelegate showNetworkFailed];
    }];
    [request startAsynchronous];   
}

- (IBAction)btnShowExpSenTouched:(id)sender {
    [btnShowExpSen setBackgroundImage: [UIImage imageNamed:@"butn_select_circle.png"] forState:UIControlStateNormal];
    [btnShowEngExp setBackgroundImage:nil forState:UIControlStateNormal];
    if (![exampleSenHtml isEqualToString:@""])
    {
        [extraData loadHTMLString: [NSString stringWithFormat:htmlPrefix, exampleSenHtml] baseURL:nil]; 
        return;
    }
    
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
    NSDictionary *currWord = [mainDelegate.WordList objectAtIndex: [[mainDelegate.filteredArr objectAtIndex: mainDelegate.CurrWordIdx] integerValue]];
    
    NSDictionary *reqDict = [NSDictionary dictionaryWithObjectsAndKeys:
                             [currWord objectForKey:@"RID"], @"dbRowID",
                             [NSString stringWithFormat:@"%d", mainDelegate.CurrDictType], @"dictType",
                             @"5", @"maxRow",
                             nil];
    
    //RPC JSON
    NSString* reqString = [NSString stringWithString:[reqDict JSONRepresentation]];    
    NSURL *url = [NSURL URLWithString:@"http://www.langlib.com/webservices/mobile/ws_mobilewordbook.asmx/GetExpSentenceByWord"];
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"]; 
    [request addRequestHeader:@"Content-Type" value:@"application/json"];    
    [request appendPostData:[reqString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setCompletionBlock:^{
        NSString *responseString = [request responseString];
        NSDictionary* responseDict = [responseString JSONValue];
        NSArray* exampleSens = (NSArray *) [responseDict objectForKey:@"d"];
        int rowCounter = 0;
        for (NSDictionary* expSen in exampleSens) {
            rowCounter++;
            [self.exampleSenHtml appendFormat:@"%d.%@", rowCounter, [expSen objectForKey:@"ESentence"]];        
            [self.exampleSenHtml appendString:@"<br />"];
            [self.exampleSenHtml appendFormat:@"&nbsp;&nbsp;%@", [expSen objectForKey:@"CSentence"]]; 
            [self.exampleSenHtml appendString:@"<br />"];        
        }
        
        if ([exampleSenHtml compare:@""] == NSOrderedSame)
            [self.exampleSenHtml setString:@"(此单词没有例句)"];
        [extraData loadHTMLString: [NSString stringWithFormat:htmlPrefix, exampleSenHtml] baseURL:nil];
        
        
    }];
    [request setFailedBlock:^{
        LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
        [mainDelegate showNetworkFailed];
    }];
    [request startAsynchronous];

}
- (IBAction)btnEditNoteTouched:(id)sender {
    EditNoteController *noteController = [[EditNoteController alloc]
                                          initWithNibName:@"EditNoteController" bundle:nil];
    
    noteController.delegate = self;    
    // Create the navigation controller and present it modally.
    [self presentModalViewController:noteController animated:YES];
    [noteController release];
}

- (IBAction)btnViewPrevWordTouched:(id)sender {
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

- (IBAction)btnViewNextWordTouched:(id)sender {
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
            [self.navigationController popToViewController:[self.navigationController.viewControllers  objectAtIndex:self.navigationController.viewControllers.count - 3] animated:YES];
        }
        else 
        {
            
        }
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
    lblFamiliarityName.text = [mainDelegate GetFamiliarityName:familiarity];
}

- (IBAction)btnFamiliarityChanged:(id)sender {
    NSInteger familiarity = ((UIButton *)sender).tag;
    [self SetFamiliarityStar:familiarity];

    [self btnShowCHNTouched:nil];
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
@end
