# Setup & workflow

## 1. Install

Requirements: Python 3.9+, ffmpeg/ffprobe, Node.js or Deno (YouTube needs a JS runtime), ~1 GB disk.

```powershell
winget install Gyan.FFmpeg
winget install Python.Python.3.12
winget install DenoLand.Deno        # skip if Node.js is installed
powershell -ExecutionPolicy Bypass -File scripts\install_skill.ps1
```

The installer copies `skills/stream-clips` to `%USERPROFILE%\.claude\skills\stream-clips` and runs
`streamclips.py setup`, which builds a private venv in `~/.streamclips`, installs faster-whisper,
OpenCV, Pillow and yt-dlp, and downloads the Whisper `tiny` + `base` models and a face model.
It ends with **READY**. Check the install any time:

```powershell
python "$env:USERPROFILE\.claude\skills\stream-clips\scripts\streamclips.py" doctor
```

Output goes to `%USERPROFILE%\StreamClips\<date>\<topic>\<creator>__<title>\`.

## 2. Find a stream

```bash
S=~/.claude/skills/stream-clips/scripts/streamclips.py
python $S find --topic "GTA 6" --keywords "gta 6,gta vi,gta6"
# A specific creator's Twitch VODs:
~/.streamclips/venv/Scripts/yt-dlp.exe --flat-playlist --playlist-end 6 \
  --print "%(title)s | %(duration)s | %(url)s" "https://www.twitch.tv/<login>/videos?filter=archives&sort=time"
```

## 3. Clip it

```bash
URL=https://www.twitch.tv/videos/<id>
# Long or still-live Twitch VOD: grab only the first 3 h of audio first (see "Problems" below)
bash scripts/section_audio.sh "$URL" 10800

python $S clip "$URL" --topic "GTA 6" --clips 6 --brain agent --language en \
  --section "0:00:00-3:00:00" --focus "<streamer>'s funniest and most hype reactions"
```

Without the `claude` CLI on PATH (e.g. the Claude desktop app), use `--brain agent`. The command
stops with exit code 3 and lists `picks/part_XXXXXX.prompt.txt` files. The agent reads each one,
writes a JSON array to the matching `.answer.json` (`[]` if nothing's good), then **re-runs the
same command** to render the clips.

Picking rules used for campaigns:
- Skip anything with slurs, sexual content or strip-club bits, and anything that makes the
  streamer look bad (campaigns reject "negative light"; TikTok limits reach).
- Skip moments where another brand's footage/logo is on screen (e.g. a movie trailer).
- Title bar and caption must name the streamer; hashtags must include the campaign tag.

## 4. Check every clip

Look at `checks/*.jpg` (3 frames per clip). Re-render if the framing is wrong:

| Symptom | Fix |
|---|---|
| Streamer shows up twice (full-cam "just chatting" segment rendered as stack) | follow-the-face crop: put `{"big_face": 0.04}` in `~/StreamClips/settings.json`, re-run with `--layout crop`, then delete settings.json |
| Tiny floating-head cam, clip came out as `blur` | force the cam box: `--cam x,y,w,h` (fractions of the 16:9 frame, e.g. bottom-left `0.03,0.55,0.33,0.45`) |
| Clip is fine but one bad clip in the set | edit `picks/chosen_<lo>_<hi>.json` in the cache dir to only the clips to redo, re-run, then restore it |

To re-render only some clips: back up `chosen_*.json`, keep just those picks, re-run the command,
rename the output file to its original number, then restore the backup.

## 5. Upload

- Use the caption kits in `campaigns/`.
- For upload tools with a 10 MB limit: `bash scripts/compress_for_upload.sh ~/StreamClips/<date>/gta-6 ./upload`
- One clip per platform. Never post the same clip twice on one platform (counts as a repost).
- Make sure the right file gets the right title. After posting, check each post's video matches
  its title. If it doesn't, **edit** the title/caption; don't delete and re-upload.
- Submit each link in Whop Content Rewards within 30 minutes of posting.

## Problems hit and how they were solved

- **Twitch VOD still live → only 15 min of audio.** stream-clips records the live edge for Twitch.
  Wait for the stream to end (`live_status` = `was_live`) or run `scripts/section_audio.sh`, which
  downloads `--download-sections "*0-<end>"` of the `Audio_Only` format straight into the cache
  folder. The format id is `Audio_Only` (case-sensitive).
- **28-hour marathon VOD.** Don't download all of it: section audio (~70 MB/hour) + `--section`.
- **Slow CPU.** Whisper `tiny` ran ~4–7 min per 10-min block on a laptop; two streams in parallel
  share the CPU. Budget ~1–2 h for 3 h of stream.
- **Windows console UnicodeEncodeError** when printing emoji titles from Python: write files with
  `encoding="utf-8"` and don't print them, or set `PYTHONIOENCODING=utf-8`.
