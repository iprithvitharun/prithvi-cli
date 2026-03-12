import Foundation

class HelpCommand: CommandHandler {
    func handle(_ input: String) -> CommandMiddleware.CommandResult? {
        guard input == "help" || input == "commands" else { return nil }

        let helpText = """

          \u{001B}[1m\u{001B}[38;5;117mpmux.sh\u{001B}[0m — Human-friendly commands

          \u{001B}[2m────────────────────────────────────────────\u{001B}[0m

          \u{001B}[1mFilesystem\u{001B}[0m
          \u{001B}[38;5;210mgo to\u{001B}[0m <folder>        cd into a directory
          \u{001B}[38;5;210mgo back\u{001B}[0m               cd ..
          \u{001B}[38;5;210mgo home\u{001B}[0m               cd ~
          \u{001B}[38;5;210mshow files\u{001B}[0m [path]     ls (with optional path)
          \u{001B}[38;5;210mopen\u{001B}[0m <file>           cat a file
          \u{001B}[38;5;210mnew folder\u{001B}[0m <name>     mkdir
          \u{001B}[38;5;210mnew file\u{001B}[0m <name>       touch
          \u{001B}[38;5;210mwhere am i\u{001B}[0m            pwd

          \u{001B}[1mGit\u{001B}[0m
          \u{001B}[38;5;210mgit status\u{001B}[0m            working tree status
          \u{001B}[38;5;210mgit save\u{001B}[0m              stage all + commit (asks message)
          \u{001B}[38;5;210mgit push\u{001B}[0m              push to remote
          \u{001B}[38;5;210mgit pull\u{001B}[0m              pull from remote
          \u{001B}[38;5;210mgit branch\u{001B}[0m            list branches
          \u{001B}[38;5;210mgit switch\u{001B}[0m            switch branch (asks which)
          \u{001B}[38;5;210mgit new branch\u{001B}[0m        create + switch (asks name)
          \u{001B}[38;5;210mgit log\u{001B}[0m               pretty commit history
          \u{001B}[38;5;210mgit undo\u{001B}[0m              undo last commit (asks confirm)
          \u{001B}[38;5;210mgit discard\u{001B}[0m           discard all changes (asks confirm)
          \u{001B}[38;5;210mgit stash\u{001B}[0m             stash changes
          \u{001B}[38;5;210mgit unstash\u{001B}[0m           restore stashed changes
          \u{001B}[38;5;210mgit diff\u{001B}[0m              show unstaged changes

          \u{001B}[1mTabs\u{001B}[0m
          \u{001B}[38;5;210mtab new\u{001B}[0m [name]        open a new tab
          \u{001B}[38;5;210mtab split\u{001B}[0m [dir]       split pane (right/down)
          \u{001B}[38;5;210mtab rename\u{001B}[0m <name>     rename current tab
          \u{001B}[38;5;210mtab close\u{001B}[0m             close current tab

          \u{001B}[1mnpm\u{001B}[0m
          \u{001B}[38;5;210mnpm dev\u{001B}[0m               npm run dev
          \u{001B}[38;5;210mnpm build\u{001B}[0m             npm run build
          \u{001B}[38;5;210mnpm install\u{001B}[0m [pkg]     install packages
          \u{001B}[38;5;210mnpm remove\u{001B}[0m <pkg>      uninstall a package

          \u{001B}[1mClaude\u{001B}[0m
          \u{001B}[38;5;210mclaude\u{001B}[0m                launch Claude Code
          \u{001B}[38;5;210mclaude\u{001B}[0m <prompt>       ask Claude a question

          \u{001B}[2mAll native commands (cd, ls, git, etc.) still work normally.\u{001B}[0m

        """

        return .init(handled: true, replacement: nil, output: helpText, interactive: nil)
    }
}
