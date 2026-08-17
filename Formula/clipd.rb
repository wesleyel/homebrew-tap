# version/url/sha256 are bumped by Renovate PRs and merged by .github/workflows/ci.yml.
class Clipd < Formula
  desc "HTTP bridge to the macOS pasteboard"
  homepage "https://github.com/wesleyel/clipd"
  url "https://github.com/wesleyel/clipd/releases/download/v0.1.1/clipd-0.1.1.tar.gz"
  sha256 "6c470d4e76cc95414223b9217e4f2ff050958335cea8b8fc5144f19322b2839c"
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

      To require a token, set CLIPD_TOKEN or run in the foreground:

        clipd --token s3cret --notify
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/clipd --version")
  end
end
