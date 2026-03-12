import SwiftUI

struct TabBarView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 1) {
                    ForEach(appState.tabs) { tab in
                        TabItemView(
                            tab: tab,
                            isSelected: tab.id == appState.selectedTabId,
                            onSelect: { appState.selectedTabId = tab.id },
                            onClose: { appState.closeTab(id: tab.id) },
                            onRename: { newTitle in
                                appState.renameTab(id: tab.id, newTitle: newTitle)
                            }
                        )
                    }
                }
                .padding(.horizontal, 8)
            }

            Spacer()

            // New tab button
            Button(action: { appState.addTab() }) {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(PmuxTheme.textMuted)
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.trailing, 12)
        }
        .frame(height: 38)
        .background(PmuxTheme.tabBar)
    }
}

struct TabItemView: View {
    let tab: TerminalTab
    let isSelected: Bool
    let onSelect: () -> Void
    let onClose: () -> Void
    let onRename: (String) -> Void

    @State private var isEditing = false
    @State private var editTitle = ""
    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 6) {
            if isEditing {
                TextField("", text: $editTitle, onCommit: {
                    if !editTitle.isEmpty {
                        onRename(editTitle)
                    }
                    isEditing = false
                })
                .textFieldStyle(.plain)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(PmuxTheme.text)
                .frame(minWidth: 60)
            } else {
                Text(tab.title)
                    .font(.system(size: 12, weight: isSelected ? .medium : .regular))
                    .foregroundColor(isSelected ? PmuxTheme.text : PmuxTheme.textMuted)
                    .lineLimit(1)
            }

            if isHovering || isSelected {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(PmuxTheme.textMuted)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(isSelected ? PmuxTheme.tabActive : (isHovering ? PmuxTheme.surfaceHover : Color.clear))
        )
        .onHover { hovering in isHovering = hovering }
        .onTapGesture(count: 2) {
            editTitle = tab.title
            isEditing = true
        }
        .onTapGesture(count: 1) {
            onSelect()
        }
        .animation(.easeInOut(duration: 0.15), value: isSelected)
        .animation(.easeInOut(duration: 0.15), value: isHovering)
    }
}
