cask "godot@4.0" do
  version "4.0"
  sha256 "de8f2e829eacc74ce0ac2a08845e9d67976ccdd5cfe3ef31a2215bba80270dfd"

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
