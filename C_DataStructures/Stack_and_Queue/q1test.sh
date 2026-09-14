#!/usr/bin/env bash
# Q1 createQueueFromLinkedList / removeOddValues 검산기
#
#   bash q1test.sh        기대값 대조만 (빠름)
#   bash q1test.sh -v     valgrind 까지 (WSL 에서만 됩니다)
#
#     check "리스트값들" "기대 큐" "홀수 뺀 기대 결과"
#     twice "리스트값들" "두 번째로 만든 큐의 기대값"
#
# 값은 공백으로 구분합니다. 빈 리스트는 "" 를, 출력이 비어 있어야 하면
# "$EMPTY" 를 씁니다.
#
# check 는 메뉴를 1..(값 넣기) → 2(큐 만들기) → 3(홀수 빼기) → 0 순서로 눌러줍니다.
# 두 함수를 한 번에 보기 때문에, 큐 만들기부터 틀렸으면 그 줄에서 먼저 걸립니다.
#
# twice 는 2 를 연속으로 두 번 누릅니다. createQueueFromLinkedList 가
# 이전 큐를 제대로 치우고 시작하는지 보려는 용도입니다.
#
# 이 문제는 while 조건을 잘못 걸면 무한 루프에 빠지면서 malloc 이 계속 쌓입니다.
# 그래서 케이스마다 시간 제한을 걸어두고, 넘기면 따로 표시합니다.
#
# gcc 찾기 / 컴파일 / 타임아웃 / 출력 비교 / valgrind / 집계는 전부
# ../common/testlib.sh 로 빠졌어요. 여기 남은 건 "Q1 에서만 다른 것" 뿐입니다.

set -u
cd "$(dirname "$0")"

SRC=Q1_C_SQ.c
. ../common/testlib.sh

check() {                # check "리스트값들" "기대 큐" "홀수 뺀 기대 결과"
	local vals="$1" wantq="$2" wanto="$3"
	local inp gotq goto

	inp=$(menu "$vals" "2\n3\n0\n")
	run "$inp"
	died "$vals" && return

	gotq=$(pick "만들어진 큐" "$OUT")
	goto=$(pick "홀수를 뺀 큐" "$OUT")

	if judge "$vals" "큐 만들기" "$gotq" "$wantq" \
	   && judge "$vals" "홀수 빼기" "$goto" "$wanto"; then
		ok "$vals"
	fi

	vgcheck "$inp" "$vals"
}

twice() {                # twice "리스트값들" "두 번째로 만든 큐의 기대값"
	local vals="$1" want="$2" inp got

	inp=$(menu "$vals" "2\n2\n0\n")
	run "$inp"
	died "2연속:$vals" && return

	got=$(pick "만들어진 큐" "$OUT" 2)
	if judge "2연속:$vals" "두 번째 큐" "$got" "$want"; then
		ok "2연속:$vals"
	fi
}

echo "=== 기본 ==="
check "2 4 5 6" "2 4 5 6" "2 4 6"
check "1 1 3"   "1 1 3"   "$EMPTY"

echo "=== 내가 만든 경계 케이스 ==="
# ? 자리를 채우고 앞의 # 을 지우면서 하나씩 돌려보세요.
#
# (1) 리스트가 비어 있을 때. 큐 만들기와 홀수 빼기가 둘 다 빈 것을 받습니다.
 check "" "$EMPTY" "$EMPTY"
#
# (2) 원소가 하나뿐인데 그게 짝수일 때. 아무것도 안 빠져야 합니다.
 check "2" "2" "2"
#
# (3) 원소가 하나뿐인데 그게 홀수일 때. 큐가 텅 비게 됩니다.
 check "3" "3" "$EMPTY"
#
# (4) 전부 짝수일 때. 한 바퀴 다 돌고 나서 순서가 그대로인지가 핵심입니다.
 check "2 4 6 8" "2 4 6 8" "2 4 6 8"
#
# (5) 전부 홀수일 때. 큐를 비우고 나서도 루프가 남은 횟수를 마저 도는 자리입니다.
 check "1 3 5 7" "1 3 5 7" "$EMPTY"
#
# (6) 짝수가 맨 앞에만 하나 있을 때. 살아남은 원소가 앞으로 돌아와야 합니다.
 check "2 1 3 5" "2 1 3 5" "2"
#
# (7) 짝수가 맨 뒤에만 하나 있을 때. (6) 과 방향이 반대입니다.
 check "1 3 5 2" "1 3 5 2" "2"
#
# (8) 0 이 섞여 있을 때. 0 을 짝수로 보는지 확인합니다.
 check "0 1 2" "0 1 2" "0 2"
#
# (9) 음수 홀수가 섞여 있을 때. C 에서 -3 % 2 가 무엇인지 먼저 생각해보세요.
 check "-2 -3 -4 -5" "-2 -3 -4 -5" "-2 -4"
#
# (10) 같은 값이 여러 번 나올 때. 하나만 지우고 마는지 봅니다.
 check "3 3 4 3" "3 3 4 3" "4"

echo "=== 큐 만들기를 두 번 연속 ==="
# 2 를 눌러 큐를 만든 뒤, 곧바로 2 를 한 번 더 누릅니다.
# 두 번째 시점에 연결 리스트가 어떤 상태인지부터 정하고, 그러면 큐가
# 어떻게 되어야 맞는지를 정해서 적으세요. 정답이 하나가 아닙니다.
 twice "2 4 6" "2 4 6" #시작에 큐를 비워서 2 4 6만 들어감

summary
