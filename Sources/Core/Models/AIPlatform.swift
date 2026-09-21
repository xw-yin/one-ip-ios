import Foundation

public enum AIConnectionStatus: String, Codable, Sendable {
    case online = "online"
    case regionBlocked = "blocked"
    case error = "error"
    case checking = "checking"
    
    public var displayText: String {
        switch self {
        case .online: return t("ai_status_online")
        case .regionBlocked: return t("ai_status_blocked")
        case .error: return t("ai_status_error")
        case .checking: return t("ai_status_checking")
        }
    }
}

public struct AIModelItem: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let company: String
    public let domain: String
    public let traceDomain: String?
    public let probeUrl: String
    public let iconSystemName: String
    
    public var status: AIConnectionStatus
    public var latencyMs: Int?
    public var exitIp: String?
    public var colo: String?
    public var countryCode: String?
    
    public init(
        id: String,
        name: String,
        company: String,
        domain: String,
        traceDomain: String? = nil,
        probeUrl: String,
        iconSystemName: String,
        status: AIConnectionStatus = .checking,
        latencyMs: Int? = nil,
        exitIp: String? = nil,
        colo: String? = nil,
        countryCode: String? = nil
    ) {
        self.id = id
        self.name = name
        self.company = company
        self.domain = domain
        self.traceDomain = traceDomain
        self.probeUrl = probeUrl
        self.iconSystemName = iconSystemName
        self.status = status
        self.latencyMs = latencyMs
        self.exitIp = exitIp
        self.colo = colo
        self.countryCode = countryCode
    }
}

public enum AIPresets {
    public static let defaultList: [AIModelItem] = [
        AIModelItem(
            id: "chatgpt",
            name: "ChatGPT",
            company: "OpenAI",
            domain: "chatgpt.com",
            traceDomain: "chatgpt.com",
            probeUrl: "https://chatgpt.com",
            iconSystemName: "bubble.left.and.sparkles.fill"
        ),
        AIModelItem(
            id: "claude",
            name: "Claude",
            company: "Anthropic",
            domain: "claude.ai",
            traceDomain: "claude.ai",
            probeUrl: "https://claude.ai",
            iconSystemName: "brain.head.profile"
        ),
        AIModelItem(
            id: "gemini",
            name: "Gemini",
            company: "Google",
            domain: "gemini.google.com",
            traceDomain: nil,
            probeUrl: "https://gemini.google.com",
            iconSystemName: "sparkles"
        ),
        AIModelItem(
            id: "grok",
            name: "Grok",
            company: "xAI",
            domain: "grok.com",
            traceDomain: "grok.com",
            probeUrl: "https://grok.com",
            iconSystemName: "bolt.fill"
        ),
        AIModelItem(
            id: "perplexity",
            name: "Perplexity",
            company: "Perplexity AI",
            domain: "perplexity.ai",
            traceDomain: "www.perplexity.ai",
            probeUrl: "https://www.perplexity.ai",
            iconSystemName: "magnifyingglass.circle.fill"
        ),
        AIModelItem(
            id: "deepseek",
            name: "DeepSeek",
            company: "深度求索",
            domain: "deepseek.com",
            traceDomain: "chat.deepseek.com",
            probeUrl: "https://chat.deepseek.com",
            iconSystemName: "waveform.path.ecg"
        ),
        AIModelItem(
            id: "qwen",
            name: "通义千问 (Qwen)",
            company: "Alibaba Cloud",
            domain: "tongyi.aliyun.com",
            traceDomain: nil,
            probeUrl: "https://tongyi.aliyun.com",
            iconSystemName: "cloud.sun.fill"
        ),
        AIModelItem(
            id: "kimi",
            name: "Kimi",
            company: "Moonshot AI",
            domain: "kimi.moonshot.cn",
            traceDomain: nil,
            probeUrl: "https://kimi.moonshot.cn",
            iconSystemName: "moon.stars.fill"
        )
    ]
}
