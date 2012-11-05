//
//  AuthorizeDelegate.h
//  LangL
//
//  Created by Zeng Li on 10/31/12.
//
//

#import <Foundation/Foundation.h>

@class Authorize;

@protocol AuthorizeDelegate <NSObject>
- (void)authorize:(Authorize *)authorize didSucceedWithAccessToken:(NSString *)accessToken userID:(NSString *)userID expiresIn:(NSInteger)seconds;

- (void)authorize:(Authorize *)authorize didFailWithError:(NSError *)error;
@end
