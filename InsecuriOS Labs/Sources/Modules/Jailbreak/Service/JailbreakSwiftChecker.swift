import UIKit

final class JailbreakSwiftChecker {
    
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
    
    static func isJailbroken() -> Bool {
        if checkURLSchemes() || checkSuspiciousFiles() || checkWritableDirectories() ||
            checkSymbolicLinks() || checkOpenSystemFiles() || checkForJailbreakTweaks() {
            return true
        }
        return false
    }
}
