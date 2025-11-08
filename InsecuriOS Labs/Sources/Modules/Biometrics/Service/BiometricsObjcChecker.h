#import <Foundation/Foundation.h>

@interface BiometricsObjcChecker : NSObject

+ (void)authenticateUserWithCompletion:(void (^)(BOOL success, NSError *error))completion;

@end
