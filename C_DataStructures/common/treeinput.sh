# 이진 트리 검산기에서 트리를 "그림에 가깝게" 적기 위한 변환기예요.
#
#     . ../common/treeinput.sh
#     lv_to_preorder "4 2 6 1 3 5 7"
#     -> 4 2 6 1 3 x x x x 5 7 x x x x
#
# 왜 있냐면요.
#
# createTree() 는 값을 **스택에서 꺼낸 순서**로 물어봅니다. 그래서 트리를 그대로
# 적으려면 머릿속에서 push/pop 을 따라가야 하고, 잎 노드마다 "자식 없음" 두 개를
# 빠뜨리지 않고 적어야 해요. 그림은 1초면 그려지는데 그걸 받아적는 데 1분이 걸립니다.
# 게다가 하나만 어긋나면 뒤가 통째로 밀려서 엉뚱한 트리가 조용히 만들어져요.
#
# 그래서 **위에서 아래로, 왼쪽에서 오른쪽으로** 읽는 순서로 적게 했습니다.
# LeetCode 가 트리를 적는 방식과 같아요.
#
#          4              적는 법:  4 2 6 1 3 5 7
#         / \                       └┘ └─┘ └─────┘
#        2   6                      1층  2층    3층
#       / \ / \
#      1  3 5  7
#
# 자리가 비었으면 그 자리에 문자를 하나 넣습니다. 보통 x 를 씁니다.
#
#          1              적는 법:  1 x 2
#           \                       루트에 왼쪽 자식이 없으니 x
#            2
#
# **뒤쪽의 빈 자리는 안 적어도 됩니다.** 잎 노드의 자식들은 알아서 채워져요.
# 이게 손으로 적을 때 제일 크게 줄어드는 부분입니다.

# 레벨 순서로 적은 트리를 createTree 가 묻는 순서로 바꿔줍니다.
lv_to_preorder() {       # lv_to_preorder "4 2 6 1 3 5 7"
	local -a LO=($1)
	local n=${#LO[@]}

	# 비었거나 루트 자리가 문자면 빈 트리예요. 문자 하나만 넘기면 됩니다.
	[ "$n" -eq 0 ] && { printf 'x'; return; }
	case "${LO[0]}" in ''|*[!0-9-]*) printf 'x'; return;; esac

	# 노드 표를 만듭니다. 자식이 없으면 -1 이에요.
	local -a val left right
	val[0]=${LO[0]}; left[0]=-1; right[0]=-1

	local cnt=1 i=1 q=0 t
	while [ "$q" -lt "$cnt" ] && [ "$i" -lt "$n" ]; do
		if [ "$i" -lt "$n" ]; then
			t=${LO[$i]}; i=$((i+1))
			case "$t" in ''|*[!0-9-]*) ;; *)
				val[$cnt]=$t; left[$cnt]=-1; right[$cnt]=-1
				left[$q]=$cnt; cnt=$((cnt+1));;
			esac
		fi
		if [ "$i" -lt "$n" ]; then
			t=${LO[$i]}; i=$((i+1))
			case "$t" in ''|*[!0-9-]*) ;; *)
				val[$cnt]=$t; left[$cnt]=-1; right[$cnt]=-1
				right[$q]=$cnt; cnt=$((cnt+1));;
			esac
		fi
		q=$((q+1))
	done

	# 안 쓰인 값이 남았다면 알려줍니다. 부모가 x 인 자리에 자식을 적으면
	# 그 값은 붙을 데가 없어서 조용히 버려지거든요. 예) "1 x x 5" 의 5
	if [ "$i" -lt "$n" ]; then
		printf '  주의  [%s]  뒤쪽 값 %d개가 붙을 자리가 없어서 버려졌어요.\n' \
			"$1" "$((n - i))" >&2
		printf '          x 자리에는 자식을 달 수 없습니다.\n' >&2
	fi

	# 이제 createTree 와 똑같은 순서로 뱉습니다. 루트를 먼저 주고, 스택에서
	# 꺼낸 노드마다 왼쪽·오른쪽을 주고, 오른쪽·왼쪽 순으로 다시 쌓아요.
	local out="${val[0]}" top=0 node l r
	local -a stk=(0)
	while [ "$top" -ge 0 ]; do
		node=${stk[$top]}; top=$((top-1))
		l=${left[$node]}; r=${right[$node]}

		if [ "$l" -ge 0 ]; then out="$out ${val[$l]}"; else out="$out x"; fi
		if [ "$r" -ge 0 ]; then out="$out ${val[$r]}"; else out="$out x"; fi

		if [ "$r" -ge 0 ]; then top=$((top+1)); stk[$top]=$r; fi
		if [ "$l" -ge 0 ]; then top=$((top+1)); stk[$top]=$l; fi
	done

	printf '%s' "$out"
}
