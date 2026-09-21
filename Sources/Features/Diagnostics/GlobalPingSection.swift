import SwiftUI

public struct GlobalPingSection: View {
    public let regions: [PingRegion]
    public var onRefresh: (() -> Void)? = nil
    
    public init(regions: [PingRegion], onRefresh: (() -> Void)? = nil) {
        self.regions = regions
        self.onRefresh = onRefresh
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.brandCyan)
                    Text(t("diag_global_ping"))
                        .font(.system(size: 15, weight: .semibold))
                }
                Spacer()
                
                Button {
                    onRefresh?()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.brandCyan)
                }
            }
            
            VStack(spacing: 12) {
                ForEach(regions) { r in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: r.iconName)
                                .font(.system(size: 13))
                                .foregroundColor(.brandCyan)
                            Text(r.name)
                                .font(.system(size: 14, weight: .medium))
                            
                            Spacer()
                            
                            if r.isChecking {
                                ProgressView()
                                    .scaleEffect(0.6)
                            } else if let avg = r.avgLatency {
                                HStack(spacing: 4) {
                                    Text("\(Int(avg))ms")
                                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                                        .foregroundColor(avg < 120 ? .statusGood : (avg < 250 ? .statusModerate : .statusPoor))
                                    
                                    if let loss = r.packetLoss, loss > 0 {
                                        Text("(\(Int(loss * 100))% 丢包)")
                                            .font(.system(size: 10))
                                            .foregroundColor(.statusPoor)
                                    }
                                }
                            } else {
                                Text("等待探测")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Latency Gauge Bar
                        GeometryReader { proxy in
                            let totalWidth = proxy.size.width
                            let progress: CGFloat = {
                                guard let avg = r.avgLatency else { return 0 }
                                return min(1.0, CGFloat(avg) / 350.0)
                            }()
                            
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 6)
                                
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: progress < 0.35 ? [.brandCyan, .statusGood] : (progress < 0.7 ? [.statusModerate, .orange] : [.statusPoor, .red]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: max(10, totalWidth * progress), height: 6)
                            }
                        }
                        .frame(height: 6)
                    }
                    .padding(.vertical, 4)
                    
                    if r.id != regions.last?.id {
                        Divider().opacity(0.3)
                    }
                }
            }
        }
        .liquidGlassCard(cornerRadius: 20, padding: 16)
    }
}
