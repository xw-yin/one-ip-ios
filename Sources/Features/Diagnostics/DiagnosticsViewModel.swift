import SwiftUI

@MainActor
public final class DiagnosticsViewModel: ObservableObject {
    @Published public var dnsResolvers: [DNSResolverItem] = []
    @Published public var cdnNodes: [CDNNodeItem] = CDNPresets.defaultList
    @Published public var interfaceInfo: LocalInterfaceInfo?
    @Published public var pingRegions: [PingRegion] = PingPresets.defaultRegions
    @Published public var rdapQuery: String = "apple.com"
    @Published public var rdapResult: RDAPResult?
    @Published public var isDiagnosing: Bool = false
    @Published public var isRDAPLoading: Bool = false
    
    private let diagService = DiagnosticsService.shared
    private let pingService = GlobalPingService.shared
    private let rdapService = RDAPService.shared
    
    public init() {}
    
    public func runDiagnostics() async {
        guard !isDiagnosing else { return }
        isDiagnosing = true
        HapticManager.shared.light()
        
        // 1. Local Interface
        self.interfaceInfo = diagService.getLocalInterfaceInfo()
        
        // 2. DNS Leak detection
        async let dnsTask = diagService.detectDNSResolvers()
        // 3. CDN Nodes
        async let cdnTask = diagService.inspectCDN(items: cdnNodes)
        // 4. Ping Regions
        async let pingTask = pingService.pingAllRegions(regions: pingRegions)
        
        let (dns, cdn, ping) = await (dnsTask, cdnTask, pingTask)
        self.dnsResolvers = dns
        self.cdnNodes = cdn
        self.pingRegions = ping
        
        self.isDiagnosing = false
        HapticManager.shared.success()
    }
    
    public func runRDAP() async {
        let q = rdapQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return }
        isRDAPLoading = true
        HapticManager.shared.light()
        
        do {
            let res = try await rdapService.lookup(query: q)
            self.rdapResult = res
            HapticManager.shared.success()
        } catch {
            HapticManager.shared.error()
        }
        self.isRDAPLoading = false
    }
}
