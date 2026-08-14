# 2026-08-05 G1 실기체 실습

## 과제 2 — 상체 모션 시퀀스

### 1. 과제 목표

G1 실기체에서 상체 모션을 실행하기 전에 로봇의 상태와 안전 조건을 확인하고,
SDK에서 제공하는 실제 Action 목록을 확인한 뒤 상체 동작을 실행하였다.

이번 실습에서는 `g1_real_sequence.py`를 이용하여 실기체의 상체 동작을 실행하고,
동작 전후의 FSM 상태와 안전 절차를 확인하였다.

---

## 2. 실기체 실행 환경

- Robot: Unitree G1
- SDK: `unitree_sdk2py`
- 실행 파일: `g1_real_sequence.py`
- 네트워크 인터페이스: `wlp2s0`
- 실행 PC IP 대역: `192.168.123.x`
- 로봇 연결 확인 IP: `192.168.123.164`

SDK 가상환경 활성화:

```bash
source ~/g1_sdk_env/bin/activate
```

실기체 코드 위치로 이동:

```bash
cd ~/robot_ws/src/g1-real
```

---

## 3. 로봇 연결 확인

실기체와 PC가 정상적으로 통신하는지 확인하기 위해 ping 테스트를 수행하였다.

```bash
ping 192.168.123.164
```

실행 결과 패킷 손실 없이 응답이 들어오는 것을 확인하였다.

```text
64 bytes from 192.168.123.164
0% packet loss
```

이를 통해 PC와 G1 실기체 사이의 네트워크 연결이 정상적으로 구성되어 있음을 확인하였다.

---

## 4. 실기체 상태 모니터링

로봇을 움직이기 전에 `g1_real_monitor.py`를 이용하여 상태를 확인하였다.

### 4.1 Precheck

```bash
python3 g1_real_monitor.py precheck --iface wlp2s0
```

확인 항목:

- 상태 스트림 정상 수신
- tick 진행 여부
- IMU 기울기 확인
- 모터 온도 확인
- 토크 수준 확인
- NaN 데이터 존재 여부 확인

실행 결과 주요 항목에서 `[PASS]`가 출력되는 것을 확인하였다.

### 4.2 Baseline 측정

```bash
python3 g1_real_monitor.py baseline --iface wlp2s0 --sec 15
```

15초 동안 기준 상태 데이터를 수집하여 `g1_baseline.json`을 생성하였다.

Baseline은 이후 관절 토크나 IMU 값이 평상시보다 크게 변했는지 판단하기 위한 기준으로 사용하였다.

### 4.3 Watch 실행

```bash
python3 g1_real_monitor.py watch --iface wlp2s0
```

실기체 동작 중 다음 항목을 지속적으로 확인하였다.

- 로봇 기울기
- 관절 위치
- 관절 토크
- 이상 상태
- 모니터링 데이터 수신 여부

모니터링 도중 데이터가 일정 시간 들어오지 않을 경우
`모니터링 끊김` 경고가 출력되는 것도 확인하였다.

---

## 5. 실기체에서 사용 가능한 Action 확인

실제 G1에서 지원되는 상체 Action을 확인하기 위해 다음 명령을 실행하였다.

```bash
python3 g1_real_sequence.py --iface wlp2s0 --list-actions
```

확인된 Action 중 일부는 다음과 같다.

```text
11  two-hand kiss
12  left kiss
13  right kiss
15  hands up
17  clap
18  high five
19  hug
20  heart
21  right heart
22  reject
23  right hand up
24  x-ray
25  face wave
26  high wave
27  shake hand
99  release arm
```

실기체가 실제로 제공하는 `GetActionList()` 결과를 확인한 뒤,
과제에서 사용할 `hands up` 동작이 지원되는 것을 확인하였다.

---

## 6. 과제 2 상체 모션 설계

이번 실기체 실행에서는 `hands_up` 동작을 사용하였다.

| 순서 | 동작 | 대기 시간 |
|---|---|---:|
| 1 | `hands_up` → 팔 Action `hands up` | 8.0 s |

실행 전후의 로봇 상태 전이와 안전 조건을 확인한 뒤 동작을 수행하였다.

전이 흐름:

```text
Damp
→ 기립(위치 잠금)
→ 균형 제어
→ 상체 동작 실행
→ 종료 선택
```

---

## 7. Dry-run 확인

실기체를 바로 움직이기 전에 먼저 실행 계획을 확인하였다.

```bash
python3 g1_real_sequence.py --dry-run
```

Dry-run을 통해 실제 로봇에 명령을 보내기 전에
동작 순서와 대기 시간을 먼저 확인하였다.

---

## 8. 안전 Gate 확인

실기체 동작 전 다음 안전 절차를 확인하였다.

### SOP ① 5단계 사전 확인

- 예약표 확인
- 동선 확인
- 비상정지 위치 확인
- 주변 공간 확보
- 실행 코드 확인

```text
[게이트] SOP ① 5단계 체크 완료하였습니까?
> y
```

### SOP ② 행어 거치 확인

로봇이 행어에 안전하게 거치되어 있는지 확인하였다.

```text
[게이트] SOP ② 행어 거치 확인 완료하였습니까?
> y
```

### 멘토 리모컨 확인

비상 상황 발생 시 즉시 Damp 상태로 전환할 수 있도록
멘토가 리모컨을 소지하고 즉시 조작 가능한 위치에 있는지 확인하였다.

```text
[게이트] 멘토가 리모컨(비상 Damp) 소지 중이고,
즉시 조작 가능한 위치입니까?
> y
```

### 모니터링 확인

`g1_real_monitor.py watch`가 정상 실행 중인지 확인하였다.

```text
[게이트] 모니터링 담당이 g1_real_monitor.py watch 가동 중입니까?
> y
```

---

## 9. 기립 및 균형 상태 확인

상체 동작을 실행하기 전에 로봇의 기립 및 균형 상태를 확인하였다.

`--arm-only` 모드에서는 현재 FSM을 직접 조회하기 어려운 경우가 있어
멘토와 로봇 상태를 육안으로 확인한 뒤 진행하였다.

```text
[콜] "기립 완료 — 모션 실행합니다"
```

---

## 10. Hands Up 동작 실행

과제 2에서 선택한 `hands_up` 동작을 실제 G1 실기체에서 실행하였다.

실제 실행 결과:

```text
[1/1] hands_up → 팔 액션 'hands up'

현재 FSM: 501

[콜] "시퀀스 완료"
```

실제 G1 로봇에서 양팔을 들어 올리는 `hands up` 상체 동작이 수행되는 것을 확인하였다.

---

## 11. 종료 및 안전 처리

동작 완료 후 다음 두 가지 종료 상태 중 하나를 선택하도록 구성하였다.

```text
d = Damp
k = 기립 유지
```

또한 비상 상황이나 `Ctrl+C`로 프로그램이 종료되는 경우에도
Damp 상태로 전환하도록 구성하였다.

```text
Ctrl+C 중단
→ 실행 중단
→ Damp 수렴
→ 안전 상태 유지
```

---

## 12. FSM 상태 전이 확인

실기체 제어 과정에서 상태 전이를 위해 FSM ID를 확인하였다.

```python
fsm_ids = {
    "Damp": 1,
    "Squat2StandUp": 706,
    "Start": 500,
}
```

일부 상태 전이는 다음과 같이 `SetFsmId()`를 이용하여 호출하도록 코드를 확인하고 수정하였다.

```python
code = self.loco.SetFsmId(fsm_ids[n])
```

실제 로봇에서는 현재 FSM 상태에서 허용되는 명령인지 확인한 뒤
다음 상태로 전이해야 한다는 것을 확인하였다.

---

## 13. 코드 수정 및 문법 확인

`g1_real_sequence.py`를 수정하는 과정에서 다음과 같은 오류가 발생하였다.

```text
SyntaxError: expected ':'
```

또한 탭과 공백이 섞이면서 다음 오류도 확인하였다.

```text
TabError: inconsistent use of tabs and spaces
```

실제 로봇에 코드를 실행하기 전에 다음 명령으로 Python 문법을 검사하였다.

```bash
python3 -m py_compile g1_real_sequence.py
```

문법 오류가 발생한 위치를 확인한 뒤 코드를 수정하였다.

---

## 14. 과제 2 실행 결과

| 확인 항목 | 결과 |
|---|---|
| SDK 환경 활성화 | 완료 |
| 실기체 네트워크 연결 | 완료 |
| Ping 통신 확인 | 완료 |
| Precheck 상태 점검 | 완료 |
| Baseline 측정 | 완료 |
| Watch 모니터링 | 완료 |
| GetActionList 확인 | 완료 |
| `hands up` Action 존재 확인 | 완료 |
| Dry-run 실행 계획 확인 | 완료 |
| 실행 전 SOP 안전 확인 | 완료 |
| 행어 거치 확인 | 완료 |
| 멘토 비상 Damp 리모컨 확인 | 완료 |
| 기립 및 균형 상태 확인 | 완료 |
| `hands_up` 실기체 실행 | 완료 |
| 실행 중 FSM 501 확인 | 완료 |
| 시퀀스 종료 확인 | 완료 |

---

## 15. 핵심 실행 명령

```bash
source ~/g1_sdk_env/bin/activate

cd ~/robot_ws/src/g1-real

ping 192.168.123.164

python3 g1_real_monitor.py precheck --iface wlp2s0

python3 g1_real_monitor.py baseline --iface wlp2s0 --sec 15

python3 g1_real_monitor.py watch --iface wlp2s0

python3 g1_real_sequence.py --dry-run

python3 g1_real_sequence.py --iface wlp2s0 --list-actions

python3 g1_real_sequence.py --iface wlp2s0 --arm-only
