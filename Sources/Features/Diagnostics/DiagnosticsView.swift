import SwiftUI

public struct DiagnosticsView: View {
    @StateObject private var viewModel = DiagnosticsViewModel()
    @EnvironmentObject private var appSettings: AppSettings
    @State private var selectedTab: Int = 0
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                // Segmented Control
                Picker("分类", selection: $selectedTab) {
                    Text(t("diag_dns_leak")).tag(0)
                    Text("CDN 边缘").tag(1)
                    Text(t("diag_global_ping")).tag(2)
                    Text("RDAP 注册").tag(3)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.top, 6)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        switch selectedTab {
                        case 0:
                            DNSLeakSection(
                                resolvers: viewModel.dnsResolvers,
                                interfaceInfo: viewModel.interfaceInfo,
                                isMasked: appSettings.isMaskIPEnabled
                            )
                        case 1:
                            CDNInspectSection(cdnNodes: viewModel.cdnNodes)
                        case 2:
                            GlobalPingSection(regions: viewModel.pingRegions) {
                                Task { await viewModel.runDiagnostics() }
                            }
                        case 3:
                            RDAPSection(
                                query: $viewModel.rdapQuery,
                                result: viewModel.rdapResult,
                                isLoading: viewModel.isRDAPLoading
                            ) {
                                Task { await viewModel.runRDAP() }
                            }
                        default:
                            EmptyView()
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .padding(.bottom, 32)
                }
            }
            .background(Color.liquidBackground.ignoresSafeArea())
            .navigationTitle(t("diag_title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await viewModel.runDiagnostics() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.brandCyan)
                            .rotationEffect(.degrees(viewModel.isDiagnosing ? 360 : 0))
                            .animation(viewModel.isDiagnosing ? .linear(duration: 1.0).repeatForever(autoreverses: false) : .default, value: viewModel.isDiagnosing)
                    }
                }
            }
            .task {
                if viewModel.dnsResolvers.isEmpty {
                    await viewModel.runDiagnostics()
                }
            }
        }
    }
}
