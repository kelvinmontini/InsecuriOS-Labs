import Foundation
import Security

final class DataStorage {
    
    init() {
        addKey(value: "c4N{you-see-me?}", account: "InsecuriOSReadOnly", service: "InsecuriOSServiceReadOnly")
    }
    
    func saveAndDeleteKeychain(key: String) {
        addKey(value: key)
        deleteKey()
    }
    
    func saveAndDeleteNSUserDefaults() {
        let key = "InsecuriOS"
        
        UserDefaults.standard.set("1o5{n5-d3f4u1l-4r3-5uck5}", forKey: key)
        UserDefaults.standard.synchronize()
        
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
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
    
    private func deleteKey() {
        let dict: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "InsecuriOS",
            kSecAttrService as String: "InsecuriOSService",
        ]
        
        _ = SecItemDelete(dict as CFDictionary)
    }
}
