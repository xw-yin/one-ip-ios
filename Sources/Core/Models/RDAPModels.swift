import Foundation

public struct RDAPResult: Codable, Equatable, Sendable {
    public var query: String
    public var source: String
    public var name: String?
    public var handle: String?
    public var objectClassName: String?
    public var status: [String]?
    public var registrationDate: String?
    public var expirationDate: String?
    public var registrar: String?
    public var nameservers: [String]?
    public var rawJsonString: String?
    
    public init(
        query: String,
        source: String = "RDAP",
        name: String? = nil,
        handle: String? = nil,
        objectClassName: String? = nil,
        status: [String]? = nil,
        registrationDate: String? = nil,
        expirationDate: String? = nil,
        registrar: String? = nil,
        nameservers: [String]? = nil,
        rawJsonString: String? = nil
    ) {
        self.query = query
        self.source = source
        self.name = name
        self.handle = handle
        self.objectClassName = objectClassName
        self.status = status
        self.registrationDate = registrationDate
        self.expirationDate = expirationDate
        self.registrar = registrar
        self.nameservers = nameservers
        self.rawJsonString = rawJsonString
    }
}
