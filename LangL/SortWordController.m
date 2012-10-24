//
//  SortWordController.m
//  LangL
//
//  Created by king bill on 11-9-7.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "SortWordController.h"
#import "WordListController.h"
#import "LangLAppDelegate.h"
#import "CommonButton.h"
#import "NavigateToNextButton.h"
#import "NavigateToPrevButton.h"
#import "NavigationButton.h"

@implementation SortWordController
@synthesize sortTypeView;
@synthesize sortTypeArr;
@synthesize currSortType;
@synthesize delegate;
@synthesize popHeader;
@synthesize showUnfamilarWord;


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
    
    self.sortTypeArr = [NSArray arrayWithObjects:@"首字母", @"熟练度正序", @"熟练度逆序", @"随机", nil];
    sortTypeView = [[UITableView alloc] initWithFrame:CGRectMake(0, 43, 320, 320) style:UITableViewStylePlain];
    sortTypeView.delegate = self;
    sortTypeView.dataSource = self;
    [self.view addSubview:self.sortTypeView];   
        
    sortTypeView.separatorColor = [UIColor clearColor];  
    sortTypeView.backgroundColor = [UIColor clearColor];
    sortTypeView.opaque = NO;
    sortTypeView.backgroundView = nil;   

    NavigationButton *btnConfirm = [[NavigationButton alloc] init];    
    [btnConfirm setTitle:@"确 定" forState:UIControlStateNormal]; 
    
    [btnConfirm addTarget:self action:@selector(btnSelectSortTouched) forControlEvents:UIControlEventTouchUpInside];  
    btnConfirm.frame = CGRectMake(255, 2, 60, 38);
    [self.view addSubview: btnConfirm];
    [btnConfirm release];
    
    NavigateToPrevButton *btnCancel = [[NavigateToPrevButton alloc] init];    
    [btnCancel setTitle:@"取 消  " forState:UIControlStateNormal]; 
    
    [btnCancel addTarget:self action:@selector(btnCancelSelectTouched) forControlEvents:UIControlEventTouchUpInside];     
    btnCancel.frame = CGRectMake(5, 2, 60, 38);
    [self.view addSubview: btnCancel];
    [btnCancel release];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

- (void)viewDidUnload
{
    [self setPopHeader:nil];
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
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)        
        return 4;
    else return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];   
    UIImageView *splitter = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_item.png"]];
    [splitter setFrame: CGRectMake(0, 43, 310, 2)];
    [cell.contentView addSubview: splitter];
    [splitter release];
    cell.textLabel.textColor = [UIColor whiteColor];
    if (indexPath.section == 0)
    {
        cell.textLabel.text = [sortTypeArr objectAtIndex:indexPath.row];    
        if (indexPath.row + 1 == currSortType)
        {
            UIImageView *selectedImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"ico_mark_finishlist.png"]];
            [selectedImage setFrame: CGRectMake(280, 5, 27, 27)];
            [cell.contentView addSubview: selectedImage];
            [selectedImage release];
        }
    }
    else
    {
        cell.textLabel.text = @"只显示不熟悉的单词"; 
        if (showUnfamilarWord)
        {
            UIImageView *selectedImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"ico_mark_finishlist.png"]];
            [selectedImage setFrame: CGRectMake(280, 5, 27, 27)];
            [cell.contentView addSubview: selectedImage];
            [selectedImage release];
        }           
    }
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        currSortType = indexPath.row + 1;        
    }
    else
    {
        if (showUnfamilarWord)
            showUnfamilarWord = NO;
        else showUnfamilarWord = YES;
    }
    [self.sortTypeView reloadData];
}


- (void)dealloc {
    [sortTypeArr release];
    [sortTypeView release];
    [popHeader release];
    [super dealloc];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
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
    if (section == 0)
        label.text = @"选择排序方式";
    else label.text = @"选择过滤方式";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14];
    label.backgroundColor = [UIColor clearColor];
    
    [headerView addSubview:label];
    [label release];
    return headerView;
}

- (void)btnSelectSortTouched {
    LangLAppDelegate *mainDelegate = (LangLAppDelegate *)[[UIApplication sharedApplication]delegate]; 
    mainDelegate.CurrSortType = currSortType;   

    switch (mainDelegate.CurrSortType) {
        case 1:
        {
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"W"
                                                         ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            [sortDescriptor release];
			mainDelegate.WordList = [mainDelegate.WordList mutableCopy];
            [mainDelegate.WordList sortUsingDescriptors:sortDescriptors];
			break;                
        }
        case 2:
        {
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"F"
                                                         ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            [sortDescriptor release];
			mainDelegate.WordList = [mainDelegate.WordList mutableCopy];
            [mainDelegate.WordList sortUsingDescriptors:sortDescriptors];
            break;                
        }
        case 3:
        {
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"F"
                                                         ascending:NO];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            [sortDescriptor release];
			mainDelegate.WordList = [mainDelegate.WordList mutableCopy];
            [mainDelegate.WordList sortUsingDescriptors:sortDescriptors];
            break;                
        }        
        case 4:
        {
            srandom(time(NULL));              
            
            NSUInteger count = mainDelegate.WordList.count;
            for (NSUInteger i = 0; i < count; ++i) {
                // Select a random element between i and end of array to swap with.
                int nElements = count - i;
                int n = (random() % nElements) + i;
                [mainDelegate.WordList exchangeObjectAtIndex:i withObjectAtIndex:n];
            }                        
        }
    }
  
        if (showUnfamilarWord)
        {
            [mainDelegate.filteredArr removeAllObjects];
            for (int i = 0; i <= mainDelegate.WordList.count - 1; i++) 
            {
                if ([[[mainDelegate.WordList objectAtIndex: i] objectForKey:@"F"] integerValue] <= 2)
                {
                    [mainDelegate.filteredArr addObject: [NSNumber numberWithInt: i]];
                }    
            }             
        }
        else
        {
            [mainDelegate.filteredArr removeAllObjects];
            
            for (int i = 0; i <= mainDelegate.WordList.count - 1; i++) {
                [mainDelegate.filteredArr addObject: [NSNumber numberWithInt: i]];
            }
        }
             
    mainDelegate.enableFilter = showUnfamilarWord;
    [self.delegate sortWordController:self hasSelectSort:YES];
}

- (void)btnCancelSelectTouched {
    [self.delegate sortWordController:self hasSelectSort:NO];
}
@end
