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
gpfind verify ~/Pictures/2025-07-10          # is every file in this folder in Google Photos?
gpfind albums                                 # list albums
gpfind albums --items "Trip 2025"             # list what is in an album
gpfind share --album "Trip 2025"              # make a share link
gpfind unshare --album "Trip 2025" --yes      # turn the share link off
gpfind album-delete --album "Trip 2025" --yes # delete the album (photos stay)
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
- `--download` skips a file that already exists with the same name and size (except when several results share a name), and stops before downloading if there is not enough free space.
- If the range holds too many items to scan to the end, it warns and exits with code 1.

### Checking originals (`verify`)

For every file in the folder (recursive, hidden files skipped) it prints `있음` (present) or `없음` (missing) `⇥ size ⇥ path`. It sends each file's SHA-1 to the request the Google Photos web app uses to ask "is this already uploaded?", so a renamed file with the same content still counts as present. Read-only.

- The exit code is 1 if anything is missing and 2 if a file could not be read (`오류`), handy before moving or deleting files in a script.
- Hidden files (starting with `.`) and symlinked subfolders are not checked, so `없음 0개` does not cover them.
- Not tested: whether items in the trash also count as present.
- Items uploaded in "Storage saver" quality, or edited copies, have different content and show as missing.
- It reads every file to hash it, so a big folder takes as long as your disk needs to read it.

### Albums (`albums`, `share`, `unshare`, `album-delete`)

- `--album` must match the title **exactly**. If only similar titles exist it lists them and stops. If several albums share the title it lists their album keys; pass the key instead of the title.
- `albums` prints `title ⇥ item count ⇥ share link (or -) ⇥ album key`.
- `share` creates a link (`photos.app.goo.gl/…`). Anyone with the link can see the album. If the album already has a link it prints that one and leaves its collaboration and location settings alone.
  - The web app turns on **collaboration** (people with the link can add photos) and **photo location sharing** when it creates a link. `gpfind share` creates it with both off. Use `--collab` and `--location` to turn them on. Comments are on, as on the web.
- `unshare` turns link sharing off (the web's "Make private"). The old link stops working; sharing again makes a new link.
- `album-delete` deletes only the album. Its photos and videos stay in your library. Afterwards it checks that the album is gone and that nothing went to the trash.
- Without `--yes`, `unshare` and `album-delete` only show what would change. They refuse shared albums someone else created (ones you only joined).
- Requests that change Google Photos are never retried. If Google rejects one, the error code is shown and it stops.
- There is no way to delete photos or videos themselves.

> [!CAUTION]
> Changing Google Photos through unofficial internal requests may count as automation under Google's terms. Use the album-changing commands only when you need them.

## License

MIT. google-photos-sync is under its own license (MIT).
