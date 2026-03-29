import Foundation
import ServiceManagement

// MARK: - Privileged Helper Tool Manager

/// Apple'ın SMJobBless API'si üzerinden Root gerektiren işlemleri yürütmek için tasarlanan 
/// mimari katmandır. "/Library" gibi salt okunur dizinlere müdahale edilmesi, purge komutu gibi
/// sistem yönetimi işlemlerinin şifre sorulmadan yapılmasını sağlamak için kullanılır.
/// 
/// Kurulum:
/// 1. Yeni bir "XPC Services" hedefine sahip Helper Tool projesi eklenmeli.
/// 2. Info.plist içerisine `SMAuthorizedClients` (Clean Magic) eklenmeli.
/// 3. Helper Tool'un Info.plist'ine `SMServerPrivilege` tanımlanmalı.
final class HelperToolManager {
    
    static let shared = HelperToolManager()
    private let helperToolLabel = "com.topcuyazilim.clean-magic-arbiter.helper"
    
    private init() {}
    
    // MARK: - Installation
    
    /// Privileged Helper Tool'un kurulu olup olmadığını ve güncelliğini kontrol eder.
    /// Gerekirse kullanıcı onayı (Admin Prompt) ile SMJobBless üzerinden aracı sisteme yükler.
    func installHelperToolIfNeeded() throws {
        var authRef: AuthorizationRef?
        var authItem = AuthorizationItem(
            name: kSMRightBlessPrivilegedHelper,
            valueLength: 0,
            value: nil,
            flags: 0
        )
        
        var authRights = AuthorizationRights(count: 1, items: &authItem)
        let flags: AuthorizationFlags = [.interactionAllowed, .extendRights, .preAuthorize]
        
        let status = AuthorizationCreate(&authRights, nil, flags, &authRef)
        
        guard status == errAuthorizationSuccess, let auth = authRef else {
            throw HelperError.authorizationFailed
        }
        
        var error: Unmanaged<CFError>?
        let success = SMJobBless(
            kSMDomainSystemLaunchd,
            helperToolLabel as CFString,
            auth,
            &error
        )
        
        if !success {
            let errorDesc = error?.takeRetainedValue().localizedDescription ?? "Unknown failure"
            throw HelperError.installationFailed(errorDesc)
        }
    }
    
    // MARK: - Invocation (XPC Connection)
    
    /// Helper Tool'u çağırarak yüksek yetkili işlemi (ör: root dizininde dosya silme veya purge) yaptırır.
    func performPrivilegedTask(endpoint: String, payload: [String: Any]) async throws {
        let connection = NSXPCConnection(machServiceName: helperToolLabel, options: .privileged)
        // connection.remoteObjectInterface = NSXPCInterface(with: PrivilegedProtocol.self)
        // connection.resume()
        
        // ... XPC üzerinden proxy nesnesini alıp RPC çağrısı yap.
    }
}

// MARK: - Errors

enum HelperError: LocalizedError {
    case authorizationFailed
    case installationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .authorizationFailed:
            return "Kullanıcı yönetici yetkilerini reddetti veya yetki alınamadı."
        case .installationFailed(let msg):
            return "SMJobBless aracı sisteme kurulamadı: \(msg)"
        }
    }
}
