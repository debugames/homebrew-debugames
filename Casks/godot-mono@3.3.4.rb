cask "godot-mono@3.3.4" do
  version "3.3.4"
  sha256 "6231791071fe63bc665ab1b8f6ee023e7665ab344061379323bdc499d82debad"

  url "https://github.com/godotengine/godot/releases/download/#{version}-stable/Godot_v#{version}-stable_mono_osx.64.zip",
      verified: "github.com/godotengine/godot/"
  name "Godot Engine"
  desc "C# scripting capable version of Godot game engine"
  homepage "https://godotengine.org/"

  livecheck do
    url :url
    regex(/^v?(\d+(?:\.\d+)+)[._-]stable$/i)
    strategy :github_latest
  end

  conflicts_with cask: [
    "godot-mono",
    "godot-mono@3",
    "godot-mono@4.3",
    "godot-mono@4.2.2",
    "godot-mono@4.1.4",
    "godot-mono@4.2.1",
    "godot-mono@4.2",
    "godot-mono@4.1.3",
    "godot-mono@4.1.2",
    "godot-mono@3.5.3",
    "godot-mono@4.0.4",
    "godot-mono@4.1.1",
    "godot-mono@4.1",
    "godot-mono@4.0.3",
    "godot-mono@4.0.2",
    "godot-mono@4.0.1",
    "godot-mono@3.5.2",
    "godot-mono@4.0",
    "godot-mono@3.5.1",
    "godot-mono@3.5",
    "godot-mono@3.4.5",
    "godot-mono@3.4.4",
    "godot-mono@3.4.3",
    "godot-mono@3.4.2",
    "godot-mono@3.4.1",
    "godot-mono@3.4",
    "godot-mono@3.3.3",
    "godot-mono@3.3.2",
    "godot-mono@3.3.1",
    "godot-mono@3.3",
    "godot-mono@3.2.3",
    "godot-mono@3.2.2",
    "godot-mono@3.2.1",
    "godot-mono@3.2",
    "godot-mono@3.1.2",
    "godot-mono@2.1.6",
    "godot-mono@3.1.1",
    "godot-mono@3.1",
    "godot-mono@3.0.6",
    "godot-mono@2.1.5",
    "godot-mono@3.0.5",
    "godot-mono@3.0.4",
    "godot-mono@3.0.3",
    "godot-mono@3.0.2",
    "godot-mono@3.0.1",
    "godot-mono@3.0",
    "godot-mono@2.1.4",
    "godot-mono@2.1.3",
    "godot-mono@2.1.2",
    "godot-mono@2.1.1",
    "godot-mono@2.1",
    "godot-mono@2.0.4.1",
    "godot-mono@2.0.3",
    "godot-mono@2.0.2",
    "godot-mono@2.0.1",
    "godot-mono@2.0",
    "godot-mono@1.1",
    "godot-mono@1.0",
  ]
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
