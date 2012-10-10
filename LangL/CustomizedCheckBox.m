//
//  CustomizedCheckBox.m
//  LangL
//
//  Created by king bill on 11-10-29.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "CustomizedCheckBox.h"

@implementation CustomizedCheckBox

@synthesize isChecked;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        
        self.contentHorizontalAlignment =
        UIControlContentHorizontalAlignmentLeft;
        
        [self setImage:[UIImage imageNamed:
                        @"butn_checkbox_n.png"]
              forState:UIControlStateNormal];
        
        [self addTarget:self action:
         @selector(checkBoxClicked)
       forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(IBAction) checkBoxClicked{
    if(self.isChecked ==NO){
        self.isChecked =YES;
        [self setImage:[UIImage imageNamed:
                        @"butn_checkbox_p.png"]
              forState:UIControlStateNormal];
        
    }else{
        self.isChecked =NO;
        [self setImage:[UIImage imageNamed:
                        @"butn_checkbox_n.png"]
              forState:UIControlStateNormal];
        
    }
}

- (void)dealloc {
    [super dealloc];
}

@end


