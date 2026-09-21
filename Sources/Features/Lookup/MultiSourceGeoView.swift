import SwiftUI

public struct MultiSourceGeoView: View {
    public let sources: [GeoInfo]
    
    public init(sources: [GeoInfo]) {
        self.sources = sources
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "square.3.layers.3d.down.right")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.brandIndigo)
                    
                    Text(t("multi_source"))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text("\(sources.count) 个数据源")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 10) {
                ForEach(sources, id: \.source) { item in
                    HStack(alignment: .top, spacing: 10) {
                        Text(item.source ?? "未知源")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.brandIndigo)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.brandIndigo.opacity(0.12), in: RoundedRectangle(cornerRadius: 6))
                            .frame(width: 84, alignment: .leading)
                        
                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 4) {
                                Text(item.flagEmoji)
                                Text(item.locationSummary)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                            
                            if let isp = item.isp {
                                Text(isp)
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                    
                    if item.source != sources.last?.source {
                        Divider().opacity(0.3)
                    }
                }
            }
        }
        .liquidGlassCard(cornerRadius: 20, padding: 18)
    }
}
