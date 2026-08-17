# Template for the Homebrew formula, and the single source of truth for it.
# The release workflow fills in 0.1.0 / 69c0a6467a2afea168e4c51f9eea2295be4e826a1fb4d64fa1513e005cb5b869 and pushes the result to
# wesleyel/homebrew-tap. Do not edit Formula/clipd.rb in the tap directly;
# the next release overwrites it.
class Clipd < Formula
  desc "HTTP bridge to the macOS pasteboard"
  homepage "https://github.com/wesleyel/clipd"
  url "https://github.com/wesleyel/clipd/releases/download/v0.1.0/clipd-0.1.0-macos-universal.tar.gz"
  sha256 "69c0a6467a2afea168e4c51f9eea2295be4e826a1fb4d64fa1513e005cb5b869"
  license "MIT"

  depends_on :macos

  def install
    bin.install "clipd"
    doc.install "README.md"
  end

  service do
    run [opt_bin/"clipd", "--notify"]
    environment_variables PATH: std_service_path_env
    keep_alive true
    log_path var/"log/clipd.log"
    error_log_path var/"log/clipd.log"
  end

  def caveats
    <<~EOS
      clipd listens on 0.0.0.0:14756. Without a token, anyone on the LAN can
      read and write the pasteboard. Set CLIPD_TOKEN if you bind beyond loopback.

      The Homebrew service runs with --notify and no token. Do not start it with
      sudo — the pasteboard is per-user.

        brew services start clipd

      To require a token, add CLIPD_TOKEN to the generated LaunchAgent, or run
      in the foreground:

        clipd --token s3cret --notify

      If you previously used the hand-written LaunchAgent, unload it first so
      it does not fight Homebrew for the port:

        launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.wesley.clipd.plist
        rm -f ~/Library/LaunchAgents/com.wesley.clipd.plist
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/clipd --version")
  end
end
