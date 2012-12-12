//
//  ConfigTestTypeParamController.m
//  LangL
//
//  Created by king bill on 11-9-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ConfigTestTypeParamController.h"
#import "LangLAppDelegate.h"

@implementation ConfigTestTypeParamController
@synthesize selectTestTypeView;

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
    selectTestTypeView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 420)];
    
    selectTestTypeView.delegate = self;
    selectTestTypeView.dataSource = self;
    [self.view addSubview:self.selectTestTypeView];      
    
    selectTestTypeView.separatorColor = [UIColor clearColor];
    selectTestTypeView.backgroundColor = [UIColor clearColor];
    selectTestTypeView.opaque = NO;
    selectTestTypeView.backgroundView = nil;      
    
    self.title = @"选择词汇书类型";
}


- (void)dealloc {
    [selectTestTypeView release];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 43;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell =  [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    
    UIImageView *splitter = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_item.png"]];
    [splitter setFrame: CGRectMake(0, 40, 320, 2)];
    [cell.contentView addSubview: splitter];
    [splitter release];
    
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
    cell.textLabel.font = [UIFont fontWithName:@"宋体" size:15];
    cell.textLabel.textColor = [UIColor whiteColor];
    switch (indexPath.row) {
        case 0:
            cell.tag = 1;
            break;    
        case 1:
            cell.tag = 15;
            break;  
        case 2:
            cell.tag = 12;
            break;  
        case 3:
            cell.tag = 4;
            break;  
        case 4:
            cell.tag = 6;
            break;  
        case 5:
            cell.tag = 7;
            break;  
        case 6:
            cell.tag = 8;
            break;  
        case 7:
            cell.tag = 9;
            break;  
        case 8:
            cell.tag = 2;
            break;  
        default:
            break;
    }
    cell.textLabel.text = [mainDelegate GetDictNameByType:cell.tag];
    if (cell.tag == mainDelegate.createParams.testType)
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
    
    mainDelegate.createParams.testType = ([tableView cellForRowAtIndexPath:indexPath]).tag;
   [selectTestTypeView reloadData];
}


@end
