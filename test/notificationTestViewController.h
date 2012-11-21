//
//  notificationTestViewController.h
//  LangL
//
//  Created by Zeng Li on 11/20/12.
//
//

#import <UIKit/UIKit.h>
#import "NavigationButton.h"
#import "NavigateToPrevButton.h"

@protocol notificationViewControllerDelegate
-(void) notificationViewWillCancel;
-(void) notificationViewWillConfirm;
@end

@interface notificationTestViewController : UIViewController{
}

@property(nonatomic, retain) id<notificationViewControllerDelegate> delegate;


@property (retain, nonatomic) IBOutlet UIImageView *popHeader;
@property (retain, nonatomic) IBOutlet UILabel *headerLabel;
@property (retain, nonatomic) IBOutlet UISwitch *notificationSwitch;
@property (retain, nonatomic) IBOutlet UILabel *hintLabel1;
@property (retain, nonatomic) IBOutlet UITextView *hintTextView1;
@property (retain, nonatomic) IBOutlet UIDatePicker *timePicker;
@property (retain, nonatomic) IBOutlet UITextView *hintTextView2;


-(void) btnCancelSelectTouched;
-(void) btnConfirmSelectTouched;

@end
