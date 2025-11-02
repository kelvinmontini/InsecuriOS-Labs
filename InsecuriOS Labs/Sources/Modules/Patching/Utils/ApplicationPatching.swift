import Foundation
import IOSSecuritySuite

typealias ptrace_t = @convention(c) (Int32, Int32, UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> Int32

final class ApplicationPatching {
    
    func denyDebuggerExternal() {
        IOSSecuritySuite.denyDebugger()
    }
    
    func denyDebuggerInternal() {
        if let handle = dlopen(nil, RTLD_GLOBAL | RTLD_NOW) {
            
            if let ptrace = dlsym(handle, "ptrace") {
                let ptraceFunc = unsafeBitCast(ptrace, to: ptrace_t.self)
                _ = ptraceFunc(31, 0, nil, nil)
            }
            
            dlclose(handle)
        }
    }
    
    func killApplication() {
        exit(-1)
    }
    
    func showAlert() {
        HLUtils.showAlert(title: "I love Apple!")
    }
}
