cask "godot-mono@3.4.2" do
  version "3.4.2"
  sha256 "701a3b55b05c2cef7e602a64a3f67568e40733eda6d54e38306d344e21bc3f43"

  url "https://github.com/godotengine/godot/releases/download/#{version}-stable/Godot_v#{version}-stable_mono_osx.universal.zip",
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

  app "Godot_mono.app"
  # shim script (https://github.com/Homebrew/homebrew-cask/issues/18809)
  shimscript = "#{staged_path}/godot-mono.wrapper.sh"
  binary shimscript, target: "godot-mono"

  preflight do
    File.write shimscript, <<~EOS
      #!/bin/bash
      '#{appdir}/Godot_mono.app/Contents/MacOS/Godot' "$@"
    EOS
  end

  uninstall quit: "org.godotengine.godot"

  zap trash: [
    "~/Library/Application Support/Godot",
    "~/Library/Caches/Godot",
    "~/Library/Saved Application State/org.godotengine.godot.savedState",
  ]
end
