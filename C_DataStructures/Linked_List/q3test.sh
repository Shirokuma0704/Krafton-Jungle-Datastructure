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
# 형식으로 한 줄 쓰면 됩니다. 값은 공백으로 구분해요.
# 빈 리스트를 넣고 싶으면 "" 를, 기대 출력이 비어 있어야 하면 "$EMPTY" 를 씁니다.

set -u
cd "$(dirname "$0")"

SRC=Q3_A_LL.c
. ../common/testlib.sh

check() {                # check "리스트값들" "기대결과"
	local vals="$1" want="$2" inp got

	inp=$(menu "$vals" "2\n0\n")
	run "$inp"
	died "$vals" && return

	got=$(pick "홀수를 뒤로 보낸" "$OUT")
	if judge "$vals" "홀수 뒤로" "$got" "$want"; then
		ok "$vals"
	fi

	# valgrind 는 정답 여부와 별개로 봅니다.
	# 답이 맞아도 free 된 메모리를 읽고 있으면 여기서 걸려요.
	vgcheck "$inp" "$vals"
}

echo "=== 문제지 예시 ==="
check "2 3 4 7 15 18"   "2 4 18 3 7 15"
check "2 7 18 3 4 15"   "2 18 4 7 3 15"
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
 check "2 4 7" "2 4 7"
#
# (4) 홀수 두 개가 붙어 있을 때. 커서를 두 칸씩 옮기는 설계가 여기서 걸립니다.
check "2 3 5 4" "2 4 3 5"
#
# (5) 음수. 홀짝 판정을 % 2 == 1 로 했으면 여기서 깨집니다.
 check "-3 2 -4 5" "2 -4 -3 5"

summary
