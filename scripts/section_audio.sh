#!/usr/bin/env bash
# Pre-download only part of a long / just-ended Twitch VOD's audio into the stream-clips
# cache, so `streamclips clip URL --section 0:00:00-3:00:00` doesn't fetch 20+ hours of audio
# (and doesn't record only the live edge while the stream is still live).
#
# Usage: scripts/section_audio.sh <twitch-vod-url> <end-seconds>
#   e.g. scripts/section_audio.sh https://www.twitch.tv/videos/2932204601 10800
# Then run the normal clip command with --section 0:00:00-<end>.
set -euo pipefail
URL="$1"; END="${2:-10800}"
PY="$HOME/.streamclips/venv/Scripts/python.exe"; [ -x "$PY" ] || PY="$HOME/.streamclips/venv/bin/python"
YTDLP="$(dirname "$PY")/yt-dlp"; [ -x "$YTDLP" ] || YTDLP="$YTDLP.exe"
DATA="${STREAMCLIPS_HOME:-$HOME/StreamClips}"

# Same cache-folder name streamclips uses (sc/pipeline.py work_dir)
WORK="$("$PY" - "$URL" "$DATA" <<'EOF'
import hashlib, re, sys
url, data = sys.argv[1].strip(), sys.argv[2]
key = hashlib.sha1(url.encode()).hexdigest()[:10]
t = re.sub(r"[^\w\s-]", "", url.split("://")[-1].lower())
t = re.sub(r"[\s_-]+", "-", t).strip("-").encode("ascii", "ignore").decode()[:40].strip("-") or "clip"
print(f"{data}/.cache/{t}_{key}")
EOF
)"
mkdir -p "$WORK"
rm -rf "$WORK"/audio.* "$WORK/blocks" "$WORK/picks" "$WORK/meta.json"
"$YTDLP" --no-warnings -f Audio_Only -N 4 --download-sections "*0-$END" -o "$WORK/audio.%(ext)s" "$URL"
echo "audio ready in $WORK"
