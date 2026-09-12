#!/usr/bin/env bash
# Q5 frontBackSplitLinkedList 검산기
#
#   bash q5test.sh        기대값 대조만 (빠름)
#   bash q5test.sh -v     valgrind 까지 (double free / 누수 검사, 느림)
#
# 앞의 문제들과 달라진 점: 결과가 두 줄(앞쪽/뒤쪽)이라 check 도 기대값을
# 두 개 받는다.
#
#     check "리스트값들" "앞쪽기대값" "뒤쪽기대값"
#
# 값은 공백으로 구분한다. 빈 리스트를 넣고 싶으면 "" 를, 기대 출력이
# 비어 있어야 하면 "$EMPTY" 를 쓴다.

set -u
cd "$(dirname "$0")"

VG=0
[ "${1:-}" = "-v" ] && VG=1

BIN=/tmp/q5test
gcc -g -Wall -Wextra -std=c11 \
	-Wno-unused-but-set-variable -Wno-unused-parameter \
	Q5_A_LL.c -o "$BIN"
[ -x "$BIN" ] || { echo "컴파일 실패"; exit 1; }

if [ "$VG" = 1 ] && ! command -v valgrind >/dev/null; then
	echo "valgrind 가 없다. 기대값 대조만 한다."
	VG=0
fi

EMPTY="비어 있음"
pass=0; fail=0; vgbad=0

# 출력에서 "앞쪽 연결 리스트: 5 4 " 같은 줄을 찾아 값 부분만 떼어낸다.
grab() {                 # grab "출력전체" "앞쪽|뒤쪽"
	echo "$1" | grep "$2 연결 리스트:" | sed 's/.*리스트: //' | sed 's/[[:space:]]*$//'
}

check() {                # check "리스트값들" "앞쪽기대값" "뒤쪽기대값"
	local vals="$1" wantf="$2" wantb="$3"
	local inp="" x out gotf gotb vgout

	for x in $vals; do inp+="1\n$x\n"; done
	inp+="2\n0\n"

	out=$(printf "$inp" | "$BIN")
	gotf=$(grab "$out" "앞쪽")
	gotb=$(grab "$out" "뒤쪽")

	if [ "$gotf" = "$wantf" ] && [ "$gotb" = "$wantb" ]; then
		pass=$((pass+1)); printf '  OK    [%s]\n' "$vals"
	else
		fail=$((fail+1))
		printf '  FAIL  [%s]\n' "$vals"
		printf '          앞쪽 나온것: [%s]  기대값: [%s]\n' "$gotf" "$wantf"
		printf '          뒤쪽 나온것: [%s]  기대값: [%s]\n' "$gotb" "$wantb"
	fi

	# valgrind 는 정답 여부와 별개로 본다.
	# 이 문제는 리스트 셋을 각각 free 하므로 노드를 공유하고 있으면
	# 답이 맞아도 double free 로 여기서 걸린다.
	if [ "$VG" = 1 ]; then
		vgout=$(printf "$inp" | valgrind -q --leak-check=full \
			--errors-for-leak-kinds=definite "$BIN" 2>&1 >/dev/null)
		# 진짜 에러 줄만 남긴다. -A2 로 그 아래 위치 정보까지 같이 본다.
		# main 의 c 초기화 누락(제공된 코드 문제)은 이 목록에 없어서 자동으로 빠진다.
		vgout=$(echo "$vgout" | grep -E -A2 \
			"Invalid read|Invalid write|Invalid free|Mismatched free|definitely lost")
		if [ -n "$vgout" ]; then
			vgbad=$((vgbad+1))
			printf '          valgrind:\n'
			echo "$vgout" | head -8 | sed 's/^/            /'
		fi
	fi
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
# (4) 홀수 개인데 3 이상. boundary++ 가 실제로 일하는 구간이다.
 check "1 2 3" "1 2" "3"
#
# (5) 값이 전부 같을 때. 개수 세기와 값 비교가 섞이면 여기서 걸린다.
 check "2 2 2 2 2" "2 2 2" "2 2"

echo
printf '  통과 %d / 실패 %d' "$pass" "$fail"
[ "$VG" = 1 ] && printf ' / valgrind 문제 %d' "$vgbad"
echo
[ "$fail" -eq 0 ] && { [ "$VG" = 0 ] || [ "$vgbad" -eq 0 ]; }
