#!/usr/bin/env bash
# Q6 moveMaxToFront 검산기
#
#   bash q6test.sh        기대값 대조만 (빠름)
#   bash q6test.sh -v     valgrind 까지 (느림)
#
# 케이스 추가하는 법:
#
#     check "리스트값들" "기대결과"
#
# 값은 공백으로 구분한다. 빈 리스트는 "" 를, 기대 출력이 비어 있어야 하면
# "$EMPTY" 를 쓴다.
#
# 이 문제는 함수가 ListNode ** 를 받아서 노드를 직접 재연결한다. 그래서
# 프로그램이 아예 죽는 경우가 생길 수 있어서, 종료 신호도 같이 본다.

set -u
cd "$(dirname "$0")"

VG=0
[ "${1:-}" = "-v" ] && VG=1

BIN=/tmp/q6test
gcc -g -Wall -Wextra -std=c11 \
	-Wno-unused-but-set-variable -Wno-unused-parameter \
	Q6_A_LL.c -o "$BIN"
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
	got=$(echo "$out" | grep "맨 앞으로 옮긴" | sed 's/.*리스트: //' | sed 's/[[:space:]]*$//')

	if [ "$rc" -ge 128 ]; then
		# 128 이상은 신호로 죽은 것. 139 = SIGSEGV, 134 = SIGABRT
		fail=$((fail+1))
		printf '  죽음  [%s]  신호 %d %s\n' "$vals" "$((rc-128))" \
			"$([ "$rc" = 139 ] && echo '(SIGSEGV)'; [ "$rc" = 134 ] && echo '(SIGABRT)')"
	elif [ "$got" = "$want" ]; then
		pass=$((pass+1)); printf '  OK    [%s]\n' "$vals"
	else
		fail=$((fail+1))
		printf '  FAIL  [%s]\n' "$vals"
		printf '          나온것: [%s]\n' "$got"
		printf '          기대값: [%s]\n' "$want"
	fi

	# valgrind 는 정답 여부와 별개로 본다. 화이트리스트 방식이라
	# 여기 적힌 종류만 통과하고 나머지 잡음은 자동으로 빠진다.
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

echo "=== 문제지 예시 ==="
check "30 20 40 70 50"   "70 30 20 40 50"

echo "=== 내가 만든 경계 케이스 ==="
# 여기를 채우세요. 아래는 어떤 상황을 확인하는 칸인지만 적어뒀습니다.
# 주석을 하나씩 풀면서 ? 자리에 기대값을 넣으면 됩니다.
#
# (1) 원소가 아예 없을 때. 옮길 최댓값 자체가 없다.
 check "" "$EMPTY"
#
# (2) 원소가 하나뿐일 때. 그게 곧 최댓값이다.
 check "7" "7"
#
# (3) 최댓값이 이미 맨 앞에 있을 때. 옮길 필요가 없는데 옮기면 깨진다.
 check "9 1 2 3" "9 1 2 3"
#
# (4) 최댓값이 맨 끝에 있을 때. 끊어낸 자리 뒤에 아무것도 없다.
 check "1 2 3 9" "9 1 2 3"
#
# (5) 최댓값이 두 번째에 있을 때. 떼어낼 노드와 맨 앞 노드가 붙어 있다.
 check "1 9 2 3" "9 1 2 3"
#
# (6) 최댓값이 여러 개일 때. 어느 것을 옮길지 먼저 정해야 기대값이 써진다.
 check "3 9 5 9 1" "9 3 5 9 1"
#
# (7) 값이 전부 음수일 때.
 check "-5 -2 -9" "-2 -5 -9"
#
# (8) 값이 전부 같을 때.
 check "4 4 4 4" "4 4 4 4"

echo
printf '  통과 %d / 실패 %d' "$pass" "$fail"
[ "$VG" = 1 ] && printf ' / valgrind 문제 %d' "$vgbad"
echo
[ "$fail" -eq 0 ] && { [ "$VG" = 0 ] || [ "$vgbad" -eq 0 ]; }
