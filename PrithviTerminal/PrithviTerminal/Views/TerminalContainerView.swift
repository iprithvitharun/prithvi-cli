import SwiftUI

/// Container that handles split panes for a given tab.
struct TerminalContainerView: View {
    let tab: TerminalTab
    @State private var splitMode: SplitMode = .single
    @State private var splitRatio: CGFloat = 0.5

    enum SplitMode {
        case single
        case horizontal  // side by side
        case vertical    // top and bottom
    }

    var body: some View {
        Group {
            switch splitMode {
            case .single:
                TerminalPaneView(paneId: tab.id, startDirectory: tab.startDirectory)

            case .horizontal:
                HSplitView {
                    TerminalPaneView(paneId: tab.id, startDirectory: tab.startDirectory)
                        .frame(minWidth: 200)
                    TerminalPaneView(paneId: UUID(), startDirectory: tab.startDirectory)
                        .frame(minWidth: 200)
                }

            case .vertical:
                VSplitView {
                    TerminalPaneView(paneId: tab.id, startDirectory: tab.startDirectory)
                        .frame(minHeight: 100)
                    TerminalPaneView(paneId: UUID(), startDirectory: tab.startDirectory)
                        .frame(minHeight: 100)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .splitRight)) { _ in
            splitMode = .horizontal
        }
        .onReceive(NotificationCenter.default.publisher(for: .splitDown)) { _ in
            splitMode = .vertical
        }
    }
}
