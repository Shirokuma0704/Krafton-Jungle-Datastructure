#!/usr/bin/env bash
# Q3 isStackPairwiseConsecutive 검산기
#
#   bash q3test.sh        기대값 대조만 (빠름)
#   bash q3test.sh -v     valgrind 까지 (WSL 에서만 됩니다)
#
#     check "넣는 순서" "$YES"   또는   "$NO"
#     again "넣는 순서" "첫 번째 판정" "두 번째 판정"
#
# 앞의 문제들과 다른 점: 결과가 리스트가 아니라 **문장**이에요.
# 그래서 기대값 자리에 $YES / $NO 를 씁니다.
#
#     YES = 스택이 두 개씩 연속입니다.
#     NO  = 스택이 두 개씩 연속이 아닙니다.
#
# ★ 값 적을 때 제일 조심할 곳 ★
# push 는 맨 앞에 꽂습니다. 그래서 **넣는 순서와 찍히는 순서가 반대**예요.
#
#     넣는 순서   4 5 10 11 15 16
#     찍히는 것   16 15 11 10 5 4      <- 문제지 예시의 그 스택
#
# 문제지 예시를 옮길 때는 예시의 스택을 뒤집어서 "넣는 순서" 칸에 적으셔야 합니다.
# 틀리면 FAIL 날 때 스택이 어떻게 찍혔는지 같이 보여주니 거기서 확인하세요.
#
# main 의 case 2 는 판정한 뒤 스택을 비웁니다. again 은 그걸 이용해서
# 빈 스택을 한 번 더 검사시켜 봅니다.

set -u
cd "$(dirname "$0")"

SRC=Q3_C_SQ.c
. ../common/testlib.sh

YES="스택이 두 개씩 연속입니다."
NO="스택이 두 개씩 연속이 아닙니다."

VERDICT='연속입니다\|연속이 아닙니다'

check() {                # check "넣는 순서" "기대 판정"
	local vals="$1" want="$2" inp got stack

	inp=$(menu "$vals" "2\n0\n")
	run "$inp"
	died "$vals" && return

	got=$(pick "$VERDICT" "$OUT")
	if judge "$vals" "판정" "$got" "$want"; then
		ok "$vals"
	else
		# 넣는 순서와 찍히는 순서가 반대라 헷갈리기 쉬워요. 실제 스택을 같이 보여줍니다.
		stack=$(pick "현재 스택" "$OUT" '$')
		printf '          그때 스택: [%s]\n' "$stack"
	fi

	vgcheck "$inp" "$vals"
}

again() {                # again "넣는 순서" "첫 번째 판정" "두 번째 판정"
	local vals="$1" want1="$2" want2="$3" inp got1 got2

	inp=$(menu "$vals" "2\n2\n0\n")
	run "$inp"
	died "2연속:$vals" && return

	got1=$(pick "$VERDICT" "$OUT" 1)
	got2=$(pick "$VERDICT" "$OUT" 2)

	if judge "2연속:$vals" "첫 번째" "$got1" "$want1" \
	   && judge "2연속:$vals" "두 번째" "$got2" "$want2"; then
		ok "2연속:$vals"
	fi

	vgcheck "$inp" "2연속:$vals"
}

echo "=== 문제지 예시 ==="
# 예시 1. 스택이 16 15 11 10 5 4 로 찍혀야 하니까 넣는 순서는 그 반대예요.
check "4 5 10 11 15 16" "$YES"
#
# 예시 2. 스택이 16 15 11 10 5 1 인 경우. 5·1 이 안 맞습니다.
# check "?" "$NO"
#
# 예시 3. 스택이 16 15 11 10 5 인 경우. 개수가 홀수라 짝이 안 맞습니다.
check "5 10 11 15 16" "$NO"

echo "=== 내가 만든 경계 케이스 ==="
# ? 자리를 채우고 앞의 # 을 지우면서 하나씩 돌려보세요.
#
# (1) 스택이 비어 있을 때. 문제지에 안 나와 있으니 먼저 정하셔야 합니다.
#     "0개는 짝이 다 맞은 것인가, 아닌가" — 정한 쪽을 여기 적고 구현을 거기 맞추세요.
 check "" "$NO"
#
# (2) 원소가 하나뿐일 때. 홀수라 짝이 안 맞습니다.
 check "7" "$NO"
#
# (3) 원소가 둘인데 연속일 때. 조건이 성립하는 가장 작은 입력이에요.
 check "1 2" "$YES"
#
# (4) 원소가 둘인데 연속이 아닐 때.
 check "5 7" "$NO"
#
# (5) 쌍의 순서가 반대일 때. 스택에서 먼저 나오는 값이 더 작은 경우예요.
#     "연속"이 방향을 따지는지 아닌지부터 정해야 기대값이 써집니다. 문제지 예시를 보세요.
 check "2 1" "$YES"
#
# (6) 두 값이 같을 때. 차이가 0 인데 이걸 연속으로 볼 것인지.
 check "5 5" "$NO"
#
# (7) 음수 쌍일 때. 뺄셈 방향을 잘못 잡으면 여기서 갈립니다.
 check "-1 -2" "$YES"
#
# (8) 첫 쌍은 맞는데 마지막 쌍이 틀릴 때. 중간에 멈추지 않고 끝까지 보는지 확인합니다.
check "1 2 4 4" "$NO"
#
# (9) 마지막 쌍은 맞는데 첫 쌍이 틀릴 때. (8) 과 방향이 반대예요.
 check "4 4 1 2" "$NO"

echo "=== 검사를 두 번 연속 ==="
# main 의 case 2 는 판정한 뒤 스택을 비웁니다. 그러니 두 번째 판정은
# 빈 스택에 대한 답이 나와야 하고, 그건 (1) 번에서 정한 것과 같아야 맞습니다.
 again "1 2 4 5" "$YES" "$NO"

summary
