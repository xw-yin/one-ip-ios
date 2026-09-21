import Foundation

public final class RDAPService: Sendable {
    public static let shared = RDAPService()
    private let network = NetworkService.shared
    
    public func lookup(query: String) async throws -> RDAPResult {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw NetworkError.invalidURL }
        
        let path: String
        if trimmed.uppercased().hasPrefix("AS") && trimmed.count > 2 && Int(trimmed.dropFirst(2)) != nil {
            let num = String(trimmed.dropFirst(2))
            path = "autnum/\(num)"
        } else if trimmed.contains(":") || trimmed.components(separatedBy: ".").count == 4 && trimmed.allSatisfy({ $0.isNumber || $0 == "." }) {
            path = "ip/\(trimmed)"
        } else {
            path = "domain/\(trimmed)"
        }
        
        let url = "https://rdap.org/\(path)"
        let (rawJson, _) = try await network.fetchString(from: url, timeout: 6.0)
        
        // Parse RDAP
        struct RDAPPayload: Decodable {
            let handle: String?
            let name: String?
            let ldhName: String?
            let objectClassName: String?
            let status: [String]?
            struct Event: Decodable {
                let eventAction: String?
                let eventDate: String?
            }
            let events: [Event]?
            struct Entity: Decodable {
                let handle: String?
                let roles: [String]?
            }
            let entities: [Entity]?
            struct Nameserver: Decodable {
                let ldhName: String?
            }
            let nameservers: [Nameserver]?
        }
        
        guard let data = rawJson.data(using: .utf8) else {
            return RDAPResult(query: trimmed, rawJsonString: rawJson)
        }
        
        let payload = try? JSONDecoder().decode(RDAPPayload.self, from: data)
        
        var regDate: String?
        var expDate: String?
        if let events = payload?.events {
            for e in events {
                if e.eventAction == "registration" { regDate = e.eventDate }
                if e.eventAction == "expiration" { expDate = e.eventDate }
            }
        }
        
        let registrar = payload?.entities?.first(where: { $0.roles?.contains("registrar") == true })?.handle
        let ns = payload?.nameservers?.compactMap { $0.ldhName }
        
        return RDAPResult(
            query: trimmed,
            source: "RDAP.org",
            name: payload?.ldhName ?? payload?.name,
            handle: payload?.handle,
            objectClassName: payload?.objectClassName,
            status: payload?.status,
            registrationDate: regDate,
            expirationDate: expDate,
            registrar: registrar,
            nameservers: ns,
            rawJsonString: rawJson
        )
    }
}
