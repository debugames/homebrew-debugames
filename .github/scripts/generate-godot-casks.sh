#!/usr/bin/env bash

# This script generates cask files of Godot.
# Requirements: gh, jq
# 1. Read all tags from the Godot repository. (https://github.com/godotengine/godot/)
# 2. Create cask files for each tag.

GODOT_REPO="godotengine/godot"

# Check arguments
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

# Fetch all releases of Godot
releases=''
page=1
while true; do
  ret=$(gh api "repos/godotengine/godot/releases?per_page=100&page=$page" | jq -r '.[].tag_name')
  releases="$releases$ret"
  page=$((page + 1))
  if [ -z "$ret" ] || [ $(echo $ret | wc -l) -lt 100 ]; then # if ret is empty or smaller than 100, then it reached the last page
      break
  fi
done

# Setup all versions and all mono versions (all godot@[version] + godot + godot@3 or godot-mono@[version] + godot-mono + godot-mono@3)
all_versions="godot godot@3"
all_mono_versions="godot-mono godot-mono@3"
for release in $releases; do
  version=$(echo $release | sed -E 's/^v//;s/-stable$//') # remove 'v' prefix and '-stable' suffix
  all_versions="$all_versions godot@$version"
  all_mono_versions="$all_mono_versions godot-mono@$version"
done

for release in $releases; do
  version=$(echo $release | sed -E 's/^v//;s/-stable$//') # remove 'v' prefix and '-stable' suffix
  major=$(echo $version | cut -d. -f1); major=${major:-0} # if major is empty, set it to 0
  minor=$(echo $version | cut -d. -f2); minor=${minor:-0}
  patch=$(echo $version | cut -d. -f3); patch=${patch:-0}
  if [ $major -le 2 ]; then
    echo "Ignore release $version (because of 3.X or lower)"
    continue
  fi
  echo "Processing release $release:"
  # If the cask files already exist and force_overwrite is false, skip it
  rb_file="godot@$version.rb"
  rb_mono_file="godot-mono@$version.rb"
  if [ -f "$output_dir/$rb_file" ] && [ -f "$output_dir/$rb_mono_file" ] && [ $force_overwrite == false ]; then
    echo "  Cask $rb_file and $rb_mono_file already exist"
    continue
  fi
  # Set required macOS version depending on the Godot version
  depends_on_macos=''
  if [ $major -ge 3 ]; then # 3.X or higher
    depends_on_macos='depends_on macos: ">= :sierra"'
  fi
  if [ $major -eq 4 ] && [ $minor -ge 2 ]; then # 4.2 or higher
    depends_on_macos='depends_on macos: ">= :high_sierra"'
  fi
  ##################################
  # For vanilla version (not Mono) #
  ##################################
  # Get macOS download URL, download it, and calculate SHA256
  res=$(gh api "repos/$GODOT_REPO/releases/tags/$release")
  macos_url=($(echo $res | jq -r '.assets[] | select(.name | contains("macos") or contains("osx")) | select(.name | contains("mono") | not) | .browser_download_url'))
  if [ -z "$macos_url" ]; then
    echo "  Error: no macOS download URL found in the release $release"
    exit 1
  fi
  macos_sha256=$(curl -sL $macos_url | shasum -a 256 | cut -d' ' -f1)
  # Replace version with #{version} in URL. (Same as the original Homebrew cask)
  macos_url=$(echo $macos_url | sed -E "s/($version)/\#\{version\}/g")
  # Set conflicts_with (excluding current version from $all_versions)
  conflicts_with_cask="conflicts_with cask: ["
  for v in $all_versions; do
    if [ "$v" == "godot@$version" ]; then
      continue
    fi
    conflicts_with_cask="$conflicts_with_cask\n    \"$v\","
  done
  conflicts_with_cask="$conflicts_with_cask\n  ]"
  # Create a cask file
  if [ $major -ge 3 ]; then # 3.X or higher
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

  $(printf "$conflicts_with_cask")
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
  fi
  echo "  $rb_file is created"
  
  ####################
  # For Mono version #
  ####################
  macos_mono_url=($(echo $res | jq -r '.assets[] | select(.name | contains("macos") or contains("osx")) | select(.name | contains("mono")) | .browser_download_url'))
  if [ -z "$macos_mono_url" ]; then
    echo "  No macOS Mono download URL found in the release $release"
    exit 1
  fi
  macos_mono_sha256=$(curl -sL $macos_mono_url | shasum -a 256 | cut -d' ' -f1)
  macos_mono_url=$(echo $macos_mono_url | sed -E "s/($version)/\#\{version\}/g")
  conflicts_with_cask_mono="conflicts_with cask: ["
  for v in $all_mono_versions; do
    if [ "$v" == "godot-mono@$version" ]; then
      continue
    fi
    conflicts_with_cask_mono="$conflicts_with_cask_mono\n    \"$v\","
  done
  conflicts_with_cask_mono="$conflicts_with_cask_mono\n  ]"
  if [ $major -ge 3 ]; then # 3.X or higher
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

  $(printf "$conflicts_with_cask_mono")
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
  fi
  echo "  $rb_mono_file is created"
done


