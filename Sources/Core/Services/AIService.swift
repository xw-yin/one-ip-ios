import Foundation

public final class AIService: Sendable {
    public static let shared = AIService()
    private let network = NetworkService.shared
    
    public func probeAll(items: [AIModelItem]) async -> [AIModelItem] {
        await withTaskGroup(of: AIModelItem.self) { group in
            for item in items {
                group.addTask {
                    await self.probeSingle(item: item)
                }
            }
            
            var results: [AIModelItem] = []
            for await probed in group {
                results.append(probed)
            }
            // Preserve original sorting
            return items.compactMap { orig in results.first(where: { $0.id == orig.id }) }
        }
    }
    
    public func probeSingle(item: AIModelItem) async -> AIModelItem {
        var updated = item
        updated.status = .checking
        
        // 1. If trace is supported, run cftrace
        if let traceDomain = item.traceDomain {
            do {
                let trace = try await network.fetchTrace(domain: traceDomain, timeout: 3.5)
                updated.exitIp = trace.ip
                updated.countryCode = trace.countryCode
                updated.colo = trace.colo
            } catch {}
        }
        
        // 2. Probe HTTP accessibility and latency
        let (isReachable, latency) = await network.probe(urlString: item.probeUrl, timeout: 4.0)
        updated.latencyMs = latency
        
        if isReachable {
            updated.status = .online
        } else if let latency, latency > 0 {
            // Reached server but returned 403 / restriction
            updated.status = .regionBlocked
        } else {
            updated.status = .error
        }
        
        return updated
    }
}
