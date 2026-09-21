import SwiftUI

// MARK: - Color Palette & Gradients
public extension Color {
    static let liquidBackground = Color(uiColor: .systemGroupedBackground)
    static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)
    
    // Status Semantic Colors
    static let statusGood = Color(red: 0.13, green: 0.77, blue: 0.45)      // #22C55E Emerald
    static let statusModerate = Color(red: 0.96, green: 0.62, blue: 0.08)  // #F59E0B Amber
    static let statusPoor = Color(red: 0.94, green: 0.27, blue: 0.24)      // #EF4444 Rose Red
    static let statusNeutral = Color(red: 0.45, green: 0.52, blue: 0.60)   // Slate
    
    // Brand Glow Tones
    static let brandCyan = Color(red: 0.06, green: 0.73, blue: 0.93)
    static let brandIndigo = Color(red: 0.39, green: 0.40, blue: 0.95)
    static let brandPurple = Color(red: 0.66, green: 0.33, blue: 0.98)
    
    static func scoreColor(for score: Int?) -> Color {
        guard let score = score, score >= 0, score <= 100 else {
            return .statusNeutral
        }
        if score >= 75 { return .statusGood }
        if score >= 45 { return .statusModerate }
        return .statusPoor
    }
}

public extension LinearGradient {
    static let brandFlow = LinearGradient(
        colors: [.brandCyan, .brandIndigo],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let goodFlow = LinearGradient(
        colors: [Color(red: 0.15, green: 0.85, blue: 0.55), Color(red: 0.08, green: 0.65, blue: 0.40)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let moderateFlow = LinearGradient(
        colors: [Color(red: 1.00, green: 0.72, blue: 0.20), Color(red: 0.95, green: 0.50, blue: 0.10)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let poorFlow = LinearGradient(
        colors: [Color(red: 0.98, green: 0.35, blue: 0.30), Color(red: 0.85, green: 0.15, blue: 0.25)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Liquid Glass Card ViewModifier
public struct LiquidGlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat
    var padding: CGFloat
    var borderOpacity: Double
    
    @Environment(\.colorScheme) private var colorScheme
    
    public func body(content: Content) -> some View {
        content
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        colorScheme == .dark ? Color.white.opacity(borderOpacity) : Color.white.opacity(0.7),
                                        colorScheme == .dark ? Color.white.opacity(borderOpacity * 0.2) : Color.black.opacity(0.04)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.0
                            )
                    }
                    .shadow(
                        color: colorScheme == .dark ? Color.black.opacity(0.35) : Color.black.opacity(0.06),
                        radius: 16,
                        x: 0,
                        y: 8
                    )
            }
    }
}

public extension View {
    func liquidGlassCard(
        cornerRadius: CGFloat = 22,
        padding: CGFloat = 16,
        borderOpacity: Double = 0.25
    ) -> some View {
        modifier(LiquidGlassCardModifier(cornerRadius: cornerRadius, padding: padding, borderOpacity: borderOpacity))
    }
    
    func monospacedDigits() -> some View {
        self.fontDesign(.monospaced)
    }
}

// MARK: - Pill Status Badge
public struct PillBadge: View {
    let title: String
    var icon: String? = nil
    var color: Color = .brandCyan
    var filled: Bool = false
    
    public init(title: String, icon: String? = nil, color: Color = .brandCyan, filled: Bool = false) {
        self.title = title
        self.icon = icon
        self.color = color
        self.filled = filled
    }
    
    public var body: some View {
        HStack(spacing: 4) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
            }
            Text(title)
                .font(.system(size: 12, weight: .medium))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background {
            Capsule(style: .continuous)
                .fill(filled ? color : color.opacity(0.12))
        }
        .overlay {
            if !filled {
                Capsule(style: .continuous)
                    .stroke(color.opacity(0.3), lineWidth: 0.8)
            }
        }
        .foregroundColor(filled ? .white : color)
    }
}

// MARK: - IP Masking Utility
public enum IPMasker {
    public static func mask(_ ip: String, enabled: Bool) -> String {
        guard enabled, !ip.isEmpty else { return ip }
        if ip.contains(":") {
            // IPv6
            let parts = ip.split(separator: ":")
            if parts.count >= 2 {
                return "\(parts[0]):\(parts[1]):****:****"
            }
            return ip
        } else if ip.contains(".") {
            // IPv4
            let parts = ip.split(separator: ".")
            if parts.count == 4 {
                return "\(parts[0]).\(parts[1]).*.*"
            }
            return ip
        }
        return ip
    }
}
