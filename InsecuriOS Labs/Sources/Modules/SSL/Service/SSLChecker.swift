import Foundation
import Security
import CommonCrypto
import Alamofire
import TrustKit

final class SSLChecker: NSObject {
    
    typealias ChallengeStateUpdate = (ChallengeState) -> Void
    
    private static let domain = "github.com"
    private static let wildcardHost = "*.\(domain)"
    private static let testURLString = "https://\(domain)"
    private static let pinnedPublicKeyHash = "sha256/e4wu8h9eLNeNUg6cVb5gGWM0PsiM9M3i3E32qKOkBAA="
    private static let pinnedPublicKeyHashBackup = "sha256/UoSFbDIf6Y0eWzco1ugHE7sHyQ92pZsc8thjcgMsaAB="
    private static let expectedHash = pinnedPublicKeyHash.replacingOccurrences(of: "sha256/", with: "")
    
    private enum Constants {
        static let loadingDelay: TimeInterval = 0.5
        static let operationDelay: TimeInterval = 1.0
    }
    
    private static func extractSPKI(from certificateData: Data) -> Data? {
        var offset = 0
        
        func readASN1Length(at: Int) -> (length: Int, bytesRead: Int)? {
            guard at < certificateData.count else { return nil }
            
            if certificateData[at] & 0x80 == 0 {
                return (Int(certificateData[at]), 1)
            } else {
                let lengthOfLength = Int(certificateData[at] & 0x7F)
                guard lengthOfLength > 0 && lengthOfLength <= 4 else { return nil }
                guard at + 1 + lengthOfLength <= certificateData.count else { return nil }
                
                var length = 0
                for i in 1...(lengthOfLength) {
                    length = (length << 8) | Int(certificateData[at + i])
                }
                return (length, lengthOfLength + 1)
            }
        }
        
        func skipASN1Element(at: Int) -> Int? {
            guard at < certificateData.count, let lengthInfo = readASN1Length(at: at + 1) else { return nil }
            return at + 1 + lengthInfo.bytesRead + lengthInfo.length
        }
        
        guard certificateData[offset] == 0x30 else { return nil }
        offset += 1
        
        guard let outerLengthInfo = readASN1Length(at: offset) else { return nil }
        offset += outerLengthInfo.bytesRead
        
        guard certificateData[offset] == 0x30 else { return nil }
        offset += 1
        
        guard let tbsLengthInfo = readASN1Length(at: offset) else { return nil }
        offset += tbsLengthInfo.bytesRead
        let tbsEnd = offset + tbsLengthInfo.length
        
        let skipTags: [UInt8] = [0xA0, 0x80, 0x02, 0x30, 0x30, 0x30, 0x30]
        for tag in skipTags {
            if offset < tbsEnd && certificateData[offset] == tag {
                guard let newOffset = skipASN1Element(at: offset) else { return nil }
                offset = newOffset
            }
        }
        
        guard offset < tbsEnd && certificateData[offset] == 0x30 else { return nil }
        let spkiStart = offset
        
        guard let spkiLengthInfo = readASN1Length(at: offset + 1) else { return nil }
        let spkiLength = 1 + spkiLengthInfo.bytesRead + spkiLengthInfo.length
        
        guard spkiStart + spkiLength <= certificateData.count else { return nil }
        
        return certificateData.subdata(in: spkiStart..<(spkiStart + spkiLength))
    }
    
    private static func calculateSHA256Hash(from data: Data) -> String {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { bytes in
            _ = CC_SHA256(bytes.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash).base64EncodedString()
    }
    
    private static func validateCertificateChain(_ trust: SecTrust, expectedHash: String) -> Bool {
        let certificateCount = SecTrustGetCertificateCount(trust)
        
        for index in 0..<certificateCount {
            guard let certificate = SecTrustGetCertificateAtIndex(trust, index) else { continue }
            guard let certificateData = SecCertificateCopyData(certificate) as Data? else { continue }
            guard let spkiData = extractSPKI(from: certificateData) else { continue }
            
            let publicKeyHash = calculateSHA256Hash(from: spkiData)
            if publicKeyHash == expectedHash {
                return true
            }
        }
        
        return false
    }
    
    private static func validateHostname(_ hostname: String) -> Bool {
        return hostname.hasSuffix(domain)
    }
    
    static func checkSSLWithURLSession() -> Bool {
        guard let url = URL(string: testURLString) else { return false }
        
        var result: Bool = false
        let group = DispatchGroup()
        
        DispatchQueue.global(qos: .userInitiated).async(group: group) {
            result = performURLSessionCheck(url: url)
        }
        
        _ = group.wait(timeout: .now() + 10)
        return result
    }
    
    private static func performURLSessionCheck(url: URL) -> Bool {
        var pinningSuccess = false
        let delegate = SSLChecker()
        let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = session.dataTask(with: url) { data, response, error in
            if error == nil, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                pinningSuccess = true
            }
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        session.invalidateAndCancel()
        
        return pinningSuccess
    }
    
    static func checkSSLWithAlamofire() -> Bool {
        guard let url = URL(string: testURLString) else { return false }
        
        var result: Bool = false
        let group = DispatchGroup()
        
        DispatchQueue.global(qos: .userInitiated).async(group: group) {
            result = performAlamofireCheck(url: url)
        }
        
        _ = group.wait(timeout: .now() + 10)
        return result
    }
    
    private static func performAlamofireCheck(url: URL) -> Bool {
        var pinningSuccess = false
        
        struct PublicKeyPinningEvaluator: ServerTrustEvaluating {
            let expectedHash: String
            
            func evaluate(_ trust: SecTrust, forHost host: String) throws {
                var error: CFError?
                guard SecTrustEvaluateWithError(trust, &error) else {
                    throw AFError.serverTrustEvaluationFailed(reason: .noCertificatesFound)
                }
                
                guard SSLChecker.validateCertificateChain(trust, expectedHash: expectedHash) else {
                    throw AFError.serverTrustEvaluationFailed(reason: .certificatePinningFailed(host: host, trust: trust, pinnedCertificates: [], serverCertificates: []))
                }
            }
        }
        
        let evaluator = PublicKeyPinningEvaluator(expectedHash: expectedHash)
        let session = Session(serverTrustManager: ServerTrustManager(evaluators: [
            domain: evaluator,
            wildcardHost: evaluator
        ]))
        
        let semaphore = DispatchSemaphore(value: 0)
        session.request(url).validate().response(queue: .global()) { response in
            pinningSuccess = (response.response?.statusCode == 200)
            semaphore.signal()
        }
        
        semaphore.wait()
        return pinningSuccess
    }
    
    static func checkSSLWithTrustKit() -> Bool {
        guard let url = URL(string: testURLString) else { return false }
        
        let trustKitConfig: [String: Any] = [
            kTSKSwizzleNetworkDelegates: false,
            kTSKPinnedDomains: [
                domain: [
                    kTSKPublicKeyHashes: [
                        expectedHash,
                        pinnedPublicKeyHashBackup.replacingOccurrences(of: "sha256/", with: "")
                    ],
                    kTSKEnforcePinning: true,
                    kTSKIncludeSubdomains: true
                ]
            ]
        ]
        
        TrustKit.initSharedInstance(withConfiguration: trustKitConfig)
        
        var pinningSuccess = false
        let session = URLSession(configuration: .default, delegate: TrustKitURLSessionDelegate(), delegateQueue: nil)
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = session.dataTask(with: url) { data, response, error in
            pinningSuccess = (error == nil && (response as? HTTPURLResponse)?.statusCode == 200)
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        session.invalidateAndCancel()
        
        return pinningSuccess
    }
    
    static func checkSSLWithURLSessionWithStates(
        onStateUpdate: @escaping ChallengeStateUpdate
    ) {
        onStateUpdate(.started)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.loadingDelay) {
            onStateUpdate(.loading)
            
            DispatchQueue.global(qos: .userInitiated).async {
                Thread.sleep(forTimeInterval: Constants.operationDelay)
                
                let result = checkSSLWithURLSession()
                let finalResult: Result<Bool, Error> = .success(result)
                
                DispatchQueue.main.async {
                    onStateUpdate(.finished(finalResult))
                }
            }
        }
    }
    
    static func checkSSLWithAlamofireWithStates(
        onStateUpdate: @escaping ChallengeStateUpdate
    ) {
        onStateUpdate(.started)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.loadingDelay) {
            onStateUpdate(.loading)
            
            DispatchQueue.global(qos: .userInitiated).async {
                Thread.sleep(forTimeInterval: Constants.operationDelay)
                
                let result = checkSSLWithAlamofire()
                let finalResult: Result<Bool, Error> = .success(result)
                
                DispatchQueue.main.async {
                    onStateUpdate(.finished(finalResult))
                }
            }
        }
    }
    
    static func checkSSLWithTrustKitWithStates(
        onStateUpdate: @escaping ChallengeStateUpdate
    ) {
        onStateUpdate(.started)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.loadingDelay) {
            onStateUpdate(.loading)
            
            DispatchQueue.global(qos: .userInitiated).async {
                Thread.sleep(forTimeInterval: Constants.operationDelay)
                
                let result = checkSSLWithTrustKit()
                let finalResult: Result<Bool, Error> = .success(result)
                
                DispatchQueue.main.async {
                    onStateUpdate(.finished(finalResult))
                }
            }
        }
    }
}

// MARK: - URLSessionDelegate for URLSession implementation
extension SSLChecker: URLSessionDelegate {
    
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        let hostname = challenge.protectionSpace.host
        
        guard SSLChecker.validateHostname(hostname) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        let policies = [SecPolicyCreateSSL(true, hostname as CFString)]
        SecTrustSetPolicies(serverTrust, policies as CFTypeRef)
        
        var error: CFError?
        guard SecTrustEvaluateWithError(serverTrust, &error) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        if SSLChecker.validateCertificateChain(serverTrust, expectedHash: SSLChecker.expectedHash) {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}

// MARK: - URLSessionDelegate for TrustKit implementation
final class TrustKitURLSessionDelegate: NSObject, URLSessionDelegate {
    
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        if TrustKit.sharedInstance().pinningValidator.handle(challenge, completionHandler: completionHandler) == false {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
