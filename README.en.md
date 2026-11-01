# gpfind

[한국어](README.md) | **English**

A tiny CLI that finds photos and videos in Google Photos **by capture date and file name**, and optionally downloads just the originals.

I wanted to check whether my camera originals (`DSC01621.ARW`, `DJI_2025...`) had made it into Google Photos, and scrolling the web UI to find them was way too tedious.
It runs on top of [google-photos-sync](https://github.com/trialuser/google-photos-sync), an unofficial web API client.

> [!WARNING]
> This is not the official API. It replays the internal requests the Google Photos web app makes, so it can break whenever Google changes the site.

## Requirements

- macOS (zsh)
- Python 3.11+ (`brew install python@3.12`)
- git

## Install

```bash
git clone https://github.com/devuterian/gpfind.git
cd gpfind
./install.sh
gpfind login        # sign in in the Chromium window; saved automatically once your photos load
```

What `install.sh` does:

- Clones google-photos-sync into `~/.local/share/google-photos-sync`, pinned to a tested commit (`44c31fe`) so upstream changes can't break it.
- Creates a venv there and installs Playwright Chromium.
- Links `~/.local/bin/gpfind`, and tells you if `~/.local/bin` isn't on your `PATH`.

Your login (cookies and browser profile) is stored only in `~/.local/share/google-photos-sync/gpsync-data`, never in the repo.

## Usage

```bash
gpfind whoami [--account N]
gpfind search --from 2019-07-29 --to 2019-07-31 --name DSC01621 DJI_2025
gpfind search --from 2025-07-10 --name DJI_20250710051936 --download ~/Downloads/gphotos
gpfind logout
```

Each match is printed as `capture time ⇥ size (bytes) ⇥ file name`. Status messages are in Korean.

```text
계정: you@gmail.com
기간 안 항목 104개, 조건에 맞는 것 2개
2025-07-10 05:05:39	5992448	DJI_20250710050539_0001_D_A01.JPG
2025-07-10 05:05:39	19376400	DJI_20250710050539_0001_D_A01.DNG
```

(`계정` = account, the second line = items in range / matches.)

- Dates are capture days **in your Mac's time zone**. `--to` is inclusive; without it, only the `--from` day is searched.
- `--name` matches the start of the file name, case-insensitive. You can pass several; leave it out to list everything in the range.
- `--account N` is the N in `photos.google.com/u/N`.
- Files saved with `--download` get their modification time set to the capture time.
- It never deletes or edits anything in Google Photos. Read and download only.

## License

MIT. google-photos-sync is under its own license (MIT).
