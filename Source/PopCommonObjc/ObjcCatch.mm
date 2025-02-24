#import <Foundation/Foundation.h>
#import "ObjcCatch.h"

@implementation ObjC

+ (void)tryExecute:(nonnull void(NS_NOESCAPE^)(void))tryBlock error:(NSError**)throwError __attribute__((swift_error(nonnull_error)))
{
	@try 
	{
		tryBlock();
	}
	@catch (NSException *exception) 
	{
		NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
		if (exception.userInfo != NULL) {
			userInfo = [[NSMutableDictionary alloc] initWithDictionary:exception.userInfo];
		}
		if (exception.reason != nil) {
			if (![userInfo.allKeys containsObject:NSLocalizedFailureReasonErrorKey]) {
				[userInfo setObject:exception.reason forKey:NSLocalizedFailureReasonErrorKey];
			}
		}
		*throwError = [[NSError alloc] initWithDomain:exception.name code:0 userInfo:userInfo];
	}
}

@end

