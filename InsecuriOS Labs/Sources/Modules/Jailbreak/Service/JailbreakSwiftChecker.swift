import UIKit
import Foundation

final class JailbreakSwiftChecker {
    
    typealias ChallengeStateUpdate = (ChallengeState) -> Void
    
    private enum Constants {
        static let loadingDelay: TimeInterval = 0.5
        static let detectionDelay: TimeInterval = 0.5
    }
    
    static func checkURLSchemes() -> Bool {
        let suspiciousSchemes = [
            "cydia://",
            "sileo://",
            "zebra://",
            "dopamine://",
            "ssh://",
            "telnet://",
            "ftpd://"
        ]
        
        for scheme in suspiciousSchemes {
            if let url = URL(string: scheme), UIApplication.shared.canOpenURL(url) {
                return true
            }
        }
        return false
    }
    
    static func checkSuspiciousFiles() -> Bool {
        let suspiciousFiles = [
            "/Applications/Cydia.app",
            "/Applications/Sileo.app",
            "/Applications/Zebra.app",
            "/Applications/Dopamine.app",
            "/bin/bash",
            "/bin/sh",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/usr/libexec/ssh-keysign",
            "/usr/libexec/sudo",
            "/private/var/lib/cydia"
        ]
        
        for file in suspiciousFiles {
            if FileManager.default.fileExists(atPath: file) {
                return true
            }
        }
        return false
    }
    
    static func checkWritableDirectories() -> Bool {
        let paths = [
            "/private/var/stash",
            "/private/tmp",
            "/private/var/mobile/Library",
            "/private/var/mobile/Applications",
            "/private/var/mobile/.ssh"
        ]
        
        for path in paths {
            do {
                let testFilePath = path + "/test.txt"
                let content = "test"
                try content.write(toFile: testFilePath, atomically: true, encoding: .utf8)
                try FileManager.default.removeItem(atPath: testFilePath)
                return true
            } catch {
                continue
            }
        }
        return false
    }
    
    static func checkSymbolicLinks() -> Bool {
        let suspiciousLinks = [
            "/private/var/lib/apt",
            "/private/var/mobile/Media",
            "/private/var/stash"
        ]
        
        for link in suspiciousLinks {
            if let destination = try? FileManager.default.destinationOfSymbolicLink(atPath: link), !destination.isEmpty {
                return true
            }
        }
        return false
    }
    
    static func checkOpenSystemFiles() -> Bool {
        let systemFiles = [
            "/private/var/run/launchd",
            "/private/var/db/.bash_history",
            "/private/etc/hosts"
        ]
        
        for file in systemFiles {
            if FileManager.default.isReadableFile(atPath: file) {
                return true
            }
        }
        return false
    }
    
    static func checkForJailbreakTweaks() -> Bool {
        let tweakFiles = [
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/Library/dpkg/info/com.saurik.cydia.list",
            "/usr/lib/libhooker.dylib"
        ]
        
        for file in tweakFiles {
            if FileManager.default.fileExists(atPath: file) {
                return true
            }
        }
        return false
    }
    
    static func isJailbroken(completion: @escaping (Bool) -> Void) {
        let urlSchemesResult = checkURLSchemes()
        let suspiciousFilesResult = checkSuspiciousFiles()
        let writableDirsResult = checkWritableDirectories()
        let symbolicLinksResult = checkSymbolicLinks()
        let systemFilesResult = checkOpenSystemFiles()
        let tweaksResult = checkForJailbreakTweaks()
        
        var detectionFlags: UInt8 = 0
        if urlSchemesResult { detectionFlags |= 0x01 }
        if suspiciousFilesResult { detectionFlags |= 0x02 }
        if writableDirsResult { detectionFlags |= 0x04 }
        if symbolicLinksResult { detectionFlags |= 0x08 }
        if systemFilesResult { detectionFlags |= 0x10 }
        if tweaksResult { detectionFlags |= 0x20 }

        completion(detectionFlags != 0)
    }
    
    static func isJailbrokenWithStates(
        onStateUpdate: @escaping ChallengeStateUpdate
    ) {
        onStateUpdate(.started)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.loadingDelay) {
            onStateUpdate(.loading)
            
            DispatchQueue.global(qos: .userInitiated).async {
                Thread.sleep(forTimeInterval: Constants.detectionDelay)
                
                var detected = false
                isJailbroken { result in
                    detected = result
                }
                
                let finalResult: Result<Bool, Error> = .success(!detected)
                
                DispatchQueue.main.async {
                    onStateUpdate(.finished(finalResult))
                }
            }
        }
    }
}
