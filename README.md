# gpfind

**한국어** | [English](README.en.md)

Google 포토에서 **촬영 날짜와 파일 이름으로** 사진·영상을 콕 집어 찾고, 원하면 원본만 받는 작은 명령.

카메라 원본(`DSC01621.ARW`, `DJI_2025...`)이 Google 포토에 올라가 있는지 확인하고 싶은데, 웹에서 스크롤하면서 찾기는 너무 귀찮아서 만들었다.
[google-photos-sync](https://github.com/trialuser/google-photos-sync)(비공식 웹 API 클라이언트) 위에서 돈다.

> [!WARNING]
> 공식 API가 아니라 Google 포토 웹이 쓰는 내부 요청을 그대로 쓴다. Google이 웹을 바꾸면 언제든 깨질 수 있다.

## 필요한 것

- macOS (zsh)
- Python 3.11 이상 (`brew install python@3.12`)
- git

## 설치

```bash
git clone https://github.com/devuterian/gpfind.git
cd gpfind
./install.sh
gpfind login        # Chromium 창에서 로그인, 사진 목록이 뜨면 자동 저장
```

`install.sh`가 하는 일:

- google-photos-sync를 `~/.local/share/google-photos-sync`에 받는다. 확인된 커밋(`44c31fe`)으로 고정해서, 업스트림이 바뀌어도 안 깨진다.
- 그 안에 venv를 만들고 Playwright Chromium을 설치한다.
- `~/.local/bin/gpfind`에 링크를 건다. `~/.local/bin`이 `PATH`에 없으면 알려준다.

로그인 정보(쿠키, 브라우저 프로필)는 `~/.local/share/google-photos-sync/gpsync-data`에만 저장된다. 레포에는 안 들어간다.

## 사용

```bash
gpfind whoami [--account N]
gpfind search --from 2019-07-29 --to 2019-07-31 --name DSC01621 DJI_2025
gpfind search --from 2025-07-10 --name DJI_20250710051936 --download ~/Downloads/gphotos
gpfind logout
```

출력은 `촬영 시각 ⇥ 용량(바이트) ⇥ 파일 이름` 한 줄씩이다.

```text
계정: you@gmail.com
기간 안 항목 104개, 조건에 맞는 것 2개
2025-07-10 05:05:39	5992448	DJI_20250710050539_0001_D_A01.JPG
2025-07-10 05:05:39	19376400	DJI_20250710050539_0001_D_A01.DNG
```

- 날짜는 **이 맥의 시간대 기준** 촬영일이고, `--to`는 그날까지 포함한다. `--to`가 없으면 하루만 본다.
- `--name`은 파일 이름 앞부분(대소문자 무시). 여러 개 줄 수 있고, 빼면 그 기간 전체 목록이 나온다.
- `--account N`은 `photos.google.com/u/N`의 N.
- `--download`로 받은 파일은 수정 시각이 촬영 시각으로 맞춰진다.
- Google 포토에서 지우거나 바꾸는 기능은 없다. 읽기와 받기만 한다.

## 라이선스

MIT. google-photos-sync는 자체 라이선스(MIT)를 따른다.
