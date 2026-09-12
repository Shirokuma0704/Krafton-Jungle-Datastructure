#!/usr/bin/env bash
# Q7 RecursiveReverse 검산기
#
#   bash q7test.sh        기대값 대조만 (빠름)
#   bash q7test.sh -v     valgrind 까지 (느림)
#
#     check "리스트값들" "기대결과"
#
# 값은 공백으로 구분한다. 빈 리스트는 "" 를, 기대 출력이 비어 있어야 하면
# "$EMPTY" 를 쓴다.
#
# 재귀 문제라 잘못 짜면 스택이 넘쳐서 죽는다. 그래서 종료 신호도 같이 본다.

set -u
cd "$(dirname "$0")"

VG=0
[ "${1:-}" = "-v" ] && VG=1

BIN=/tmp/q7test
gcc -g -Wall -Wextra -std=c11 \
	-Wno-unused-but-set-variable -Wno-unused-parameter \
	Q7_A_LL.c -o "$BIN"
[ -x "$BIN" ] || { echo "컴파일 실패"; exit 1; }

if [ "$VG" = 1 ] && ! command -v valgrind >/dev/null; then
	echo "valgrind 가 없다. 기대값 대조만 한다."
	VG=0
fi

EMPTY="비어 있음"
pass=0; fail=0; vgbad=0

check() {                # check "리스트값들" "기대결과"
	local vals="$1" want="$2"
	local inp="" x out got rc vgout

	for x in $vals; do inp+="1\n$x\n"; done
	inp+="2\n0\n"

	out=$(printf "$inp" | "$BIN" 2>/dev/null)
	rc=$?
	got=$(echo "$out" | grep "뒤집은" | sed 's/.*리스트: //' | sed 's/[[:space:]]*$//')

	if [ "$rc" -ge 128 ]; then
		fail=$((fail+1))
		printf '  죽음  [%s]  신호 %d %s\n' "$vals" "$((rc-128))" \
			"$([ "$rc" = 139 ] && echo '(SIGSEGV - 스택 넘침이거나 잘못된 주소)'; \
			   [ "$rc" = 134 ] && echo '(SIGABRT)')"
	elif [ "$got" = "$want" ]; then
		pass=$((pass+1)); printf '  OK    [%s]\n' "$vals"
	else
		fail=$((fail+1))
		printf '  FAIL  [%s]\n' "$vals"
		printf '          나온것: [%s]\n' "$got"
		printf '          기대값: [%s]\n' "$want"
	fi

	if [ "$VG" = 1 ]; then
		vgout=$(printf "$inp" | valgrind -q --leak-check=full \
			--errors-for-leak-kinds=definite "$BIN" 2>&1 >/dev/null)
		vgout=$(echo "$vgout" | grep -E -A2 \
			"Invalid read|Invalid write|Invalid free|Mismatched free|definitely lost|uninitialised")
		if [ -n "$vgout" ]; then
			vgbad=$((vgbad+1))
			printf '          valgrind:\n'
			echo "$vgout" | head -8 | sed 's/^/            /'
		fi
	fi
}

# 1..N 을 만들고 N..1 을 기대값으로 돌린다. 재귀 깊이를 보는 용도.
deep() {                 # deep N
	local n="$1" i asc="" desc=""
	for i in $(seq 1 "$n");   do asc="$asc $i";   done
	for i in $(seq "$n" -1 1); do desc="$desc $i"; done
	check "${asc# }" "${desc# }"
}

echo "=== 기본 ==="
check "1 2 3 4 5"   "5 4 3 2 1"

echo "=== 내가 만든 경계 케이스 ==="
# 주석을 하나씩 풀면서 ? 자리를 채우세요.
#
# (1) 원소가 아예 없을 때. 재귀가 첫 호출에서 바로 끝나야 한다.
 check "" "$EMPTY"
#
# (2) 원소가 하나뿐일 때. 뒤집어도 자기 자신이다.
 check "7" "7"
#
# (3) 원소가 둘일 때. 재귀가 딱 한 번 더 들어간다.
 check "1 2" "2 1"
#
# (4) 원소가 셋일 때. 가운데가 제자리에 남는지 본다.
 check "1 2 3" "3 2 1"
#
# (5) 값이 전부 같을 때. 순서가 바뀌었는지 값으로는 확인이 안 되는 경우다.
 check "4 4 4" "4 4 4"
#
# (6) 음수와 0 이 섞일 때.
 check "-1 0 -2" "-2 0 -1"

echo "=== 재귀 깊이 ==="
# 스택이 언제쯤 버거워지는지 본다. 숫자를 올려가며 확인해도 된다.
deep 100
# deep 10000

echo
printf '  통과 %d / 실패 %d' "$pass" "$fail"
[ "$VG" = 1 ] && printf ' / valgrind 문제 %d' "$vgbad"
echo
[ "$fail" -eq 0 ] && { [ "$VG" = 0 ] || [ "$vgbad" -eq 0 ]; }
