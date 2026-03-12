import Foundation

struct TerminalTab: Identifiable {
    let id = UUID()
    var title: String
    var splitPanes: [SplitPane]
    var startDirectory: String?

    init(title: String = "Terminal", startDirectory: String? = nil) {
        self.title = title
        self.splitPanes = [SplitPane()]
        self.startDirectory = startDirectory
    }
}

struct SplitPane: Identifiable {
    let id = UUID()
    var direction: SplitDirection?

    enum SplitDirection {
        case horizontal
        case vertical
    }
}
