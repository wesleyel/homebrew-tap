# version/url/sha256 are bumped by Renovate PRs and merged by .github/workflows/ci.yml.
class NcmNowplaying < Formula
  desc "Playback position and word-level lyrics from NetEase Cloud Music on macOS"
  homepage "https://github.com/wesleyel/ncm-nowplaying"
  url "https://github.com/wesleyel/ncm-nowplaying/releases/download/v0.1.1/ncm-nowplaying-0.1.1-macos-universal.tar.gz"
  sha256 "a16f5591b0516e246b5e63a7517fde002c99bcca1152ebb12884e04f3f927eed"
  license "MIT"

  depends_on :macos

  def install
    bin.install "ncm-nowplaying"
    doc.install "README.md", "detail.md"
  end

  service do
    run [opt_bin/"ncm-nowplaying"]
    keep_alive true
    log_path var/"log/ncm-nowplaying.log"
    error_log_path var/"log/ncm-nowplaying.log"
  end

  def caveats
    <<~EOS
      NetEase Cloud Music must be launched with a debugging port, otherwise there is
      no playback state to read:

        osascript -e 'quit app "NeteaseMusic"' && open -a NeteaseMusic --args --remote-debugging-port=9222

      Once running:

        http://127.0.0.1:3574/          current snapshot as JSON
        ws://127.0.0.1:3574/ws          event stream
        http://127.0.0.1:3574/overlay   lyric page for OBS

      To run it in the background: brew services start ncm-nowplaying
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ncm-nowplaying --version")
  end
end
