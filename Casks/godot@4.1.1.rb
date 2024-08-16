cask "godot@4.1.1" do
  version "4.1.1"
  sha256 "bbfe748f094fb655c32e0655d9c187b7c76031220d55a9f67a8e360756170c40"

  url "https://github.com/godotengine/godot/releases/download/#{version}-stable/Godot_v#{version}-stable_macos.universal.zip",
      verified: "github.com/godotengine/godot/"
  name "Godot Engine"
  desc "Game development engine"
  homepage "https://godotengine.org/"

  livecheck do
    url :url
    regex(/^v?(\d+(?:\.\d+)+)[._-]stable$/i)
    strategy :github_latest
  end

  conflicts_with cask: [
    "godot",
    "godot@3",
    "godot@4.3",
    "godot@4.2.2",
    "godot@4.1.4",
    "godot@4.2.1",
    "godot@4.2",
    "godot@4.1.3",
    "godot@4.1.2",
    "godot@3.5.3",
    "godot@4.0.4",
    "godot@4.1",
    "godot@4.0.3",
    "godot@4.0.2",
    "godot@4.0.1",
    "godot@3.5.2",
    "godot@4.0",
    "godot@3.5.1",
    "godot@3.5",
    "godot@3.4.5",
    "godot@3.4.4",
    "godot@3.4.3",
    "godot@3.4.2",
    "godot@3.4.1",
    "godot@3.4",
    "godot@3.3.4",
    "godot@3.3.3",
    "godot@3.3.2",
    "godot@3.3.1",
    "godot@3.3",
    "godot@3.2.3",
    "godot@3.2.2",
    "godot@3.2.1",
    "godot@3.2",
    "godot@3.1.2",
    "godot@2.1.6",
    "godot@3.1.1",
    "godot@3.1",
    "godot@3.0.6",
    "godot@2.1.5",
    "godot@3.0.5",
    "godot@3.0.4",
    "godot@3.0.3",
    "godot@3.0.2",
    "godot@3.0.1",
    "godot@3.0",
    "godot@2.1.4",
    "godot@2.1.3",
    "godot@2.1.2",
    "godot@2.1.1",
    "godot@2.1",
    "godot@2.0.4.1",
    "godot@2.0.3",
    "godot@2.0.2",
    "godot@2.0.1",
    "godot@2.0",
    "godot@1.1",
    "godot@1.0",
  ]
  depends_on macos: ">= :sierra"

  app "Godot.app"
  binary "#{appdir}/Godot.app/Contents/MacOS/Godot", target: "godot"

  uninstall quit: "org.godotengine.godot"

  zap trash: [
    "~/Library/Application Support/Godot",
    "~/Library/Caches/Godot",
    "~/Library/Saved Application State/org.godotengine.godot.savedState",
  ]
end
