import SwiftUI

@main
struct PmuxTerminalApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Tab") {
                    NotificationCenter.default.post(name: .newTab, object: nil)
                }
                .keyboardShortcut("t", modifiers: .command)

                Button("Split Right") {
                    NotificationCenter.default.post(name: .splitRight, object: nil)
                }
                .keyboardShortcut("d", modifiers: .command)

                Button("Split Down") {
                    NotificationCenter.default.post(name: .splitDown, object: nil)
                }
                .keyboardShortcut("d", modifiers: [.command, .shift])

                Divider()

                Button("Close Tab") {
                    NotificationCenter.default.post(name: .closeTab, object: nil)
                }
                .keyboardShortcut("w", modifiers: .command)
            }
        }
    }
}

extension Notification.Name {
    static let newTab = Notification.Name("pmux.newTab")
    static let closeTab = Notification.Name("pmux.closeTab")
    static let splitRight = Notification.Name("pmux.splitRight")
    static let splitDown = Notification.Name("pmux.splitDown")
}
