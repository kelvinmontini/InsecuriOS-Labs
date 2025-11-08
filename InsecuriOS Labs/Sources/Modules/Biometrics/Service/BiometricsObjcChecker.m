#import <LocalAuthentication/LocalAuthentication.h>

@interface BiometricsObjcChecker : NSObject

+ (void)authenticateUserWithCompletion:(void (^)(BOOL success, NSError *error))completion;

@end

@implementation BiometricsObjcChecker

+ (BOOL)isBiometricAuthenticationAvailable {
    LAContext *context = [[LAContext alloc] init];
    NSError *error = nil;
    return [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
}

+ (void)authenticateUserWithCompletion:(void (^)(BOOL success, NSError *error))completion {
    LAContext *context = [[LAContext alloc] init];
    
    if (![self isBiometricAuthenticationAvailable]) {
        NSError *error = [NSError errorWithDomain:@"Biometrics" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Biometrics not available"}];
        completion(NO, error);
        return;
    }
    
    NSString *reason = @"Please authenticate yourself";
    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
            localizedReason:reason
                      reply:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(success, error);
        });
    }];
}

@end
