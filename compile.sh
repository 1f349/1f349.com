#!/bin/bash
function mp() {
  echo "  <meta property=\"$1\" content=\"$2\">"
}

rm -rf build/
mkdir build/
cp -r assets/ build/assets/
find . -name '*.page' -print0 |
  while IFS= read -r -d '' ff; do
    d=`dirname "$ff"`
    f2=`basename "$ff"`
    f3="${f2%.page}.html" # build filename
    echo "Writing $ff -> $f3"
    mkdir -p "build/$d"
    exec 3<> "build/$d/$f3"
    while IFS= read -r p; do
      a=`echo "$p" | tr -d '[:space:]'`
      if [ "$a" == "{{head}}" ]; then
        echo "  <title>$(yq -r '.meta.title' "$ff")</title>" >&3
        echo "  <meta name=\"author\" content=\"$(yq -r '.meta.title' "$ff")\">" >&3
        mp "og:title" "$(yq -r '.meta.og-title' "$ff")" >&3
        mp "og:url" "$(yq -r '.meta.og-url' "$ff")" >&3
        mp "og:type" "$(yq -r '.meta.og-type' "$ff")" >&3
        mp "og:image" "$(yq -r '.meta.og-image' "$ff")" >&3
        mp "og:site_name" "$(yq -r '.meta.og-site_name' "$ff")" >&3
      elif [ "$a" == "{{page}}" ]; then
        yq -r '.content' "$ff" >&3
      else
        echo "$p" >&3
      fi
    done < "+layout.html"
    exec 3>&-
  done
