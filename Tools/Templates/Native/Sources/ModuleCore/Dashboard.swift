import Foundation
import NookPluginSDK

public struct DemoState: Codable, Equatable {
    public var count: Int
    public var available: Bool
    public var message: String
    public init(count: Int = 0, available: Bool = true, message: String = "Local demo · no devices connected") {
        self.count = count; self.available = available; self.message = message
    }
    public func validate() throws {
        guard (0...999).contains(count), message.count <= 100 else { throw ModuleProblem("Invalid demo state.") }
    }
    public mutating func apply(_ action: String) {
        guard available else { return }
        if action == "increment" { count = min(999, count + 1) }
        if action == "reset" { count = 0 }
    }
    public func snapshot(title: String, cards: Bool) -> PluginSnapshot {
        let actions: [PluginAction] = [
            .init("increment", "Add one", enabled: available && count < 999, symbol: "plus"),
            .init("reset", "Reset", enabled: available && count > 0, symbol: "arrow.counterclockwise", confirmation: "Reset this module’s demo counter to zero?")
        ]
        return PluginSnapshot(title: title, status: message, activity: message,
            fields: [.init("Count", String(count))], actions: cards ? [] : actions,
            badge: available ? "Demo" : "Offline",
            panels: cards ? [.init("overview", "Overview", cards: [
                .init("counter", title: "Your first module", subtitle: "Local counter", value: String(count), detail: available ? "These buttons only change this demo. Real integrations own their connections and commands." : "Controls are disabled while this fixture is offline.", symbol: "square.stack.3d.up", actions: actions)
            ])] : nil)
    }
}
