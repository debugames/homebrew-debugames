cask "godot-dotnet@4.0.4" do
  version "4.0.4"
  sha256 "b69c384a1cc56824ab79750f6338e437ac19d3a33d87c8d73f8ec86b076558e1"

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
