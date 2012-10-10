//
//  AboutController.h
//  LangL
//
//  Created by king bill on 11-9-6.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShowAboutDelegate;

@interface AboutController : UIViewController<UIScrollViewDelegate> {
    id <ShowAboutDelegate> delegate;
    UIScrollView *scrollView;
}

@property (nonatomic, assign) id  delegate;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
- (void)layoutScrollImages;
@end


@protocol ShowAboutDelegate

- (void) aboutController:(AboutController *)aboutController;

@end