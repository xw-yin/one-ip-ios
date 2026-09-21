import Foundation

public struct PingRegion: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let code: String
    public let iconName: String
    
    public var minLatency: Double?
    public var avgLatency: Double?
    public var maxLatency: Double?
    public var packetLoss: Double?
    public var isChecking: Bool
    
    public init(
        id: String,
        name: String,
        code: String,
        iconName: String,
        minLatency: Double? = nil,
        avgLatency: Double? = nil,
        maxLatency: Double? = nil,
        packetLoss: Double? = nil,
        isChecking: Bool = false
    ) {
        self.id = id
        self.name = name
        self.code = code
        self.iconName = iconName
        self.minLatency = minLatency
        self.avgLatency = avgLatency
        self.maxLatency = maxLatency
        self.packetLoss = packetLoss
        self.isChecking = isChecking
    }
}

public enum PingPresets {
    public static let defaultRegions: [PingRegion] = [
        PingRegion(id: "AS", name: "亚洲 (Asia)", code: "AS", iconName: "globe.asia.australia.fill"),
        PingRegion(id: "NA", name: "北美洲 (North America)", code: "NA", iconName: "globe.americas.fill"),
        PingRegion(id: "EU", name: "欧洲 (Europe)", code: "EU", iconName: "globe.europe.africa.fill"),
        PingRegion(id: "OC", name: "大洋洲 (Oceania)", code: "OC", iconName: "globe.central.south.asia.fill"),
        PingRegion(id: "SA", name: "南美洲 (South America)", code: "SA", iconName: "globe.americas.fill"),
        PingRegion(id: "AF", name: "非洲 (Africa)", code: "AF", iconName: "globe.europe.africa.fill")
    ]
}

public struct DNSResolverItem: Identifiable, Equatable, Sendable {
    public let id: String
    public let sourceName: String
    public var resolverIp: String?
    public var geoSummary: String?
    public var isChecking: Bool
    public var errorDescription: String?
    
    public init(
        id: String,
        sourceName: String,
        resolverIp: String? = nil,
        geoSummary: String? = nil,
        isChecking: Bool = false,
        errorDescription: String? = nil
    ) {
        self.id = id
        self.sourceName = sourceName
        self.resolverIp = resolverIp
        self.geoSummary = geoSummary
        self.isChecking = isChecking
        self.errorDescription = errorDescription
    }
}
