#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JailbreakObjcChecker : NSObject

+ (BOOL)checkURLSchemes;
+ (BOOL)checkSuspiciousFiles;
+ (BOOL)checkWritableDirectories;
+ (BOOL)checkSymbolicLinks;
+ (BOOL)checkOpenSystemFiles;
+ (BOOL)checkForJailbreakTweaks;
+ (BOOL)isJailbroken;

@end

@implementation JailbreakObjcChecker

+ (BOOL)checkURLSchemes {
    NSArray *suspiciousSchemes = @[
        @"cydia://",
        @"sileo://",
        @"zebra://",
        @"dopamine://",
        @"ssh://",
        @"telnet://",
        @"ftpd://"
    ];

    for (NSString *scheme in suspiciousSchemes) {
        NSURL *url = [NSURL URLWithString:scheme];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)checkSuspiciousFiles {
    NSArray *suspiciousFiles = @[
        @"/Applications/Cydia.app",
        @"/Applications/Sileo.app",
        @"/Applications/Zebra.app",
        @"/Applications/Dopamine.app",
        @"/bin/bash",
        @"/bin/sh",
        @"/usr/sbin/sshd",
        @"/etc/apt",
        @"/usr/libexec/ssh-keysign",
        @"/usr/libexec/sudo",
        @"/private/var/lib/cydia"
    ];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSString *file in suspiciousFiles) {
        if ([fileManager fileExistsAtPath:file]) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)checkWritableDirectories {
    NSArray *paths = @[
        @"/private/var/stash",
        @"/private/tmp",
        @"/private/var/mobile/Library",
        @"/private/var/mobile/Applications",
        @"/private/var/mobile/.ssh"
    ];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSString *path in paths) {
        NSError *error = nil;
        NSString *testFilePath = [path stringByAppendingPathComponent:@"test.txt"];
        NSString *content = @"test";

        if ([content writeToFile:testFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
            [fileManager removeItemAtPath:testFilePath error:nil];
            return YES;
        }
    }
    return NO;
}

+ (BOOL)checkSymbolicLinks {
    NSArray *suspiciousLinks = @[
        @"/private/var/lib/apt",
        @"/private/var/mobile/Media",
        @"/private/var/stash"
    ];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSString *link in suspiciousLinks) {
        NSError *error = nil;
        NSString *destination = [fileManager destinationOfSymbolicLinkAtPath:link error:&error];
        if (destination && destination.length > 0) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)checkOpenSystemFiles {
    NSArray *systemFiles = @[
        @"/private/var/run/launchd",
        @"/private/var/db/.bash_history",
        @"/private/etc/hosts"
    ];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSString *file in systemFiles) {
        if ([fileManager isReadableFileAtPath:file]) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)checkForJailbreakTweaks {
    NSArray *tweakFiles = @[
        @"/Library/MobileSubstrate/MobileSubstrate.dylib",
        @"/Library/dpkg/info/com.saurik.cydia.list",
        @"/usr/lib/libhooker.dylib"
    ];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSString *file in tweakFiles) {
        if ([fileManager fileExistsAtPath:file]) {
            return YES;
        }
    }
    return NO;
}

+ (void)isJailbrokenWithCompletion:(void (^)(BOOL detected))completion {
    BOOL urlSchemesResult = [self checkURLSchemes];
    BOOL suspiciousFilesResult = [self checkSuspiciousFiles];
    BOOL writableDirsResult = [self checkWritableDirectories];
    BOOL symbolicLinksResult = [self checkSymbolicLinks];
    BOOL systemFilesResult = [self checkOpenSystemFiles];
    BOOL tweaksResult = [self checkForJailbreakTweaks];
    
    uint8_t detectionFlags = 0;
    if (urlSchemesResult) { detectionFlags |= 0x01; }
    if (suspiciousFilesResult) { detectionFlags |= 0x02; }
    if (writableDirsResult) { detectionFlags |= 0x04; }
    if (symbolicLinksResult) { detectionFlags |= 0x08; }
    if (systemFilesResult) { detectionFlags |= 0x10; }
    if (tweaksResult) { detectionFlags |= 0x20; }
    
    completion(detectionFlags != 0);
}

@end
