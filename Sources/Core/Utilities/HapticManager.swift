import UIKit

@MainActor
public final class HapticManager {
    public static let shared = HapticManager()
    
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let notificationFeedback = UINotificationFeedbackGenerator()
    
    private init() {
        lightImpact.prepare()
        mediumImpact.prepare()
        selectionFeedback.prepare()
    }
    
    public func light() {
        guard isEnabled else { return }
        lightImpact.impactOccurred(intensity: 0.8)
    }
    
    public func medium() {
        guard isEnabled else { return }
        mediumImpact.impactOccurred(intensity: 0.9)
    }
    
    public func heavy() {
        guard isEnabled else { return }
        heavyImpact.impactOccurred(intensity: 1.0)
    }
    
    public func selection() {
        guard isEnabled else { return }
        selectionFeedback.selectionChanged()
    }
    
    public func success() {
        guard isEnabled else { return }
        notificationFeedback.notificationOccurred(.success)
    }
    
    public func warning() {
        guard isEnabled else { return }
        notificationFeedback.notificationOccurred(.warning)
    }
    
    public func error() {
        guard isEnabled else { return }
        notificationFeedback.notificationOccurred(.error)
    }
    
    private var isEnabled: Bool {
        UserDefaults.standard.object(forKey: "settings_haptic_enabled") as? Bool ?? true
    }
}
