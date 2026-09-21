import SwiftUI
import UIKit

public struct OverviewView: View {
    @StateObject private var viewModel = OverviewViewModel()
    @EnvironmentObject private var appSettings: AppSettings
    @State private var showingShareSheet = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header Subtitle & Last Updated
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(t("overview_subtitle"))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        
                        // Status indicator pill
                        HStack(spacing: 6) {
                            Circle()
                                .fill(viewModel.isRefreshing ? Color.brandCyan : Color.statusGood)
                                .frame(width: 8, height: 8)
                            
                            Text(viewModel.isRefreshing ? t("refreshing") : "在线实时")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.ultraThinMaterial, in: Capsule())
                    }
                    .padding(.horizontal, 4)
                    
                    // 1. Health Score Gauge Card
                    VStack(alignment: .center, spacing: 8) {
                        HStack {
                            Label(t("cleanliness_score"), systemImage: "shield.lefthalf.filled")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(LinearGradient.brandFlow)
                            Spacer()
                        }
                        
                        HealthGaugeView(
                            score: viewModel.healthScore.score,
                            status: viewModel.healthScore.status,
                            flags: viewModel.healthScore.flags
                        )
                    }
                    .liquidGlassCard(cornerRadius: 22, padding: 18)
                    
                    // 2. Dual IP Cards
                    VStack(spacing: 14) {
                        IPCardView(
                            title: t("domestic_ip"),
                            subtitle: "国内节点回传出口",
                            geo: viewModel.domesticGeo,
                            isLoading: viewModel.isRefreshing && viewModel.domesticGeo == nil,
                            isMasked: appSettings.isMaskIPEnabled,
                            iconName: "network.badge.shield.half.filled",
                            accentGradient: .brandFlow
                        )
                        
                        IPCardView(
                            title: t("global_ip"),
                            subtitle: "海外骨干网与公网出口",
                            geo: viewModel.globalGeo,
                            isLoading: viewModel.isRefreshing && viewModel.globalGeo == nil,
                            isMasked: appSettings.isMaskIPEnabled,
                            iconName: "globe.americas.fill",
                            accentGradient: LinearGradient(colors: [.brandPurple, .brandIndigo], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                    }
                    
                    // 3. Map Card
                    MapCardView(geo: viewModel.globalGeo ?? viewModel.domesticGeo)
                    
                    // 4. Exit Split Routing Card
                    ExitSplitView(items: viewModel.exitRoutes, isMasked: appSettings.isMaskIPEnabled)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .background(Color.liquidBackground.ignoresSafeArea())
            .navigationTitle(t("overview_title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        Button {
                            shareIPSummary()
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        
                        Button {
                            Task {
                                await viewModel.refreshAll()
                            }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.brandCyan)
                                .rotationEffect(.degrees(viewModel.isRefreshing ? 360 : 0))
                                .animation(viewModel.isRefreshing ? .linear(duration: 1.0).repeatForever(autoreverses: false) : .default, value: viewModel.isRefreshing)
                        }
                    }
                }
            }
            .refreshable {
                await viewModel.refreshAll()
            }
            .task {
                if viewModel.globalGeo == nil {
                    await viewModel.refreshAll()
                }
            }
        }
    }
    
    private func shareIPSummary() {
        HapticManager.shared.selection()
        var text = "【One IP 诊断报告】\n"
        if let dom = viewModel.domesticGeo {
            text += "国内出口: \(dom.ip) (\(dom.locationSummary) · \(dom.isp ?? ""))\n"
        }
        if let glob = viewModel.globalGeo {
            text += "公网出口: \(glob.ip) (\(glob.locationSummary) · \(glob.isp ?? ""))\n"
        }
        if let score = viewModel.healthScore.score {
            text += "纯净度得分: \(score)/100 (\(viewModel.healthScore.status.displayText))\n"
        }
        text += "时间: \(Date().formatted())"
        
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(activityVC, animated: true)
        }
    }
}
