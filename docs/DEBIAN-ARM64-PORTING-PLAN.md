# SekaiPop Debian ARM64 포팅 계획서

- 작성일: 2026-10-21 (Asia/Seoul)
- 분석 기준: 로컬 커밋 `e3bad50d5459bd27358b2d97aebdf6549cce84d0`, `sekaipop/VERSION` = `1.0.0`
- 단계: 분석 및 구현 계획. 이 문서 외 프로그램·설치 스크립트 변경 없음.
- 검증 범위: 로컬 정적 분석과 공식 웹 자료 확인. 현재 작업 호스트는 macOS이며 Debian 설치, ARM64 실행, GPU·PAM 동작은 아직 검증하지 않았습니다.

## 1. 결론과 지원 목표

**Debian 13 (trixie) ARM64 + 필요한 공식 trixie-backports 패키지를 기준으로 포팅하는 방안을 권장합니다.** 중심 작업은 QML 화면 재작성보다 패키지 관리, 버전 검사, 셰이더, 세션 통합, 업데이트 경로의 이식입니다. 공식 ARM64 패키지가 존재하므로 Hyprland와 Quickshell 전체를 처음부터 소스 빌드하는 방식은 기본 경로로 삼지 않습니다.

| 구성요소 | 조사에서 확인한 버전·제공 상태 | 판단 |
| --- | --- | --- |
| Hyprland | backports `0.55.2+ds-1~bpo13+1`, arm64 제공 [S2] | 저장소가 요구하는 0.55+ Lua 구성의 최소 버전 조건 충족. 실제 Lua API와 IPC는 별도 실행 검증 |
| Quickshell | backports `0.3.0-1~bpo13+1`, arm64 제공 [S3] | 첫 검증 후보. 모든 SekaiPop QML 타입·속성 지원을 보장하지는 않음 |
| Qt | trixie Qt Core `6.8.2+dfsg-9+deb13u2`, arm64 제공 [S4] | 저장소의 Qt 6.7+ 조건 충족. 동봉 셰이더는 별도 처리 |
| qsb | trixie `qt6-shader-baker` 6.8.2-3, arm64 제공 [S5] | 대상 Qt로 셰이더 재생성 |
| Hyprsunset | backports `0.4.0-1~bpo13+1`, arm64 제공 [S6] | 야간 조명 후보, 프로토콜·명령 호환성 검증 |

위 버전은 조회 시점의 후보이며 릴리스 인증 목록이 아닙니다. 설치 직전에 대상 장치의 APT 후보 버전·아키텍처·의존성 해석을 다시 확인하고, 통과한 조합을 기록합니다. stable과 backports를 선택적으로 사용하고 testing/sid를 섞는 방식은 기본 계획에서 제외합니다. [S8]

사용자가 Debian 버전과 장치를 지정하지 않았으므로 Debian 13을 잠정 기준으로 잡았습니다. Debian 12, Debian 파생 배포판, ARM 32비트는 첫 인증 범위에서 제외합니다. Raspberry Pi, Apple Silicon, Qualcomm 등은 같은 ARM64라도 커널·GPU·절전 지원이 다르므로 한 장치의 성공을 모든 ARM64 장치의 성공으로 확대하지 않습니다.

완료 목표는 바·독·런처·위젯·테마·설정·알림·polkit·잠금·클립보드·오디오·네트워크·스크린샷·패키지 업데이트가 실제 Debian 세션에서 동작하는 데스크톱입니다. 하드웨어가 제공하지 않는 배터리·백라이트·Bluetooth는 지원 불가 사유를 표시하고 셸은 정상 동작해야 합니다. 영상 배경·음악 인식·Discord 연동·WARP·외부 Hyprland 플러그인은 선택 기능으로 명시적으로 관리합니다.

## 2. 프로젝트 구조와 재사용 가능성

원본 README는 작성자가 시각적 설계와 동작을 지시하고 Claude가 코드 대부분을 작성했다고 명시합니다. [S1] 이를 품질 결론으로 사용하지 않고 실제 구현과 테스트를 근거로 판단합니다.

| 계층 | 파일·디렉터리 | 역할 및 포팅 영향 |
| --- | --- | --- |
| 진입점 | `sekaipop/shell.qml` | Quickshell ShellRoot, 배경·화면·서비스 통합 |
| UI | `sekaipop/modules/` | Qt Quick 기반 화면. 원래 디자인과 동작을 유지 |
| 시스템 연결 | `sekaipop/services/`, `sekaipop/scripts/` | D-Bus, 외부 명령, 설정·캐시, 오디오 분석 |
| 컴포지터 | `hypr/hyprland.lua`, `hypr/hyprland/`, `hypr/custom/` | Lua 구성, 자동 시작, 키 바인딩, 사용자 오버라이드 |
| 설치 | `get.sh`, `install.sh`, `install-deps.sh`, `check-deps.sh` | 다운로드 → 의존성 → 구성 복사·백업 → 검사 |
| 렌더링 | `sekaipop/shaders/` | GLSL 소스와 Qt Shader Bundle |
| 회귀 검사 | `sekaipop/tests/` | JS·Shell·Python 검사와 실행 중 성능 도구 |

추적 파일 기준 QML 363개, JS 137개, Shell 76개, Python 10개, Lua 16개, QSB 36개입니다. 주요 UI가 선언형 코드이고 Python 분석기는 NumPy를 사용하므로 자체 CPU 명령어 변환보다는 네이티브 의존성 및 GPU 호환성이 우선입니다. 이는 모든 파일의 아키텍처 중립성을 증명한 결과는 아닙니다.

재사용할 요소도 있습니다. `check-deps.sh`는 이미 `/usr/lib/aarch64-linux-gnu/qt6/` 경로를 탐색하고, 셰이더 컴파일러는 Debian의 `/usr/lib/qt6/bin/qsb` 경로를 포함합니다. [S5] 여러 이미지 스크립트는 `magick`/`convert` 대체 경로가 있으며, `PowerBusyService.qml`은 이미 apt/dpkg 실행을 감지합니다.

## 3. 확인된 장애물과 변경 지점

| 우선순위 | 근거 | 현재 동작 / 문제 | 계획 |
| --- | --- | --- | --- |
| P0 | `install-deps.sh` 전제 검사와 패키지 배열 | pacman 없으면 종료. AUR helper와 Arch 패키지명에 종속 | 공통 설치 흐름과 Arch/Debian 패키지 백엔드 분리 |
| P0 | `install.sh:228`, `scripts/system/update-check.sh:109` | Qt를 pacman으로 조회하므로 Debian에서 값이 비어 셰이더 재빌드 조건을 건너뜀 | 실제 실행 Qt와 qsb 확인을 설치·업데이트 공통 로직으로 통합 |
| P0 | `shaders/compile-shaders.sh`, `shaders/visualizer/` | 최상위 소스만 재빌드. 시각화 QSB 8개에는 대응 GLSL이 없음 | 전체 QSB 호환성 검사 및 원본 확보·대체 구현 |
| P0 | `hypr/hyprland.lua`, `scripts/hyprland/displays.sh` | Lua 구성뿐 아니라 화면 설정도 `hyprctl eval`과 `hl.monitor` 사용 | 0.55.2 실제 API 확인. 구형 Hyprland용 conf 변환만으로 해결하려 하지 않음 |
| P0 | `modules/sekai/lock/LockContext.qml:24`, `hypr/hypridle.conf` | PAM `login` 사용. 셸 실패 시 hyprlock 대체 경로는 설치되어 있어야 유효 | Debian PAM 정책, 잠금 확인 후 절전, 장애 시 복구 경로 검증 |
| P1 | `scripts/system/pkg-updates.sh`, `services/PackageUpdatesService.qml` | 조회는 checkupdates/AUR, 실행 버튼은 paru/yay/pacman | APT 조회·실행 경로를 함께 추가 |
| P1 | `modules/sekai/settings/SettingsPageBar.qml` | AUR 옵션 노출 | 배포판별 설정·오류 안내 표시 |
| P1 | `hypr/hyprland/env.lua`, `install-deps.sh` | 기본 Qt 테마는 kde인데 설치기는 비 KDE에서 qt6ct 선택 | 설치된 테마 통합과 세션 환경변수를 일치시킴 |
| P1 | `install.sh`, `scripts/system/update-check.sh`의 `.source` 처리 | 포팅 후 원본 main을 추적하면 수정이 사라질 수 있음 | 포팅 저장소·브랜치·태그 출처 보존과 업데이트 실패 복구 |
| P1 | `check-deps.sh` | Arch 설치 안내, 모듈 디렉터리 존재 중심 검사 | Debian 패키지 안내, 실제 QML 로드 검사, CLI 별칭 처리 |
| P1 | `install-deps.sh` GPU 자동 탐지 | PCI AMD/Intel/NVIDIA 중심 | ARM GPU를 잘못 분류하지 않고 기존 드라이버 유지·기능 검사 |
| P2 | `tests/perf-test/perf-baseline.sh` | GPU 측정은 AMD/NVIDIA 중심 | ARM에서 미지원 측정값은 N/A로 기록, 프레임 지연·CPU·메모리로 보완 |

P0는 셸 기동·화면·잠금의 차단 요소, P1은 일상 사용과 유지보수의 필수 요소, P2는 최적화·관측 항목입니다.

### 셰이더는 독립된 초기 검증 항목

QSB는 곧바로 x86 실행 바이너리로 취급할 대상이 아닙니다. Qt 직렬화 버전, 포함된 GLSL/SPIR-V 등 렌더링 타깃, 드라이버 지원을 나누어 확인해야 합니다. 원본의 Qt 6.12 빌드 설명은 저장소의 주장으로 기록하고 대상 qsb와 실제 렌더링으로 확인합니다.

최상위에는 28개 GLSL 소스와 대응 QSB가 있지만 시각화 하위의 `aurora`, `dots`, `mirror`, `pulse`, `ribbons`, `ring`, `scope`, `tide` 8개는 QSB만 있습니다. 하위 `build.sh`도 소스가 없으면 건너뛰므로 종료 코드 0만으로 재빌드 성공을 판단하면 안 됩니다.

원본 출처·라이선스·커밋을 추적해 GLSL을 확보하거나, 대상 Qt에서 동봉 QSB가 읽히고 표시되는지 검증합니다. 실패하면 동일 효과를 소스로 재구현하거나 호환 효과로 명시적으로 대체합니다. 기능을 조용히 제거하지 않습니다. 모든 효과의 입력 소스·생성물·컴파일러 버전·실행 결과를 목록으로 남깁니다.

## 4. 의존성 및 설치 설계

공통 기능 ID에 Arch와 Debian 패키지 매핑을 연결하고 설치기·검사기·UI 안내가 같은 목록을 사용하도록 합니다. `ID`, `VERSION_CODENAME`, dpkg 아키텍처를 우선 판별하고 `aarch64` 커널 이름과 Debian `arm64` 이름을 구분합니다. 지원하지 않는 조합은 설치 전에 중단합니다.

다음 표는 구현을 위한 **매핑 후보**입니다. 앞의 공식 버전 표 외 전체 패키지의 가용성과 조합은 아직 설치 검증하지 않았으며, M0에서 ARM64 APT 메타데이터와 설치 시뮬레이션으로 확정합니다.

| 기능 | Debian 패키지 후보 / 처리 |
| --- | --- |
| Qt QML | `qml6-module-qtquick`, `qml6-module-qtquick-controls`, `qml6-module-qtquick-layouts`, `qml6-module-qtquick-effects`, `qml6-module-qtquick-shapes`, `qml6-module-qtqml-models`, `qml6-module-qt-labs-folderlistmodel` |
| 미디어·이미지·Wayland | `qml6-module-qtmultimedia`, `qt6-multimedia-plugins`, `qt6-image-formats-plugins`, `qt6-svg-plugins`, `qt6-wayland` |
| 오디오 | `pipewire`, `pipewire-pulse`, `wireplumber`, `pulseaudio-utils`, `cava`, `easyeffects` |
| 네트워크·전원 | `network-manager`, `bluez`, `blueman`, `upower`, `power-profiles-daemon`, `brightnessctl`, `ddcutil` |
| 세션 | `dbus-user-session`, `polkitd`, `xdg-desktop-portal`, `xdg-desktop-portal-hyprland`, `xdg-desktop-portal-gtk`, `gnome-keyring`, `xwayland` |
| 캡처·입력 | `grim`, `slurp`, `swappy`, `wf-recorder`, `wl-clipboard`, `cliphist`, `wtype`, `tesseract-ocr`, `tesseract-ocr-eng`, `imagemagick`, `ffmpeg` |
| Python | `python3`, `python3-numpy`, 선택 `python3-aubio` |
| 공통 CLI | `bash`, `coreutils`, `procps`, `jq`, `curl`, `git`, `fontconfig`, `xdg-utils`, `xdg-user-dirs`, `libnotify-bin`, `playerctl` |
| 폰트 | Noto 계열 우선. Google Sans Flex·Material Symbols Rounded는 정확한 폰트와 라이선스·체크섬을 확보 |
| 추가 생태계 | matugen, hypridle, hyprpicker, mpvpaper, songrec, nwg-displays 등의 후보 버전·ARM64 제공 여부를 개별 확정 |

Quickshell 설치만으로 SekaiPop의 모든 import가 해결된다고 가정하지 않습니다. `QtQuick.Controls.impl`처럼 내부 API를 사용하는 코드와 Pam/Polkit/Pipewire/Hyprland 모듈을 실제 로드합니다. Quickshell은 Qt private ABI에 의존하므로 임의 Qt 교체를 피하고 소스 빌드가 필요한 경우 같은 Qt에 맞춰 ARM64 `.deb`로 재현 가능하게 빌드합니다. [S7]

설치기는 다음 동작을 보장해야 합니다.

1. stable 패키지와 backports 필요 패키지를 나누고 설치 전 변경 목록을 표시합니다. 시스템 전체 업그레이드는 기본 작업에 넣지 않습니다.
2. `--dry-run`은 다운로드·설치·서비스·홈 디렉터리 변경을 하지 않습니다. 기존 옵션의 의미와 Arch 경로를 유지합니다.
3. 필수 패키지·셰이더·QML 검증 실패 시 실제 구성 교체 전에 중단합니다. 선택 기능은 누락 사유를 별도로 보고합니다.
4. 기존 Hyprland 구성과 사용자 custom 파일, SekaiPop 설정을 보존하고 재실행해도 중복 autostart·서비스가 생기지 않도록 합니다.
5. 서비스는 존재와 상태를 확인해 활성화합니다. 기존 네트워크 관리자를 무조건 NetworkManager로 바꾸거나 DNS 설정을 덮어쓰지 않습니다.
6. GPU 드라이버·커널은 자동 교체하지 않습니다. logind 장치 접근, backlight, DDC/I²C는 해당 장치에서만 구성합니다.
7. 기존 `--restore`는 Hyprland 복구 중심입니다. 새로 추가한 파일·서비스 설정의 복구 범위를 기록하며 패키지·사용자 데이터까지 모두 복원한다고 안내하지 않습니다.

## 5. 업데이트와 기능 호환성

APT 조회는 비특권 상태에서 로컬 패키지 인덱스를 사용하고 마지막 갱신 시각·실패·보류 패키지를 구분합니다. 갱신되지 않은 인덱스를 최신이라고 표시하지 않습니다. 실제 업데이트는 사용자 동작으로 실행하며 바의 주기적 조회에서 sudo를 호출하지 않습니다. 기존 출력 계약을 확장해 backend와 상태를 제공하고 Debian에서는 AUR 옵션을 숨깁니다.

셸 자체 업데이트는 포팅 배포 출처를 유지하고 staging에서 QML·셰이더를 검증한 후 교체합니다. 다운로드 실패·컴파일 실패·호환되지 않는 버전에서 기존 셸과 설정이 유지되어야 합니다. Git 설치, 관리 복사본, 태그 설치, 심볼릭 링크 설치를 각각 검증합니다.

Bluetooth, 백라이트, 전원 프로필, DDC, 녹화 코덱은 실행 파일 존재와 실제 기능 가용성을 구분합니다. EasyEffects CLI·프리셋 형식과 QtMultimedia 영상 재생도 버전별 확인 대상입니다. Discord/Vencord는 사용 가능한 ARM64 클라이언트와 플러그인 경로를 먼저 확인하며, WARP는 기존 DNS를 변경하는 경로까지 별도 선택 기능으로 검증합니다. Hyprland 외부 플러그인은 컴포지터 ABI가 맞는 조합만 허용합니다.

## 6. 구현 마일스톤

| 단계 | 작업·산출물 | 종료 조건 | 예상 노력 |
| --- | --- | --- | --- |
| M0 기반 검증 | Debian 13 ARM64 VM, 패키지 manifest, GPU·장치 정보, 최소 QML/셰이더 로드 결과 | APT 의존성 해석, Quickshell import, Lua 설정, 셰이더 36개 검사 결과 확보 | 1–2 인일 |
| M1 설치·검사 | 배포판 백엔드, 패키지 매핑, 서비스·폰트 설정, dry-run·백업 | 새 VM 설치·재설치·복구 및 Arch 경로 회귀 통과 | 2–3 인일 |
| M2 렌더링·세션 | 공통 Qt/qsb 처리, 누락 셰이더 해결, 자동 시작·portal·테마·PAM 통합 | 바·배경·설정·잠금 기동, 모든 기본 효과 렌더링 | 2–4 인일 |
| M3 일상 기능·업데이트 | APT UI, 포팅 출처 보존, 오디오·네트워크·선택 기능 처리 | 업데이트와 실패 복구, 필수 기능 시나리오 통과 | 2–3 인일 |
| M4 ARM64 인증 | 실제 장치 반복 검사, 성능 프로필, 설치 안내·지원표·릴리스 증거 | 아래 수용 기준 충족, 미검증 영역 명시 | 2–4 인일 |

합계 약 9–16 인일은 초기 추정입니다. 시각화 소스 확보, Quickshell API 차이, 장치 드라이버 문제에 따라 늘어날 수 있습니다. M0에서 큰 불일치가 나오면 구현 범위와 추정을 다시 정합니다. 각 단계는 독립적으로 검토 가능한 변경 단위로 진행합니다.

## 7. 검증 계층과 완료 기준

| 검증 환경 | 확인할 내용 | 증명하지 못하는 내용 |
| --- | --- | --- |
| 정적 검사·단위 테스트 | 스크립트 문법, 패키지 분기, 업데이트 파싱, 설정 보존, 실패 복구 | 실제 Wayland·GPU·인증 |
| ARM64 컨테이너 | 패키지 의존성·설치 파일·CLI·기존 JS/Python/Shell 회귀 | 실제 logind/PAM 세션, 화면·절전 |
| ARM64 VM의 로그인 세션 | Hyprland/Quickshell 시작, UI, portal, 설치·업데이트 | 물리 GPU·배터리·DDC·실장치 suspend |
| 실제 대상 ARM64 장치 | GPU 렌더링·입력·오디오·다중 모니터·절전·성능 | 다른 SoC 전체의 호환성 |
| Arch 회귀 환경 | 기존 설치 및 런타임 경로 유지 | Debian 호환성 자체 |

기존 `tests/update-test`, `tests/lock-sleep-test`, `tests/lock-transition-test`, `tests/lock-wallpaper-test`, `tests/analyzer-test`, `tests/plugin-test`, `tests/migrate-test`, `tests/perf-test`를 재사용합니다. 기존 테스트가 파일 텍스트 검사인지 실제 실행 검사인지 구분하여 결과를 보고합니다.

릴리스 수용 기준은 다음과 같습니다.

- [ ] 깨끗한 Debian 13 ARM64에 설치·재설치 성공. dry-run 전후 대상 파일·서비스 상태 변화 없음.
- [ ] 런타임 필수 QML import 오류, 검은 배경, 셰이더 로드 실패 없음. 동봉 36개 QSB의 검증 결과 기록.
- [ ] 재로그인 후 셸·알림·polkit가 각각 의도대로 동작하고 중복 agent 없음.
- [ ] 잠금/해제 20회, 지원 장치에서 suspend/resume 10회 통과. 오암호 거부, 빈 암호 처리, 셸 장애·멀티모니터에서 잠금 유지 확인.
- [ ] 잠금 완료를 확인하지 못한 상태로 자동 절전하지 않음. fallback lock 사용 시 설치·인증·복귀 검증.
- [ ] 오디오 출력·입력·MPRIS, 네트워크 연결, 클립보드, 캡처·녹화·화면 공유, 설정 저장·복원 통과.
- [ ] 배터리·Bluetooth·백라이트 없는 장치에서도 셸 정상 동작. 지원하지 않는 기능은 원인 표시.
- [ ] APT 조회·실행, 셸 업데이트 성공·실패·복구 통과. 포팅 출처 유지 및 사용자 설정 보존.
- [ ] 동일 해상도·주사율에서 idle 10분과 애니메이션 반복을 측정. 60 Hz 기준 프레임 예산 16.7 ms 초과 비율, CPU, RSS, 온도·스로틀링 기록. 최종 성능 합격선은 M0 장치 기준으로 확정.
- [ ] 저부하 설정에서는 영상 배경·고비용 시각 효과를 줄여도 잠금과 필수 기능 유지.
- [ ] 실제 장치 모델, 커널·Mesa·Hyprland·Quickshell·Qt·패키지 버전, 로그와 화면 증거를 지원표에 기록.

## 8. 구현 착수 시 확정할 정보

Debian 릴리스, ARM64 장치/SoC/GPU, VM인지 실기기인지, 기존 DE·로그인 관리자, 모니터 구성, 영상 배경·Discord 등 필수 선택 기능을 확인합니다. 이 정보가 없더라도 M0의 Debian 13 ARM64 VM과 공식 패키지 검증은 진행할 수 있으나 실제 장치 인증은 완료할 수 없습니다.

첫 기술적 판단 지점은 **공식 backports 조합에서 현재 QML·Lua·셰이더가 로드되는가**입니다. 성공하면 배포판 통합에 집중하고, 실패하면 API 차이를 좁혀 호환 패치를 적용합니다. 필요한 경우에만 고정된 upstream 버전을 Debian용으로 빌드하며 OS 전체의 Qt 교체로 우회하지 않습니다.

## 9. 확인한 외부 근거

아래 링크는 작성 시 검색 또는 열기로 실제 페이지와 본문 접근을 확인했습니다. 패키지 페이지의 존재는 대상 장치에서 설치·실행 성공했다는 뜻이 아닙니다. 학술 자료는 사용하지 않았습니다.

- [S1: 원본 SekaiPop 저장소·README](https://github.com/Blapples/SekaiPop)
- [S2: Debian trixie-backports Hyprland](https://packages.debian.org/trixie-backports/hyprland)
- [S3: Debian trixie-backports Quickshell](https://packages.debian.org/trixie-backports/x11/quickshell)
- [S4: Debian trixie Qt Core](https://packages.debian.org/trixie/libqt6core6t64)
- [S5: Debian ARM64 qt6-shader-baker 파일 목록](https://packages.debian.org/trixie/arm64/qt6-shader-baker/filelist)
- [S5 보충: qt6-shader-baker 버전·아키텍처](https://packages.debian.org/trixie/qt6-shader-baker)
- [S6: Debian trixie-backports Hyprsunset](https://packages.debian.org/trixie-backports/hyprsunset)
- [S7: Quickshell 공식 미러 빌드 문서](https://github.com/quickshell-mirror/quickshell/blob/master/BUILD.md)
- [S8: Debian Backports 공식 사용 안내](https://backports.debian.org/Instructions/)

## 구현 진행 기록 — 2026-10-22

Debian 패키지 백엔드, 단일 설치 진입점, ARM64 matugen 빌드, 폰트·테마 설치, Qt 셰이더 재생성, QML 검증 후 교체, APT 위젯, 잠금 확인 후 절전, 업데이트 검증 및 UTM OpenGL 옵션을 구현했습니다. 대상 환경은 사용자 확인에 따라 **macOS UTM / Debian trixie ARM64**로 확정했습니다.

ARM64 컨테이너 설치와 Wayland QML 컴파일은 통과했습니다. 실제 UTM GPU·PAM·포털·오디오·절전 복귀 인수 검증은 남아 있습니다. 상세 결과는 [검증 기록](DEBIAN-ARM64-VALIDATION.md), 사용 방법은 [설치 안내](DEBIAN-ARM64.md)에 기록합니다. 계획의 전체 인수 조건이 완료되었다고 간주하지 않습니다.
