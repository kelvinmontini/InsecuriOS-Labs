#import <Foundation/Foundation.h>

@interface JailbreakObjcChecker : NSObject

+ (void)isJailbrokenWithCompletion:(void (^)(BOOL detected))completion;

@end
