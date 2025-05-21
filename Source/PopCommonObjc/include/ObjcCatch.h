#import <Foundation/Foundation.h>


//	adapted from https://stackoverflow.com/questions/32758811/catching-nsexception-in-swift
@interface ObjC : NSObject

+ (void)tryExecute:(nonnull void(NS_NOESCAPE^)(void))tryBlock error:(NSError*_Nullable*_Nullable)throwError __attribute__((swift_error(nonnull_error)));

@end

