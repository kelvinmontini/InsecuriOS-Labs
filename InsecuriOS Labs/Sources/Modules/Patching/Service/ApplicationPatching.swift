import Foundation
import Darwin
import UIKit

typealias ptrace_t = @convention(c) (Int32, Int32, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> Int32

final class ApplicationPatching {
    
    typealias ChallengeStateUpdate = (ChallengeState) -> Void

    private struct DebugCheckResult {
        let processInfo: extern_proc?
        let ptraceResult: Int32
        let ptraceErrno: Int32
    }
    
    private enum Constants {
        static let loadingDelay: TimeInterval = 0.5
        static let detectionDelay: TimeInterval = 2.0
    }
    
    private func createResult(challengeFailed: Bool) -> Result<Bool, Error> {
        return .success(challengeFailed)
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
            
            guard let checkResult = self?.checkDebugger() else {
                let result = self?.createResult(challengeFailed: false) ?? .success(false)
                DispatchQueue.main.async {
                    onStateUpdate(.finished(result))
                }
                return
            }
            
            var debuggerDetected = false
            
            if let processInfo = checkResult.processInfo {
                let flagValue = processInfo.p_flag
                let directCheck = (flagValue & P_TRACED) != 0
                let shiftCheck = ((flagValue >> 11) & 1) == 1
                let tamperingDetected = directCheck != shiftCheck
                debuggerDetected = directCheck || tamperingDetected
            }
            
            if !debuggerDetected {
                let ptraceDetected = checkResult.ptraceResult == -1 && checkResult.ptraceErrno == EPERM
                debuggerDetected = ptraceDetected
            }
            
            let result = self?.createResult(challengeFailed: debuggerDetected) ?? .success(false)
            
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
            
            guard let processInfo = self?.isDebuggerAttached() else {
                let result = self?.createResult(challengeFailed: false) ?? .success(false)
                DispatchQueue.main.async {
                    onStateUpdate(.finished(result))
                }
                return
            }
            
            let flagValue = processInfo.p_flag
            let directCheck = (flagValue & P_TRACED) != 0
            let shiftCheck = ((flagValue >> 11) & 1) == 1
            let tamperingDetected = directCheck != shiftCheck
            let debuggerDetected = directCheck || tamperingDetected
            let result = self?.createResult(challengeFailed: debuggerDetected) ?? .success(false)
            
            DispatchQueue.main.async {
                onStateUpdate(.finished(result))
            }
        }
    }
    
    @inline(never)
    func getTextInMemory() {
        let alertController = UIAlertController(
            title: "Neo",
            message: "There is no spoon",
            preferredStyle: .alert
        )

        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)

        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    private func isDebuggerAttached() -> extern_proc? {
        var kinfo = kinfo_proc()
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout<kinfo_proc>.stride
        
        let sysctlRet = sysctl(&mib, UInt32(mib.count), &kinfo, &size, nil, 0)
        
        guard sysctlRet == 0 else {
            return nil
        }
        
        return kinfo.kp_proc
    }
    
    private func checkDebugger() -> DebugCheckResult {
        var kinfo = kinfo_proc()
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout<kinfo_proc>.stride
        
        let sysctlRet = sysctl(&mib, UInt32(mib.count), &kinfo, &size, nil, 0)
        let processInfo = sysctlRet == 0 ? kinfo.kp_proc : nil
        
        guard let handle = dlopen(nil, RTLD_GLOBAL | RTLD_NOW) else {
            return DebugCheckResult(processInfo: processInfo, ptraceResult: 0, ptraceErrno: 0)
        }
        
        defer {
            dlclose(handle)
        }
        
        guard let ptrace = dlsym(handle, "ptrace") else {
            return DebugCheckResult(processInfo: processInfo, ptraceResult: 0, ptraceErrno: 0)
        }
        
        let ptraceFunc = unsafeBitCast(ptrace, to: ptrace_t.self)
        let PT_DENY_ATTACH: Int32 = 31
        let result = ptraceFunc(PT_DENY_ATTACH, 0, nil, nil)
        let currentErrno = result == -1 ? errno : 0
        
        return DebugCheckResult(processInfo: processInfo, ptraceResult: result, ptraceErrno: currentErrno)
    }
}
