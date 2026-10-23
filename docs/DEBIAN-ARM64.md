# Debian 13 ARM64 / UTM 설치

이 포트의 대상은 macOS의 UTM에서 실행하는 Debian 13(trixie) ARM64입니다. ARM64 컨테이너 설치와 Wayland 구성 컴파일을 검증했으며, 실제 UTM 화면·잠금 해제·절전 검증은 별도로 필요합니다. AMD64도 설치 분기를 제공하지만 이번 검증 대상은 아닙니다.

## 한 스크립트로 설치

이 변경사항이 포함된 저장소 전체를 Debian VM으로 복사한 뒤, 해당 폴더에서 일반 사용자로 실행합니다. 사용자에게 sudo 권한과 인터넷 연결이 필요합니다.

```bash
bash get.sh --utm
```

설치 내용을 먼저 보려면:

```bash
bash get.sh --utm --dry-run
```

질문 없이 기본 전체 설정으로 설치하려면 `bash get.sh --utm --yes`를 사용합니다. 기존 Hyprland 설정을 유지하려면 `bash get.sh --utm --hypr merge`를 사용합니다. 설치 후 로그아웃하고 로그인 화면에서 일반 **Hyprland** 세션을 선택합니다. 디스플레이 매니저가 없는 TTY 환경에서는 로그인한 일반 사용자로 `Hyprland`를 실행합니다.

원본 저장소의 기존 원격 설치 URL에는 아직 이 포트가 배포되지 않았습니다. 현재는 변경된 로컬 체크아웃의 `get.sh`를 실행해야 합니다. 수정된 체크아웃은 자동 업데이트를 비활성화하여 원본 Arch 버전으로 되돌아가는 것을 막습니다. 갱신은 이 포트의 새 체크아웃에서 같은 설치 명령을 다시 실행합니다.

## UTM 설정

QEMU 기반 VM은 UTM의 Display 설정에서 GPU 가속을 지원하는 virtio 장치를 사용합니다. UTM 공식 문서에는 `virtio-gpu-gl-pci`와 VirGL OpenGL 지원이 설명되어 있습니다. `--utm`은 Qt Quick 렌더러를 OpenGL로 지정하고 `spice-vdagent`, `pciutils`, `mesa-utils`를 설치합니다. VM 설정 자체를 변경하지는 않습니다.

Apple Virtualization 기반 VM과 QEMU 기반 VM의 그래픽 기능은 같지 않습니다. 이 옵션만으로 GPU 가속이나 호스트와의 클립보드 연동을 보장하지 않습니다. UTM에서 장치가 제공되지 않는 Bluetooth, 백라이트, DDC, 배터리 기능은 해당 하드웨어 없이 사용할 수 없습니다.

- [UTM Linux guest support](https://docs.getutm.app/guest-support/linux/)
- [UTM QEMU display 설정](https://docs.getutm.app/settings-qemu/devices/display/)

## 설치 동작

- Debian 공식 trixie-backports에서 Hyprland 0.55 이상과 Quickshell을 설치합니다. 요청된 패키지와 의존성에 backports를 적용하며 전체 배포판 업그레이드는 하지 않습니다.
- Qt 6.8 환경의 `qsb`로 소스가 있는 셰이더 28개를 재빌드하고 전체 36개 번들을 읽어 검증합니다. QML import 검증에 실패하면 기존 셸을 교체하지 않습니다.
- matugen은 기존 설치가 없으면 고정된 v4.2.0 커밋을 ARM64에서 빌드합니다. Rust 빌드 때문에 최초 설치에는 시간이 걸립니다. 폰트와 GTK 테마는 고정된 다운로드의 SHA-256을 검증합니다.
- 패키지 위젯은 APT 캐시를 읽고 마지막 인덱스 시각을 표시합니다. 실제 갱신은 터미널에서 sudo로 수행합니다. Debian에서는 AUR 옵션을 숨깁니다.
- 서비스는 systemd가 실행 중일 때 구성합니다. systemd-networkd가 사용 중이면 NetworkManager로 자동 전환하지 않습니다.
- 셸의 절전 및 최대 절전 요청은 compositor의 잠금 완료 응답을 기다립니다. 외부 logind 이벤트나 UTM 자체의 VM 일시 정지는 이 경로와 별개입니다.

## 확인과 복구

설치한 체크아웃에서 다음 명령으로 의존성과 구성 상태를 확인합니다.

```bash
bash check-deps.sh
Hyprland --verify-config -c "$HOME/.config/hypr/hyprland.lua"
```

Hyprland 세션 안에서 전체 QML 컴파일도 확인할 수 있습니다.

```bash
bash "$HOME/.config/quickshell/sekaipop/scripts/system/check-qml.sh" "$HOME/.config/quickshell/sekaipop"
```

설치기는 기존 셸을 `.bak-시간` 폴더에 보관합니다. 기존 Hyprland의 모니터·워크스페이스·override·custom 설정도 보존합니다. 최초 설치 전에 사용하던 개인 Hyprland 설정의 백업이 있다면 다음 명령으로 복구합니다. SekaiPop 재설치 직전 설정은 별도의 `hypr.sekaipop-previous` 폴더에 보관되며 이 명령의 자동 복구 대상이 아닙니다:

```bash
bash install.sh --restore
```

이 복구는 Hyprland 설정 대상입니다. APT 패키지, 저장소, 서비스, 폰트와 셸 전체를 제거하는 명령은 아닙니다.

실제 UTM에서는 첫 로그인 후 화면 출력·해상도 변경·패널·오디오·포털 화면 공유·PAM 잠금 해제·절전 복귀를 확인해야 합니다. 실패 시 `~/.cache/sekaipop/hypr-errors.log`, Hyprland 로그 및 `qs -c sekaipop`의 출력을 확인합니다.
