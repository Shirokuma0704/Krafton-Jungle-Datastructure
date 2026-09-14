#!/usr/bin/env bash
# Q5 recursiveReverse 검산기
#
#   bash q5test.sh        기대값 대조만 (빠름)
#   bash q5test.sh -v     valgrind 까지 (WSL 에서만 됩니다)
#
#     check "큐에 넣을 값들" "뒤집은 기대값"
#     again "큐에 넣을 값들" "뒤집은 기대값" "한 번 더 눌렀을 때의 기대값"
#     deep  N                1..N 을 넣고 N..1 이 나오는지 본다
#
# 값은 공백으로 구분합니다. 빈 큐는 "" 를, 출력이 비어 있어야 하면 "$EMPTY" 를 씁니다.
#
# Q4 와 거의 같은 구조예요. 다른 점 두 가지만 기억하시면 됩니다.
#   - 값 넣을 때 찍히는 라벨이 "현재 큐" 가 아니라 "만들어진 큐" 입니다.
#   - 이 문제의 LinkedList 에는 tail 이 없어요. 그래서 Q4 의 andmore 는 뺐습니다.
#
# 재귀 문제라 잘못 짜면 스택이 넘쳐서 죽습니다. testlib 의 died() 가 SIGSEGV 와
# 시간 초과를 구분해서 표시하니, 어느 쪽으로 죽는지도 단서가 돼요 ( •̀ ω •́ )
#
# ※ 문제지 HTML 의 Q5 "여백 메모" 는 사실상 정답 코드입니다. 다 짜기 전에는
#    펼치지 마세요. 한 번 보면 되돌릴 수 없어요.

set -u
cd "$(dirname "$0")"

SRC=Q5_C_SQ.c
. ../common/testlib.sh

check() {                # check "값들" "뒤집은 기대값"
	local vals="$1" want="$2" inp got

	inp=$(menu "$vals" "2\n0\n")
	run "$inp"
	died "$vals" && return

	got=$(pick "뒤집은 큐" "$OUT")
	if judge "$vals" "재귀 뒤집기" "$got" "$want"; then
		ok "$vals"
	fi

	vgcheck "$inp" "$vals"
}

again() {                # again "값들" "뒤집은 기대값" "한 번 더 눌렀을 때"
	local vals="$1" want1="$2" want2="$3" inp got1 got2

	inp=$(menu "$vals" "2\n2\n0\n")
	run "$inp"
	died "2연속:$vals" && return

	got1=$(pick "뒤집은 큐" "$OUT" 1)
	got2=$(pick "뒤집은 큐" "$OUT" 2)

	if judge "2연속:$vals" "첫 번째" "$got1" "$want1" \
	   && judge "2연속:$vals" "두 번째" "$got2" "$want2"; then
		ok "2연속:$vals"
	fi

	vgcheck "$inp" "2연속:$vals"
}

deep() {                 # deep N   ->  1..N 을 넣고 N..1 이 나오는지 본다
	local n="$1" i asc="" desc="" inp got

	for i in $(seq 1 "$n");    do asc="$asc $i";   done
	for i in $(seq "$n" -1 1); do desc="$desc $i"; done
	asc="${asc# }"; desc="${desc# }"

	inp=$(menu "$asc" "2\n0\n")
	run "$inp"
	died "깊이 $n" && return

	# 값이 많아서 통째로 찍으면 화면을 덮어요. 앞뒤 몇 개만 보여줍니다.
	got=$(pick "뒤집은 큐" "$OUT")
	if [ "$got" = "$desc" ]; then
		ok "깊이 $n"
	else
		fail=$((fail+1))
		printf '  FAIL  [깊이 %d]\n' "$n"
		printf '          나온것 앞 5개: %s ...\n' "$(echo "$got"  | cut -d" " -f1-5)"
		printf '          기대값 앞 5개: %s ...\n' "$(echo "$desc" | cut -d" " -f1-5)"
		printf '          개수: 나온것 %d / 기대값 %d\n' \
			"$(echo "$got" | wc -w)" "$(echo "$desc" | wc -w)"
	fi
}

echo "=== 기본 ==="
# 문제지에 나온 예시 그대로예요.
check "1 2 3 4 5" "5 4 3 2 1"

echo "=== 내가 만든 경계 케이스 ==="
# ? 자리를 채우고 앞의 # 을 지우면서 하나씩 돌려보세요.
#
# (1) 큐가 비어 있을 때. 재귀가 첫 호출에서 바로 끝나야 합니다.
#     base case 를 안 넣었으면 여기서 끝없이 내려가다 죽어요.
# check "" "?"
#
# (2) 원소가 하나뿐일 때. 재귀가 딱 한 단계 들어갔다 나옵니다.
# check "7" "?"
#
# (3) 원소가 둘일 때. 뒤집기가 실제로 일어나는 가장 작은 입력이에요.
# check "1 2" "?"
#
# (4) 원소가 셋일 때. 가운데가 제자리에 남는지 봅니다.
# check "1 2 3" "?"
#
# (5) 값이 전부 같을 때. 순서가 바뀌었는지 값으로는 확인이 안 되는 경우예요.
#     그래도 개수는 유지돼야 합니다.
# check "4 4 4" "?"
#
# (6) 음수와 0 이 섞일 때.
# check "-1 0 -2" "?"
#
# (7) 원소가 열 개쯤일 때. 중간에서 순서가 어긋나지 않는지 봅니다.
# check "?" "?"

echo "=== 뒤집기를 두 번 연속 ==="
# main 의 case 2 는 출력한 뒤에 큐를 비웁니다. 그러니 두 번째로 2 를 눌렀을 때
# 재귀 함수가 받는 큐가 어떤 상태인지부터 정하고 기대값을 적으세요.
# 사실상 (1) 번을 한 번 더 확인하는 셈이라, 둘의 기대값이 이어져야 맞습니다.
# again "1 2 3" "?" "?"

echo "=== 재귀 깊이 ==="
# 스택 프레임이 몇 개까지 버티는지 봅니다. 숫자를 올려가며 확인해도 돼요.
# 죽으면 died() 가 "신호 11 (SIGSEGV)" 로 알려줍니다.
#
# 다만 이 문제의 enqueue 는 매번 리스트를 끝까지 걸어가서 붙습니다(tail 이 없어요).
# 그래서 넣는 것만으로도 O(n^2) 이라, 숫자를 크게 올리면 재귀가 아니라
# 시간 초과로 먼저 걸립니다. 그때는 LIMIT 을 올려서 구분하세요.
deep 100
# deep 1000

summary
