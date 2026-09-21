import SwiftUI

public struct IPLookupView: View {
    @StateObject private var viewModel = IPLookupViewModel()
    @EnvironmentObject private var appSettings: AppSettings
    @FocusState private var isFieldFocused: Bool
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Search Bar
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16, weight: .semibold))
                        
                        TextField(t("lookup_placeholder"), text: $viewModel.searchQuery)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .font(.system(size: 15, weight: .medium, design: .monospaced))
                            .focused($isFieldFocused)
                            .submitLabel(.search)
                            .onSubmit {
                                Task { await viewModel.search() }
                            }
                        
                        if !viewModel.searchQuery.isEmpty {
                            Button {
                                viewModel.searchQuery = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 14))
                            }
                        }
                        
                        Button {
                            isFieldFocused = false
                            Task { await viewModel.search() }
                        } label: {
                            Text(t("lookup_button"))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(LinearGradient.brandFlow, in: Capsule())
                        }
                    }
                    .liquidGlassCard(cornerRadius: 18, padding: 12)
                    
                    // History Chips
                    if !viewModel.historyItems.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(t("lookup_history"))
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Button(t("clear_history")) {
                                    viewModel.clearHistory()
                                }
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(viewModel.historyItems, id: \.self) { item in
                                        Button {
                                            viewModel.searchQuery = item
                                            Task { await viewModel.search(ipOrDomain: item) }
                                        } label: {
                                            Text(item)
                                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                                .foregroundColor(.primary)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 5)
                                                .background(.ultraThinMaterial, in: Capsule())
                                                .overlay {
                                                    Capsule().stroke(Color.white.opacity(0.15), lineWidth: 0.8)
                                                }
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Loading State
                    if viewModel.isLoading {
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("正在聚合多源 BGP 与风险数据库...")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    }
                    
                    // Error Message
                    if let err = viewModel.errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.statusPoor)
                            Text(err)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.statusPoor)
                        }
                        .padding()
                        .background(Color.statusPoor.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Main Search Results
                    if let geo = viewModel.mainGeo, !viewModel.isLoading {
                        // 1. IP Card
                        IPCardView(
                            title: "目标 IP 详情",
                            subtitle: viewModel.currentTarget,
                            geo: geo,
                            isLoading: false,
                            isMasked: appSettings.isMaskIPEnabled,
                            iconName: "magnifyingglass.circle.fill",
                            accentGradient: .brandFlow
                        )
                        
                        // 2. Health & Score Card
                        if let health = viewModel.healthScore {
                            VStack(alignment: .center, spacing: 10) {
                                HStack {
                                    Label("IP 纯净度与风险评估", systemImage: "shield.lefthalf.filled")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(LinearGradient.brandFlow)
                                    Spacer()
                                }
                                
                                HealthGaugeView(
                                    score: health.score,
                                    status: health.status,
                                    flags: health.flags
                                )
                            }
                            .liquidGlassCard(cornerRadius: 22, padding: 18)
                        }
                        
                        // 3. Multi-Source Comparison
                        if !viewModel.multiSources.isEmpty {
                            MultiSourceGeoView(sources: viewModel.multiSources)
                        }
                        
                        // 4. BGP & Network Topology
                        if let bgp = viewModel.bgpInfo {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack(spacing: 8) {
                                    Image(systemName: "point.3.connected.trianglepath.dotted")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.brandCyan)
                                    Text(t("bgp_info"))
                                        .font(.system(size: 15, weight: .semibold))
                                }
                                
                                VStack(spacing: 8) {
                                    BGPDetailRow(label: t("asn_number"), value: geo.asn ?? "N/A")
                                    Divider().opacity(0.3)
                                    BGPDetailRow(label: t("cidr_block"), value: bgp.prefix ?? "N/A")
                                    Divider().opacity(0.3)
                                    BGPDetailRow(label: "组织机构 (Holder)", value: bgp.holder ?? "N/A")
                                    Divider().opacity(0.3)
                                    BGPDetailRow(label: "注册局 (RIR)", value: bgp.registry ?? "N/A")
                                    Divider().opacity(0.3)
                                    BGPDetailRow(label: t("ptr_record"), value: bgp.ptr ?? "N/A")
                                }
                            }
                            .liquidGlassCard(cornerRadius: 20, padding: 18)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .background(Color.liquidBackground.ignoresSafeArea())
            .navigationTitle(t("lookup_title"))
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

public struct BGPDetailRow: View {
    public let label: String
    public let value: String
    
    public var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundColor(.primary)
                .lineLimit(1)
        }
        .padding(.vertical, 2)
    }
}
