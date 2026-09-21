import Foundation
import CoreLocation

public struct GeoInfo: Codable, Equatable, Sendable {
    public var ip: String
    public var country: String?
    public var countryCode: String?
    public var region: String?
    public var city: String?
    public var isp: String?
    public var asn: String?
    public var latitude: Double?
    public var longitude: Double?
    public var timezone: String?
    public var source: String?
    
    public init(
        ip: String,
        country: String? = nil,
        countryCode: String? = nil,
        region: String? = nil,
        city: String? = nil,
        isp: String? = nil,
        asn: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        timezone: String? = nil,
        source: String? = nil
    ) {
        self.ip = ip
        self.country = country
        self.countryCode = countryCode
        self.region = region
        self.city = city
        self.isp = isp
        self.asn = asn
        self.latitude = latitude
        self.longitude = longitude
        self.timezone = timezone
        self.source = source
    }
    
    public var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude,
              lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180 else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    public var flagEmoji: String {
        guard let code = countryCode, code.count == 2 else { return "🌐" }
        let base: UInt32 = 127397
        var scalarView = String.UnicodeScalarView()
        for scalar in code.uppercased().unicodeScalars {
            guard let newScalar = UnicodeScalar(base + scalar.value) else { return "🌐" }
            scalarView.append(newScalar)
        }
        return String(scalarView)
    }
    
    public var locationSummary: String {
        let parts = [city, region, country].compactMap { $0 }.filter { !$0.isEmpty }
        return parts.isEmpty ? t("未知地理位置") : parts.joined(separator: ", ")
    }
}

public struct RiskFlags: Codable, Equatable, Sendable {
    public var isResidential: Bool?
    public var isDatacenter: Bool?
    public var isMobile: Bool?
    public var isVpn: Bool?
    public var isProxy: Bool?
    public var isTor: Bool?
    public var isCrawler: Bool?
    public var isAbuse: Bool?
    
    public init(
        isResidential: Bool? = nil,
        isDatacenter: Bool? = nil,
        isMobile: Bool? = nil,
        isVpn: Bool? = nil,
        isProxy: Bool? = nil,
        isTor: Bool? = nil,
        isCrawler: Bool? = nil,
        isAbuse: Bool? = nil
    ) {
        self.isResidential = isResidential
        self.isDatacenter = isDatacenter
        self.isMobile = isMobile
        self.isVpn = isVpn
        self.isProxy = isProxy
        self.isTor = isTor
        self.isCrawler = isCrawler
        self.isAbuse = isAbuse
    }
}

public enum HealthStatus: String, Codable, Sendable {
    case good = "good"
    case moderate = "moderate"
    case poor = "poor"
    case unknown = "unknown"
    
    public var displayText: String {
        switch self {
        case .good: return t("score_good")
        case .moderate: return t("score_moderate")
        case .poor: return t("score_poor")
        case .unknown: return t("score_unknown")
        }
    }
}

public struct IPHealthScore: Codable, Equatable, Sendable {
    public var score: Int?
    public var status: HealthStatus
    public var checkedAt: Date
    public var flags: RiskFlags
    
    public init(
        score: Int? = nil,
        status: HealthStatus = .unknown,
        checkedAt: Date = Date(),
        flags: RiskFlags = RiskFlags()
    ) {
        self.score = score
        self.status = status
        self.checkedAt = checkedAt
        self.flags = flags
    }
}

public struct BGPInfo: Codable, Equatable, Sendable {
    public var prefix: String?
    public var asn: String?
    public var holder: String?
    public var registry: String?
    public var ptr: String?
    
    public init(
        prefix: String? = nil,
        asn: String? = nil,
        holder: String? = nil,
        registry: String? = nil,
        ptr: String? = nil
    ) {
        self.prefix = prefix
        self.asn = asn
        self.holder = holder
        self.registry = registry
        self.ptr = ptr
    }
}

public struct ExitRouteItem: Identifiable, Equatable, Sendable {
    public var id: String { name }
    public var name: String
    public var domain: String
    public var iconName: String
    public var exitIp: String?
    public var countryCode: String?
    public var colo: String?
    public var latencyMs: Int?
    public var isChecking: Bool
    public var isReachable: Bool
    
    public init(
        name: String,
        domain: String,
        iconName: String,
        exitIp: String? = nil,
        countryCode: String? = nil,
        colo: String? = nil,
        latencyMs: Int? = nil,
        isChecking: Bool = false,
        isReachable: Bool = false
    ) {
        self.name = name
        self.domain = domain
        self.iconName = iconName
        self.exitIp = exitIp
        self.countryCode = countryCode
        self.colo = colo
        self.latencyMs = latencyMs
        self.isChecking = isChecking
        self.isReachable = isReachable
    }
}
