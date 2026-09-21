import SwiftUI

public struct AIMatrixView: View {
    @StateObject private var viewModel = AIMatrixViewModel()
    @EnvironmentObject private var appSettings: AppSettings
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 18) {
                    // Summary Banner
                    HStack(spacing: 14) {
                        Image(systemName: "sparkles.rectangle.stack.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(LinearGradient.brandFlow)
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text("\(viewModel.accessibleCount)/\(viewModel.aiModels.count) 个 AI 平台可用")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text(t("ai_matrix_subtitle"))
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .liquidGlassCard(cornerRadius: 20, padding: 16)
                    
                    // AI Grid/Cards
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.aiModels) { model in
                            AICardView(item: model, isMasked: appSettings.isMaskIPEnabled) {
                                Task { await viewModel.probeSingle(id: model.id) }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .background(Color.liquidBackground.ignoresSafeArea())
            .navigationTitle(t("ai_matrix_title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await viewModel.probeAll() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.brandCyan)
                            .rotationEffect(.degrees(viewModel.isProbing ? 360 : 0))
                            .animation(viewModel.isProbing ? .linear(duration: 1.0).repeatForever(autoreverses: false) : .default, value: viewModel.isProbing)
                    }
                }
            }
            .refreshable {
                await viewModel.probeAll()
            }
            .task {
                if viewModel.aiModels.allSatisfy({ $0.status == .checking }) {
                    await viewModel.probeAll()
                }
            }
        }
    }
}
