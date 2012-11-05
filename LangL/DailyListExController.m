//
//  DailyListExController.m
//  LangL
//
//  Created by king bill on 11-8-20.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "DailyListExController.h"
#import "LangLAppDelegate.h"
#import "SBJson.h"
#import "WordListController.h"
@implementation DailyListExController

@synthesize dailyListDict;
@synthesize dailyListView;

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
    // Do any additional setup after loading the view from its nib.
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg_main_green.png"]];
    self.view.backgroundColor = background;
    [background release];
    
    dailyListView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 415) style:UITableViewStylePlain];
    dailyListView.delegate = self;
    dailyListView.dataSource = self;
    [self.view addSubview:self.dailyListView];
    
    dailyListView.separatorColor = [UIColor clearColor];  
    dailyListView.backgroundColor = [UIColor clearColor];
    dailyListView.opaque = NO;
    dailyListView.backgroundView = nil;    
    
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
    for (NSDictionary *schedule in mainDelegate.ScheduleList) {
        if ([[schedule objectForKey:@"Idx"] integerValue] == mainDelegate.CurrItemIdx) {
            self.dailyListDict = schedule;
            break;
        }        
    }
    self.navigationController.toolbarHidden = YES; 
    self.title = [NSString stringWithFormat:@"%@计划", [dailyListDict objectForKey:@"CDate"]];
}

- (void)viewDidUnload
{
    [dailyListDict release];
    [dailyListView release];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidAppear:(BOOL)animated
{
	
	NSArray* NL = [dailyListDict valueForKey:@"NL"];
	NSArray* OL = [dailyListDict valueForKey:@"OL"];
	
	BOOL flag = TRUE;
	
	for(NSDictionary* dict in NL){
		if([[dict valueForKey:@"C"] boolValue] == FALSE){
			flag = FALSE;
		}
	}
	if(FALSE == flag){
		return;
	}
	
	for(NSDictionary* dict in OL){
		if([[dict valueForKey:@"C"] boolValue] == FALSE){
			flag = FALSE;
		}
	}
	
	if(flag){
		
		NSArray *StoreFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *DoucumentsDirectiory = [StoreFilePath objectAtIndex:0];
		NSString* filePath = [DoucumentsDirectiory stringByAppendingPathComponent:@"Tango.plist"];
		//check time to see if need to refresh
		NSDictionary* fileData = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
		NSDate* fileDate = [fileData objectForKey:NSFileModificationDate];
		NSDate* today = [NSDate date];
		
		if ([[[today dateByAddingTimeInterval:-(60*60*0.8)] earlierDate:fileDate] isEqualToDate:fileDate] || ![[NSFileManager defaultManager] fileExistsAtPath:filePath]){
			//Pop alert view for share
			SocialAlert* alertDelegate = [[SocialAlert alloc] init];
			UIAlertView* alert = [[UIAlertView alloc]
								  initWithTitle:@"提示" message:@"恭喜您成功完成了当前练习，将这个消息告诉朋友？" delegate:alertDelegate cancelButtonTitle:@"取消" otherButtonTitles:@"好的", nil];
			[alert show];
			[alert release];
		}
	}

    [super viewDidAppear:animated];
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
    if (mainDelegate.NeedReloadSchedule)
    {
        [dailyListView reloadData];
    }

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if ((((NSArray *)[dailyListDict objectForKey:@"NL"]).count == 0) || (((NSArray *)[dailyListDict objectForKey:@"OL"]).count == 0))
    {
        return 1;
    }
    else return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (((NSArray *)[dailyListDict objectForKey:@"NL"]).count == 0)
    {
        NSArray *oldList = [dailyListDict objectForKey:@"OL"];
        return oldList.count;  
    }
    else if (((NSArray *)[dailyListDict objectForKey:@"OL"]).count == 0)
    {
        NSArray *newList = [dailyListDict objectForKey:@"NL"];
        return newList.count;  
    }
    else
    {
        if (section == 0)
        {
            NSArray *newList = [dailyListDict objectForKey:@"NL"];
            return newList.count;  
        }  
        else 
        {
            NSArray *oldList = [dailyListDict objectForKey:@"OL"];
            return oldList.count;  
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    UIImageView *splitter = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_item.png"]];
    [splitter setFrame: CGRectMake(0, 64, 310, 2)];
    [cell.contentView addSubview: splitter];
    [splitter release];
     cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_item.png"]] autorelease];
    NSArray *dataList;
    bool isNewList;
    
    if (((NSArray *)[dailyListDict objectForKey:@"NL"]).count == 0)
    {
        dataList = [dailyListDict objectForKey:@"OL"];
        isNewList = NO;
    }
    else if (((NSArray *)[dailyListDict objectForKey:@"OL"]).count == 0)
    {
        dataList = [dailyListDict objectForKey:@"NL"];
        isNewList = YES;
    }
    else
    {
        if (indexPath.section == 0)
        {
            dataList = [dailyListDict objectForKey:@"NL"];
            isNewList = YES;
        }
        else
        {
            dataList = [dailyListDict objectForKey:@"OL"];
            isNewList = NO;
        }
    }
    

    
    NSDictionary *singleList = [dataList objectAtIndex: indexPath.row];
    
    bool isFinish = [[singleList objectForKey:@"C"] boolValue] == YES;
    
    UILabel *hint1 = [[UILabel alloc] initWithFrame:CGRectMake(60, 3, 100, 30)];
    hint1.textColor = [UIColor whiteColor];
    hint1.text = [NSString stringWithFormat:@"List %d", [[singleList objectForKey:@"LID"] integerValue]];
    hint1.font = [UIFont systemFontOfSize:15];
    hint1.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview: hint1];
    [hint1 release];
    
    NSString *iconFileName;
    if (isNewList)
    {
        if (isFinish)
        {
            iconFileName = @"ico_new_list_finish.png";
        }
        else            
        {
            iconFileName = @"ico_new_list.png";
            
        }        
    }
    else
    {
        if (isFinish)
        {
            iconFileName = @"ico_review_list_finish.png";
        }
        else            
        {
            iconFileName = @"ico_review_list.png";            
        }      
    }
    
    UIImageView *iconImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:iconFileName]];
    [iconImage setFrame: CGRectMake(10, 8, 40, 46)];
    [cell.contentView addSubview: iconImage];
    [iconImage release]; 
    
    UILabel *hint2 = [[UILabel alloc] initWithFrame:CGRectMake(60, 30, 150, 20)];
    if (isFinish)
    {
        hint2.textColor = [UIColor greenColor];
        hint2.text = @"已完成";
    }
    else
    {
        hint2.textColor = [UIColor colorWithRed:255.0/255.0 green:160.0/255.0 blue:0.0/255.0 alpha:1];
        hint2.text = @"未完成";
    }
    hint2.font = [UIFont systemFontOfSize:13];
    hint2.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview: hint2];
    [hint2 release];
  
    UIImageView *disclosureImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"ico_arrow.png"]];
    [disclosureImage setFrame: CGRectMake(280, 20, 20, 24)];
    [cell.contentView addSubview: disclosureImage];
    [disclosureImage release];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
    NSInteger listID;
    if (((NSArray *)[dailyListDict objectForKey:@"NL"]).count == 0)
    {
        NSArray *oldList = [dailyListDict objectForKey:@"OL"];
        NSDictionary *singleList = [oldList objectAtIndex: indexPath.row];
        listID = [[singleList objectForKey:@"LID"] integerValue];
    }
    else if (((NSArray *)[dailyListDict objectForKey:@"OL"]).count == 0)
    {
        NSArray *newList = [dailyListDict objectForKey:@"NL"];
        NSDictionary *singleList = [newList objectAtIndex: indexPath.row];
        listID = [[singleList objectForKey:@"LID"] integerValue];
    }
    else
    {
        if (indexPath.section == 0)
        {
            NSArray *newList = [dailyListDict objectForKey:@"NL"];
            NSDictionary *singleList = [newList objectAtIndex: indexPath.row];
            listID = [[singleList objectForKey:@"LID"] integerValue];
        }
        else
        {
            NSArray *oldList = [dailyListDict objectForKey:@"OL"];
            NSDictionary *singleList = [oldList objectAtIndex: indexPath.row];
            listID = [[singleList objectForKey:@"LID"] integerValue];
        }
    }
    
    
    mainDelegate.CurrListID = listID;
    WordListController *detailViewController = [[WordListController alloc] initWithNibName:@"WordListController" bundle:nil];
    
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];

}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section 
{
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)] autorelease];  
    UIImage *img = [UIImage imageNamed:@"bg_item_title.png"];
    
    UIImage *stretchImage1 = [img stretchableImageWithLeftCapWidth:3.0 topCapHeight:5.0];
    UIImageView *imageView = [[[UIImageView alloc] initWithImage:stretchImage1] autorelease];
    imageView.frame = CGRectMake(0,0,tableView.bounds.size.width,40);
    
    [headerView addSubview:imageView];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 20)];
    
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14];
    label.backgroundColor = [UIColor clearColor];
   
    if (((NSArray *)[dailyListDict objectForKey:@"NL"]).count == 0)
    {
        label.text = @"复习的单元";
    }
    else if (((NSArray *)[dailyListDict objectForKey:@"OL"]).count == 0)
    {
        label.text = @"新背的单元";
    }
    else
    {        
        if (section == 0)
        {
            label.text = @"新背的单元";
        }
        else
        {
            label.text = @"复习的单元";
        }
    }
    [headerView addSubview:label];
    [label release];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}


@end
