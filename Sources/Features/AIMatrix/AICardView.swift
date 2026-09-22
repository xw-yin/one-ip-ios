import SwiftUI

public struct AICardView: View {
    public let item: AIModelItem
    public let isMasked: Bool
    public var onRetry: (() -> Void)? = nil
    
    public init(item: AIModelItem, isMasked: Bool = false, onRetry: (() -> Void)? = nil) {
        self.item = item
        self.isMasked = isMasked
        self.onRetry = onRetry
    }
    
    private var statusColor: Color {
        switch item.status {
        case .online: return .statusGood
        case .regionBlocked: return .statusModerate
        case .error: return .statusPoor
        case .checking: return .brandCyan
        }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Top Row: Icon + Name + Status Pill
            HStack(spacing: 10) {
                SiteIconView(
                    domain: item.domain,
                    fallbackSystemName: item.iconSystemName,
                    size: 20,
                    tintColor: statusColor
                )
                .frame(width: 32, height: 32)
                .background(statusColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(item.company)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status Pill
                HStack(spacing: 5) {
                    if item.status == .checking {
                        ProgressView()
                            .scaleEffect(0.6)
                    } else {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 6, height: 6)
                    }
                    
                    Text(item.status.displayText)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(statusColor)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.12), in: Capsule())
            }
            
            Divider().opacity(0.3)
            
            // Bottom Row: Latency & Exit IP / Colo
            HStack {
                // Latency
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    if let lat = item.latencyMs {
                        Text("\(lat)ms")
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundColor(lat < 300 ? .statusGood : .statusModerate)
                    } else {
                        Text("--")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Exit IP & Colo
                if let exit = item.exitIp, !exit.isEmpty {
                    HStack(spacing: 4) {
                        Text(IPMasker.mask(exit, enabled: isMasked))
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.secondary)
                        
                        if let colo = item.colo {
                            Text(colo)
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.brandCyan)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background(Color.brandCyan.opacity(0.12), in: RoundedRectangle(cornerRadius: 4))
                        }
                    }
                } else {
                    Text(item.domain)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
        }
        .liquidGlassCard(cornerRadius: 18, padding: 14)
    }
}
