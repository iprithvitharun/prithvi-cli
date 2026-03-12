class Pmux < Formula
  desc "Human-friendly shell commands for Ghostty terminal"
  homepage "https://github.com/iprithvitharun/homebrew-pmux"
  url "https://github.com/iprithvitharun/homebrew-pmux/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "PLACEHOLDER"
  license "MIT"

  def install
    (share/"pmux").install "pmux.zsh"
    (share/"pmux/lib").install Dir["lib/*.zsh"]
    (share/"pmux/commands").install Dir["commands/*.zsh"]
    (share/"pmux").install "ghostty.example.conf"
  end

  def caveats
    <<~EOS
      To activate pmux, add this to your ~/.zshrc:

        source "$(brew --prefix)/share/pmux/pmux.zsh"

      Then restart your terminal or run: source ~/.zshrc
      Type "help" to see available commands.
    EOS
  end

  test do
    assert_predicate share/"pmux/pmux.zsh", :exist?
    assert_predicate share/"pmux/lib/colors.zsh", :exist?
    assert_predicate share/"pmux/commands/git.zsh", :exist?
  end
end
