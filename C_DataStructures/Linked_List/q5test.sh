#!/usr/bin/env bash
# Q5 frontBackSplitLinkedList 검산기
#
#   bash q5test.sh        기대값 대조만 (빠름)
#   bash q5test.sh -v     valgrind 까지 (double free / 누수 검사, 느림)
#
# 앞의 문제들과 달라진 점: 결과가 두 줄(앞쪽/뒤쪽)이라 check 도 기대값을
# 두 개 받아요.
#
#     check "리스트값들" "앞쪽기대값" "뒤쪽기대값"
#
# 값은 공백으로 구분합니다. 빈 리스트를 넣고 싶으면 "" 를, 기대 출력이
# 비어 있어야 하면 "$EMPTY" 를 씁니다.

set -u
cd "$(dirname "$0")"

# 이 문제의 템플릿은 main 의 c 를 초기화하지 않고 while 조건에서 씁니다(61행).
# 제공된 코드의 문제지 님 코드가 아니라서, uninitialised 는 빼고 봅니다.
VG_PATTERN="Invalid read|Invalid write|Invalid free|Mismatched free|definitely lost"

SRC=Q5_A_LL.c
. ../common/testlib.sh

check() {                # check "리스트값들" "앞쪽기대값" "뒤쪽기대값"
	local vals="$1" wantf="$2" wantb="$3" inp gotf gotb

	inp=$(menu "$vals" "2\n0\n")
	run "$inp"
	died "$vals" && return

	gotf=$(pick "앞쪽 연결 리스트" "$OUT")
	gotb=$(pick "뒤쪽 연결 리스트" "$OUT")

	if judge "$vals" "앞쪽" "$gotf" "$wantf" \
	   && judge "$vals" "뒤쪽" "$gotb" "$wantb"; then
		ok "$vals"
	fi

	# 이 문제는 리스트 셋을 각각 free 하니까, 노드를 공유하고 있으면
	# 답이 맞아도 double free 로 여기서 걸립니다.
	vgcheck "$inp" "$vals"
}

echo "=== 문제지 예시 ==="
check "2 3 5 6 7"   "2 3 5"   "6 7"

echo "=== 내가 만든 경계 케이스 ==="
# 여기를 채우세요. 아래는 어떤 상황을 확인하는 칸인지만 적어뒀습니다.
# 기대값은 문제지의 "홀수면 남는 하나는 앞쪽" 규칙을 따라가면 나옵니다.
#
# (1) 원소가 아예 없을 때. 앞뒤 둘 다 어떻게 되어야 하는지.
check "" "$EMPTY" "$EMPTY"
#
# (2) 원소가 하나뿐일 때. 홀수 개라 남는 하나가 어디로 가는지.
check "1" "1" "$EMPTY"
#
# (3) 짝수 개일 때 가장 작은 경우.
 check "1 2" "1" "2"
#
# (4) 홀수 개인데 3 이상. boundary++ 가 실제로 일하는 구간입니다.
 check "1 2 3" "1 2" "3"
#
# (5) 값이 전부 같을 때. 개수 세기와 값 비교가 섞이면 여기서 걸립니다.
 check "2 2 2 2 2" "2 2 2" "2 2"

summary
