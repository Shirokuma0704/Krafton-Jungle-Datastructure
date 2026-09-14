#!/usr/bin/env bash
# Q4 reverse 검산기
#
#   bash q4test.sh        기대값 대조만 (빠름)
#   bash q4test.sh -v     valgrind 까지 (WSL 에서만 됩니다)
#
#     check   "큐에 넣을 값들" "뒤집은 기대값"
#     again   "큐에 넣을 값들" "뒤집은 기대값" "한 번 더 눌렀을 때의 기대값"
#     andmore "큐에 넣을 값들" "뒤집은 기대값" "그다음 넣을 값" "그때 큐의 기대값"
#
# 값은 공백으로 구분합니다. 빈 큐는 "" 를, 출력이 비어 있어야 하면
# "$EMPTY" 를 씁니다. Q2 에서 세 번 걸렸던 그 자리예요 ( ˊ̱˂˃ˋ̱ )
#
# Q1/Q2 와 다른 점이 하나 있어요. 여기선 값이 연결 리스트를 거치지 않고
# 곧바로 큐로 들어갑니다. 그래서 메뉴가 1/2/0 두 개뿐이에요.
#
# 그리고 main 의 case 2 는 뒤집어서 출력한 뒤에 큐를 통째로 비웁니다.
# 그래서 2 를 두 번 누르면 두 번째는 빈 큐를 뒤집는 셈이 돼요. again 이
# 그걸 보는 용도고, 빈 큐에서 안 죽는지를 확인합니다.
#
# andmore 는 뒤집은 뒤에 1 을 한 번 더 눌러봅니다. 이 문제의 LinkedList 에는
# tail 포인터가 있어서, 큐를 enqueue/dequeue 말고 직접 주무르면 tail 이
# 옛날 노드를 가리킨 채 남을 수 있거든요. 그 흔적이 여기서 드러납니다.

set -u
cd "$(dirname "$0")"

SRC=Q4_C_SQ.c
. ../common/testlib.sh

check() {                # check "값들" "뒤집은 기대값"
	local vals="$1" want="$2" inp got

	inp=$(menu "$vals" "2\n0\n")
	run "$inp"
	died "$vals" && return

	got=$(pick "뒤집은 큐" "$OUT")
	if judge "$vals" "뒤집기" "$got" "$want"; then
		ok "$vals"
	fi

	vgcheck "$inp" "$vals"
}

again() {                # again "값들" "뒤집은 기대값" "한 번 더 눌렀을 때"
	local vals="$1" want1="$2" want2="$3" inp got1 got2

	inp=$(menu "$vals" "2\n2\n0\n")
	run "$inp"
	died "2연속:$vals" && return

	got1=$(pick "뒤집은 큐" "$OUT" 1)
	got2=$(pick "뒤집은 큐" "$OUT" 2)

	if judge "2연속:$vals" "첫 번째" "$got1" "$want1" \
	   && judge "2연속:$vals" "두 번째" "$got2" "$want2"; then
		ok "2연속:$vals"
	fi

	vgcheck "$inp" "2연속:$vals"
}

andmore() {              # andmore "값들" "뒤집은 기대값" "그다음 넣을 값" "그때 큐"
	local vals="$1" want="$2" extra="$3" wantq="$4" inp got gotq

	inp=$(menu "$vals" "2\n1\n$extra\n0\n")
	run "$inp"
	died "뒤에더:$vals" && return

	got=$(pick "뒤집은 큐" "$OUT")
	gotq=$(pick "현재 큐" "$OUT" '$')     # 마지막 "현재 큐" 줄

	if judge "뒤에더:$vals" "뒤집기" "$got" "$want" \
	   && judge "뒤에더:$vals" "그다음 enqueue" "$gotq" "$wantq"; then
		ok "뒤에더:$vals"
	fi

	vgcheck "$inp" "뒤에더:$vals"
}

echo "=== 기본 ==="
# 문제지에 나온 예시 그대로예요.
check "1 2 3 4 5" "5 4 3 2 1"

echo "=== 내가 만든 경계 케이스 ==="
# ? 자리를 채우고 앞의 # 을 지우면서 하나씩 돌려보세요.
# 한 줄 채울 때마다 돌리시는 게 좋아요.
#
# (1) 큐가 비어 있는데 그냥 뒤집기를 누를 때. 여기서 죽거나 멈추면 안 됩니다.
 check "" "$EMPTY"
#
# (2) 원소가 하나뿐일 때. 뒤집어도 그대로입니다.
 check "7" "7"
#
# (3) 원소가 둘일 때. 뒤집기가 실제로 일어나는 가장 작은 입력이에요.
 check "1 2" "2 1"
#
# (4) 같은 값만 여러 개일 때. 눈으로는 구분이 안 되니, 개수가 유지되는지를 봅니다.
 check "4 4 4" "4 4 4"
#
# (5) 음수가 섞여 있을 때.
 check "-1 2 -3" "-3 2 -1"
#
# (6) 0 이 맨 앞과 맨 뒤에 있을 때. 뒤집으면 자리가 바뀌어야 합니다.
 check "0 5 0" "0 5 0"
#
# (7) 원소가 꽤 많을 때. 중간에 순서가 어긋나지 않는지 봅니다. 열 개쯤이면 충분해요.
 check "1 2 3 4 5 6 7 8 9 0" "0 9 8 7 6 5 4 3 2 1"

echo "=== 뒤집기를 두 번 연속 ==="
# main 의 case 2 가 출력 뒤에 큐를 비웁니다. 그러니 두 번째로 2 를 눌렀을 때
# 뒤집기 함수가 받는 큐가 어떤 상태인지부터 정하고 기대값을 적으세요.
 again "1 2 3" "3 2 1" "$EMPTY"

echo "=== 뒤집은 다음에 하나 더 넣기 ==="
# 뒤집고 나서 1 을 눌러 값을 하나 더 넣습니다.
# 그 직전에 main 이 큐를 비웠다는 걸 감안해서, "현재 큐" 에 뭐가 찍혀야
# 맞는지를 정해서 적으세요.
 andmore "1 2 3" "3 2 1" "9" "9"

summary
