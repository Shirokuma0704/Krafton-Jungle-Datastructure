# 이진 탐색 트리 검산기용 도우미예요.
#
#     . ../common/bstinput.sh
#     bst_draw "20 15 50 10 18 25 80"
#
# 왜 따로 있냐면요.
#
# 이진 트리 문제들은 트리 모양을 직접 적어줬는데, 이진 탐색 트리는 다릅니다.
# **넣는 순서만 정하면 모양이 따라 정해져요.** 작으면 왼쪽, 크면 오른쪽이라는
# 규칙이 자리를 결정하니까요. 그래서 여기서는 트리가 아니라 **삽입 순서**를 적습니다.
#
#     20 15 50 10 18 25 80  을 순서대로 넣으면
#
#              20
#            /    \
#          15      50
#         /  \    /  \
#       10    18 25   80
#
# 같은 값을 여러 번 넣으면 insertBSTNode 가 두 번째부터 그냥 버립니다.
# 그래서 이 트리에는 중복이 안 생겨요.
#
# 순서가 바뀌면 모양이 통째로 바뀝니다. 오름차순으로만 넣으면 오른쪽으로만
# 뻗은 한 줄이 돼요. 그게 이 문제의 재미있는 자리입니다.

. "$(dirname "${BASH_SOURCE[0]}")/treeinput.sh"

# 넣는 순서를 받아서 만들어질 트리를 레벨 순서 한 줄로 돌려줍니다.
bst_to_lv() {            # bst_to_lv "20 15 50 10 18 25 80"
	local -a IN=($1)
	local n=${#IN[@]}
	[ "$n" -eq 0 ] && { printf 'x'; return; }

	local -a V L R
	local cnt=0 v cur

	for v in "${IN[@]}"; do
		case "$v" in ''|*[!0-9-]*) continue;; esac

		if [ "$cnt" -eq 0 ]; then
			V[0]="$v"; L[0]=-1; R[0]=-1; cnt=1
			continue
		fi

		# 작으면 왼쪽, 크면 오른쪽. 같으면 버립니다.
		cur=0
		while :; do
			if [ "$v" -lt "${V[$cur]}" ]; then
				if [ "${L[$cur]}" -lt 0 ]; then
					V[$cnt]="$v"; L[$cnt]=-1; R[$cnt]=-1
					L[$cur]=$cnt; cnt=$((cnt+1)); break
				fi
				cur=${L[$cur]}
			elif [ "$v" -gt "${V[$cur]}" ]; then
				if [ "${R[$cur]}" -lt 0 ]; then
					V[$cnt]="$v"; L[$cnt]=-1; R[$cnt]=-1
					R[$cur]=$cnt; cnt=$((cnt+1)); break
				fi
				cur=${R[$cur]}
			else
				break      # 이미 있는 값이면 아무것도 안 합니다
			fi
		done
	done

	[ "$cnt" -eq 0 ] && { printf 'x'; return; }

	local -a Q=(0)
	local qi=0 node out="${V[0]}"
	while [ "$qi" -lt "${#Q[@]}" ]; do
		node=${Q[$qi]}; qi=$((qi+1))
		if [ "${L[$node]}" -ge 0 ]; then out="$out ${V[${L[$node]}]}"; Q+=("${L[$node]}"); else out="$out x"; fi
		if [ "${R[$node]}" -ge 0 ]; then out="$out ${V[${R[$node]}]}"; Q+=("${R[$node]}"); else out="$out x"; fi
	done
	while [ "${out% x}" != "$out" ]; do out="${out% x}"; done

	printf '%s' "$out"
}

# 넣는 순서대로 만들어질 트리를 그려줍니다.
#
#   ※ 기대값을 먼저 손으로 적어보시고, 그다음에 이걸로 맞춰보세요.
#     먼저 그려버리면 "삽입 순서가 모양을 어떻게 바꾸는지" 를 못 배웁니다.
bst_draw() {             # bst_draw "20 15 50 10 18 25 80"
	tree_draw "$(bst_to_lv "$1")"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	bst_draw "$1"
fi
