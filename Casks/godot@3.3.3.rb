cask "godot@3.3.3" do
  version "3.3.3"
  sha256 "c87fce2df4e21d066ac17abda52a7bae5bf26cc77c78f6c71e21556a53d51702"

  url "https://github.com/godotengine/godot/releases/download/#{version}-stable/Godot_v#{version}-stable_osx.universal.zip",
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
