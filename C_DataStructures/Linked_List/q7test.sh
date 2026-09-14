#!/usr/bin/env bash
# Q7 RecursiveReverse 검산기
#
#   bash q7test.sh        기대값 대조만 (빠름)
#   bash q7test.sh -v     valgrind 까지 (느림)
#
#     check "리스트값들" "기대결과"
#     deep N                 1..N 을 넣고 N..1 이 나오는지 본다
#
# 값은 공백으로 구분합니다. 빈 리스트는 "" 를, 기대 출력이 비어 있어야 하면
# "$EMPTY" 를 씁니다.
#
# 재귀 문제라 잘못 짜면 스택이 넘쳐서 죽어요. testlib 의 died() 가 그 신호를
# 잡아서 따로 표시해줍니다.

set -u
cd "$(dirname "$0")"

SRC=Q7_A_LL.c
. ../common/testlib.sh

check() {                # check "리스트값들" "기대결과"
	local vals="$1" want="$2" inp got

	inp=$(menu "$vals" "2\n0\n")
	run "$inp"
	died "$vals" && return

	got=$(pick "뒤집은" "$OUT")
	if judge "$vals" "뒤집기" "$got" "$want"; then
		ok "$vals"
	fi

	vgcheck "$inp" "$vals"
}

deep() {                 # deep N
	local n="$1" i asc="" desc=""
	for i in $(seq 1 "$n");    do asc="$asc $i";   done
	for i in $(seq "$n" -1 1); do desc="$desc $i"; done
	check "${asc# }" "${desc# }"
}

echo "=== 기본 ==="
check "1 2 3 4 5"   "5 4 3 2 1"

echo "=== 내가 만든 경계 케이스 ==="
# 주석을 하나씩 풀면서 ? 자리를 채우세요.
#
# (1) 원소가 아예 없을 때. 재귀가 첫 호출에서 바로 끝나야 합니다.
 check "" "$EMPTY"
#
# (2) 원소가 하나뿐일 때. 뒤집어도 자기 자신이에요.
 check "7" "7"
#
# (3) 원소가 둘일 때. 재귀가 딱 한 번 더 들어갑니다.
 check "1 2" "2 1"
#
# (4) 원소가 셋일 때. 가운데가 제자리에 남는지 봅니다.
 check "1 2 3" "3 2 1"
#
# (5) 값이 전부 같을 때. 순서가 바뀌었는지 값으로는 확인이 안 되는 경우예요.
 check "4 4 4" "4 4 4"
#
# (6) 음수와 0 이 섞일 때.
 check "-1 0 -2" "-2 0 -1"

echo "=== 재귀 깊이 ==="
# 스택이 언제쯤 버거워지는지 봅니다. 숫자를 올려가며 확인해도 돼요.
deep 100
# deep 10000

summary
