import Foundation
import AppKit

/// Keeps terminal view instances alive across tab switches.
/// SwiftUI would destroy/recreate NSViews on tab change — this prevents that.
class TerminalManager: ObservableObject {
    private var terminals: [UUID: PrithviTerminalView] = [:]
    private var currentDirectories: [UUID: String] = [:]

    func terminalView(for tabId: UUID, startDirectory: String? = nil) -> PrithviTerminalView {
        if let existing = terminals[tabId] {
            return existing
        }
        let view = PrithviTerminalView()
        view.setupTerminal(startDirectory: startDirectory)
        terminals[tabId] = view
        return view
    }

    func removeTerminal(for tabId: UUID) {
        terminals.removeValue(forKey: tabId)
        currentDirectories.removeValue(forKey: tabId)
    }

    func hasTerminal(for tabId: UUID) -> Bool {
        terminals[tabId] != nil
    }

    func updateDirectory(for tabId: UUID, directory: String) {
        currentDirectories[tabId] = directory
    }

    func currentDirectory(for tabId: UUID) -> String? {
        currentDirectories[tabId]
    }

    /// Returns the directory of any active terminal (for new tab inheritance)
    func activeDirectory() -> String? {
        // Return the most recently updated directory
        currentDirectories.values.first
    }
}
