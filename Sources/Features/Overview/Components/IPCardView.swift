import SwiftUI
import UIKit

public struct IPCardView: View {
    public let title: String
    public let subtitle: String
    public let geo: GeoInfo?
    public let isLoading: Bool
    public let isMasked: Bool
    public let iconName: String
    public let accentGradient: LinearGradient
    
    @State private var copied: Bool = false
    
    public init(
        title: String,
        subtitle: String,
        geo: GeoInfo?,
        isLoading: Bool,
        isMasked: Bool = false,
        iconName: String = "network",
        accentGradient: LinearGradient = .brandFlow
    ) {
        self.title = title
        self.subtitle = subtitle
        self.geo = geo
        self.isLoading = isLoading
        self.isMasked = isMasked
        self.iconName = iconName
        self.accentGradient = accentGradient
    }
    
    private var displayedIP: String {
        guard let g = geo, !g.ip.isEmpty else { return "..." }
        return IPMasker.mask(g.ip, enabled: isMasked)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Row
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: iconName)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(accentGradient)
                    
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else if let source = geo?.source {
                    Text(source)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(.ultraThinMaterial, in: Capsule())
                }
            }
            
            // IP & Copy Row
            HStack(alignment: .center, spacing: 10) {
                if let flag = geo?.flagEmoji {
                    Text(flag)
                        .font(.system(size: 24))
                }
                
                Text(displayedIP)
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                Spacer()
                
                Button {
                    if let rawIP = geo?.ip, !rawIP.isEmpty {
                        UIPasteboard.general.string = rawIP
                        HapticManager.shared.success()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            copied = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                            withAnimation { copied = false }
                        }
                    }
                } label: {
                    Image(systemName: copied ? "checkmark.circle.fill" : "doc.on.doc.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(copied ? .statusGood : .secondary)
                        .padding(8)
                        .background(Color.secondary.opacity(0.12), in: Circle())
                }
                .buttonStyle(.plain)
            }
            
            Divider()
                .opacity(0.4)
            
            // Metadata: ISP, ASN & Location
            VStack(alignment: .leading, spacing: 8) {
                if let isp = geo?.isp, !isp.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "building.2.crop.circle")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        Text(isp)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        if let asn = geo?.asn, !asn.isEmpty {
                            Text(asn)
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.brandCyan)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.brandCyan.opacity(0.12), in: RoundedRectangle(cornerRadius: 6))
                        }
                    }
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    Text(geo?.locationSummary ?? t("正在定位地理信息..."))
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .liquidGlassCard(cornerRadius: 20, padding: 18)
    }
}
