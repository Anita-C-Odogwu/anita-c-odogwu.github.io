#!/usr/bin/env bash
set -euo pipefail

WATERMARK_TEXT="© Anita C. Odogwu"
MAX_WIDTH=1600
QUALITY=85

process_file() {
  local f="$1"
  local rel="${f#./}"
  local dir="$(dirname "$rel")"
  local base="$(basename "$rel")"
  local name="${base%.*}"
  local target_dir="optimized-images/$dir"
  mkdir -p "$target_dir"

  local out_webp="$target_dir/${name}.webp"
  local out_webp_wm="$target_dir/${name}-wm.webp"

  echo "Processing: $f -> $out_webp_wm"

  # Auto-orient, resize and create webp
  magick "$f" -auto-orient -strip -resize "${MAX_WIDTH}x${MAX_WIDTH}>" -quality ${QUALITY} "$out_webp"

  # Temporary watermark canvas
  tmp_wm=$(mktemp --suffix=.png)
  img_width=$(magick identify -format "%w" "$out_webp")
  pts=$(( img_width / 20 ))
  if [ "$pts" -lt 18 ]; then pts=18; fi
  if [ "$pts" -gt 120 ]; then pts=120; fi

  magick -size ${img_width}x${pts} xc:none -gravity center \
    -font Arial -pointsize ${pts} -fill "rgba(255,255,255,0.55)" -annotate -30 "$WATERMARK_TEXT" \
    "$tmp_wm"

  magick "$out_webp" "$tmp_wm" -gravity southeast -geometry +40+40 -compose over -composite "$out_webp_wm"

  rm -f "$tmp_wm"
}

export -f process_file

for dir in "Finished Drawings" "Ceremony"; do
  if [ -d "$dir" ]; then
    find "$dir" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) -print0 | while IFS= read -r -d '' file; do
      process_file "$file"
    done
  else
    echo "Directory not found: $dir (skipping)"
  fi
done

echo "Done processing images. Optimized images are in optimized-images/"
