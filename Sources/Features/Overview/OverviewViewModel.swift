import SwiftUI

@MainActor
public final class OverviewViewModel: ObservableObject {
    @Published public var domesticGeo: GeoInfo?
    @Published public var globalGeo: GeoInfo?
    @Published public var healthScore: IPHealthScore = IPHealthScore()
    @Published public var exitRoutes: [ExitRouteItem] = [
        ExitRouteItem(name: "Cloudflare", domain: "cloudflare.com", iconName: "cloud.fill"),
        ExitRouteItem(name: "GitHub", domain: "github.com", iconName: "chevron.left.forwardslash.chevron.right"),
        ExitRouteItem(name: "Google", domain: "google.com", iconName: "globe"),
        ExitRouteItem(name: "Apple", domain: "apple.com", iconName: "applelogo"),
        ExitRouteItem(name: "ChatGPT", domain: "chatgpt.com", iconName: "bubble.left.and.sparkles.fill"),
        ExitRouteItem(name: "Claude", domain: "claude.ai", iconName: "brain.head.profile"),
        ExitRouteItem(name: "Discord", domain: "gateway.discord.gg", iconName: "bubble.left.and.bubble.right.fill"),
        ExitRouteItem(name: "X (Twitter)", domain: "x.com", iconName: "antenna.radiowaves.left.and.right")
    ]
    @Published public var isRefreshing: Bool = false
    @Published public var lastUpdated: Date = Date()
    
    private let ipService = IPService.shared
    private let network = NetworkService.shared
    
    public init() {}
    
    public func refreshAll() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        HapticManager.shared.light()
        
        async let domesticTask: GeoInfo? = {
            try? await self.ipService.fetchDomesticIP()
        }()
        
        async let globalTask: GeoInfo? = {
            try? await self.ipService.fetchGlobalIP()
        }()
        
        let (dom, glob) = await (domesticTask, globalTask)
        self.domesticGeo = dom
        self.globalGeo = glob
        
        // Evaluate Health Score on Global Public IP
        if let gIP = glob?.ip, !gIP.isEmpty {
            self.healthScore = await self.ipService.evaluateHealth(for: gIP)
        } else if let dIP = dom?.ip, !dIP.isEmpty {
            self.healthScore = await self.ipService.evaluateHealth(for: dIP)
        }
        
        // Probe Exit Routes
        await probeExitRoutes()
        
        self.lastUpdated = Date()
        self.isRefreshing = false
        HapticManager.shared.success()
    }
    
    private func probeExitRoutes() async {
        for index in exitRoutes.indices {
            exitRoutes[index].isChecking = true
        }
        
        await withTaskGroup(of: (Int, ExitRouteItem).self) { group in
            for (index, item) in self.exitRoutes.enumerated() {
                group.addTask {
                    var updated = item
                    do {
                        let trace = try await self.network.fetchTrace(domain: item.domain, timeout: 3.5)
                        updated.exitIp = trace.ip
                        updated.colo = trace.colo
                        updated.countryCode = trace.countryCode
                        updated.isReachable = true
                        let (_, lat) = await self.network.probe(urlString: "https://\(item.domain)")
                        updated.latencyMs = lat
                    } catch {
                        let (isReachable, lat) = await self.network.probe(urlString: "https://\(item.domain)", timeout: 3.5)
                        updated.isReachable = isReachable
                        updated.latencyMs = lat
                    }
                    updated.isChecking = false
                    return (index, updated)
                }
            }
            
            for await (idx, result) in group {
                if idx < self.exitRoutes.count {
                    self.exitRoutes[idx] = result
                }
            }
        }
    }
}
