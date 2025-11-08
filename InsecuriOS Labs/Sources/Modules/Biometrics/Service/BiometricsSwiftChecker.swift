import LocalAuthentication

final class BiometricsSwiftChecker {
    static func isBiometricAuthenticationAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    static func authenticateUser(completion: @escaping (Bool, Error?) -> Void) {
        let context = LAContext()
        
        guard isBiometricAuthenticationAvailable() else {
            completion(false, NSError(domain: "Biometrics", code: -1, userInfo: [NSLocalizedDescriptionKey: "Biometrics not available"]))
            return
        }
        
        let reason = "Please authenticate yourself"
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
}
