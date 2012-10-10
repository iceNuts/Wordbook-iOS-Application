//
//  ConfigTaskParamController.m
//  LangL
//
//  Created by king bill on 11-9-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ConfigTaskParamController.h"
#import "LangLAppDelegate.h"

@implementation ConfigTaskParamController
@synthesize selectTaskView;

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
    self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"bg_main_green.png"]]; 
    selectTaskView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 250)];
    
    selectTaskView.delegate = self;
    selectTaskView.dataSource = self;
    [self.view addSubview:self.selectTaskView];      
    selectTaskView.separatorColor = [UIColor clearColor];
    selectTaskView.backgroundColor = [UIColor clearColor];
    selectTaskView.opaque = NO;
    selectTaskView.backgroundView = nil;  
    self.title = @"选择任务量";
}


- (void)dealloc {
    [selectTaskView release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
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
    return 65;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    
    UIImageView *splitter = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_item.png"]];
    [splitter setFrame: CGRectMake(0, 63, 320, 2)];
    [cell.contentView addSubview: splitter];
    [splitter release];
    
    cell.textLabel.font = [UIFont fontWithName:@"宋体" size:15];
    cell.detailTextLabel.font = [UIFont fontWithName:@"宋体" size:13];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1];
    cell.textLabel.textColor = [UIColor whiteColor];
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"较少";
            cell.detailTextLabel.text = @"约200单词";
            cell.tag = 2;
            break;
        case 1:
            cell.textLabel.text = @"中等";
            cell.detailTextLabel.text = @"约300单词";
            cell.tag = 3;
            break;    
        case 2:
            cell.textLabel.text = @"较多";
            cell.detailTextLabel.text = @"约400单词";
            cell.tag = 4;
            break; 
        default:
            break;
    }
    if (cell.tag == mainDelegate.createParams.listCountPerDay)
    {
        UIImageView *selectedImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"ico_mark_finishlist.png"]];
        [selectedImage setFrame: CGRectMake(280, 15, 27, 27)];
        [cell.contentView addSubview: selectedImage];
        [selectedImage release];
    }
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
    
    mainDelegate.createParams.listCountPerDay = ([tableView cellForRowAtIndexPath:indexPath]).tag;
    [selectTaskView reloadData];
}



@end
