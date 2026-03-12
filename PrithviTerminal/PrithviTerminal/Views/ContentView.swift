import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var terminalManager = TerminalManager()
    @State private var lastActiveDirectory: String?

    var body: some View {
        VStack(spacing: 0) {
            // Custom tab bar
            TabBarView()

            // Terminal content — ZStack keeps all tabs alive, only selected is visible
            ZStack {
                ForEach(appState.tabs) { tab in
                    TerminalContainerView(tab: tab)
                        .opacity(tab.id == appState.selectedTabId ? 1 : 0)
                        .allowsHitTesting(tab.id == appState.selectedTabId)
                }
            }
        }
        .background(PmuxTheme.background)
        .environmentObject(terminalManager)
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("pmux.renameTab"))) { notification in
            if let title = notification.userInfo?["title"] as? String,
               let id = appState.selectedTabId {
                appState.renameTab(id: id, newTitle: title)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("pmux.directoryChanged"))) { notification in
            if let dir = notification.userInfo?["directory"] as? String {
                // dir may be a file:// URL (from OSC 7) or a plain path
                if dir.hasPrefix("file://"),
                   let url = URL(string: dir) {
                    lastActiveDirectory = url.path
                } else {
                    lastActiveDirectory = dir
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .newTab)) { notification in
            let title = notification.userInfo?["title"] as? String
            appState.addTab(title: title, startDirectory: lastActiveDirectory)
        }
    }
}
