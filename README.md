# KRAFTON Jungle Week 4 — Data Structures (C)

파이썬으로 **쓰기만** 하던 자료구조를, 이번엔 C로 **직접 만들어 보는** 주차입니다.
포인터와 `malloc` / `free`에 익숙해지는 게 진짜 목표예요.

## 구성

| 폴더 | 내용 |
|---|---|
| [C_DataStructures](C_DataStructures) | 과제 27문제 + 문제지 PDF + 빌드 설정 |

풀이 순서와 진행 체크리스트, 개발 환경 설명은 [C_DataStructures/README.md](C_DataStructures/README.md)에 있습니다.

## 개발 환경

발제문이 요구하는 `Ubuntu 22.04 LTS (x86_64)` 환경을 WSL2로 올려서 씁니다.

```
gcc 11.4.0  /  gdb 12.1  /  valgrind 3.18.1  /  cmake 3.22.1
```

Windows MinGW로도 빌드는 되지만 `valgrind`가 없어요. 이번 과제는 메모리를 직접
할당하고 해제하는 게 핵심이라, 누수와 이중 해제를 잡아주는 도구가 있는 쪽이 맞습니다.

## 이번 주 목표

- 과제의 모든 구현 통과하기
- 테스트 케이스를 스스로 만들어 보고 통과하는지 확인하기 (이번 주는 주어진 테스트가 없음)
- 알고리즘의 놓친 부분 확인하기

## 진행 기록

트러블슈팅과 배운 것은 따로 정리합니다. WIL은 목요일에 `WEEK4` 태그로 제출.
