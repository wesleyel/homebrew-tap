#!/bin/zsh

set -euo pipefail

if [[ $# -ne 2 ]]; then
    print -u2 "usage: $0 OUTPUT_APP VERSION"
    exit 64
fi

shim_output=$1
shim_version=$2

if [[ $shim_output != *.app || $shim_output == "/.app" ]]; then
    print -u2 "refusing unsafe output path: $shim_output"
    exit 64
fi

for stable_zed in "/Applications/Zed.app" "${HOME}/Applications/Zed.app"; do
    stable_plist="${stable_zed}/Contents/Info.plist"
    [[ -f $stable_plist ]] || continue

    stable_id=$(/usr/bin/plutil -extract CFBundleIdentifier raw "$stable_plist" 2>/dev/null || true)
    if [[ $stable_id == "dev.zed.Zed" ]]; then
        print -u2 "Zed stable is already installed at $stable_zed; the Termio shim is unnecessary."
        exit 1
    fi
done

if [[ -e $shim_output ]]; then
    /bin/rm -rf -- "$shim_output"
fi

/bin/mkdir -p "${shim_output}/Contents/MacOS" "${shim_output}/Contents/Resources"

shim_module_cache="${shim_output:h}/.zed-termio-shim-module-cache"
/bin/mkdir -p "$shim_module_cache"
trap '/bin/rm -rf -- "$shim_module_cache"' EXIT

/usr/bin/xcrun swiftc -O -parse-as-library -framework AppKit -module-cache-path "$shim_module_cache" \
    -o "${shim_output}/Contents/MacOS/ZedTermioShim" - <<'SWIFT'
import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let targetBundleIdentifier = "dev.zed.Zed-Dev"

    func application(_ application: NSApplication, open urls: [URL]) {
        guard !urls.isEmpty else {
            application.terminate(nil)
            return
        }

        guard let target = NSWorkspace.shared.urlForApplication(
            withBundleIdentifier: targetBundleIdentifier
        ) else {
            let alert = NSAlert()
            alert.messageText = "Zed Dev Not Found"
            alert.informativeText = "Install Zed Dev before using the Termio shim."
            alert.alertStyle = .warning
            alert.runModal()
            application.terminate(nil)
            return
        }

        NSWorkspace.shared.open(
            urls,
            withApplicationAt: target,
            configuration: NSWorkspace.OpenConfiguration()
        ) { _, _ in
            Task { @MainActor in
                application.terminate(nil)
            }
        }
    }
}

@main
struct ZedTermioShim {
    @MainActor
    static func main() {
        let application = NSApplication.shared
        let delegate = AppDelegate()
        application.delegate = delegate
        application.setActivationPolicy(.accessory)
        application.run()
    }
}
SWIFT

shim_plist="${shim_output}/Contents/Info.plist"

/usr/bin/plutil -create xml1 "$shim_plist"
/usr/libexec/PlistBuddy -c 'Add :CFBundleDevelopmentRegion string en' "$shim_plist"
/usr/libexec/PlistBuddy -c 'Add :CFBundleExecutable string ZedTermioShim' "$shim_plist"
/usr/libexec/PlistBuddy -c 'Add :CFBundleIconFile string Zed' "$shim_plist"
/usr/libexec/PlistBuddy -c 'Add :CFBundleIdentifier string dev.zed.Zed' "$shim_plist"
/usr/libexec/PlistBuddy -c 'Add :CFBundleInfoDictionaryVersion string 6.0' "$shim_plist"
/usr/libexec/PlistBuddy -c 'Add :CFBundleName string Zed' "$shim_plist"
/usr/libexec/PlistBuddy -c 'Add :CFBundleDisplayName string Zed' "$shim_plist"
/usr/libexec/PlistBuddy -c 'Add :CFBundlePackageType string APPL' "$shim_plist"
/usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string $shim_version" "$shim_plist"
/usr/libexec/PlistBuddy -c "Add :CFBundleVersion string $shim_version" "$shim_plist"
/usr/libexec/PlistBuddy -c 'Add :LSUIElement bool true' "$shim_plist"
/usr/libexec/PlistBuddy -c 'Add :LSMinimumSystemVersion string 11.0' "$shim_plist"
/usr/libexec/PlistBuddy -c 'Add :NSHighResolutionCapable bool true' "$shim_plist"

/usr/bin/plutil -replace CFBundleDocumentTypes -json \
    '[{"CFBundleTypeName":"Folder","CFBundleTypeRole":"Editor","LSHandlerRank":"Alternate","LSItemContentTypes":["public.folder"]}]' \
    "$shim_plist"

for zed_dev in "/Applications/Zed Dev.app" "${HOME}/Applications/Zed Dev.app"; do
    zed_dev_icon="${zed_dev}/Contents/Resources/Zed Dev.icns"
    [[ -f $zed_dev_icon ]] || continue
    /bin/cp "$zed_dev_icon" "${shim_output}/Contents/Resources/Zed.icns"
    break
done

/usr/bin/codesign --force --deep --sign - "$shim_output"
