//
//  CustomizedCheckBox.h
//  LangL
//
//  Created by king bill on 11-10-29.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomizedCheckBox : UIButton{
    BOOL isChecked;
}

@property (nonatomic,assign) BOOL isChecked;
-(IBAction) checkBoxClicked;


@end
