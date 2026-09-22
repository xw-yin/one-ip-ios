import SwiftUI

public struct ExitSplitView: View {
    public let items: [ExitRouteItem]
    public let isMasked: Bool
    
    public init(items: [ExitRouteItem], isMasked: Bool = false) {
        self.items = items
        self.isMasked = isMasked
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.triangle.branch")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.brandPurple)
                    
                    Text(t("quick_split"))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text("\(items.filter { $0.isReachable }.count)/\(items.count)")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.brandPurple)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.brandPurple.opacity(0.12), in: Capsule())
            }
            
            VStack(spacing: 8) {
                ForEach(items) { item in
                    HStack(spacing: 12) {
                        SiteIconView(
                            domain: item.domain,
                            fallbackSystemName: item.iconName,
                            size: 18
                        )
                        .frame(width: 28, height: 28)
                        .background(.ultraThinMaterial, in: Circle())
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                            
                            if let exit = item.exitIp, !exit.isEmpty {
                                Text(IPMasker.mask(exit, enabled: isMasked))
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(.secondary)
                            } else {
                                Text(item.domain)
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        if let colo = item.colo {
                            Text(colo)
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.brandCyan)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.brandCyan.opacity(0.1), in: RoundedRectangle(cornerRadius: 5))
                        }
                        
                        if item.isChecking {
                            ProgressView()
                                .scaleEffect(0.7)
                                .frame(width: 50)
                        } else if item.isReachable {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color.statusGood)
                                    .frame(width: 6, height: 6)
                                if let lat = item.latencyMs {
                                    Text("\(lat)ms")
                                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                        .foregroundColor(.statusGood)
                                }
                            }
                            .frame(minWidth: 50, alignment: .trailing)
                        } else {
                            Text("超时")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.statusPoor)
                                .frame(minWidth: 50, alignment: .trailing)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    if item.id != items.last?.id {
                        Divider()
                            .opacity(0.3)
                    }
                }
            }
        }
        .liquidGlassCard(cornerRadius: 20, padding: 18)
    }
}
