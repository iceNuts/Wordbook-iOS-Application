//
//  HintButton.m
//  LangL
//
//  Created by king bill on 11-11-8.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "HintButton.h"

@implementation HintButton

- (id)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, 35.0, 35.0);
        
        // Center the text vertically and horizontally
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        
        UIImage *image = [UIImage imageNamed:@"butn_help_n.png"];
        
        // Make a stretchable image from the original image
        UIImage *stretchImage = 
        [image stretchableImageWithLeftCapWidth:15.0 topCapHeight:0.0];
        
        // Set the background to the stretchable image
        [self setBackgroundImage:stretchImage forState:UIControlStateNormal];
        
        UIImage *image1 = [UIImage imageNamed:@"butn_help_p.png"];
        
        // Make a stretchable image from the original image
       // UIImage *stretchImage1 =         
        //[image1 stretchableImageWithLeftCapWidth:15.0 topCapHeight:0.0];
        
        // Set the background to the stretchable image
        [self setBackgroundImage:image1 forState:  UIControlStateSelected];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; 
        // Make the background color clear
        self.backgroundColor = [UIColor clearColor];
        
        // Set the font properties
        [self setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.titleLabel.shadowOffset = CGSizeMake(0, -1);
        self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    
    return self;
}

@end
