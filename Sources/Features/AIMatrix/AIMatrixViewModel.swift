import SwiftUI

@MainActor
public final class AIMatrixViewModel: ObservableObject {
    @Published public var aiModels: [AIModelItem] = AIPresets.defaultList
    @Published public var isProbing: Bool = false
    @Published public var lastUpdated: Date = Date()
    
    private let aiService = AIService.shared
    
    public init() {}
    
    public func probeAll() async {
        guard !isProbing else { return }
        isProbing = true
        HapticManager.shared.light()
        
        for index in aiModels.indices {
            aiModels[index].status = .checking
        }
        
        let probed = await aiService.probeAll(items: aiModels)
        self.aiModels = probed
        self.lastUpdated = Date()
        self.isProbing = false
        HapticManager.shared.success()
    }
    
    public func probeSingle(id: String) async {
        guard let index = aiModels.firstIndex(where: { $0.id == id }) else { return }
        aiModels[index].status = .checking
        let updated = await aiService.probeSingle(item: aiModels[index])
        aiModels[index] = updated
    }
    
    public var accessibleCount: Int {
        aiModels.filter { $0.status == .online }.count
    }
}
