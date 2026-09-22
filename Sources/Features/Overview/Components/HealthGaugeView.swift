import SwiftUI

public struct HealthGaugeView: View {
    public let score: Int?
    public let status: HealthStatus
    public let flags: RiskFlags
    
    @State private var animatedProgress: CGFloat = 0.0
    
    public init(score: Int?, status: HealthStatus, flags: RiskFlags) {
        self.score = score
        self.status = status
        self.flags = flags
    }
    
    private var normalizedScore: CGFloat {
        guard let s = score else { return 0 }
        return CGFloat(max(0, min(100, s))) / 100.0
    }
    
    private var gaugeColor: Color {
        Color.scoreColor(for: score)
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            // Circular Score Ring
            ZStack {
                // Background Track (Clean solid muted track)
                Circle()
                    .trim(from: 0.0, to: 0.75)
                    .stroke(
                        Color(uiColor: .tertiarySystemFill),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(135))
                    .frame(width: 140, height: 140)
                
                // Animated Progress Stroke (Single solid non-gradient color)
                Circle()
                    .trim(from: 0.0, to: animatedProgress * 0.75)
                    .stroke(
                        gaugeColor,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(135))
                    .frame(width: 140, height: 140)
                
                // Center Text
                VStack(spacing: 2) {
                    if let s = score {
                        Text("\(s)")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .contentTransition(.numericText())
                    } else {
                        ProgressView()
                            .scaleEffect(1.2)
                    }
                    
                    Text(status.displayText)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(gaugeColor)
                }
            }
            .padding(.top, 10)
            
            // Risk Tag Chips
            RiskFlagsView(flags: flags)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75)) {
                animatedProgress = normalizedScore
            }
        }
        .onChange(of: score) { _, newScore in
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75)) {
                if let s = newScore {
                    animatedProgress = CGFloat(s) / 100.0
                } else {
                    animatedProgress = 0
                }
            }
        }
    }
}

public struct RiskFlagsView: View {
    public let flags: RiskFlags
    
    public var body: some View {
        FlowLayout(spacing: 8) {
            if flags.isResidential == true {
                PillBadge(title: t("residential"), icon: "house.fill", color: .statusGood)
            }
            if flags.isDatacenter == true {
                PillBadge(title: t("datacenter"), icon: "server.rack", color: .brandIndigo)
            }
            if flags.isMobile == true {
                PillBadge(title: t("mobile"), icon: "antenna.radiowaves.left.and.right", color: .brandCyan)
            }
            if flags.isVpn == true {
                PillBadge(title: t("vpn"), icon: "lock.shield.fill", color: .statusModerate)
            }
            if flags.isProxy == true {
                PillBadge(title: t("proxy"), icon: "arrow.triangle.branch", color: .statusModerate)
            }
            if flags.isTor == true {
                PillBadge(title: t("tor"), icon: "network", color: .statusPoor)
            }
            if flags.isCrawler == true {
                PillBadge(title: t("crawler"), icon: "ladybug.fill", color: .statusModerate)
            }
            if flags.isAbuse == true {
                PillBadge(title: t("abuse"), icon: "exclamationmark.triangle.fill", color: .statusPoor)
            }
        }
    }
}

// Minimal Flow Layout for Tag Badges
public struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 320
        var height: CGFloat = 0
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > width && currentX > 0 {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            rowHeight = max(rowHeight, size.height)
            currentX += size.width + spacing
        }
        height = currentY + rowHeight
        return CGSize(width: width, height: height)
    }
    
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX = bounds.minX
        var currentY = bounds.minY
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX && currentX > bounds.minX {
                currentX = bounds.minX
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: ProposedViewSize(size))
            rowHeight = max(rowHeight, size.height)
            currentX += size.width + spacing
        }
    }
}
