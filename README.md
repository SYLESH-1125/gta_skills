# gta_skills

Tools and notes for clipping GTA 6 streams into vertical Shorts/Reels/TikToks for
creator clipping campaigns (Reach / Whop Content Rewards).

| Path | What it is |
|---|---|
| `skills/stream-clips/` | The **stream-clips** agent skill: finds streams, transcribes them locally with Whisper, picks viral moments, renders 9:16 clips with facecam, title bar and word-by-word captions |
| `scripts/install_skill.ps1` | Windows installer: copies the skill into `~/.claude/skills` and runs its setup |
| `scripts/section_audio.sh` | Pre-downloads only the first N seconds of a long Twitch VOD's audio (fixes live / 20h+ VODs) |
| `scripts/compress_for_upload.sh` | Re-encodes finished clips to 720p and under 10 MB for browser upload tools |
| `SETUP.md` | Full setup and the exact workflow, including fixes for the problems hit along the way |
| `campaigns/` | Campaign rules, caption/title options and the upload checklist |

Quick start (Windows, PowerShell):

```powershell
winget install Gyan.FFmpeg
winget install Python.Python.3.12
powershell -ExecutionPolicy Bypass -File scripts\install_skill.ps1
```

Then in Claude Code: *"Find today's biggest GTA 6 streams and make 3 clips from each."*

See [SETUP.md](SETUP.md) for details.
