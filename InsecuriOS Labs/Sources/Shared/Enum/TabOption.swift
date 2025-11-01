import UIKit

enum TabOption: String, CaseIterable {
    case home = "Home"
    case instrumentation = "Instrumentation"
    case storage = "Data Storage"
    case jailbreakDetection = "Jailbreak Detection"
    case sslPinning = "SSL Pinning"
    case biometrics = "Touch ID / Face ID"
    
    var icon: String {
        switch self {
        case .home: return "house"
        case .storage: return "externaldrive"
        case .instrumentation: return "wrench"
        case .jailbreakDetection: return "iphone.homebutton"
        case .sslPinning: return "wifi.slash"
        case .biometrics: return "faceid"
        }
    }
}
