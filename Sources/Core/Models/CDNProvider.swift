import Foundation

public struct CDNNodeItem: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let testUrl: String
    public let isTrace: Bool
    public let targetHeaders: [String]
    
    public var detectedNode: String?
    public var latencyMs: Int?
    public var isChecking: Bool
    public var errorDescription: String?
    
    public init(
        id: String,
        name: String,
        testUrl: String,
        isTrace: Bool = false,
        targetHeaders: [String] = [],
        detectedNode: String? = nil,
        latencyMs: Int? = nil,
        isChecking: Bool = false,
        errorDescription: String? = nil
    ) {
        self.id = id
        self.name = name
        self.testUrl = testUrl
        self.isTrace = isTrace
        self.targetHeaders = targetHeaders
        self.detectedNode = detectedNode
        self.latencyMs = latencyMs
        self.isChecking = isChecking
        self.errorDescription = errorDescription
    }
}

public enum CDNPresets {
    public static let defaultList: [CDNNodeItem] = [
        CDNNodeItem(
            id: "cf_global",
            name: "Cloudflare (Global)",
            testUrl: "https://www.cloudflare.com/cdn-cgi/trace",
            isTrace: true
        ),
        CDNNodeItem(
            id: "cf_china",
            name: "Cloudflare (China CDN)",
            testUrl: "https://perfops.cloudflareperf.com/cdn-cgi/trace",
            isTrace: true
        ),
        CDNNodeItem(
            id: "fastly",
            name: "Fastly",
            testUrl: "https://fastly.jsdelivr.net/npm/react@18/umd/react.production.min.js",
            targetHeaders: ["x-served-by", "fastly-debug-digest"]
        ),
        CDNNodeItem(
            id: "aws_cloudfront",
            name: "AWS CloudFront",
            testUrl: "https://djlzvy5xcvhxt.cloudfront.net/500b-bench.jpg",
            targetHeaders: ["x-amz-cf-pop", "x-amz-cf-id"]
        ),
        CDNNodeItem(
            id: "akamai",
            name: "Akamai Edge",
            testUrl: "https://perfopsrum.akamaized.net/500b-bench.jpg",
            targetHeaders: ["x-cache", "x-cache2", "server"]
        ),
        CDNNodeItem(
            id: "jsdelivr",
            name: "jsDelivr Edge",
            testUrl: "https://cdn.jsdelivr.net/npm/latency-test@1.0.0/generate_200",
            targetHeaders: ["x-served-by", "cf-ray", "x-id"]
        ),
        CDNNodeItem(
            id: "gcp_lb",
            name: "Google Cloud CDN (Anycast)",
            testUrl: "https://global.gcping.com/api/ping",
            targetHeaders: ["server", "via"]
        )
    ]
}
