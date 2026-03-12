import Foundation

/// Tab commands are handled specially — they post notifications
/// to the app layer rather than sending shell commands.
class TabCommands: CommandHandler {
    func handle(_ input: String) -> CommandMiddleware.CommandResult? {
        if input == "tab new" || input.hasPrefix("tab new ") {
            let name = input == "tab new" ? nil : String(input.dropFirst(8)).trimmingCharacters(in: .whitespaces)
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .newTab,
                    object: nil,
                    userInfo: name != nil ? ["title": name!] : nil
                )
            }
            return .init(
                handled: true,
                replacement: nil,
                output: "  \u{001B}[38;5;114m✓\u{001B}[0m New tab opened" + (name != nil ? ": \u{001B}[38;5;117m\(name!)\u{001B}[0m" : ""),
                interactive: nil
            )
        }

        if input == "tab split" || input == "tab split right" {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .splitRight, object: nil)
            }
            return .init(handled: true, replacement: nil, output: "  \u{001B}[38;5;114m✓\u{001B}[0m Split pane → right", interactive: nil)
        }

        if input == "tab split down" {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .splitDown, object: nil)
            }
            return .init(handled: true, replacement: nil, output: "  \u{001B}[38;5;114m✓\u{001B}[0m Split pane ↓ down", interactive: nil)
        }

        if input.hasPrefix("tab rename ") {
            let name = String(input.dropFirst(11)).trimmingCharacters(in: .whitespaces)
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: Notification.Name("pmux.renameTab"),
                    object: nil,
                    userInfo: ["title": name]
                )
            }
            return .init(handled: true, replacement: nil, output: "  \u{001B}[38;5;114m✓\u{001B}[0m Tab renamed to \u{001B}[38;5;117m\(name)\u{001B}[0m", interactive: nil)
        }

        if input == "tab close" {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .closeTab, object: nil)
            }
            return .init(handled: true, replacement: nil, output: nil, interactive: nil)
        }

        return nil
    }
}
