#!/bin/zsh
# google-photos-sync를 설치하고 gpfind를 ~/.local/bin에 연결한다.
set -e
GPSYNC_REPO=https://github.com/trialuser/google-photos-sync.git
GPSYNC_COMMIT=44c31fe   # 이 커밋에서 확인함. 업스트림이 바뀌어도 안 깨지게 고정
D="$HOME/.local/share/google-photos-sync"
BIN="$HOME/.local/bin"

PY=""
for c in python3.13 python3.12 python3.11 python3; do
  if command -v $c >/dev/null && $c -c 'import sys; sys.exit(sys.version_info < (3, 11))'; then PY=$c; break; fi
done
[ -n "$PY" ] || { echo "Python 3.11 이상이 필요합니다. brew install python@3.12 로 설치한 뒤 다시 실행하세요."; exit 1; }

[ -d "$D" ] || git clone "$GPSYNC_REPO" "$D"
git -C "$D" fetch -q origin
git -C "$D" -c advice.detachedHead=false checkout -q "$GPSYNC_COMMIT"
[ -d "$D/.venv" ] || $PY -m venv "$D/.venv"
"$D/.venv/bin/pip" install -q -e "$D"
"$D/.venv/bin/playwright" install chromium
mkdir -p "$D/gpsync-data" "$BIN" && chmod 700 "$D/gpsync-data"
ln -sf "${0:A:h}/gpfind" "$BIN/gpfind"
echo "설치 완료. gpfind login 으로 로그인하세요."
case ":$PATH:" in *":$BIN:"*) ;; *) echo "참고: $BIN 이 PATH에 없습니다. ~/.zshrc 에 export PATH=\"\$HOME/.local/bin:\$PATH\" 를 추가하세요.";; esac
