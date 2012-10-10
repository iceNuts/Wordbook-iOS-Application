//
//  NavigationButton.m
//  LangL
//
//  Created by king bill on 11-12-5.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "NavigationButton.h"

@implementation NavigationButton

- (id)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, 60.0, 38.0);
        
        // Center the text vertically and horizontally
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        
        UIImage *image = [UIImage imageNamed:@"butn_header_n.png"];
        
        // Make a stretchable image from the original image
        UIImage *stretchImage = 
        [image stretchableImageWithLeftCapWidth:15.0 topCapHeight:0.0];
        
        // Set the background to the stretchable image
        [self setBackgroundImage:stretchImage forState:UIControlStateNormal];
        
        UIImage *image1 = [UIImage imageNamed:@"butn_header_p.png"];
        
        // Make a stretchable image from the original image
        UIImage *stretchImage1 =         
        [image1 stretchableImageWithLeftCapWidth:15.0 topCapHeight:0.0];
        
        // Set the background to the stretchable image
        [self setBackgroundImage:stretchImage1 forState:  UIControlStateSelected];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; 
        // Make the background color clear
        self.backgroundColor = [UIColor clearColor];
        
        // Set the font properties
        [self setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.titleLabel.shadowOffset = CGSizeMake(0, -1);
        self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    }
    
    return self;
}

@end
