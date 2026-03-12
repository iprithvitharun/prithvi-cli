import SwiftUI

enum PmuxTheme {
    // ── Background ─────────────────────────────────────
    static let background = Color(hex: "1e1e2e")
    static let surface = Color(hex: "282840")
    static let surfaceHover = Color(hex: "313147")

    // ── Tab bar ────────────────────────────────────────
    static let tabBar = Color(hex: "181825")
    static let tabActive = Color(hex: "1e1e2e")
    static let tabInactive = Color(hex: "181825")
    static let tabBorder = Color(hex: "313147")

    // ── Text ───────────────────────────────────────────
    static let text = Color(hex: "cdd6f4")
    static let textSecondary = Color(hex: "a6adc8")
    static let textMuted = Color(hex: "6c7086")

    // ── Accent ─────────────────────────────────────────
    static let pink = Color(hex: "f5a0b0")
    static let cyan = Color(hex: "89dceb")
    static let green = Color(hex: "a6e3a1")
    static let yellow = Color(hex: "f9e2af")
    static let red = Color(hex: "f38ba8")
    static let blue = Color(hex: "89b4fa")
    static let mauve = Color(hex: "cba6f7")

    // ── Terminal colors (Catppuccin Mocha) ──────────────
    static let terminalBackground = Color(hex: "1e1e2e")
    static let terminalForeground = Color(hex: "cdd6f4")
    static let terminalCursor = Color(hex: "f5e0dc")

    // ANSI colors
    static let ansiBlack = Color(hex: "45475a")
    static let ansiRed = Color(hex: "f38ba8")
    static let ansiGreen = Color(hex: "a6e3a1")
    static let ansiYellow = Color(hex: "f9e2af")
    static let ansiBlue = Color(hex: "89b4fa")
    static let ansiMagenta = Color(hex: "f5c2e7")
    static let ansiCyan = Color(hex: "94e2d5")
    static let ansiWhite = Color(hex: "bac2de")

    // Bright ANSI
    static let ansiBrightBlack = Color(hex: "585b70")
    static let ansiBrightRed = Color(hex: "f38ba8")
    static let ansiBrightGreen = Color(hex: "a6e3a1")
    static let ansiBrightYellow = Color(hex: "f9e2af")
    static let ansiBrightBlue = Color(hex: "89b4fa")
    static let ansiBrightMagenta = Color(hex: "f5c2e7")
    static let ansiBrightCyan = Color(hex: "94e2d5")
    static let ansiBrightWhite = Color(hex: "a6adc8")

    // ── Fonts ──────────────────────────────────────────
    static let monoFont = "JetBrains Mono"
    static let monoFontFallback = "Menlo"
    static let fontSize: CGFloat = 14
}
