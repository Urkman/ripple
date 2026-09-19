#!/bin/zsh
set -euo pipefail

wireframe_dir="${0:A:h}"
render_dir="$(mktemp -d)"
trap 'rm -rf "$render_dir"' EXIT
rendered_count=0

for source in "$wireframe_dir"/*.svg; do
    stem="${source:t:r}"
    rendered="$render_dir/${stem}.png"
    sips -s format png "$source" --out "$rendered" >/dev/null
    if [[ ! -f "$rendered" ]]; then
        print -u2 "sips did not render $source"
        exit 1
    fi
    cp "$rendered" "$wireframe_dir/$stem.png"
    (( rendered_count += 1 ))
done

print "Rendered $rendered_count shared wireframe previews."
