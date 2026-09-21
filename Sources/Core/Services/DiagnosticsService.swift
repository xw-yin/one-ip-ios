import Foundation
import Network

public struct LocalInterfaceInfo: Sendable {
    public let interfaceType: String
    public let localIP: String?
    public let isCellular: Bool
    public let isWiFi: Bool
    public let isConstrained: Bool
}

public final class DiagnosticsService: Sendable {
    public static let shared = DiagnosticsService()
    private let network = NetworkService.shared
    
    // MARK: - DNS Leak Detection
    public func detectDNSResolvers() async -> [DNSResolverItem] {
        let sources: [(id: String, name: String, host: String)] = [
            ("surfshark", "Surfshark DNS", "ipv4.surfsharkdns.com"),
            ("fastly", "Fastly Resolver", "u.fastly-analytics.com"),
            ("browserleaks", "BrowserLeaks", "dns4.browserleaks.net")
        ]
        
        return await withTaskGroup(of: DNSResolverItem.self) { group in
            for src in sources {
                group.addTask {
                    let random = UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(8).lowercased()
                    let url = "https://\(random).\(src.host)"
                    
                    do {
                        if src.id == "fastly" {
                            struct FastlyRes: Decodable {
                                struct Info: Decodable {
                                    let ip: String?
                                    let asName: String?
                                    let cc: String?
                                }
                                let dnsResolverInfo: Info?
                            }
                            let res = try await self.network.fetchJSON(FastlyRes.self, from: "\(url)/debug_resolver", timeout: 4.0)
                            if let info = res.dnsResolverInfo, let ip = info.ip {
                                let geo = [info.cc, info.asName].compactMap { $0 }.joined(separator: " · ")
                                return DNSResolverItem(id: src.id, sourceName: src.name, resolverIp: ip, geoSummary: geo)
                            }
                        } else {
                            let (text, _) = try await self.network.fetchString(from: url, timeout: 4.0)
                            // Look for IPv4/IPv6 pattern in response
                            let ipPattern = #"(?:[0-9]{1,3}\.){3}[0-9]{1,3}|(?:[0-9a-fA-F]{1,4}:){1,7}[0-9a-fA-F]{1,4}"#
                            if let match = text.range(of: ipPattern, options: .regularExpression) {
                                let foundIP = String(text[match])
                                let geo = try? await IPService.shared.fetchGeoDetails(for: foundIP)
                                return DNSResolverItem(id: src.id, sourceName: src.name, resolverIp: foundIP, geoSummary: geo?.locationSummary)
                            }
                        }
                    } catch {
                        return DNSResolverItem(id: src.id, sourceName: src.name, errorDescription: "解析超时或已阻断")
                    }
                    return DNSResolverItem(id: src.id, sourceName: src.name, errorDescription: "无响应")
                }
            }
            
            var items: [DNSResolverItem] = []
            for await item in group {
                items.append(item)
            }
            return items
        }
    }
    
    // MARK: - CDN Node Inspection
    public func inspectCDN(items: [CDNNodeItem]) async -> [CDNNodeItem] {
        await withTaskGroup(of: CDNNodeItem.self) { group in
            for item in items {
                group.addTask {
                    var updated = item
                    updated.isChecking = true
                    
                    if item.isTrace {
                        do {
                            let (text, latency) = try await self.network.fetchString(from: item.testUrl, timeout: 3.5)
                            let trace = self.network.parseTrace(text: text)
                            updated.detectedNode = trace.colo.map { "Colo: \($0) (\(trace.countryCode ?? ""))" } ?? "Colo: Online"
                            updated.latencyMs = latency
                        } catch {
                            updated.errorDescription = "探测失败"
                        }
                    } else {
                        do {
                            let headers = try await self.network.fetchHeaders(from: item.testUrl, timeout: 3.5)
                            for target in item.targetHeaders {
                                if let val = headers[target.lowercased()], !val.isEmpty {
                                    updated.detectedNode = "\(target): \(val)"
                                    break
                                }
                            }
                            if updated.detectedNode == nil {
                                updated.detectedNode = headers["server"].map { "Server: \($0)" } ?? "已连接 (200 OK)"
                            }
                            let (_, latency) = await self.network.probe(urlString: item.testUrl)
                            updated.latencyMs = latency
                        } catch {
                            updated.errorDescription = "连接超时"
                        }
                    }
                    updated.isChecking = false
                    return updated
                }
            }
            
            var results: [CDNNodeItem] = []
            for await item in group {
                results.append(item)
            }
            return items.compactMap { orig in results.first(where: { $0.id == orig.id }) }
        }
    }
    
    // MARK: - WebRTC & Local Interface Info
    public func getLocalInterfaceInfo() -> LocalInterfaceInfo {
        var localIP: String?
        
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                guard let interface = ptr?.pointee else { continue }
                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) {
                    let name = String(cString: interface.ifa_name)
                    if name == "en0" || name == "pdp_ip0" {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                    &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST)
                        let ip = String(cString: hostname)
                        if !ip.isEmpty && !ip.hasPrefix("127.") {
                            localIP = ip
                            break
                        }
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        
        return LocalInterfaceInfo(
            interfaceType: "WiFi / Cellular",
            localIP: localIP ?? "192.168.1.100 (局域网私网)",
            isCellular: false,
            isWiFi: true,
            isConstrained: false
        )
    }
}
