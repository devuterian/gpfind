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
gpfind verify ~/Pictures/2025-07-10        # 폴더 안 파일이 Google 포토에 있는지
gpfind albums                               # 앨범 목록
gpfind albums --items "여행 2025"            # 앨범 안 항목
gpfind share --album "여행 2025"             # 공유 링크 만들기
gpfind unshare --album "여행 2025" --yes     # 공유 링크 끄기
gpfind album-delete --album "여행 2025" --yes  # 앨범 삭제 (사진은 남음)
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
- `--download`는 같은 이름, 같은 용량의 파일이 이미 있으면 건너뛴다(결과 안에 이름이 겹치는 항목은 빼고). 받기 전에 남은 공간이 모자라면 멈춘다.
- 기간 안 항목이 너무 많아 끝까지 못 보면 경고를 띄우고 종료 코드 1로 끝난다.

### 원본 대조 (`verify`)

폴더(하위 폴더 포함, 숨김 파일 제외) 안 파일마다 `있음` 또는 `없음 ⇥ 용량 ⇥ 경로`를 한 줄씩 찍는다. 파일 내용의 SHA-1을 Google 포토 웹이 업로드 전에 "이미 있나?"를 물을 때 쓰는 요청에 보내서 대조하니까, 이름이 바뀌어도 내용이 같으면 `있음`이다. 읽기만 한다.

- `없음`이 하나라도 있으면 종료 코드가 1, 못 읽은 파일(`오류`)이 있으면 2다. 옮기거나 지우기 전에 스크립트에서 확인하기 좋다.
- 숨김 파일(`.`으로 시작)과 링크로 걸린 하위 폴더는 보지 않는다. 그런 게 있는 폴더는 `없음 0개`여도 전부 확인한 게 아니다.
- 휴지통에 있는 항목도 `있음`으로 나오는지는 확인 못 했다.
- `저장용량 절약` 화질로 올렸거나 편집본만 있으면 원본과 내용이 달라서 `없음`으로 나온다.
- 파일을 전부 읽어서 해시를 내니까 큰 폴더는 디스크 읽기 속도만큼 걸린다.

### 앨범 (`albums`, `share`, `unshare`, `album-delete`)

- `--album`은 제목이 **정확히** 같아야 한다. 비슷한 제목만 있으면 후보를 보여주고 멈춘다. 같은 제목이 여러 개면 앨범 키 목록을 보여주니, 제목 대신 키를 넣는다.
- `albums`는 `제목 ⇥ 개수 ⇥ 공유 링크(없으면 -) ⇥ 앨범 키`를 찍는다.
- `share`는 링크(`photos.app.goo.gl/…`)를 만든다. 링크가 있으면 누구나 그 앨범을 볼 수 있다. 이미 링크가 있으면 새로 만들지 않고 그 링크를 보여준다. 이때 공동작업·촬영 장소 설정은 건드리지 않는다.
  - 웹에서 링크를 만들면 **공동작업(링크로 들어온 사람이 사진 추가)**과 **사진 촬영 장소 공유**가 켜진다. `gpfind share`는 둘 다 끈 채로 만든다. 켜려면 `--collab`, `--location`. 댓글은 웹처럼 켜진다.
- `unshare`는 링크 공유를 끈다(웹의 "비공개로 설정"). 예전 링크는 더 이상 안 열리고, 다시 `share`하면 새 링크가 생긴다.
- `album-delete`는 앨범만 지운다. 안에 있던 사진·동영상은 라이브러리에 남는다. 지운 뒤 앨범이 목록에서 사라졌는지, 사진이 휴지통에 가지 않았는지 확인한다.
- `unshare`와 `album-delete`는 `--yes`가 없으면 무엇이 바뀌는지만 보여주고 끝난다. 다른 사람이 만든 공유 앨범(내가 참여만 한 것)은 바꾸지 않는다.
- Google 포토를 바꾸는 요청은 실패해도 다시 보내지 않는다. Google이 거절하면 오류 코드를 보여주고 멈춘다.
- 사진·동영상 자체를 지우는 기능은 없다.

> [!CAUTION]
> 비공식 내부 요청으로 Google 포토를 바꾸는 건 Google 약관상 자동화로 볼 수 있다. 앨범을 바꾸는 명령은 필요할 때만 쓰자.

## 라이선스

MIT. google-photos-sync는 자체 라이선스(MIT)를 따른다.
