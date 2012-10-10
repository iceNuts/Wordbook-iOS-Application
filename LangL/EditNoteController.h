//
//  EditNoteController.h
//  LangL
//
//  Created by king bill on 11-8-20.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditNoteModalDelegate;

@interface EditNoteController : UIViewController<UITextFieldDelegate> {
    id <EditNoteModalDelegate> delegate;
    UITextField *txtWordNote;
}

@property (nonatomic, assign) id  delegate;

@property (nonatomic, retain) IBOutlet UITextField *txtWordNote;

@end


@protocol EditNoteModalDelegate

- (void) editNoteController:(EditNoteController *)editNoteController SaveNewNote:(NSString *)newNoteText;

@end
