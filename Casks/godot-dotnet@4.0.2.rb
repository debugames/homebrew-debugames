cask "godot-dotnet@4.0.2" do
  version "4.0.2"
  sha256 "b5c051214b13c0de98909a21bf6a0d1abb273b09b73191c21ca565740fc35814"

  url "https://github.com/godotengine/godot/releases/download/#{version}-stable/Godot_v#{version}-stable_mono_macos.universal.zip",
      verified: "github.com/godotengine/godot/"
  name "Godot Engine"
  desc "C# scripting capable version of Godot game engine"
  homepage "https://godotengine.org/"

  livecheck do
    url :url
    regex(/^v?(\d+(?:\.\d+)+)[._-]stable$/i)
    strategy :github_latest
  end

  depends_on cask: "dotnet-sdk"
  depends_on macos: ">= :sierra"

  app "Godot_dotnet.app"
  # shim script (https://github.com/Homebrew/homebrew-cask/issues/18809)
  shimscript = "#{staged_path}/godot-dotnet.wrapper.sh"
  binary shimscript, target: "godot-dotnet"

  preflight do
    File.write shimscript, <<~EOS
      #!/bin/bash
      '#{appdir}/Godot_dotnet.app/Contents/MacOS/Godot' "$@"
    EOS
  end

  uninstall quit: "org.godotengine.godot"

  zap trash: [
    "~/Library/Application Support/Godot",
    "~/Library/Caches/Godot",
    "~/Library/Saved Application State/org.godotengine.godot.savedState",
  ]
end
