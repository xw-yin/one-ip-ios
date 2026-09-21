import SwiftUI

public struct CDNInspectSection: View {
    public let cdnNodes: [CDNNodeItem]
    
    public init(cdnNodes: [CDNNodeItem]) {
        self.cdnNodes = cdnNodes
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "network")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.brandIndigo)
                    Text(t("diag_cdn_nodes"))
                        .font(.system(size: 15, weight: .semibold))
                }
                Spacer()
            }
            
            VStack(spacing: 10) {
                ForEach(cdnNodes) { node in
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(node.name)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            if let detected = node.detectedNode {
                                Text(detected)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            } else if let err = node.errorDescription {
                                Text(err)
                                    .font(.system(size: 11))
                                    .foregroundColor(.statusPoor)
                            } else {
                                Text("探测中...")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        if node.isChecking {
                            ProgressView()
                                .scaleEffect(0.7)
                        } else if let lat = node.latencyMs {
                            Text("\(lat)ms")
                                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                .foregroundColor(lat < 150 ? .statusGood : .statusModerate)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background((lat < 150 ? Color.statusGood : Color.statusModerate).opacity(0.12), in: RoundedRectangle(cornerRadius: 6))
                        }
                    }
                    .padding(.vertical, 4)
                    
                    if node.id != cdnNodes.last?.id {
                        Divider().opacity(0.3)
                    }
                }
            }
        }
        .liquidGlassCard(cornerRadius: 20, padding: 16)
    }
}
