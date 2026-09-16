#!/usr/bin/env bash
# BST Q3 preOrderIterative 검산기
#
#   bash q3test.sh        기대값 대조만 (빠름)
#   bash q3test.sh -v     valgrind 까지 (WSL 에서만 됩니다)
#
#     check "이름" "넣는 순서" "기대 전위순회"
#     twice "이름" "넣는 순서" "기대 전위순회"    2번을 두 번 눌러봅니다
#
# 입력은 q1test.sh 와 같아요. 트리 모양이 아니라 **넣는 순서**를 적습니다.
#
#     20 15 50 10 18 25 80  을 순서대로 넣으면
#
#              20                 전위 순회: 20 15 10 18 50 25 80
#            /    \
#          15      50             나부터 찍고 -> 왼쪽 전부 -> 오른쪽 전부
#         /  \    /  \
#       10    18 25   80
#
#     bash ../common/bstinput.sh "20 15 50 10 18 25 80"   로 그려볼 수 있어요
#
# ★ Q2 의 지름길이 여기서는 안 통합니다 ★
#
# 중위 순회는 어떤 순서로 넣든 결과가 오름차순이었어요. 전위 순회는 다릅니다.
# **넣는 순서가 바뀌면 결과도 바뀝니다.**
#
#     20 15 50 10 18 25 80  ->  전위 20 15 10 18 50 25 80
#     10 15 18 20 25 50 80  ->  전위 10 15 18 20 25 50 80   (오른쪽 한 줄)
#
# 같은 값들인데 결과가 다르죠. 중위 순회는 "왼쪽 다음 나" 라서 항상 작은 것부터
# 나오지만, 전위는 "나부터" 라서 루트가 무엇이냐가 그대로 드러나거든요.
#
# 그래서 이 문제부터는 기대값을 적으려면 **트리 모양을 실제로 떠올려야** 합니다.
# 예측을 먼저 적고, 그다음에 아래로 맞춰보세요.
#
#     bash ../common/bstinput.sh "20 15 50 10 18 25 80"
#
# ★ q1 과 달라진 것: 큐가 아니라 스택이고, 인자 모양도 다릅니다 ★
#
#     q1   void enqueue(QueueNode **head, QueueNode **tail, BSTNode *node);
#     q2   void push(Stack *stack, BSTNode *node);
#
# q1 은 머리와 꼬리를 따로 받았는데, q2 는 Stack 구조체 하나를 통째로 받습니다.
# 구조체 안에 top 이 들어 있어서 별표가 하나면 충분해요. 헷갈리기 쉬운 자리입니다.
#
# ★ 문제지 조건 ★
#
# "시작할 때 스택이 비어 있지 않으면 먼저 비워야 합니다."
#
# main 의 case 2 는 removeAll 을 안 해서 2번을 여러 번 누를 수 있어요.
# 그래서 twice 로 두 번 눌러봅니다.

set -u
cd "$(dirname "$0")"

SRC=Q3_F_BST.c
. ../common/testlib.sh
. ../common/bstinput.sh

LABEL='순회 결과:'       # 메뉴 안내문은 "전위 순회 출력;" 이라 안 걸립니다.

feed() {                 # feed "20 15 50"  ->  "1\n20\n1\n15\n1\n50\n"
	local v out=""
	for v in $1; do out+="1\n$v\n"; done
	printf '%s' "$out"
}

grab() {                 # grab 1 "$OUT"
	printf '%s\n' "$2" | grep "$LABEL" | sed -n "$1p" | sed 's/.*: //; s/[[:space:]]*$//'
}

check() {                # check "이름" "넣는 순서" "기대 전위순회"
	local name="$1" seq="$2" want="$3" inp got

	inp="$(feed "$seq")2\n0\n"
	run "$inp"
	died "$name" && return

	got=$(grab 1 "$OUT")
	[ -z "$got" ] && got="$EMPTY"
	[ -z "$want" ] && want="$EMPTY"

	if judge "$name" "전위순회" "$got" "$want"; then
		ok "$name"
	fi

	vgcheck "$inp" "$name"
}

twice() {                # twice "이름" "넣는 순서" "기대 전위순회"
	local name="$1" seq="$2" want="$3" inp first second

	inp="$(feed "$seq")2\n2\n0\n"
	run "$inp"
	died "$name" && return

	first=$(grab 1 "$OUT");  [ -z "$first" ]  && first="$EMPTY"
	second=$(grab 2 "$OUT"); [ -z "$second" ] && second="$EMPTY"
	[ -z "$want" ] && want="$EMPTY"

	if judge "$name (첫 번째)" "전위순회" "$first" "$want"; then
		if judge "$name (두 번째)" "전위순회" "$second" "$want"; then
			ok "$name"
		fi
	fi

	vgcheck "$inp" "$name"
}

echo "=== 문제지 예시 ==="
check "문제지 그림" "20 15 50 10 18 25 80" "20 15 10 18 50 25 80"

echo "=== 기본 ==="
check "한 노드" "7" "7"

echo "=== 내가 만든 경계 케이스 ==="
# ? 자리를 채우고 앞의 # 을 지우면서 하나씩 돌려보세요.
# 한 번에 다 풀지 마시고, 하나 채우고 한 번 돌리는 식으로요.
# 아무것도 안 찍혀야 하면 기대값 자리에 "$EMPTY" 나 "" 를 쓰세요.
#
# (1) 아무것도 안 넣고 바로 2번을 누른 경우. 넣는 순서 자리를 비워두시면 됩니다.
#     빈 스택에서 pop 을 부르면 그대로 터지는 자리이기도 해요.
 check "빈 트리" "" ""
#
# (2) 내림차순으로만 넣은 경우. 왼쪽으로만 한 줄로 내려가는 트리가 됩니다.
#     전위 순회는 "나부터" 라서, 이 모양에서 결과가 어떻게 나오는지 적어보세요.
 check "내림차순" "5 4 3 2 1 0" "5 4 3 2 1 0"
#
# (3) (2) 를 거꾸로, 오름차순으로만 넣은 경우. 오른쪽 한 줄이 됩니다.
#     스택에 쌓이는 모양이 (2) 와 반대예요. 한쪽만 테스트하면 반대쪽 자식을
#     스택에 넣는 코드가 한 번도 안 돕니다.
 check "오름차순" " -5 1 2 3 4 5" "-5 1 2 3 4 5"
#
# (4) 같은 값을 여러 번 넣은 경우. insertBSTNode 가 두 번째부터 버리니까
#     결과에 몇 번 나와야 하는지 먼저 정하고 적으세요.
 check "중복 값" "0 0 0 0 0" "0"
 check "복잡한 갈래" "50 60 20 10 40 30" "50 20 10 40 30 60"

#
# (5) 2번을 두 번 누르는 경우. 문제지가 "스택이 비어 있지 않으면 먼저 비우라"
#     고 한 자리예요. check 대신 twice 를 쓰시고 기대값은 한 번만 적으세요.
twice "두 번 순회" "20 15 50 10 18 25 80" "20 15 10 18 50 25 80"
summary
