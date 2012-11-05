//
//  SocialAlert.m
//  LangL
//
//  Created by Zeng Li on 11/5/12.
//
//

#import "SocialAlert.h"

@implementation SocialAlert

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	
	NSArray *StoreFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *DoucumentsDirectiory = [StoreFilePath objectAtIndex:0];
	filePath = [DoucumentsDirectiory stringByAppendingPathComponent:@"Tango.plist"];
	
	if(1 == buttonIndex){
		testViewController* test = [[testViewController alloc] init];
		[test show: YES];
	}else if(0 == buttonIndex){
		//set file time
		NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
		[dict setObject:@"show" forKey:@"show"];
		[dict writeToFile:filePath atomically:YES];
	}
}

@end
