import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var tabs: [TerminalTab] = []
    @Published var selectedTabId: UUID?

    private var cancellables = Set<AnyCancellable>()
    private var tabCounter: Int = 0

    init() {
        // Start with one tab
        let firstTab = TerminalTab(title: nextTabTitle())
        tabs = [firstTab]
        selectedTabId = firstTab.id

        setupNotifications()
    }

    private func nextTabTitle() -> String {
        tabCounter += 1
        return "Untitled Term \(tabCounter)"
    }

    private func setupNotifications() {
        NotificationCenter.default.publisher(for: .closeTab)
            .sink { [weak self] _ in self?.closeCurrentTab() }
            .store(in: &cancellables)
    }

    func addTab(title: String? = nil, startDirectory: String? = nil) {
        let tab = TerminalTab(title: title ?? nextTabTitle(), startDirectory: startDirectory)
        tabs.append(tab)
        selectedTabId = tab.id
    }

    func closeTab(id: UUID) {
        guard tabs.count > 1 else { return } // Keep at least one tab
        if let index = tabs.firstIndex(where: { $0.id == id }) {
            tabs.remove(at: index)
            if selectedTabId == id {
                selectedTabId = tabs[max(0, index - 1)].id
            }
        }
    }

    func closeCurrentTab() {
        if let id = selectedTabId {
            closeTab(id: id)
        }
    }

    func renameTab(id: UUID, newTitle: String) {
        if let index = tabs.firstIndex(where: { $0.id == id }) {
            tabs[index].title = newTitle
        }
    }

    var selectedTab: TerminalTab? {
        tabs.first(where: { $0.id == selectedTabId })
    }
}
