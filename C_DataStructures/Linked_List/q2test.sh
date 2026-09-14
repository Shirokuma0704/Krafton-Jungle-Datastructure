#!/usr/bin/env bash
# Q2 alternateMergeLinkedList 검산기
#
#   bash q2test.sh        기대값 대조만 (빠름)
#   bash q2test.sh -v     valgrind 까지 (WSL 에서만 됩니다)
#
#     check "ll1값들" "ll2값들" "기대ll1" "기대ll2"
#
# 값은 공백으로 구분합니다. 빈 리스트는 "" 를, 출력이 비어 있어야 하면
# "$EMPTY" 를 씁니다.
#
# 이 문제만 리스트가 둘이라 메뉴도 둘이에요. 1 이 리스트 1, 2 가 리스트 2 고
# 3 이 번갈아 합치기입니다. menu 의 세 번째 인자가 그 번호예요.

set -u
cd "$(dirname "$0")"

SRC=Q2_A_LL.c
. ../common/testlib.sh

check() {                # check "ll1값들" "ll2값들" "기대ll1" "기대ll2"
	local a="$1" b="$2" e1="$3" e2="$4"
	local inp g1 g2 name

	inp="$(menu "$a" "" 1)$(menu "$b" "3\n0\n" 2)"
	name="ll1=[$a] ll2=[$b]"
	run "$inp"
	died "$name" && return

	g1=$(pick "만들어진" "$OUT" 1)
	g2=$(pick "만들어진" "$OUT" 2)

	if judge "$name" "리스트 1" "$g1" "$e1" \
	   && judge "$name" "리스트 2" "$g2" "$e2"; then
		ok "$name"
	fi

	vgcheck "$inp" "$name"
}

E="$EMPTY"

check "1 2 3"        "4 5 6 7"   "1 4 2 5 3 6"              "7"
check "1 5 7 3 9 11" "6 10 2 4"  "1 6 5 10 7 2 3 4 9 11"    "$E"
check "1 2 3 4"      "5 6 7 8"   "1 5 2 6 3 7 4 8"          "$E"
check "1 2"          "3 4 5 6 7" "1 3 2 4"                  "5 6 7"
check "1 2 3 4 5"    "6 7"       "1 6 2 7 3 4 5"            "$E"
check ""             "1 2 3"     "$E"                       "1 2 3"
check "1"            "2 3"       "1 2"                      "3"
check "1 2 3"        ""          "1 2 3"                    "$E"

summary
