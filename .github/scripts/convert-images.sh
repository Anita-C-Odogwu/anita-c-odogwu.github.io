#!/usr/bin/env bash
set -euo pipefail

# convert-images.sh
# - Finds images under Finished Drawings/ and Ceremony/
# - Creates optimized WebP copies and watermarked WebP copies under optimized-images/
# - Uses ImageMagick (magick) available on ubuntu-latest runners

WATERMARK_TEXT="© Anita C. Odogwu"
MAX_WIDTH=1600
QUALITY=85

process_file() {
  local f="$1"
  # create target dir preserving structure under optimized-images/
  # remove leading ./ if present
  local rel="${f#./}"
  local dir="$(dirname "$rel")"
  local base="$(basename "$rel")"
  local name="${base%.*}"
  local target_dir="optimized-images/$dir"
  mkdir -p "$target_dir"

  local out_webp="$target_dir/${name}.webp"
  local out_webp_wm="$target_dir/${name}-wm.webp"

  echo "Processing: $f -> $out_webp_wm"

  # Resize and convert to webp; auto-orient first so rotated images keep correct orientation
  magick "$f" -auto-orient -strip -resize "${MAX_WIDTH}x${MAX_WIDTH}>" -quality ${QUALITY} "$out_webp"

  # Create a rotated watermark image (transparent background) sized relative to source width
  # We'll create a watermark canvas and then composite it onto the image bottom-right
  # Create temporary watermark image
  tmp_wm=$(mktemp --suffix=.png)
  # Determine a good pointsize based on image width
  img_width=$(magick identify -format "%w" "$out_webp")
  # choose point size as ~5% of width, clamp
  pts=$(( img_width / 20 ))
  if [ "$pts" -lt 18 ]; then pts=18; fi
  if [ "$pts" -gt 120 ]; then pts=120; fi

  # create watermark canvas with rotated text
  magick -size ${img_width}x${pts} xc:none -gravity center \
    -font Arial -pointsize ${pts} -fill "rgba(255,255,255,0.55)" -annotate -30 "$WATERMARK_TEXT" \
    "$tmp_wm"

  # Composite watermark onto image at bottom-right with small offset
  magick "$out_webp" "$tmp_wm" -gravity southeast -geometry +40+40 -compose over -composite "$out_webp_wm"

  # Clean up
  rm -f "$tmp_wm"
}

export -f process_file

# Find image files in the two folders (if they exist)
for dir in "Finished Drawings" "Ceremony"; do
  if [ -d "$dir" ]; then
    # Use find to list common image extensions
    find "$dir" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) -print0 | while IFS= read -r -d '' file; do
      process_file "$file"
    done
  else
    echo "Directory not found: $dir (skipping)"
  fi
done

# Stage optimized images so the workflow can commit them
# (The workflow step that runs this script will handle committing afterwards.)

echo "Done processing images. Optimized images are in optimized-images/"
