#!/usr/bin/env bash

# This script is used to create the Godot casks for Homebrew.
# 1. Read all tags from the Godot repository. (https://github.com/godotengine/godot/)
# 2. Create a cask for each tag.
# Requirements:
# - gh, jq

GODOT_REPO="godotengine/godot"

# Usage: ./create-godot-casks.sh OUTPUT_DIR
if [ $# -ne 1 ]; then
    echo "Usage: $0 OUTPUT_DIR"
    exit 1
fi
output_dir=$1

# Fetch all releases from the Godot repository
releases=''
page=1
while true; do
    ret=$(gh api "repos/godotengine/godot/releases?per_page=100&page=$page" | jq -r '.[].tag_name')
    releases="$releases$ret"
    page=$((page + 1))
    # if ret is empty or smaller than 100, then it reached the last page
    if [ -z "$ret" ] || [ $(echo $ret | wc -l) -lt 100 ]; then
        break
    fi
done

for release in $releases; do
    echo "Processing release $release:"
    version=$(echo $release | sed -E 's/^v//;s/-stable$//') # remove 'v' prefix and '-stable' suffix
    rb_file="godot@$version.rb"
    rb_mono_file="godot-mono@$version.rb"
    # if both rb_file and rb_mono_file already exist, then skip
    if [ -f "$output_dir/$rb_file" ] && [ -f "$output_dir/$rb_mono_file" ]; then
        echo "  Cask $rb_file and $rb_mono_file already exist"
        continue
    fi
    major=$(echo $version | cut -d. -f1)
    minor=$(echo $version | cut -d. -f2)
    # patch=$(echo $version | cut -d. -f3)
    if [ $major -le 3 ]; then
        echo "Ignoring version 3.X or lower ($version)"
        continue
    fi
    # Get *.zip file of normal and mono, and get the SHA256 checksum
    res=$(gh api "repos/$GODOT_REPO/releases/tags/$release")
    macos_url=($(echo $res | jq -r '.assets[] | select(.name | contains("macos") or contains("osx")) | select(.name | contains("mono") | not) | .browser_download_url'))
    macos_mono_url=($(echo $res | jq -r '.assets[] | select(.name | contains("macos") or contains("osx")) | select(.name | contains("mono")) | .browser_download_url'))
    macos_sha256=$(curl -# -L $macos_url | shasum -a 256 | cut -d' ' -f1)
    macos_mono_sha256=$(curl -# -L $macos_mono_url | shasum -a 256 | cut -d' ' -f1)
    # For future updates, it may be necessary to change the required macOS version on specific major or minor versions
    required_macos_version="high_sierra"
    required_macos_mono_version="sierra"
    # If there is a version in the URL, replace it with #{version} to make it the same as the original Homebrew.
    macos_url=$(echo $macos_url | sed -E "s/($version)/\#\{version\}/g")
    macos_mono_url=$(echo $macos_mono_url | sed -E "s/($version)/\#\{version\}/g")
    
    cat > "$output_dir/$rb_file" <<EOF
cask "godot@$version" do
  version "$version"
  sha256 "$macos_sha256"

  url "$macos_url",
      verified: "github.com/$GODOT_REPO/"
  name "Godot Engine"
  desc "Game development engine"
  homepage "https://godotengine.org/"

  livecheck do
    url :url
    regex(/^v?(\d+(?:\.\d+)+)[._-]stable$/i)
    strategy :github_latest
  end

  conflicts_with cask: "godot@3"
  depends_on macos: ">= :$required_macos_version"

  app "Godot.app"
  binary "#{appdir}/Godot.app/Contents/MacOS/Godot", target: "godot"

  uninstall quit: "org.godotengine.godot"

  zap trash: [
    "~/Library/Application Support/Godot",
    "~/Library/Caches/Godot",
    "~/Library/Saved Application State/org.godotengine.godot.savedState",
  ]
end
EOF

    cat > "$output_dir/$rb_mono_file" <<EOF
cask "godot-mono@$version" do
  version "$version"
  sha256 "$macos_mono_sha256"

  url "$macos_mono_url",
      verified: "github.com/$GODOT_REPO/"
  name "Godot Engine"
  desc "C# scripting capable version of Godot game engine"
  homepage "https://godotengine.org/"

  livecheck do
    url :url
    regex(/^v?(\d+(?:\.\d+)+)[._-]stable$/i)
    strategy :github_latest
  end

  depends_on cask: "dotnet-sdk"
  depends_on macos: ">= :$required_macos_mono_version"

  app "Godot_mono.app"
  # shim script (https://github.com/Homebrew/homebrew-cask/issues/18809)
  shimscript = "#{staged_path}/godot-mono.wrapper.sh"
  binary shimscript, target: "godot-mono"

  preflight do
    File.write shimscript, <<~EOS
      #!/bin/bash
      '#{appdir}/Godot_mono.app/Contents/MacOS/Godot' "\$@"
    EOS
  end

  uninstall quit: "org.godotengine.godot"

  zap trash: [
    "~/Library/Application Support/Godot",
    "~/Library/Caches/Godot",
    "~/Library/Saved Application State/org.godotengine.godot.savedState",
  ]
end
EOF
done


