cask "godot@3.2.1" do
  version "3.2.1"
  sha256 "bf03a9430d53ed1f748f25d8840cba109f99e1d5d11ae8b23535a0b75286ec95"

  url "https://github.com/godotengine/godot/releases/download/#{version}-stable/Godot_v#{version}-stable_osx.64.zip",
      verified: "github.com/godotengine/godot/"
  name "Godot Engine"
  desc "Game development engine"
  homepage "https://godotengine.org/"

  livecheck do
    url :url
    regex(/^v?(\d+(?:\.\d+)+)[._-]stable$/i)
    strategy :github_latest
  end

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
