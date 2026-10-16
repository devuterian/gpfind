# gpfind

Google 포토에서 **촬영 날짜와 파일 이름으로** 사진·영상을 콕 집어 찾고, 원하면 원본만 받는 작은 명령.
[google-photos-sync](https://github.com/trialuser/google-photos-sync)(비공식 웹 API 클라이언트) 위에서 돈다.

## 설치

```bash
./install.sh
gpfind login        # Chromium 창에서 로그인, 사진 목록이 뜨면 자동 저장
```

로그인 정보는 `/Users/marie/.local/share/google-photos-sync/gpsync-data`에만 저장된다(레포에 없음).

## 사용

```bash
gpfind whoami [--account N]
gpfind search --from 2019-07-29 --to 2019-07-31 --name DSC01621 DJI_2025
gpfind search --from 2025-07-10 --name DJI_20250710051936 --download ~/Downloads/gphotos
gpfind logout
```

- 날짜는 한국 시간 촬영일 기준, `--to`는 그날 포함. `--to`가 없으면 하루만.
- `--name`은 파일 이름 앞부분(대소문자 무시). 빼면 그 기간 전체 목록.
- `--account N`은 `photos.google.com/u/N`의 N.
- Google 포토에서 지우거나 바꾸는 기능은 없다.
