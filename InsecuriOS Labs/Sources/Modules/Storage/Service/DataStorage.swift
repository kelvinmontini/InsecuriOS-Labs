import Foundation
import Security

final class DataStorage {
    
    typealias ChallengeStateUpdate = (ChallengeState) -> Void
    
    private enum Constants {
        static let loadingDelay: TimeInterval = 0.5
        static let operationDelay: TimeInterval = 1.5
    }
    
    init() {
        let encrypted = "\u{30}\u{71}\u{76}\u{26}\u{39}\u{72}\u{2c}\u{2e}\u{3b}\u{6f}\u{29}\u{71}\u{3b}\u{21}\u{2a}\u{76}\u{73}\u{2c}\u{6f}\u{34}\u{76}\u{2e}\u{37}\u{71}\u{63}\u{3f}"
        addKey(encryptedValue: encrypted, account: "InsecuriOSReadOnly", service: "InsecuriOSServiceReadOnly")
    }
    
    func saveAndDeleteKeychain(key: String) {
        addKey(encryptedValue: key)
        deleteKey()
    }
    
    func saveAndDeleteKeychainWithStates(
        key: String,
        onStateUpdate: @escaping ChallengeStateUpdate
    ) {
        onStateUpdate(.started)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.loadingDelay) {
            onStateUpdate(.loading)
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            Thread.sleep(forTimeInterval: Constants.operationDelay)
            
            guard let self = self else {
                DispatchQueue.main.async {
                    onStateUpdate(.finished(.success(false)))
                }
                return
            }
            
            self.addKey(encryptedValue: key)
            self.deleteKey()
            
            let result: Result<Bool, Error> = .success(false)
            DispatchQueue.main.async {
                onStateUpdate(.finished(result))
            }
        }
    }
    
    func saveAndDeleteNSUserDefaultsWithStates(
        onStateUpdate: @escaping ChallengeStateUpdate
    ) {
        onStateUpdate(.started)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.loadingDelay) {
            onStateUpdate(.loading)
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            Thread.sleep(forTimeInterval: Constants.operationDelay)
            
            guard let self = self else {
                DispatchQueue.main.async {
                    onStateUpdate(.finished(.success(false)))
                }
                return
            }
            
            self.saveAndDeleteNSUserDefaults()
            
            let result: Result<Bool, Error> = .success(false)
            DispatchQueue.main.async {
                onStateUpdate(.finished(result))
            }
        }
    }
    
    func saveAndDeleteNSUserDefaults() {
        let key = "InsecuriOS"
        let encrypted = "\u{26}\u{71}\u{24}\u{76}\u{39}\u{37}\u{31}\u{71}\u{30}\u{6f}\u{26}\u{71}\u{24}\u{76}\u{37}\u{73}\u{36}\u{77}\u{6f}\u{76}\u{30}\u{71}\u{6f}\u{35}\u{71}\u{76}\u{29}\u{63}\u{3f}"

        let decryptKey: UInt8 = 0x42
        let decrypted = encrypted.utf8.map { Character(UnicodeScalar($0 ^ decryptKey)) }
        let value = String(decrypted)
        
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
        
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    func keychainDumpWithStates(
        onStateUpdate: @escaping ChallengeStateUpdate
    ) {
        onStateUpdate(.started)
        
        DispatchQueue.global(qos: .userInitiated).async {
            let result: Result<Bool, Error> = .success(false)
            DispatchQueue.main.async {
                onStateUpdate(.finished(result))
            }
        }
    }
    
    static func encrypt(_ plain: String) -> String {
        let key: UInt8 = 0x42
        let encrypted = plain.utf8.map { Character(UnicodeScalar($0 ^ key)) }
        return String(encrypted)
    }
    
    private func addKey(value: String, account: String = "InsecuriOS", service: String = "InsecuriOSService") {
        guard let data = value.data(using: .utf8) else {
            return
        }
        
        let dict: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]
        
        _ = SecItemAdd(dict as CFDictionary, nil)
    }
    
    private func addKey(encryptedValue: String, account: String = "InsecuriOS", service: String = "InsecuriOSService") {
        let key: UInt8 = 0x42
        let decrypted = encryptedValue.utf8.map { Character(UnicodeScalar($0 ^ key)) }
        let value = String(decrypted)
        
        guard let data = value.data(using: .utf8) else {
            return
        }
        
        let dict: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]
        
        let status = SecItemAdd(dict as CFDictionary, nil)

        if status == errSecDuplicateItem {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: account,
                kSecAttrService as String: service,
            ]
            
            let updateDict: [String: Any] = [
                kSecValueData as String: data,
            ]
            
            _ = SecItemUpdate(query as CFDictionary, updateDict as CFDictionary)
        }
    }
    
    private func deleteKey() {
        let dict: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "InsecuriOS",
            kSecAttrService as String: "InsecuriOSService",
        ]
        
        _ = SecItemDelete(dict as CFDictionary)
    }
}
