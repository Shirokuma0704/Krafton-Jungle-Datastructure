#!/usr/bin/env bash
# Q1 identical 검산기
#
#   bash q1test.sh        기대값 대조만 (빠름)
#   bash q1test.sh -v     valgrind 까지 (WSL 에서만 됩니다)
#
#     check "이름" "트리1" "트리2" "$SAME"  또는  "$DIFF"
#     shape "이름" "트리1"  "중위순회 기대값"      입력이 내 생각대로 들어갔는지
#
# ★ 입력 형식이 지금까지와 또 다릅니다 ★
#
# createTree() 가 값을 하나씩 물어보는데, 그 순서가 **전위 순회**예요.
# 루트를 먼저 받고, 그다음부터는 스택에서 꺼낸 노드마다 "왼쪽, 오른쪽" 을 묻습니다.
# 왼쪽을 나중에 push 하니까 왼쪽이 먼저 나와요.
#
#     1 을 루트로, 2 와 3 을 자식으로 두는 트리
#
#            1          입력: 1  2  3  x  x  x  x
#           / \                └┬─┘  └─┬──┘ └─┬─┘
#          2   3             루트  1의자식  2의자식 3의자식
#
# 정수 대신 **문자**를 넣으면 그 자리는 NULL 이 됩니다. 위의 x 가 그거예요.
# 그래서 루트 자리에 x 하나만 넣으면 빈 트리가 됩니다.
#
# 자식을 안 적고 넘어갈 수가 없어요. NULL 이어도 x 를 적어야 다음 질문으로 갑니다.
# 값 개수가 하나라도 어긋나면 그 뒤가 통째로 밀려서 **엉뚱한 트리가 조용히 만들어져요.**
# 그래서 아래에 shape 를 같이 넣어뒀습니다. 판정을 보기 전에 트리부터 맞는지 보세요.
#
# 판정이 전부 반대로 나오면 main 이 무엇을 참으로 치는지부터 보세요.
# Q3 와 Q7 에서 겪은 그 자리예요.
#
# 디버거로 돌리실 거면 main 맨 위에 setvbuf(stdout, NULL, _IONBF, 0); 넣어두시고요.

set -u
cd "$(dirname "$0")"

SRC=Q1_E_BT.c
. ../common/testlib.sh

SAME="두 트리는 구조가 같습니다."
DIFF="두 트리는 다릅니다."

VERDICT='두 트리는'      # 메뉴 안내문은 "두 트리의" 라서 안 걸립니다.

# 값 목록을 한 줄에 하나씩으로 펴줍니다.
tree() {                 # tree "1 2 3 x x x x"  ->  "1\n2\n3\nx\nx\nx\nx\n"
	local t out=""
	for t in $1; do out+="$t\n"; done
	printf '%s' "$out"
}

# 값 개수가 맞는지 먼저 셉니다. 트리 하나에 필요한 개수는 이렇게 정해져요.
#
#     루트 1개 + 만들어지는 노드마다 왼쪽·오른쪽 2개  =  1 + 2 × (정수 개수)
#
# 모자라면 프로그램이 입력을 다 먹고도 다음 값을 계속 기다립니다. 그런데 stdin 이
# 끝나면 scanf 는 기다리지 않고 바로 실패해서 돌아와요. main 은 그 실패를 안 보고
# 메뉴를 다시 물어보고, 그게 끝없이 반복됩니다. 그래서 겉으로는 "무한 루프" 로만
# 보이고 진짜 원인인 "값이 모자람" 은 안 보여요. 그래서 여기서 먼저 끊습니다.
tokens_ok() {            # tokens_ok "이름" "1 2 3 x x x x"
	local t n=0 k=0 need
	for t in $2; do
		n=$((n+1))
		case "$t" in ''|*[!0-9-]*) ;; *) k=$((k+1));; esac
	done
	need=$((1 + 2 * k))
	[ "$n" -eq "$need" ] && return 0

	fail=$((fail+1))
	printf '  입력  [%s]  값이 %d개인데 %d개가 필요해요\n' "$1" "$n" "$need"
	printf '          정수가 %d개니까 1 + 2×%d = %d 개.\n' "$k" "$k" "$need"
	printf '          NULL 자리도 문자로 적어주셔야 다음 질문으로 넘어갑니다.\n'
	return 1
}

check() {                # check "이름" "트리1" "트리2" "기대 판정"
	local name="$1" t1="$2" t2="$3" want="$4" inp got

	tokens_ok "$name" "$t1" || return
	tokens_ok "$name" "$t2" || return

	inp="1\n$(tree "$t1")2\n$(tree "$t2")3\n0\n"
	run "$inp"
	died "$name" && return

	got=$(pick "$VERDICT" "$OUT")
	if judge "$name" "판정" "$got" "$want"; then
		ok "$name"
	fi

	vgcheck "$inp" "$name"
}

# 입력이 내 생각대로 먹혔는지만 봅니다. printTree 가 중위 순회라, 트리를
# 왼쪽부터 훑은 값들이 나와요. 빈 트리면 기대값 자리에 $EMPTY 를 쓰세요.
shape() {                # shape "이름" "트리1" "중위순회 기대값"
	local name="$1" t1="$2" want="$3" inp got

	tokens_ok "$name" "$t1" || return

	inp="1\n$(tree "$t1")0\n"
	run "$inp"
	died "$name" && return

	got=$(pick "만들어진 트리 1" "$OUT")
	[ -z "$got" ] && got="$EMPTY"

	if judge "$name" "중위순회" "$got" "$want"; then
		ok "$name"
	fi
}

echo "=== 입력이 내 생각대로 들어갔는지 ==="
# 판정을 믿으려면 트리부터 맞아야 해요. 여기가 틀리면 아래는 볼 필요도 없습니다.
shape "한 노드"   "1 x x"          "1"
shape "세 노드"   "1 2 3 x x x x"  "2 1 3"
#
# 빈 트리도 한 줄 넣어보세요. 루트 자리에 문자 하나만 주면 됩니다.
# shape "빈 트리" "?" "$EMPTY"

echo "=== 기본 ==="
check "한 노드, 값 같음"  "1 x x"  "1 x x"  "$SAME"
check "한 노드, 값 다름"  "1 x x"  "2 x x"  "$DIFF"
check "세 노드, 완전 같음" "1 2 3 x x x x" "1 2 3 x x x x" "$SAME"

echo "=== 내가 만든 경계 케이스 ==="
# ? 자리를 채우고 앞의 # 을 지우면서 하나씩 돌려보세요.
# 한 번에 다 풀지 마시고, 하나 채우고 한 번 돌리는 식으로요.
#
# (1) 양쪽 다 빈 트리일 때. 재귀가 맨 처음에 마주치는 경우이고,
#     "둘 다 없으면 같은 것인가" 를 정하는 자리예요.
check "둘 다 빈 트리" "x" "x" "$SAME"
#
# (2) 한쪽만 빈 트리일 때. (1) 과 원인이 다릅니다. 한쪽에는 노드가 있고
#     다른 쪽에는 없는데, 이때 NULL 을 먼저 안 걸러내면 없는 쪽을 따라갑니다.
 check "한쪽만 빈 트리" "1 2 3 x x x x" "x" "$DIFF"
#
# (3) 값은 전부 같은데 자식이 붙은 방향이 다를 때. 한쪽은 왼쪽에, 다른 쪽은
#     오른쪽에 달아보세요. 값만 비교하는 풀이가 여기서 걸립니다.
check "값 같고 모양 다름" "1 x 2 x x" "1 2 x x x" "$DIFF"
#
# (4) 왼쪽 서브트리는 같고 오른쪽만 다를 때. 한쪽 결과만 보고 끝내버리는
#     풀이가 여기서 드러나요.
 check "오른쪽만 다름" "1 2 3 4 5 6 7 4 5 x x x x x x x x x x" "1 2 3 4 5 6 7 8 9 x x x x x x x x x x" "$DIFF"
#
# (5) (4) 를 뒤집어서, 오른쪽은 같고 왼쪽만 다를 때.
# check "왼쪽만 다름" "?" "?" "?"
#
# (6) 한쪽이 다른 쪽보다 한 층 더 깊을 때. 위쪽은 전부 같아서, 끝까지
#     내려가야 차이가 나옵니다.
check "깊이가 다름" "1 2 3 x x x x" "1 2 3 4 5 6 x x x x x x x" "$DIFF"
#
# (7) 값이 음수이거나 0 일 때. 0 을 "없음" 으로 착각하는 코드가 있으면 여기서 터져요.
check "0 과 음수" "0 -1 -2 x x x x" "0 -1 -2 x x x x" "$SAME"

summary
