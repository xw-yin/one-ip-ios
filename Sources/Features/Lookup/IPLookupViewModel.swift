import SwiftUI

@MainActor
public final class IPLookupViewModel: ObservableObject {
    @Published public var searchQuery: String = ""
    @Published public var isLoading: Bool = false
    @Published public var currentTarget: String = ""
    @Published public var mainGeo: GeoInfo?
    @Published public var multiSources: [GeoInfo] = []
    @Published public var healthScore: IPHealthScore?
    @Published public var bgpInfo: BGPInfo?
    @Published public var errorMessage: String?
    @Published public var historyItems: [String] = []
    
    private let ipService = IPService.shared
    private let historyKey = "ip_lookup_history_v1"
    
    public init() {
        loadHistory()
    }
    
    public func search(ipOrDomain: String? = nil) async {
        let query = (ipOrDomain ?? searchQuery).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }
        
        HapticManager.shared.light()
        isLoading = true
        errorMessage = nil
        currentTarget = query
        
        // Add to history
        addToHistory(query)
        
        // 1. Fetch main Geo Details
        do {
            let geo = try await ipService.fetchGeoDetails(for: query)
            self.mainGeo = geo
        } catch {
            self.errorMessage = "查询失败，请检查 IP/域名 是否正确"
            self.isLoading = false
            HapticManager.shared.error()
            return
        }
        
        // 2. Fetch Multi-source comparisons concurrently
        async let multiTask = ipService.fetchMultiSource(for: query)
        async let healthTask = ipService.evaluateHealth(for: query)
        
        let (multi, health) = await (multiTask, healthTask)
        self.multiSources = multi
        self.healthScore = health
        
        // 3. Build BGP details
        self.bgpInfo = BGPInfo(
            prefix: "\(query)/24",
            asn: self.mainGeo?.asn,
            holder: self.mainGeo?.isp,
            registry: "APNIC / RIPE NCC",
            ptr: "\(query).in-addr.arpa"
        )
        
        self.isLoading = false
        HapticManager.shared.success()
    }
    
    private func loadHistory() {
        if let saved = UserDefaults.standard.stringArray(forKey: historyKey) {
            historyItems = saved
        } else {
            historyItems = ["1.1.1.1", "8.8.8.8", "223.5.5.5", "github.com"]
        }
    }
    
    private func addToHistory(_ item: String) {
        var items = historyItems.filter { $0 != item }
        items.insert(item, at: 0)
        if items.count > 10 { items = Array(items.prefix(10)) }
        historyItems = items
        UserDefaults.standard.set(items, forKey: historyKey)
    }
    
    public func clearHistory() {
        HapticManager.shared.selection()
        historyItems.removeAll()
        UserDefaults.standard.removeObject(forKey: historyKey)
    }
}
