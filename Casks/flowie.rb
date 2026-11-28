# version/sha256 are written by wesleyel/flowie on each release, release candidates included
# (the newest version only); see docs/release-automation.md.
cask "flowie" do
  version "1.1.0-rc.2"
  sha256 "9394178afd97de48cf3f8e875ff1f32cc8f694f38f15880e83ecb656049fb8e0"

  url "https://github.com/wesleyel/flowie/releases/download/v#{version}/Flowie-#{version}-macos.zip"
  name "Flowie"
  desc "Keyboard-first outliner with zoomable bullets, math and local storage"
  homepage "https://wesleyel.github.io/flowie/"

  livecheck do
    url :url
    strategy :github_latest
  end

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
