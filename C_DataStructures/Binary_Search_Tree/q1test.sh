#!/usr/bin/env bash
# BST Q1 levelOrderTraversal 검산기
#
#   bash q1test.sh        기대값 대조만 (빠름)
#   bash q1test.sh -v     valgrind 까지 (WSL 에서만 됩니다)
#
#     check "이름" "넣는 순서" "기대 레벨순회"
#     twice "이름" "넣는 순서" "기대 레벨순회"    2번을 두 번 눌러봅니다
#
# ★ 입력이 트리가 아니라 "넣는 순서" 입니다 ★
#
# 이진 트리 문제들은 트리 모양을 직접 적어줬는데, 여기는 다릅니다. 작으면 왼쪽
# 크면 오른쪽이라는 규칙이 자리를 정하니까, **넣는 순서만 정하면 모양이 따라옵니다.**
#
#     20 15 50 10 18 25 80  을 순서대로 넣으면
#
#              20                 레벨 순회: 20 15 50 10 18 25 80
#            /    \
#          15      50
#         /  \    /  \
#       10    18 25   80
#
# 순서가 바뀌면 모양이 통째로 바뀌어요. 오름차순으로만 넣으면 오른쪽으로만 뻗은
# 한 줄이 됩니다. 이게 이 문제에서 제일 재미있는 자리예요.
#
# 같은 값을 여러 번 넣으면 insertBSTNode 가 두 번째부터 버립니다. 그래서 이
# 트리에는 중복이 안 생겨요.
#
# ★ 기대값을 먼저 손으로 적으세요 ★
#
# 그리고 나서 이걸로 맞춰보실 수 있습니다.
#
#     bash ../common/bstinput.sh "20 15 50 10 18 25 80"
#
# 먼저 그려버리면 "넣는 순서가 모양을 어떻게 바꾸는지" 를 못 배웁니다.
# 예측을 적고 -> 검산기 돌리고 -> 틀렸으면 그려보는 순서가 제일 남아요.
#
# ★ 문제지 조건 하나 ★
#
# "시작할 때 큐가 비어 있지 않으면 먼저 비워야 합니다."
#
# main 의 case 2 는 removeAll 을 안 해서 2번을 여러 번 누를 수 있어요. 그래서
# twice 로 두 번 눌러봅니다. 큐를 안 비우면 두 번째 결과가 첫 번째와 달라집니다.

set -u
cd "$(dirname "$0")"

SRC=Q1_F_BST.c
. ../common/testlib.sh
. ../common/bstinput.sh

LABEL='순회 결과:'       # 메뉴 안내문은 "레벨 순회 출력;" 이라 안 걸립니다.

# 넣는 순서를 메뉴 입력으로 펴줍니다. 값 하나에 "1, 값" 두 줄이에요.
feed() {                 # feed "20 15 50"  ->  "1\n20\n1\n15\n1\n50\n"
	local v out=""
	for v in $1; do out+="1\n$v\n"; done
	printf '%s' "$out"
}

# 찍힌 줄들만 뽑아냅니다. n 번째 것을 고를 수 있어요.
grab() {                 # grab 1 "$OUT"
	printf '%s\n' "$2" | grep "$LABEL" | sed -n "$1p" | sed 's/.*: //; s/[[:space:]]*$//'
}

check() {                # check "이름" "넣는 순서" "기대 레벨순회"
	local name="$1" seq="$2" want="$3" inp got

	inp="$(feed "$seq")2\n0\n"
	run "$inp"
	died "$name" && return

	got=$(grab 1 "$OUT")
	[ -z "$got" ] && got="$EMPTY"
	[ -z "$want" ] && want="$EMPTY"

	if judge "$name" "레벨순회" "$got" "$want"; then
		ok "$name"
	fi

	vgcheck "$inp" "$name"
}

# 2번을 두 번 눌러서 두 번 다 같은 결과가 나오는지 봅니다.
twice() {                # twice "이름" "넣는 순서" "기대 레벨순회"
	local name="$1" seq="$2" want="$3" inp first second

	inp="$(feed "$seq")2\n2\n0\n"
	run "$inp"
	died "$name" && return

	first=$(grab 1 "$OUT");  [ -z "$first" ]  && first="$EMPTY"
	second=$(grab 2 "$OUT"); [ -z "$second" ] && second="$EMPTY"
	[ -z "$want" ] && want="$EMPTY"

	if judge "$name (첫 번째)" "레벨순회" "$first" "$want"; then
		if judge "$name (두 번째)" "레벨순회" "$second" "$want"; then
			ok "$name"
		fi
	fi

	vgcheck "$inp" "$name"
}

echo "=== 문제지 예시 ==="
check "문제지 그림" "20 15 50 10 18 25 80" "20 15 50 10 18 25 80"

echo "=== 기본 ==="
check "한 노드" "7" "7"

echo "=== 내가 만든 경계 케이스 ==="
# ? 자리를 채우고 앞의 # 을 지우면서 하나씩 돌려보세요.
# 한 번에 다 풀지 마시고, 하나 채우고 한 번 돌리는 식으로요.
# 아무것도 안 찍혀야 하면 기대값 자리에 "$EMPTY" 나 "" 를 쓰세요.
#
# (1) 아무것도 안 넣고 바로 2번을 누른 경우. 넣는 순서 자리를 비워두시면 됩니다.
#     root 가 NULL 인데 큐에 넣으려 들면 여기서 터져요.
 check "빈 트리" "" ""
#
# (2) 오름차순으로만 넣은 경우. 트리가 한 줄이 되는데, 그 줄이 레벨 순회에서
#     어떻게 나오는지 적어보세요. 층마다 노드가 하나씩입니다.
 check "오름차순" "1 2 3 4" "1 2 3 4"
#
# (3) (2) 를 거꾸로, 내림차순으로만 넣은 경우. 반대쪽으로 한 줄이 됩니다.
#     한쪽만 테스트하면 반대쪽 가지를 큐에 넣는 코드가 한 번도 안 돌 수 있어요.
 check "내림차순" "5 4 3 2 1" "5 4 3 2 1"
#
# (4) 같은 값을 여러 번 넣은 경우. insertBSTNode 가 두 번째부터 버리니까
#     결과에 몇 번 나와야 하는지 먼저 정하고 적으세요.
 check "중복 값" "1 1 1 1" "1"
#
# (5) 2번을 두 번 누르는 경우. 문제지가 "큐가 비어 있지 않으면 먼저 비우라" 고
#     한 자리예요. 큐를 안 비우면 두 번째가 첫 번째와 달라집니다.
#     check 대신 twice 를 쓰시면 됩니다. 기대값은 한 번만 적으세요.
 twice "두 번 순회" "" ""

summary
