cask "godot@3.1.1" do
  version "3.1.1"
  sha256 "bd6beb619c759988d6142a179b0cebe53ce26975e3e798cb124d9ed6d9b1c6e1"

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
