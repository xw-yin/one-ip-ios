import Foundation

public final class GlobalPingService: Sendable {
    public static let shared = GlobalPingService()
    private let network = NetworkService.shared
    
    // Representative edge targets for each continent
    private let regionEndpoints: [String: [String]] = [
        "AS": [
            "https://hkg.speed.cloudflare.com/__down?bytes=0",
            "https://tyo.speed.cloudflare.com/__down?bytes=0"
        ],
        "NA": [
            "https://sjc.speed.cloudflare.com/__down?bytes=0",
            "https://iad.speed.cloudflare.com/__down?bytes=0"
        ],
        "EU": [
            "https://fra.speed.cloudflare.com/__down?bytes=0",
            "https://lhr.speed.cloudflare.com/__down?bytes=0"
        ],
        "OC": [
            "https://syd.speed.cloudflare.com/__down?bytes=0"
        ],
        "SA": [
            "https://gru.speed.cloudflare.com/__down?bytes=0"
        ],
        "AF": [
            "https://jnb.speed.cloudflare.com/__down?bytes=0"
        ]
    ]
    
    public func pingAllRegions(regions: [PingRegion]) async -> [PingRegion] {
        await withTaskGroup(of: PingRegion.self) { group in
            for region in regions {
                group.addTask {
                    await self.pingSingleRegion(region: region)
                }
            }
            
            var results: [PingRegion] = []
            for await r in group {
                results.append(r)
            }
            return regions.compactMap { orig in results.first(where: { $0.id == orig.id }) }
        }
    }
    
    public func pingSingleRegion(region: PingRegion) async -> PingRegion {
        var updated = region
        updated.isChecking = true
        
        guard let endpoints = regionEndpoints[region.code], !endpoints.isEmpty else {
            updated.isChecking = false
            return updated
        }
        
        var latencies: [Double] = []
        for url in endpoints {
            let (reachable, lat) = await network.probe(urlString: url, timeout: 3.5)
            if reachable, let lat {
                latencies.append(Double(lat))
            }
        }
        
        if latencies.isEmpty {
            updated.packetLoss = 1.0
        } else {
            updated.minLatency = latencies.min()
            updated.maxLatency = latencies.max()
            let sum = latencies.reduce(0, +)
            updated.avgLatency = sum / Double(latencies.count)
            updated.packetLoss = 0.0
        }
        
        updated.isChecking = false
        return updated
    }
}
