//
//  WordListCell.m
//  LangL
//
//  Created by king bill on 11-11-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WordListCell.h"

@implementation WordListCell

@synthesize familiarityLabel;
@synthesize wordLabel;
@synthesize expLabel;
@synthesize splitter;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        splitter = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_item.png"]];
        [splitter setFrame: CGRectMake(0, 50, 320, 2)];
        [self.contentView addSubview: splitter];
                
        UIImageView *familiarityIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ico_star_green.png"]];
        familiarityIcon.frame = CGRectMake(280, 10, 26, 26);
        [self.contentView addSubview: familiarityIcon];
        [familiarityIcon release];
        
        familiarityLabel = [[UILabel alloc] initWithFrame:CGRectMake(280, 10, 26, 26)];       
        familiarityLabel.backgroundColor = [UIColor clearColor];
        familiarityLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:215.0/255.0 blue:0.0/255.0 alpha:1];

        familiarityLabel.font = [UIFont systemFontOfSize:11];
        familiarityLabel.textAlignment = UITextAlignmentCenter;
        [self.contentView addSubview: familiarityLabel];
        
        
        wordLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, 280, 20)];
        wordLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:170.0/255.0 blue:0.0/255.0 alpha:1];
        wordLabel.font = [UIFont systemFontOfSize:18]; 
        wordLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview: wordLabel];
        
        expLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 26, 280, 20)];
        expLabel.textColor = [UIColor colorWithRed:211.0/255.0 green:211.0/255.0 blue:211.0/255.0 alpha:1];
        expLabel.font = [UIFont systemFontOfSize:13];
        expLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview: expLabel];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [familiarityLabel setOpaque:NO];
}

@end
