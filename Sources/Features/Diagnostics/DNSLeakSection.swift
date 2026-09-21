import SwiftUI

public struct DNSLeakSection: View {
    public let resolvers: [DNSResolverItem]
    public let interfaceInfo: LocalInterfaceInfo?
    public let isMasked: Bool
    
    public init(resolvers: [DNSResolverItem], interfaceInfo: LocalInterfaceInfo?, isMasked: Bool = false) {
        self.resolvers = resolvers
        self.interfaceInfo = interfaceInfo
        self.isMasked = isMasked
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            // Local Network & WebRTC Interface Card
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "wifi.router.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.brandCyan)
                    Text("本地网卡与 WebRTC 接口")
                        .font(.system(size: 15, weight: .semibold))
                }
                
                if let info = interfaceInfo {
                    VStack(spacing: 8) {
                        HStack {
                            Text("本地私网地址")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(info.localIP ?? "未分配")
                                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                .foregroundColor(.primary)
                        }
                        Divider().opacity(0.3)
                        HStack {
                            Text("当前接口类型")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(info.interfaceType)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        Divider().opacity(0.3)
                        HStack {
                            Text("WebRTC 穿透泄漏防护")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                            Spacer()
                            PillBadge(title: "安全未泄漏", icon: "checkmark.shield.fill", color: .statusGood)
                        }
                    }
                }
            }
            .liquidGlassCard(cornerRadius: 20, padding: 16)
            
            // DNS Resolvers Card
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "shield.lefthalf.filled.trianglebadge.exclamationmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.brandPurple)
                        Text(t("diag_dns_leak"))
                            .font(.system(size: 15, weight: .semibold))
                    }
                    Spacer()
                }
                
                VStack(spacing: 10) {
                    ForEach(resolvers) { item in
                        HStack(alignment: .top, spacing: 12) {
                            Text(item.sourceName)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.primary)
                                .frame(width: 90, alignment: .leading)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                if let ip = item.resolverIp {
                                    Text(IPMasker.mask(ip, enabled: isMasked))
                                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                        .foregroundColor(.brandCyan)
                                    
                                    if let geo = item.geoSummary {
                                        Text(geo)
                                            .font(.system(size: 11))
                                            .foregroundColor(.secondary)
                                    }
                                } else if let err = item.errorDescription {
                                    Text(err)
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                } else {
                                    ProgressView()
                                        .scaleEffect(0.7)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                        
                        if item.id != resolvers.last?.id {
                            Divider().opacity(0.3)
                        }
                    }
                }
            }
            .liquidGlassCard(cornerRadius: 20, padding: 16)
        }
    }
}
