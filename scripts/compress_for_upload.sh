#!/usr/bin/env bash
# Re-encode finished clips to 720x1280 and under ~9.3 MB each (for browser upload tools
# with a 10 MB limit). Originals are left untouched.
#
# Usage: scripts/compress_for_upload.sh <clips-folder> <output-folder>
#   e.g. scripts/compress_for_upload.sh ~/StreamClips/2026-11-19/gta-6 ./upload
set -euo pipefail
SRC="$1"; OUT="$2"; mkdir -p "$OUT"
find "$SRC" -name "*.mp4" -not -path "*/_rejected/*" | while read -r f; do
  d=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$f")
  vb=$(awk -v d="$d" 'BEGIN{printf "%d", (9.3*8192/d)-130}')
  n=$(basename "$f")
  ffmpeg -y -v error -i "$f" -vf "scale=720:1280:flags=lanczos" -c:v libx264 -preset slow \
    -b:v "${vb}k" -maxrate "${vb}k" -bufsize "$((vb*2))k" -pix_fmt yuv420p \
    -c:a aac -b:a 128k -movflags +faststart "$OUT/$n"
  echo "$(du -k "$OUT/$n" | cut -f1) KB  $n"
done
