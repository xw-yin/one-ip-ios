import SwiftUI

/// A modern view that resolves and renders site/brand icons with high fidelity.
/// Hierarchy:
/// 1. Pre-bundled, high-resolution vector/bitmap brand assets (instant, offline, pixel-perfect)
/// 2. Dynamic favicon retrieval via DuckDuckGo with disk/memory caching (for any arbitrary domain)
/// 3. Crisp Apple SF Symbol fallback with semantic tinting
public struct SiteIconView: View {
    public let domain: String
    public let fallbackSystemName: String
    public var size: CGFloat = 20
    public var tintColor: Color? = nil
    
    @State private var remoteImage: UIImage? = nil
    
    public init(
        domain: String,
        fallbackSystemName: String = "globe",
        size: CGFloat = 20,
        tintColor: Color? = nil
    ) {
        self.domain = domain
        self.fallbackSystemName = fallbackSystemName
        self.size = size
        self.tintColor = tintColor
    }
    
    private var bundledImageName: String? {
        let clean = domain.lowercased()
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
            .split(separator: "/").first.map(String.init) ?? domain.lowercased()
        
        if clean.contains("chatgpt.com") || clean.contains("openai.com") {
            return "brand_chatgpt"
        } else if clean.contains("claude.ai") || clean.contains("anthropic.com") {
            return "brand_claude"
        } else if clean.contains("gemini.google") {
            return "brand_gemini"
        } else if clean.contains("grok.com") || clean.contains("x.ai") {
            return "brand_grok"
        } else if clean.contains("deepseek.com") {
            return "brand_deepseek"
        } else if clean.contains("perplexity.ai") {
            return "brand_perplexity"
        } else if clean.contains("qwen") || clean.contains("aliyun.com") {
            return "brand_qwen"
        } else if clean.contains("moonshot.cn") || clean.contains("kimi") {
            return "brand_kimi"
        } else if clean.contains("cloudflare.com") {
            return "brand_cloudflare"
        } else if clean.contains("github.com") {
            return "brand_github"
        } else if clean.contains("apple.com") {
            return "brand_apple"
        } else if clean.contains("discord") {
            return "brand_discord"
        } else if clean == "x.com" || clean.contains("twitter.com") {
            return "brand_x"
        } else if clean.contains("google.com") {
            return "brand_google"
        }
        return nil
    }
    
    private var localImage: UIImage? {
        guard let name = bundledImageName else { return nil }
        return UIImage(named: name)
    }
    
    private var isMonochromeBrand: Bool {
        guard let name = bundledImageName else { return false }
        return ["brand_github", "brand_apple", "brand_x", "brand_perplexity", "brand_grok", "brand_kimi"].contains(name)
    }
    
    public var body: some View {
        Group {
            if let local = localImage {
                if isMonochromeBrand {
                    Image(uiImage: local)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(tintColor ?? .primary)
                        .frame(width: size, height: size)
                } else {
                    Image(uiImage: local)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size, height: size)
                }
            } else if let remote = remoteImage {
                Image(uiImage: remote)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
            } else {
                Image(systemName: fallbackSystemName)
                    .font(.system(size: size * 0.8, weight: .semibold))
                    .foregroundColor(tintColor ?? .primary)
                    .frame(width: size, height: size)
            }
        }
        .task(id: domain) {
            if localImage == nil && !domain.isEmpty {
                await fetchFavicon()
            }
        }
    }
    
    private func fetchFavicon() async {
        let clean = domain.lowercased()
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
            .split(separator: "/").first.map(String.init) ?? domain.lowercased()
        
        guard let url = URL(string: "https://icons.duckduckgo.com/ip3/\(clean).ico") else { return }
        
        do {
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 5)
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { return }
            if let image = UIImage(data: data) {
                await MainActor.run {
                    self.remoteImage = image
                }
            }
        } catch {
            // Graceful fallback to SF Symbol
        }
    }
}
