//
//  GoToWordController.h
//  LangL
//
//  Created by king bill on 11-8-20.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GoToWordDelegate;

@interface GoToWordController : UIViewController<UITextFieldDelegate> {
    id <GoToWordDelegate> delegate;
    UITextField *gotoIdx;
}

@property (nonatomic, assign) id  delegate;
- (IBAction)confirmGoTo:(id)sender;
@property (nonatomic, retain) IBOutlet UITextField *gotoIdx;

- (IBAction)cancelGoTo:(id)sender;
@end


@protocol GoToWordDelegate

- (void) gotoWordController:(GoToWordController *)gotoWordController GoToWord:(NSInteger)wordIdx;

@end