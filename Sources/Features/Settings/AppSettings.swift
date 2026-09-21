import SwiftUI

public enum AppearanceMode: String, CaseIterable, Identifiable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .system: return "跟随系统 (System)"
        case .light: return "浅色模式 (Light)"
        case .dark: return "深色模式 (Dark)"
        }
    }
}

public struct CloudStatusItem: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let provider: String
    public let iconName: String
    public var isOperational: Bool
    public var latencyMs: Int?
    public var statusDescription: String
}

@MainActor
public final class AppSettings: ObservableObject {
    public static let shared = AppSettings()
    
    @AppStorage("custom_worker_url") public var customWorkerURL: String = "https://ip.huzhihui.com"
    @AppStorage("mask_ip_enabled") public var isMaskIPEnabled: Bool = false
    @AppStorage("settings_haptic_enabled") public var isHapticEnabled: Bool = true
    @AppStorage("appearance_mode") public var appearanceMode: AppearanceMode = .system
    
    @Published public var cloudServices: [CloudStatusItem] = [
        CloudStatusItem(id: "cf", name: "Cloudflare", provider: "Cloudflare Edge", iconName: "cloud.fill", isOperational: true, latencyMs: 24, statusDescription: "All Systems Operational"),
        CloudStatusItem(id: "github", name: "GitHub", provider: "Microsoft / GitHub", iconName: "chevron.left.forwardslash.chevron.right", isOperational: true, latencyMs: 38, statusDescription: "Normal"),
        CloudStatusItem(id: "openai", name: "OpenAI API", provider: "OpenAI", iconName: "sparkles", isOperational: true, latencyMs: 52, statusDescription: "Operational"),
        CloudStatusItem(id: "apple", name: "Apple Services", provider: "Apple Inc.", iconName: "applelogo", isOperational: true, latencyMs: 18, statusDescription: "Available"),
        CloudStatusItem(id: "aws", name: "AWS Cloud", provider: "Amazon Web Services", iconName: "server.rack", isOperational: true, latencyMs: 45, statusDescription: "Normal"),
        CloudStatusItem(id: "gcp", name: "Google Cloud", provider: "Google LLC", iconName: "globe", isOperational: true, latencyMs: 32, statusDescription: "All Services Normal")
    ]
    
    public func refreshCloudStatus() async {
        for index in cloudServices.indices {
            let item = cloudServices[index]
            let testUrl: String
            switch item.id {
            case "cf": testUrl = "https://www.cloudflare.com/cdn-cgi/trace"
            case "github": testUrl = "https://api.github.com"
            case "openai": testUrl = "https://api.openai.com"
            case "apple": testUrl = "https://apple.com"
            case "aws": testUrl = "https://aws.amazon.com"
            default: testUrl = "https://google.com"
            }
            let (isUp, lat) = await NetworkService.shared.probe(urlString: testUrl)
            cloudServices[index].isOperational = isUp
            cloudServices[index].latencyMs = lat
            cloudServices[index].statusDescription = isUp ? "正常运行中" : "可能存在波动"
        }
    }
}
