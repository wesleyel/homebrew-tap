cask "zed-dev-termio-shim" do
  version "0.1.0"
  sha256 "8fd0851b26d8ea14b3ff2f75b604a79cf25a0d19ba9320a47eccaa1ee7eeb2be"

  url "file://#{File.expand_path("../Scripts/zed-dev-termio-shim-build.sh", __dir__)}"
  name "Zed Dev Termio Shim"
  desc "Expose Zed Dev through the stable Zed bundle identifier for Termio"
  homepage "https://github.com/wesleyel/homebrew-tap"

  livecheck do
    skip "Versioned with the tap source"
  end

  conflicts_with cask: "zed"
  depends_on macos: :big_sur

  app "Zed Termio Shim.app"

  preflight_steps do
    run "/bin/zsh",
        args:           [
          "{{staged_path}}/zed-dev-termio-shim-build.sh",
          "{{staged_path}}/Zed Termio Shim.app",
          version,
        ],
        writable_paths: ["."],
        writable_base:  :staged_path
  end

  postflight_steps do
    run "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister",
        args: ["-f", "{{appdir}}/Zed Termio Shim.app"]
  end

  uninstall_preflight_steps do
    run "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister",
        args:         ["-u", "{{appdir}}/Zed Termio Shim.app"],
        must_succeed: false
  end

  caveats <<~EOS
    Zed Dev must be installed with bundle identifier dev.zed.Zed-Dev.
    Restart Termio after installing, upgrading, or uninstalling this shim because
    Termio caches its installed-editor list for the lifetime of the process.
  EOS
end
