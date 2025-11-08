import Foundation
import Darwin

typealias ptrace_t = @convention(c) (Int32, Int32, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> Int32

final class ApplicationPatching {
    
    typealias ChallengeStateUpdate = (ChallengeState) -> Void
    
    private enum Constants {
        static let loadingDelay: TimeInterval = 0.5
        static let detectionDelay: TimeInterval = 2.0
    }
    
    private func createResult(debuggerDetected: Bool) -> Result<Bool, Error> {
        return .success(debuggerDetected)
    }

    func denyDebuggerExternalWithStates(
        onStateUpdate: @escaping ChallengeStateUpdate
    ) {
        onStateUpdate(.started)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.loadingDelay) {
            onStateUpdate(.loading)
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            Thread.sleep(forTimeInterval: Constants.detectionDelay)
            
            let debuggerDetected = self?.isDebuggerAttachedExternal() ?? false
            let result = self?.createResult(debuggerDetected: debuggerDetected) ?? .success(false)
            
            DispatchQueue.main.async {
                onStateUpdate(.finished(result))
            }
        }
    }
    
    func denyDebuggerInternalWithStates(
        onStateUpdate: @escaping ChallengeStateUpdate
    ) {
        onStateUpdate(.started)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.loadingDelay) {
            onStateUpdate(.loading)
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            Thread.sleep(forTimeInterval: Constants.detectionDelay)
            
            let debuggerDetected = self?.isDebuggerAttached() ?? false
            let result = self?.createResult(debuggerDetected: debuggerDetected) ?? .success(false)
            
            DispatchQueue.main.async {
                onStateUpdate(.finished(result))
            }
        }
    }
    
    func verifyTextInMemoryWithStates(
        onStateUpdate: @escaping ChallengeStateUpdate
    ) {
        onStateUpdate(.started)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.loadingDelay) {
            let expectedText = "I love Hacking!"
            let actualText = self.getTextInMemory()
            let isTextIncorrect = actualText != expectedText
            let result = self.createResult(debuggerDetected: isTextIncorrect)
            
            onStateUpdate(.finished(result))
        }
    }
    
    private func getTextInMemory() -> String {
        return "I love Apple!"
    }
    
    private func isDebuggerAttached() -> Bool {
        var kinfo = kinfo_proc()
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout<kinfo_proc>.stride
        
        let sysctlRet = sysctl(&mib, UInt32(mib.count), &kinfo, &size, nil, 0)
        
        if sysctlRet != 0 {
            return false
        }
        
        return (kinfo.kp_proc.p_flag & P_TRACED) != 0
    }
    
    private func isDebuggerAttachedExternal() -> Bool {
        var kinfo = kinfo_proc()
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout<kinfo_proc>.stride
        
        let sysctlRet = sysctl(&mib, UInt32(mib.count), &kinfo, &size, nil, 0)
        
        if sysctlRet == 0 {
            let isTraced = (kinfo.kp_proc.p_flag & P_TRACED) != 0
            
            if isTraced {
                return true
            }
        }
        
        guard let handle = dlopen(nil, RTLD_GLOBAL | RTLD_NOW) else {
            return false
        }
        
        defer {
            dlclose(handle)
        }
        
        guard let ptrace = dlsym(handle, "ptrace") else {
            return false
        }
        
        let ptraceFunc = unsafeBitCast(ptrace, to: ptrace_t.self)
        
        let PT_DENY_ATTACH: Int32 = 31
        let result = ptraceFunc(PT_DENY_ATTACH, 0, nil, nil)
        
        if result == -1 {
            let currentErrno = errno
            if currentErrno == EPERM {
                return true
            }
        }
        
        return false
    }
}
