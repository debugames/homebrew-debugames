#!/usr/bin/env bash

# This script is used to create the Godot casks for Homebrew.
# 1. Read all tags from the Godot repository. (https://github.com/godotengine/godot/)
# 2. Create a cask for each tag.
# Requirements:
# - gh, jq

GODOT_REPO="godotengine/godot"

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "Usage: $0 OUTPUT_DIR [-f]"
    echo "  OUTPUT_DIR: Directory to save the cask files"
    echo "  -f: Force overwrite existing cask files"
    exit 1
fi
output_dir=$1
force_overwrite=false
if [ $# -eq 2 ] && [ "$2" == "-f" ]; then
    force_overwrite=true
fi

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
    major=$(echo $version | cut -d. -f1); major=${major:-0} # if major is empty, set it to 0
    minor=$(echo $version | cut -d. -f2); minor=${minor:-0}
    patch=$(echo $version | cut -d. -f3); patch=${patch:-0}
    if [ $major -le 3 ]; then
        echo "  Ignoring version 3.X or lower ($version)"
        continue
    fi
    rb_file="godot@$version.rb"
    rb_mono_file="godot-mono@$version.rb"
    if [ -f "$output_dir/$rb_file" ] && [ -f "$output_dir/$rb_mono_file" ]; then
        echo "  Cask $rb_file and $rb_mono_file already exist"
        continue
    fi
    # Get *.zip file of normal and mono, and get the SHA256 checksum
    res=$(gh api "repos/$GODOT_REPO/releases/tags/$release")
    macos_url=($(echo $res | jq -r '.assets[] | select(.name | contains("macos") or contains("osx")) | select(.name | contains("mono") | not) | .browser_download_url'))
    macos_mono_url=($(echo $res | jq -r '.assets[] | select(.name | contains("macos") or contains("osx")) | select(.name | contains("mono")) | .browser_download_url'))
    macos_sha256=$(curl -sL $macos_url | shasum -a 256 | cut -d' ' -f1)
    macos_mono_sha256=$(curl -sL $macos_mono_url | shasum -a 256 | cut -d' ' -f1)
    # Replace version with #{version} in URL. (Same as the original Homebrew cask)
    macos_url=$(echo $macos_url | sed -E "s/($version)/\#\{version\}/g")
    macos_mono_url=$(echo $macos_mono_url | sed -E "s/($version)/\#\{version\}/g")

    depends_on_macos=''
    if [ $major -eq 4 ] && [ $minor -ge 1 ]; then # 4.1 or higher
        depends_on_macos='depends_on macos: ">= :sierra"'
    fi
    if [ $major -eq 4 ] && [ $minor -ge 2 ]; then # 4.2 or higher
        depends_on_macos='depends_on macos: ">= :high_sierra"'
    fi
    
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
  $depends_on_macos

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
  $depends_on_macos

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
    echo "  Created cask $rb_file and $rb_mono_file"
done


