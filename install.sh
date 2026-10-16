#!/bin/zsh
# google-photos-sync를 설치하고 gpfind를 ~/.local/bin에 연결한다.
set -e
D=/Users/marie/.local/share/google-photos-sync
[ -d $D ] || git clone https://github.com/trialuser/google-photos-sync.git $D
cd $D
[ -d .venv ] || python3.12 -m venv .venv
.venv/bin/pip install -q -e .
.venv/bin/playwright install chromium
mkdir -p gpsync-data && chmod 700 gpsync-data
ln -sf "${0:A:h}/gpfind" /Users/marie/.local/bin/gpfind
echo "설치 완료. gpfind login 으로 로그인하세요."
