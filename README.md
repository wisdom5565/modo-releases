# MODO

개인 업무일지·공수 관리 앱 (Mac, Windows)

- **하루 일지**: 한 일을 구분(작업, 문의 및 대응, 업무관리)별로 적고, 일지 모양 그대로 복사
- **기록 모으기**: Claude Code·Codex·Gemini CLI 대화와 git 커밋, ChatGPT 답에서 한 일을 모아 확인한 뒤 추가
- **공수 관리**: 프로젝트 > 요건별 계획 공수와 작업로그 시간, 실적·남은 시간
- **기록 달력·주간보고**: 날짜별 기록과 그달 h·MD·MM 합계, 주간보고 초안
- **내 PC에만 저장**: 서버·로그인 없음. 자동 백업, 집·회사 PC는 동기화 폴더로 맞춤

## 설치

**터미널 명령 한 줄** (가장 쉬움, 설치 경고 없음)

- Mac (터미널)
  ```sh
  curl -fsSL https://raw.githubusercontent.com/wisdom5565/modo-releases/main/install.sh | bash
  ```
- Windows (PowerShell)
  ```powershell
  irm https://raw.githubusercontent.com/wisdom5565/modo-releases/main/install.ps1 | iex
  ```

최신 버전을 받아, 릴리스에 올린 sha256과 맞는지 확인한 뒤 설치합니다.

**직접 받기**: [릴리스 페이지](https://github.com/wisdom5565/modo-releases/releases/latest)에서 받습니다.

- Mac: 위의 설치 명령을 권장합니다. dmg로 설치하면(Apple 칩은 `MODO-x.y.z-arm64.dmg`, Intel은 `MODO-x.y.z.dmg`) "MODO는 손상되었기 때문에 열 수 없습니다"가 뜹니다. MODO를 응용 프로그램으로 옮긴 뒤 터미널에서 `xattr -dr com.apple.quarantine /Applications/MODO.app`을 한 번 실행하면 열립니다. ('열도록 허용'으로는 열리지 않습니다)
- Windows: `MODO-Setup-x.y.z.exe`를 실행하고, "Windows의 PC 보호" 창이 뜨면 **추가 정보 → 실행**.

## 업데이트

- 새 버전이 나오면 앱 오늘 화면에 알림이 뜹니다. 설정 > 앱 정보 > **업데이트 확인**으로 직접 볼 수도 있습니다.
- Windows는 뒤에서 받아 두었다가 앱을 끌 때 설치합니다. Mac은 **받아서 열기**로 설치 파일을 열어 줍니다.
- 위의 터미널 명령을 다시 실행해도 최신 버전으로 바뀝니다. 기록은 그대로 남습니다.
