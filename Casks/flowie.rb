# version/sha256 are written by wesleyel/flowie on each final release; see docs/release-automation.md.
# Until 1.0.0 is out this points at the only build, release candidate 1.0.0-rc.1.
cask "flowie" do
  version "1.0.0-rc.1"
  sha256 "def60f3e6086dd20a7115e605063b393075ea8561e13870ac1c8d6db9ea41160"

  url "https://github.com/wesleyel/flowie/releases/download/v#{version}/Flowie-#{version}-macos.zip"
  name "Flowie"
  desc "Keyboard-first outliner with zoomable bullets, math and local storage"
  homepage "https://wesleyel.github.io/flowie/"

  livecheck do
    url :url
    strategy :github_latest
  end

  conflicts_with cask: "flowie@beta"
  depends_on macos: :ventura

  app "Flowie.app"

  # The release zip is ad-hoc signed and not notarized; without this Gatekeeper
  # blocks the first launch.
  postflight_steps do
    run "/usr/bin/xattr",
        args: ["-dr", "com.apple.quarantine", "{{appdir}}/Flowie.app"]
  end

  zap trash: [
    "~/Library/Application Support/Flowie",
    "~/Library/Saved Application State/flowie.spokey.cn.savedState",
  ]

  caveats <<~EOS
    This is the open-source build: unsandboxed, with its outline in
    ~/Library/Application Support/Flowie. The Mac App Store version installs to the
    same /Applications/Flowie.app, so keep only one of them.
  EOS
end
