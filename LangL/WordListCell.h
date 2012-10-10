//
//  WordListCell.h
//  LangL
//
//  Created by king bill on 11-11-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WordListCell : UITableViewCell {
    UILabel *familiarityLabel;
    UILabel *wordLabel;
    UILabel *expLabel;
    UIImageView *splitter;
}

@property(nonatomic,retain) UILabel *familiarityLabel;
@property(nonatomic,retain) UILabel *wordLabel;
@property(nonatomic,retain) UILabel *expLabel;
@property(nonatomic,retain) UIImageView *splitter;
@end
