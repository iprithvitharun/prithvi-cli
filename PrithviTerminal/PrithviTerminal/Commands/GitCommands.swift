import Foundation

class GitCommands: CommandHandler {
    func handle(_ input: String) -> CommandMiddleware.CommandResult? {
        switch input {
        case "git status":
            return .init(
                handled: true,
                replacement: """
                echo '' && echo '  \\033[38;5;111m→\\033[0m \\033[1mGit Status\\033[0m' && echo '' && \
                git status --short | while IFS= read -r line; do \
                  sc="${line:0:2}"; f="${line:3}"; \
                  case "$sc" in \
                    '??') echo "  \\033[38;5;203m●\\033[0m \\033[2muntracked\\033[0m  $f" ;; \
                    ' M') echo "  \\033[38;5;221m●\\033[0m \\033[2mmodified\\033[0m   $f" ;; \
                    'M ') echo "  \\033[38;5;114m●\\033[0m \\033[2mstaged\\033[0m     $f" ;; \
                    'A ') echo "  \\033[38;5;114m●\\033[0m \\033[2madded\\033[0m      $f" ;; \
                    ' D') echo "  \\033[38;5;203m●\\033[0m \\033[2mdeleted\\033[0m    $f" ;; \
                    *) echo "  \\033[38;5;243m●\\033[0m $sc $f" ;; \
                  esac; \
                done && echo ''
                """,
                output: nil,
                interactive: nil
            )

        case "git save":
            return .init(
                handled: true,
                replacement: nil,
                output: nil,
                interactive: .init(
                    question: "Commit message?",
                    handler: { msg in
                        "git add -A && git commit -m '\(msg.replacingOccurrences(of: "'", with: "'\\''"))'"
                    }
                )
            )

        case "git push":
            return .init(
                handled: true,
                replacement: "git push -u origin $(git symbolic-ref --short HEAD 2>/dev/null)",
                output: nil,
                interactive: nil
            )

        case "git pull":
            return .init(
                handled: true,
                replacement: "git pull",
                output: nil,
                interactive: nil
            )

        case "git branch":
            return .init(
                handled: true,
                replacement: """
                echo '' && echo '  \\033[38;5;111m→\\033[0m \\033[1mBranches\\033[0m' && echo '' && \
                git branch --list | while IFS= read -r line; do \
                  if [[ "$line" == '* '* ]]; then \
                    echo "  \\033[38;5;114m●\\033[0m \\033[1m${line:2}\\033[0m \\033[2m(current)\\033[0m"; \
                  else \
                    echo "  \\033[38;5;243m○\\033[0m ${line:2}"; \
                  fi; \
                done && echo ''
                """,
                output: nil,
                interactive: nil
            )

        case "git switch":
            return .init(
                handled: true,
                replacement: nil,
                output: nil,
                interactive: .init(
                    question: "Which branch?",
                    handler: { branch in
                        "git checkout \(branch.trimmingCharacters(in: .whitespaces))"
                    }
                )
            )

        case "git new branch":
            return .init(
                handled: true,
                replacement: nil,
                output: nil,
                interactive: .init(
                    question: "Branch name?",
                    handler: { name in
                        "git checkout -b \(name.trimmingCharacters(in: .whitespaces))"
                    }
                )
            )

        case "git log":
            return .init(
                handled: true,
                replacement: "git log --oneline --graph --decorate --color -20",
                output: nil,
                interactive: nil
            )

        case "git undo":
            return .init(
                handled: true,
                replacement: nil,
                output: nil,
                interactive: .init(
                    question: "Are you sure? This will undo the last commit. (yes/no)",
                    handler: { confirm in
                        if confirm.lowercased() == "yes" || confirm.lowercased() == "y" {
                            return "git reset --soft HEAD~1 && echo '  \\033[38;5;114m✓\\033[0m Undone. Changes are still staged.'"
                        }
                        return "echo '  \\033[38;5;111m→\\033[0m Cancelled'"
                    }
                )
            )

        case "git discard":
            return .init(
                handled: true,
                replacement: nil,
                output: nil,
                interactive: .init(
                    question: "Discard ALL uncommitted changes? (yes/no)",
                    handler: { confirm in
                        if confirm.lowercased() == "yes" || confirm.lowercased() == "y" {
                            return "git checkout -- . && git clean -fd && echo '  \\033[38;5;114m✓\\033[0m All changes discarded'"
                        }
                        return "echo '  \\033[38;5;111m→\\033[0m Cancelled'"
                    }
                )
            )

        case "git stash":
            return .init(
                handled: true,
                replacement: "git stash push -m \"pmux-stash-$(date +%H:%M:%S)\"",
                output: nil,
                interactive: nil
            )

        case "git unstash":
            return .init(
                handled: true,
                replacement: "git stash pop",
                output: nil,
                interactive: nil
            )

        case "git diff":
            return .init(
                handled: true,
                replacement: "git diff --color",
                output: nil,
                interactive: nil
            )

        default:
            return nil
        }
    }
}
