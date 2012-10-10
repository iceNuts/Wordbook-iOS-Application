//
//  CommonButton.m
//  LangL
//
//  Created by king bill on 11-10-30.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "CommonButton.h"

@implementation CommonButton

- (id)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, 49.0, 30.0);
        
        // Center the text vertically and horizontally
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        
        UIImage *image = [UIImage imageNamed:@"butn_green_n.png"];
        
        // Make a stretchable image from the original image
        UIImage *stretchImage = 
        [image stretchableImageWithLeftCapWidth:5.0 topCapHeight:0.0];
        
        // Set the background to the stretchable image
        [self setBackgroundImage:stretchImage forState:UIControlStateNormal];
        
        UIImage *image1 = [UIImage imageNamed:@"butn_green_p.png"];
        
        // Make a stretchable image from the original image
        UIImage *stretchImage1 = 
        [image1 stretchableImageWithLeftCapWidth:5.0 topCapHeight:0.0];
        
        // Set the background to the stretchable image
        [self setBackgroundImage:stretchImage1 forState:  UIControlStateSelected];
        
        // Make the background color clear
        self.backgroundColor = [UIColor clearColor];
        
        // Set the font properties
        [self setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.titleLabel.shadowOffset = CGSizeMake(0, -1);
        self.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    }
    
    return self;
}

@end
