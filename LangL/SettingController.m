//
//  SettingController.m
//  LangL
//
//  Created by bill on 12-8-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SettingController.h"
#import "LangLAppDelegate.h"
#import "NavigationButton.h"

@interface SettingController ()

@end

@implementation SettingController
@synthesize settingView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"bg_main_green.png"]];     
    settingView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 230) style:UITableViewStylePlain];
    
    settingView.delegate = self;
    settingView.dataSource = self;
    [self.view addSubview: self.settingView];      
    settingView.separatorColor = [UIColor clearColor];
    settingView.backgroundColor = [UIColor clearColor];
    settingView.opaque = NO;
    settingView.backgroundView = nil;        
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [settingView release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";    
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];   
    
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];   
    bool choice = NO;
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"单词自动发音";
            choice = mainDelegate.AutoVoice;
            break;
        case 1:
            cell.textLabel.text = @"测试模式自动进入下一词";
            choice = mainDelegate.AutoNextWord;
            break;
        case 2:
            cell.textLabel.text = @"测试模式自动标熟练度";
            choice = mainDelegate.AutoFamiliarity;
            break;
        default:
            break;
    }
    
    if (choice)
    {        
        UIImageView *selectedImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"ico_mark_finishlist.png"]];
        [selectedImage setFrame: CGRectMake(280, 5, 27, 27)];
        [cell.contentView addSubview: selectedImage];
        [selectedImage release];
    }		
    cell.textLabel.textColor = [UIColor whiteColor];
    UIImageView *splitter = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_item.png"]];
    [splitter setFrame: CGRectMake(0, 50, 320, 2)];
    [cell.contentView addSubview: splitter];
    [splitter release];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate];   
    switch (indexPath.row) {
        case 0:
            mainDelegate.AutoVoice = !mainDelegate.AutoVoice;
            break;
        case 1:
            mainDelegate.AutoNextWord = !mainDelegate.AutoNextWord;
            break;
        case 2:
            mainDelegate.AutoFamiliarity = !mainDelegate.AutoFamiliarity;
            break;
        default:
            break;
    }
  
    NSArray *StoreFilePath            =    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *DoucumentsDirectiory =    [StoreFilePath objectAtIndex:0];
    NSString *filePath                =    [DoucumentsDirectiory stringByAppendingPathComponent:@"LangLibWbSetting.plist"];    
            
    NSMutableDictionary* newValueDict = [[NSMutableDictionary alloc] initWithCapacity:3];    
    [newValueDict setObject:[NSNumber numberWithBool: mainDelegate.AutoVoice] forKey:@"AutoVoice"];
    [newValueDict setObject:[NSNumber numberWithBool: mainDelegate.AutoNextWord] forKey:@"AutoNextWord"];
    [newValueDict setObject:[NSNumber numberWithBool: mainDelegate.AutoFamiliarity] forKey:@"AutoFamiliarity"];
    [newValueDict writeToFile:filePath atomically: YES];     
    [newValueDict release];    

    [self.settingView reloadData];
}


@end
