#!/usr/bin/env bash
# Q3 moveOddItemsToBack 검산기
#
#   bash q3test.sh        기대값 대조만 (빠름)
#   bash q3test.sh -v     valgrind 까지 (use-after-free / 누수 검사, 느림)
#
# 케이스 추가하는 법: 아래 "내가 만든 경계 케이스" 칸에
#
#     check "리스트값들" "기대결과"
#
# 형식으로 한 줄 쓰면 된다. 값은 공백으로 구분한다.
# 빈 리스트를 넣고 싶으면 "" 를 쓰고, 기대 출력은 "$EMPTY" 를 쓴다.

set -u
cd "$(dirname "$0")"

VG=0
[ "${1:-}" = "-v" ] && VG=1

BIN=/tmp/q4test
# 두 경고는 제공된 코드가 내는 잡음이라 컴파일러 쪽에서 끈다.
#   unused-but-set-variable : main 의 j
#   unused-parameter        : 아직 비어 있는 함수의 ll
# 나머지 경고는 전부 그대로 보여준다.
gcc -g -Wall -Wextra -std=c11 \
	-Wno-unused-but-set-variable -Wno-unused-parameter \
	Q4_A_LL.c -o "$BIN"
[ -x "$BIN" ] || { echo "컴파일 실패"; exit 1; }

if [ "$VG" = 1 ] && ! command -v valgrind >/dev/null; then
	echo "valgrind 가 없다. 기대값 대조만 한다."
	VG=0
fi

EMPTY="비어 있음"
pass=0; fail=0; vgbad=0

check() {                # check "리스트값들" "기대결과"
	local vals="$1" want="$2"
	local inp="" x out got vgout

	for x in $vals; do inp+="1\n$x\n"; done
	inp+="2\n0\n"

	out=$(printf "$inp" | "$BIN")
	got=$(echo "$out" | grep "짝수를 뒤로 보낸" | sed 's/.*리스트: //' | sed 's/[[:space:]]*$//')

	if [ "$got" = "$want" ]; then
		pass=$((pass+1)); printf '  OK    [%s]\n' "$vals"
	else
		fail=$((fail+1))
		printf '  FAIL  [%s]\n' "$vals"
		printf '          나온것: [%s]\n' "$got"
		printf '          기대값: [%s]\n' "$want"
	fi

	# valgrind 는 정답 여부와 별개로 본다.
	# 답이 맞아도 free 된 메모리를 읽고 있으면 여기서 걸린다.
	if [ "$VG" = 1 ]; then
		vgout=$(printf "$inp" | valgrind -q --leak-check=full --errors-for-leak-kinds=definite "$BIN" 2>&1 >/dev/null)
		if [ -n "$vgout" ]; then
			vgbad=$((vgbad+1))
			printf '          valgrind:\n'
			echo "$vgout" | grep -E "Invalid read|Invalid write|Invalid free|definitely lost|^==.*at 0x" | head -6 | sed 's/^/            /'
		fi
	fi
}

echo "=== 문제지 예시 ==="
check "2 3 4 7 15 18"   "3 7 15 2 4 18"
check "2 7 18 3 4 15"   "7 3 15 2 18 4"
check "1 3 5"           "1 3 5"
check "2 4 6"           "2 4 6"

echo "=== 내가 만든 경계 케이스 ==="
# 여기를 채우세요. 아래 세 줄은 어떤 상황을 확인하는 칸인지만 적어뒀습니다.
# 기대 출력은 문제지 예시 두 개를 손으로 따라가 보면 규칙이 나옵니다.
#
# (1) 원소가 아예 없을 때 함수가 뭘 해야 하는지
check "" "$EMPTY"
#
# (2) 원소가 하나뿐일 때. 홀수 하나인 경우와 짝수 하나인 경우를 따로 봐야 합니다.
 check "7" "7"
 check "8" "8"
#
# (3) 홀수가 리스트 맨 끝에 이미 있을 때. 옮길 필요가 없는데 옮기면 순서가 깨집니다.
 check "1 3 4" "1 3 4"
#
# (4) 홀수 두 개가 붙어 있을 때. 커서를 두 칸씩 옮기는 설계가 여기서 걸립니다.
check "2 4 3 5" "3 5 2 4"
#
# (5) 음수. 홀짝 판정을 % 2 == 1 로 했으면 여기서 깨집니다.
 check "-3 2 -4 5" "-3 5 2 -4"

echo
printf '  통과 %d / 실패 %d' "$pass" "$fail"
[ "$VG" = 1 ] && printf ' / valgrind 문제 %d' "$vgbad"
echo
[ "$fail" -eq 0 ] && { [ "$VG" = 0 ] || [ "$vgbad" -eq 0 ]; }
