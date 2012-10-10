//
//  CreateWordBookParams.h
//  LangL
//
//  Created by king bill on 11-9-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CreateWordBookParams : NSObject
{
    NSDate *beginDate;
    NSInteger listCountPerDay;
    NSInteger sortType;
    NSInteger testType;
}

@property (nonatomic, retain) NSDate *beginDate;
@property NSInteger listCountPerDay;
@property NSInteger sortType;
@property NSInteger testType;

@end
