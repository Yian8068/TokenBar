import Foundation

enum ClientTabVisibility {
    static let storageKey = "tokenbar.tabs.hiddenClients"

    static func hiddenClientIds(from raw: String) -> Set<String> {
        Set(raw.split(separator: ",").map(String.init).filter { !$0.isEmpty })
    }

    static func rawValue(forHidden hidden: Set<String>) -> String {
        hidden.sorted().joined(separator: ",")
    }

    static func visibleClients(from detected: [String], hiddenRaw: String) -> [String] {
        let hidden = hiddenClientIds(from: hiddenRaw)
        return detected.filter { !hidden.contains($0) }
    }
}
