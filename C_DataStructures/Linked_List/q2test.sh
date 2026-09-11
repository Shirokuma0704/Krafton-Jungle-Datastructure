#!/usr/bin/env bash
# Q2 alternateMergeLinkedList 검산기
# 쓰는 법:  bash q2test.sh
set -u
cd "$(dirname "$0")"

gcc -g -Wall -Wextra -std=c11 Q2_A_LL.c -o /tmp/q2test 2>&1 | grep -v "set but not used" | grep -v "int c, i, j" | grep -v "In function" | grep -v '\^'
[ -x /tmp/q2test ] || { echo "컴파일 실패"; exit 1; }

pass=0; fail=0

check() {            # check "ll1값들" "ll2값들" "기대ll1" "기대ll2"
	local a="$1" b="$2" e1="$3" e2="$4"
	local inp="" x out g1 g2
	for x in $a; do inp+="1\n$x\n"; done
	for x in $b; do inp+="2\n$x\n"; done
	inp+="3\n0\n"

	out=$(printf "$inp" | /tmp/q2test | grep 만들어진)
	g1=$(echo "$out" | sed -n '1p' | sed 's/.*리스트 1: //' | sed 's/[[:space:]]*$//')
	g2=$(echo "$out" | sed -n '2p' | sed 's/.*리스트 2: //' | sed 's/[[:space:]]*$//')

	if [ "$g1" = "$e1" ] && [ "$g2" = "$e2" ]; then
		pass=$((pass+1))
		printf '  OK    ll1=[%s] ll2=[%s]\n' "$a" "$b"
	else
		fail=$((fail+1))
		printf '  FAIL  ll1=[%s] ll2=[%s]\n' "$a" "$b"
		printf '          나온것: [%s] / [%s]\n' "$g1" "$g2"
		printf '          기대값: [%s] / [%s]\n' "$e1" "$e2"
	fi
}

E="비어 있음"

check "1 2 3"        "4 5 6 7"   "1 4 2 5 3 6"              "7"
check "1 5 7 3 9 11" "6 10 2 4"  "1 6 5 10 7 2 3 4 9 11"    "$E"
check "1 2 3 4"      "5 6 7 8"   "1 5 2 6 3 7 4 8"          "$E"
check "1 2"          "3 4 5 6 7" "1 3 2 4"                  "5 6 7"
check "1 2 3 4 5"    "6 7"       "1 6 2 7 3 4 5"            "$E"
check ""             "1 2 3"     "$E"                       "1 2 3"
check "1"            "2 3"       "1 2"                      "3"
check "1 2 3"        ""          "1 2 3"                    "$E"

echo
echo "  통과 $pass / 실패 $fail"
[ "$fail" -eq 0 ]
