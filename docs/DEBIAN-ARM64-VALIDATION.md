# Debian ARM64 포팅 검증 기록

검증일: 2026-10-22(KST). 기준 원본 커밋: `e3bad50d5459bd27358b2d97aebdf6549cce84d0`. 이 기록은 작업 트리의 포팅 변경을 대상으로 합니다.

## 환경과 결과

macOS의 Docker에서 `debian:trixie`, `linux/arm64` 컨테이너를 실행했습니다. 일반 테스트 사용자와 sudo를 사용했으며 호스트 저장소는 읽기 전용으로 마운트했습니다. 설치 실행에는 별도 소스 스냅샷을 사용했습니다. 실행 중인 설치 스크립트를 수정하면 Bash가 이후 내용을 잘못 읽을 수 있으므로, 설치가 끝날 때까지 해당 소스는 수정하지 않아야 합니다.

| 검증 | 결과 / 범위 |
|---|---|
| APT 전체 필수 패키지 의존성 해석 및 설치 | 통과; 명시한 패키지에 `-t trixie-backports` 적용 |
| Hyprland | ARM64 `0.55.2+ds-1~bpo13+1` 설치; 생성된 Lua 설정 `--verify-config` 결과 `config ok` |
| Quickshell | ARM64 `0.3.0-1~bpo13+1` 설치 |
| Qt 셰이더 | `qt6-shader-baker 6.8.2-3`; 소스 28개 재빌드, 전체 36개 번들 검사 통과 |
| 전체 설치 | 일반 사용자로 `get.sh --yes --utm -- --no-services` 성공; systemd 없는 컨테이너이므로 서비스 활성화 제외 |
| UTM 의존성 | `spice-vdagent 0.22.1-4.1` 및 진단 도구 설치 확인 |
| 폰트 / GTK 테마 | 고정 다운로드 SHA-256 확인 후 설치 |
| matugen | 고정 v4.2.0 소스의 ARM64 네이티브 빌드 성공; 실제 GTK 및 Qt 색상 파일 생성 확인 |
| QML | headless import 통과; Weston headless Wayland에서 전체 셸 component 컴파일 통과 |
| 재설치 / dry-run | custom 파일 보존 확인; dry-run 전후 사용자 config 전체 파일 SHA-256 일치 |
| 포팅 회귀 테스트 | `port_test.py` 6개 통과; APT 읽기 전용 조회, 잠금 확인 전 절전 거부, 설치·업데이트 검증 실패 시 기존 설치 보존 등 |
| 업데이트 기존 회귀 | `update_check_test.sh` 전체 통과 |
| 셸 정적 검사 | 대상 17개 `bash -n` 및 컨테이너의 ShellCheck error 수준 통과; `git diff --check` 통과 |

기존 lock-sleep, lock-transition, lock-calendar, lyrics, update_notify 테스트도 통과했습니다. 기존 `lock-wallpaper-test`는 `HookService is not defined`로 실패하며, 변경 전 원본 커밋에서도 같은 실패를 재현했습니다. 이 포팅의 성공 항목에 포함하지 않았습니다.

## 실행 검증의 경계

전체 QML 검사는 컴포넌트를 컴파일하며 셸 전체를 인스턴스화하지 않습니다. 따라서 실제 패널 렌더링·서비스 통합·상호작용 검증과 같지 않습니다. GPU 없는 컨테이너에서는 Hyprland의 headless backend 시작이 실패했으며, QML 컴파일에는 별도 Weston 소프트웨어 Wayland 서버를 사용했습니다.

실제 UTM의 가상 GPU/DRM, OpenGL 가속, 여러 해상도, 포털 화면 공유, 오디오, PAM 인증, 잠금 후 절전·복귀, SPICE 연동은 미검증입니다. 실제 VM에서 이 항목들이 통과해야 데스크톱 사용 검증이 완료됩니다. Arch 및 AMD64 전체 설치 역시 이번 ARM64 검증 결과로 대체하지 않습니다.

바이너리만 존재하는 시각화 셰이더 8개는 Qt 6.8 도구로 읽기 검증이 통과했습니다. 소스 재빌드나 GPU별 시각적 일치 검증을 했다는 의미는 아닙니다.

## 재현 명령

Debian ARM64 테스트 환경에서 저장소 루트 기준:

```bash
python3 sekaipop/tests/debian-port-test/port_test.py
bash sekaipop/tests/update-test/update_check_test.sh
bash get.sh --utm --dry-run
bash get.sh --utm --yes
bash check-deps.sh
Hyprland --verify-config -c "$HOME/.config/hypr/hyprland.lua"
```

로그인된 Wayland 환경에서는:

```bash
bash "$HOME/.config/quickshell/sekaipop/scripts/system/check-qml.sh" "$HOME/.config/quickshell/sekaipop"
```

## 확인한 공식 자료

- [Debian trixie-backports Hyprland](https://packages.debian.org/trixie-backports/hyprland)
- [Debian trixie-backports Quickshell](https://packages.debian.org/trixie-backports/x11/quickshell)
- [Qt Shader Tools qsb](https://doc.qt.io/qt-6/qtshadertools-qsb.html)
- [Quickshell WlSessionLock](https://quickshell.org/docs/v0.3.0/types/Quickshell.Wayland/WlSessionLock/)
- [UTM QEMU display](https://docs.getutm.app/settings-qemu/devices/display/)
