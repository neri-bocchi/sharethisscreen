cask "sharethisscreen" do
  # version/sha256 are rewritten by ./release.sh — keep them on their own lines.
  version "1.5.0"
  sha256 "aecaf8aa2171aca24459e8a22f76ca9f1ec7e95d184c68806048eca8a1b6f976"

  url "https://github.com/neri-bocchi/sharethisscreen/releases/download/v#{version}/ShareThisScreen-#{version}.zip"
  name "ShareThisScreen"
  desc "Mirrors one window into a window you share, so calls never see your whole screen"
  homepage "https://github.com/neri-bocchi/sharethisscreen"

  livecheck do
    url :url
    strategy :github_latest
  end

  # ScreenCaptureKit + the Continuity Camera device type need macOS 14.
  depends_on macos: :sonoma

  app "ShareThisScreen.app"

  # The release is signed with a stable self-signed identity, not with a
  # Developer ID, so it is not notarized. Homebrew quarantines every cask it
  # downloads, and Gatekeeper refuses to open a quarantined app that Apple
  # never notarized — the user would get "damaged and can't be opened".
  # Stripping the quarantine flag is what makes the app launchable; Gatekeeper
  # only assesses quarantined bundles, and the signature itself stays intact
  # (which is what keeps the Screen Recording grant alive across upgrades).
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/ShareThisScreen.app"]
  end

  uninstall quit: "app.sharethisscreen.mirror"

  zap trash: [
    "~/Library/Preferences/app.sharethisscreen.mirror.plist",
    "~/Library/Saved Application State/app.sharethisscreen.mirror.savedState",
  ]

  caveats <<~EOS
    ShareThisScreen needs Screen Recording permission, which macOS only lets you
    grant by hand — no installer can do it for you.

      1. Launch ShareThisScreen. It will ask, and offer to open the pane for you.
      2. System Settings › Privacy & Security › Screen & System Audio Recording
      3. Enable ShareThisScreen, then reopen the app.

    Open that pane directly with:
      open "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"

    The camera overlay (⌘J) asks for Camera permission the first time you enable
    it. Skip it if you never use the overlay.

    If the toggle is already on but the mirror stays black, the permission is
    stale — reset it and relaunch:
      tccutil reset ScreenCapture app.sharethisscreen.mirror
  EOS
end
