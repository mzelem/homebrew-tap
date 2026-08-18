class Upmixd < Formula
  desc "Stereo-to-5.1 upmix daemon with live EQ and menu-bar panel"
  homepage "https://github.com/mzelem/upmixd"
  url "https://github.com/mzelem/upmixd/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "00f4cf4eec043001fabd62c38790dab4b5a5da6e791a6c78665b3705f598903e"
  license "MIT"

  depends_on :macos
  depends_on xcode: ["15.0", :build]

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"
    bin.install ".build/release/upmixd"
    libexec.install ".build/release/upmix-panel"
    libexec.install "dist/UpmixPanel-Info.plist"
    libexec.install "dist/com.utw.upmix-panel.plist"
    bin.install "dist/upmixd-panel"
  end

  service do
    run [opt_bin/"upmixd", "--set-default"]
    keep_alive true
    process_type :interactive
    log_path var/"log/upmixd.log"
    error_log_path var/"log/upmixd.log"
  end

  def caveats
    <<~EOS
      upmixd captures system audio through the BlackHole virtual driver:
        brew install --cask blackhole-2ch
      then restart coreaudiod (sudo killall coreaudiod) or reboot once.

      Start the daemon (also starts at login):
        brew services start upmixd
      Grant microphone access when macOS asks — capturing from BlackHole
      counts as audio input; silence with a healthy log usually means the
      permission was denied (System Settings > Privacy > Microphone).

      Optional menu-bar panel with EQ sliders:
        upmixd-panel install

      All settings live in ~/.config/upmixd.conf, reloaded the instant
      you save.

      Previously installed from source with `make install`? Run
      `make uninstall` first — otherwise two daemons will fight over the
      audio device. After `brew upgrade`, rerun `upmixd-panel install`
      to refresh the panel app copy.
    EOS
  end

  test do
    output = shell_output("#{bin}/upmixd --bogus 2>&1", 64)
    assert_match "usage", output
  end
end
