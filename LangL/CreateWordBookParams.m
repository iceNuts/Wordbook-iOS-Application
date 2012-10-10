//
//  CreateWordBookParams.m
//  LangL
//
//  Created by king bill on 11-9-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "CreateWordBookParams.h"

@implementation CreateWordBookParams

@synthesize testType;
@synthesize beginDate;
@synthesize listCountPerDay;
@synthesize sortType;

- (id)init
{
    self = [super init];
    if (self) {
        testType = -1;
        listCountPerDay = 3;
        sortType = 0;
        self.beginDate = [NSDate dateWithTimeIntervalSinceNow: 0.0];
    }
    
    return self;
}

- (void)dealloc {
    [beginDate release];
    [super dealloc];
}


@end
