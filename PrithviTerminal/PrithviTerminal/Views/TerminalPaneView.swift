import SwiftUI
import SwiftTerm

/// Wraps a SwiftTerm LocalProcessTerminalView in SwiftUI.
/// Uses TerminalManager to persist views across tab switches.
struct TerminalPaneView: NSViewRepresentable {
    let paneId: UUID
    var startDirectory: String? = nil
    @EnvironmentObject var terminalManager: TerminalManager

    func makeNSView(context: Context) -> PmuxTerminalView {
        return terminalManager.terminalView(for: paneId, startDirectory: startDirectory)
    }

    func updateNSView(_ nsView: PmuxTerminalView, context: Context) {}
}

/// Custom terminal view that wraps LocalProcessTerminalView.
class PmuxTerminalView: NSView {
    private var terminal: LocalProcessTerminalView!
    private var zdotdirCleanup: String?  // temp dir path to clean up
    private static var instanceCounter: Int = 0

    override var acceptsFirstResponder: Bool { true }

    deinit {
        // Clean up temp ZDOTDIR
        if let path = zdotdirCleanup {
            try? FileManager.default.removeItem(atPath: path)
        }
    }

    /// Builds the shell environment with ZDOTDIR pointing to a temp dir
    /// that sources the user's real .zshrc + the pmux.sh plugin.
    static func buildShellEnvironment(tabNumber: Int = 1, tabTitle: String = "", startDirectory: String? = nil) -> ([String], String) {
        // Find the plugin path — relative to the app binary or the repo
        let pluginPath = findPluginPath()

        // Create temp ZDOTDIR
        let tempDir = NSTemporaryDirectory() + "pmux-shell-\(ProcessInfo.processInfo.processIdentifier)-\(UUID().uuidString.prefix(8))"
        try? FileManager.default.createDirectory(atPath: tempDir, withIntermediateDirectories: true)

        // .zshenv — source user's real .zshenv
        let zshenv = """
        [[ -f "$HOME/.zshenv" ]] && source "$HOME/.zshenv"
        """
        try? zshenv.write(toFile: tempDir + "/.zshenv", atomically: true, encoding: .utf8)

        // .zprofile — source user's real .zprofile
        let zprofile = """
        [[ -f "$HOME/.zprofile" ]] && source "$HOME/.zprofile"
        """
        try? zprofile.write(toFile: tempDir + "/.zprofile", atomically: true, encoding: .utf8)

        // .zshrc — source user's real .zshrc, cd to start dir, THEN our plugin (banner needs correct dir)
        let cdTarget = startDirectory ?? "$HOME/Documents"
        let zshrc = """
        [[ -f "$HOME/.zshrc" ]] && source "$HOME/.zshrc"
        cd "\(cdTarget)" 2>/dev/null
        source '\(pluginPath)'
        """
        try? zshrc.write(toFile: tempDir + "/.zshrc", atomically: true, encoding: .utf8)

        // Build full environment: inherit current process env + override ZDOTDIR
        var env = ProcessInfo.processInfo.environment
        env["ZDOTDIR"] = tempDir
        env["TERM"] = "xterm-256color"
        env["PMUX_TERMINAL"] = "1"
        env["PMUX_TAB_NUMBER"] = "\(tabNumber)"
        env["PMUX_TAB_TITLE"] = tabTitle

        let envArray = env.map { "\($0.key)=\($0.value)" }
        return (envArray, tempDir)
    }

    /// Locate the pmux.zsh plugin file
    static func findPluginPath() -> String {
        // Check relative to the binary (for development builds)
        let bundlePath = Bundle.main.bundlePath

        // Check in the repo structure (development)
        // The app is at PmuxTerminal/build/pmux.sh.app or PmuxTerminal/.build/debug/
        let possiblePaths = [
            // Repo root (relative to .build/debug/)
            bundlePath + "/../../../../pmux.zsh",
            // Repo root (relative to build/pmux.sh.app/Contents/MacOS/)
            bundlePath + "/../../../../../pmux.zsh",
            // Inside app bundle Resources
            Bundle.main.path(forResource: "pmux", ofType: "zsh") ?? "",
            // Absolute fallback — repo path
            "/Users/ptharun/Documents/GitHub/prithvi-cli/pmux.zsh",
        ]

        for path in possiblePaths {
            let resolved = (path as NSString).standardizingPath
            if FileManager.default.fileExists(atPath: resolved) {
                return resolved
            }
        }

        // Final fallback
        return "/Users/ptharun/Documents/GitHub/prithvi-cli/pmux.zsh"
    }

    func setupTerminal(startDirectory: String? = nil) {
        terminal = LocalProcessTerminalView(frame: bounds)
        terminal.autoresizingMask = [.width, .height]

        // Theme colors
        let bgColor = NSColor(hex: "1e1e2e")
        let fgColor = NSColor(hex: "cdd6f4")

        terminal.nativeBackgroundColor = bgColor
        terminal.nativeForegroundColor = fgColor
        terminal.selectedTextBackgroundColor = NSColor(hex: "585b70")

        // ANSI palette — 16 SwiftTerm.Color values (UInt16 0-65535, multiply 8-bit by 257)
        func c(_ r: UInt16, _ g: UInt16, _ b: UInt16) -> SwiftTerm.Color {
            SwiftTerm.Color(red: r * 257, green: g * 257, blue: b * 257)
        }
        let ansiPalette: [SwiftTerm.Color] = [
            c(0x45, 0x47, 0x5a), // black
            c(0xf3, 0x8b, 0xa8), // red
            c(0xa6, 0xe3, 0xa1), // green
            c(0xf9, 0xe2, 0xaf), // yellow
            c(0x89, 0xb4, 0xfa), // blue
            c(0xf5, 0xc2, 0xe7), // magenta
            c(0x94, 0xe2, 0xd5), // cyan
            c(0xba, 0xc2, 0xde), // white
            c(0x58, 0x5b, 0x70), // bright black
            c(0xf3, 0x8b, 0xa8), // bright red
            c(0xa6, 0xe3, 0xa1), // bright green
            c(0xf9, 0xe2, 0xaf), // bright yellow
            c(0x89, 0xb4, 0xfa), // bright blue
            c(0xf5, 0xc2, 0xe7), // bright magenta
            c(0x94, 0xe2, 0xd5), // bright cyan
            c(0xa6, 0xad, 0xc8), // bright white
        ]
        terminal.installColors(ansiPalette)

        // Font
        if let font = NSFont(name: "JetBrains Mono", size: 14) {
            terminal.font = font
        } else {
            terminal.font = NSFont(name: "Menlo", size: 14) ?? NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        }

        // Delegate
        terminal.processDelegate = self

        addSubview(terminal)

        // Start shell with pmux.sh plugin auto-loaded via ZDOTDIR
        let shell = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"
        Self.instanceCounter += 1
        let tabNum = Self.instanceCounter
        let tabTitle = "Untitled Term \(tabNum)"
        let (env, cleanup) = Self.buildShellEnvironment(tabNumber: tabNum, tabTitle: tabTitle, startDirectory: startDirectory)
        self.zdotdirCleanup = cleanup

        let home = ProcessInfo.processInfo.environment["HOME"] ?? NSHomeDirectory()
        let documents = home + "/Documents"
        let startDir = startDirectory ?? (FileManager.default.fileExists(atPath: documents) ? documents : home)
        terminal.startProcess(
            executable: shell,
            args: ["-i", "--login"],
            environment: env,
            execName: "-zsh",
            currentDirectory: startDir
        )

    }

    override func layout() {
        super.layout()
        terminal?.frame = bounds
    }

    override func becomeFirstResponder() -> Bool {
        terminal?.window?.makeFirstResponder(terminal)
        return true
    }
}

// MARK: - LocalProcessTerminalViewDelegate
extension PmuxTerminalView: LocalProcessTerminalViewDelegate {
    func sizeChanged(source: LocalProcessTerminalView, newCols: Int, newRows: Int) {
        // Handled by SwiftTerm
    }

    func setTerminalTitle(source: LocalProcessTerminalView, title: String) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: Notification.Name("pmux.renameTab"),
                object: nil,
                userInfo: ["title": title]
            )
        }
    }

    func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {
        if let dir = directory {
            NotificationCenter.default.post(
                name: Notification.Name("pmux.directoryChanged"),
                object: nil,
                userInfo: ["directory": dir]
            )
        }
    }

    func processTerminated(source: TerminalView, exitCode: Int32?) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .closeTab, object: nil)
        }
    }
}
