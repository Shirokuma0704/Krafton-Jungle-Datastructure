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

# 레벨 순서로 적은 트리를 중위 순회한 결과로 바꿔줍니다.
# printTree() 가 중위 순회라, 프로그램이 찍어낼 줄과 바로 맞대볼 수 있어요.
#
#     lv_to_inorder "4 2 6 1 3 5 7"   ->   1 2 3 4 5 6 7
#
# 덕분에 검산기에서 기대값도 트리로 적을 수 있습니다. 입력 칸과 기대값 칸이
# 같은 언어가 되니까, 한쪽은 트리고 한쪽은 출력 문자열이라 헷갈릴 일이 없어요.
lv_to_inorder() {        # lv_to_inorder "4 2 6 1 3 5 7"
	local -a LO=($(_norm_spec "$1"))
	local n=${#LO[@]}

	[ "$n" -eq 0 ] && return
	case "${LO[0]}" in ''|*[!0-9-]*) return;; esac

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

	# 왼쪽 끝까지 내려갔다가, 꺼내서 찍고, 오른쪽으로 한 발. 그걸 반복해요.
	local -a stk
	local top=-1 node=0 out="" first=1
	while [ "$top" -ge 0 ] || [ "$node" -ge 0 ]; do
		while [ "$node" -ge 0 ]; do
			top=$((top+1)); stk[$top]=$node
			node=${left[$node]}
		done
		node=${stk[$top]}; top=$((top-1))
		if [ "$first" = 1 ]; then out="${val[$node]}"; first=0
		else out="$out ${val[$node]}"; fi
		node=${right[$node]}
	done

	printf '%s' "$out"
}


# 레벨 순서로 적은 트리를 createTree 가 묻는 순서로 바꿔줍니다.
lv_to_preorder() {       # lv_to_preorder "4 2 6 1 3 5 7"
	local -a LO=($(_norm_spec "$1"))
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


############################################################################
# 깊은 트리를 적는 두 번째 방법: 그림을 그대로 들여쓰기로 적기
############################################################################
#
# 레벨 순서는 넓고 꽉 찬 트리에 좋은데, 깊고 듬성듬성한 트리에서는 x 를 몇 개
# 넣어야 하는지 세는 게 일이 됩니다. 그래서 **보이는 대로 적는** 방법을 하나 더
# 뒀어요. 줄바꿈이 들어 있으면 검산기가 알아서 이쪽으로 읽습니다.
#
#     1                      1
#     ├─L 2                  ├ 왼쪽 자식이 2
#     │  └─L 4               │ 그 밑에 또 왼쪽으로 4
#     │     └─L 7            │
#     └─R 3                  └ 오른쪽 자식이 3
#        └─R 6
#
# 적을 때는 이렇게 씁니다. 들여쓰기가 부모 자식 관계이고, L / R 로 어느 쪽인지
# 말해줍니다. 없는 자식은 그냥 안 적으면 돼요. x 를 셀 필요가 없습니다.
#
#     check "이름" "
#     1
#       L 2
#         L 4
#           L 7
#         R 5
#       R 3
#     " "1"
#
# L / R 을 빼면 적은 순서대로 왼쪽, 오른쪽이 됩니다. 한쪽만 있을 때는 L 이나 R 을
# 꼭 붙여주세요. 안 붙이면 왼쪽으로 갑니다.
#
# 트리가 맞게 적혔는지 보고 싶으면 이렇게 그려볼 수 있어요.
#
#     bash ../common/treeinput.sh "50 30 60 25 65 10 75 x x 20 15"

# 들여쓴 그림을 레벨 순서 한 줄로 바꿉니다.
indent_to_lv() {
	local raw line ind val side expanded stripped p target
	local -a V L R NX SI SN
	local cnt=0 top=-1

	while IFS= read -r raw; do
		[ -z "${raw//[$' \t\r']/}" ] && continue

		expanded="${raw//$'\t'/    }"
		expanded="${expanded%$'\r'}"
		stripped="${expanded#"${expanded%%[! ]*}"}"
		ind=$(( ${#expanded} - ${#stripped} ))

		# 그림 문자로 그린 걸 그대로 붙여넣어도 읽히게 털어냅니다.
		stripped="${stripped//[│├└─]/ }"
		stripped="${stripped#"${stripped%%[! ]*}"}"

		# L / R 마커는 붙여 써도 되고 띄어 써도 됩니다. L2 도 되고 L 2 도 돼요.
		# 값은 정수라 L 이나 R 로 시작할 일이 없으니 첫 글자만 보면 됩니다.
		side=""
		case "$stripped" in
			[Ll]*) side=L; val="${stripped#?}";;
			[Rr]*) side=R; val="${stripped#?}";;
			*)     val="$stripped";;
		esac
		val="${val#"${val%%[! ]*}"}"
		val="${val%%[ $'\t']*}"
		[ -z "$val" ] && continue

		while [ "$top" -ge 0 ] && [ "${SI[$top]}" -ge "$ind" ]; do top=$((top-1)); done

		if [ "$top" -ge 0 ]; then
			p=${SN[$top]}
			if   [ "$side" = L ]; then target=L; NX[$p]=1
			elif [ "$side" = R ]; then target=R; NX[$p]=2
			elif [ "${NX[$p]:-0}" -eq 0 ]; then target=L; NX[$p]=1
			else target=R; NX[$p]=2
			fi
		else
			target=ROOT
		fi

		# 정수가 아니면 그 자리를 비워두는 표시로 봅니다. 자리만 먹고 노드는 안 생겨요.
		case "$val" in ''|*[!0-9-]*)
			[ "$target" = ROOT ] && { printf 'x'; return; }
			continue;;
		esac

		V[$cnt]="$val"; L[$cnt]=-1; R[$cnt]=-1; NX[$cnt]=0
		case "$target" in
			L) L[$p]=$cnt;;
			R) R[$p]=$cnt;;
		esac

		top=$((top+1)); SI[$top]=$ind; SN[$top]=$cnt
		cnt=$((cnt+1))
	done <<< "$1"

	[ "$cnt" -eq 0 ] && { printf 'x'; return; }

	# 위에서 아래로 훑으면서 레벨 순서로 펴냅니다.
	local -a Q=(0)
	local qi=0 n out="${V[0]}"
	while [ "$qi" -lt "${#Q[@]}" ]; do
		n=${Q[$qi]}; qi=$((qi+1))
		if [ "${L[$n]}" -ge 0 ]; then out="$out ${V[${L[$n]}]}"; Q+=("${L[$n]}"); else out="$out x"; fi
		if [ "${R[$n]}" -ge 0 ]; then out="$out ${V[${R[$n]}]}"; Q+=("${R[$n]}"); else out="$out x"; fi
	done
	while [ "${out% x}" != "$out" ]; do out="${out% x}"; done

	printf '%s' "$out"
}

# 어느 형식으로 적었든 레벨 순서 한 줄로 맞춰줍니다.
_norm_spec() {
	case "$1" in
		*$'\n'*) indent_to_lv "$1";;
		*)       printf '%s' "$1";;
	esac
}

# 적은 트리가 맞는지 눈으로 보려고 그려줍니다.
_td_rec() {
	local n=$1 prefix="$2" conn="$3" tag="$4" l r cp
	[ "$n" -lt 0 ] && return
	printf '%s%s%s%s\n' "$prefix" "$conn" "$tag" "${_TDV[$n]}"

	cp="$prefix"
	if [ -n "$conn" ]; then
		if [ "$conn" = "└─" ]; then cp="$prefix   "; else cp="$prefix│  "; fi
	fi

	l=${_TDL[$n]}; r=${_TDR[$n]}
	if [ "$l" -ge 0 ] && [ "$r" -ge 0 ]; then
		_td_rec "$l" "$cp" "├─" "L "
		_td_rec "$r" "$cp" "└─" "R "
	elif [ "$l" -ge 0 ]; then
		_td_rec "$l" "$cp" "└─" "L "
	elif [ "$r" -ge 0 ]; then
		_td_rec "$r" "$cp" "└─" "R "
	fi
}

tree_draw() {            # tree_draw "50 30 60 25 65 10 75 x x 20 15"
	local spec; spec=$(_norm_spec "$1")
	local -a LO=($spec)
	local n=${#LO[@]}

	[ "$n" -eq 0 ] && { echo "(빈 트리)"; return; }
	case "${LO[0]}" in ''|*[!0-9-]*) echo "(빈 트리)"; return;; esac

	_TDV=(); _TDL=(); _TDR=()
	_TDV[0]=${LO[0]}; _TDL[0]=-1; _TDR[0]=-1

	local cnt=1 i=1 q=0 t
	while [ "$q" -lt "$cnt" ] && [ "$i" -lt "$n" ]; do
		if [ "$i" -lt "$n" ]; then
			t=${LO[$i]}; i=$((i+1))
			case "$t" in ''|*[!0-9-]*) ;; *)
				_TDV[$cnt]=$t; _TDL[$cnt]=-1; _TDR[$cnt]=-1
				_TDL[$q]=$cnt; cnt=$((cnt+1));;
			esac
		fi
		if [ "$i" -lt "$n" ]; then
			t=${LO[$i]}; i=$((i+1))
			case "$t" in ''|*[!0-9-]*) ;; *)
				_TDV[$cnt]=$t; _TDL[$cnt]=-1; _TDR[$cnt]=-1
				_TDR[$q]=$cnt; cnt=$((cnt+1));;
			esac
		fi
		q=$((q+1))
	done

	_td_rec 0 "" "" ""
	printf '\n레벨 순서로 적으면:  %s\n' "$spec"
}

# 직접 실행하면 그려만 줍니다.  bash treeinput.sh "1 2 3"
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	tree_draw "$1"
fi
