# version/sha256 are written by wesleyel/flowie on each release, release candidates included;
# see docs/release-automation.md.
cask "flowie@beta" do
  version "1.0.0-rc.1"
  sha256 "def60f3e6086dd20a7115e605063b393075ea8561e13870ac1c8d6db9ea41160"

  url "https://github.com/wesleyel/flowie/releases/download/v#{version}/Flowie-#{version}-macos.zip"
  name "Flowie"
  desc "Keyboard-first outliner with zoomable bullets, math and local storage"
  homepage "https://wesleyel.github.io/flowie/"

  # Release candidates are GitHub pre-releases, which :github_latest skips.
  livecheck do
    url "https://github.com/wesleyel/flowie.git"
    regex(/^v?(\d+(?:\.\d+)+(?:-rc\.\d+)?)$/i)
  end

  conflicts_with cask: "flowie"
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
    This follows Flowie's release candidates (and final versions).
    This is the open-source build: unsandboxed, with its outline in
    ~/Library/Application Support/Flowie. The Mac App Store version installs to the
    same /Applications/Flowie.app, so keep only one of them.
  EOS
end
