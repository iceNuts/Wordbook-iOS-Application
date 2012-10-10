//
//  ConfigSortParamController.m
//  LangL
//
//  Created by king bill on 11-9-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ConfigSortParamController.h"
#import "LangLAppDelegate.h"

@implementation ConfigSortParamController

@synthesize selectSortView;

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
    selectSortView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
    
    selectSortView.delegate = self;
    selectSortView.dataSource = self;
    [self.view addSubview:self.selectSortView];   
    selectSortView.separatorColor = [UIColor clearColor];
    selectSortView.backgroundColor = [UIColor clearColor];
    selectSortView.opaque = NO;
    selectSortView.backgroundView = nil;  
    self.title = @"选择排序方式";
}


- (void)dealloc {
    [selectSortView release];
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
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
 
    
    UIImageView *splitter = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_item.png"]];
    [splitter setFrame: CGRectMake(0, 43, 320, 2)];
    [cell.contentView addSubview: splitter];
    [splitter release];
    
    cell.textLabel.font = [UIFont fontWithName:@"宋体" size:15];
    cell.detailTextLabel.font = [UIFont fontWithName:@"宋体" size:13];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"字母正序";
            cell.tag = 0;
            break;
        case 1:
            cell.textLabel.text = @"字母逆序";
            cell.tag = 1;
            break;    
        case 2:
            cell.textLabel.text = @"考试频率";
            cell.tag = 2;
            break; 
        case 3:
            cell.textLabel.text = @"随机";
            cell.tag = 3;
            break; 
        default:
            break;
    }
    if (cell.tag == mainDelegate.createParams.sortType)
    {
        UIImageView *selectedImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"ico_mark_finishlist.png"]];
        [selectedImage setFrame: CGRectMake(280, 5, 27, 27)];
        [cell.contentView addSubview: selectedImage];
        [selectedImage release];
    }
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
    
    mainDelegate.createParams.sortType = ([tableView cellForRowAtIndexPath:indexPath]).tag;
    [selectSortView reloadData];
}

@end
