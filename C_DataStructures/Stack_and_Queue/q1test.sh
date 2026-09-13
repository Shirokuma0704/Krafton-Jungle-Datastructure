#!/usr/bin/env bash
# Q1 createQueueFromLinkedList / removeOddValues 검산기
#
#   bash q1test.sh        기대값 대조만 (빠름)
#   bash q1test.sh -v     valgrind 까지 (WSL 에서만 됩니다)
#
#     check "리스트값들" "기대 큐" "홀수 뺀 기대 결과"
#     twice "리스트값들" "두 번째로 만든 큐의 기대값"
#
# 값은 공백으로 구분합니다. 빈 리스트는 "" 를, 출력이 비어 있어야 하면
# "$EMPTY" 를 씁니다.
#
# check 는 메뉴를 1..(값 넣기) → 2(큐 만들기) → 3(홀수 빼기) → 0 순서로 눌러줍니다.
# 두 함수를 한 번에 보기 때문에, 큐 만들기부터 틀렸으면 그 줄에서 먼저 걸립니다.
#
# twice 는 2 를 연속으로 두 번 누릅니다. createQueueFromLinkedList 가
# 이전 큐를 제대로 치우고 시작하는지 보려는 용도입니다.
#
# 이 문제는 while 조건을 잘못 걸면 무한 루프에 빠지면서 malloc 이 계속 쌓입니다.
# 그래서 케이스마다 시간 제한을 걸어두고, 넘기면 따로 표시합니다.

set -u
cd "$(dirname "$0")"

VG=0
[ "${1:-}" = "-v" ] && VG=1

LIMIT=5          # 한 케이스에 허용할 초. 무한 루프를 여기서 끊습니다.

# --- 어디서 돌리든 gcc 를 찾아냅니다 ------------------------------------
# WSL 이나 PATH 에 gcc 가 있으면 그걸 쓰고, 없으면 CLion 번들 MinGW 를 찾습니다.
find_gcc() {
	if command -v gcc >/dev/null 2>&1; then echo gcc; return 0; fi
	local c
	for c in "/c/Program Files/JetBrains/CLion"*/bin/mingw/bin/gcc.exe \
	         "$HOME/AppData/Local/Programs/CLion"*/bin/mingw/bin/gcc.exe \
	         "/c/Program Files/JetBrains/Toolbox/apps/CLion"*/bin/mingw/bin/gcc.exe; do
		[ -x "$c" ] && { echo "$c"; return 0; }
	done
	return 1
}

GCC=$(find_gcc) || {
	echo "gcc 를 못 찾았습니다."
	echo "  - WSL 에서 돌리시거나"
	echo "  - CLion 이 설치된 경로가 위 목록과 다르면 find_gcc 에 경로를 한 줄 추가하세요."
	exit 1
}

# Windows 에서는 실행 파일에 .exe 가 붙습니다.
EXE=""
case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) EXE=".exe";; esac

WORK=$(mktemp -d) || exit 1
trap 'rm -rf "$WORK"' EXIT
BIN="$WORK/q1test$EXE"

"$GCC" -g -Wall -Wextra -std=c11 \
	-Wno-unused-but-set-variable -Wno-unused-parameter \
	Q1_C_SQ.c -o "$BIN"
[ -x "$BIN" ] || { echo "컴파일 실패"; exit 1; }

if [ "$VG" = 1 ] && ! command -v valgrind >/dev/null 2>&1; then
	echo "valgrind 가 없습니다. 기대값 대조만 합니다. (valgrind 는 WSL 쪽에 있습니다)"
	VG=0
fi

EMPTY="비어 있음"
pass=0; fail=0; vgbad=0; hang=0

# 메뉴 입력 문자열을 만듭니다. 값들을 1 로 넣고, 뒤에 원하는 메뉴를 붙입니다.
menu() {                 # menu "값들" "뒤에 붙일 메뉴들"
	local vals="$1" tail="$2" inp="" x
	for x in $vals; do inp+="1\n$x\n"; done
	printf '%s' "$inp$tail"
}

# 출력에서 원하는 줄을 뽑습니다. 프롬프트가 같은 줄에 붙어 나오므로 잘라냅니다.
pick() {                 # pick "출력전체" "찾을라벨" [몇번째]
	echo "$2" | grep "$1" | sed -n "${3:-1}p" | sed 's/.*큐: //' | sed 's/[[:space:]]*$//'
}

run() {                  # run "메뉴입력"  ->  전역 OUT, RC 를 채웁니다
	OUT=$(printf "$1" | timeout -k 1 "$LIMIT" "$BIN" 2>/dev/null)
	RC=$?
}

# 시간 초과나 비정상 종료를 공통으로 처리합니다. 걸리면 1 을 돌려줍니다.
died() {                 # died "케이스이름"
	if [ "$RC" = 124 ]; then
		hang=$((hang+1)); fail=$((fail+1))
		printf '  멈춤  [%s]  %d초 안에 안 끝났습니다 (무한 루프 의심)\n' "$1" "$LIMIT"
		return 0
	elif [ "$RC" -ge 128 ]; then
		fail=$((fail+1))
		printf '  죽음  [%s]  신호 %d %s\n' "$1" "$((RC-128))" \
			"$([ "$RC" = 139 ] && echo '(SIGSEGV - 잘못된 주소)'; \
			   [ "$RC" = 134 ] && echo '(SIGABRT)')"
		return 0
	fi
	return 1
}

judge() {                # judge "케이스이름" "항목" "나온것" "기대값"
	if [ "$3" = "$4" ]; then
		return 0
	fi
	fail=$((fail+1))
	printf '  FAIL  [%s]  %s\n' "$1" "$2"
	printf '          나온것: [%s]\n' "$3"
	printf '          기대값: [%s]\n' "$4"
	return 1
}

check() {                # check "리스트값들" "기대 큐" "홀수 뺀 기대 결과"
	local vals="$1" wantq="$2" wanto="$3"
	local inp gotq goto vgout

	inp=$(menu "$vals" "2\n3\n0\n")
	run "$inp"
	died "$vals" && return

	gotq=$(pick "만들어진 큐" "$OUT")
	goto=$(pick "홀수를 뺀 큐" "$OUT")

	if judge "$vals" "큐 만들기" "$gotq" "$wantq" \
	   && judge "$vals" "홀수 빼기" "$goto" "$wanto"; then
		pass=$((pass+1)); printf '  OK    [%s]\n' "$vals"
	fi

	if [ "$VG" = 1 ]; then
		vgout=$(printf "$inp" | valgrind -q --leak-check=full \
			--errors-for-leak-kinds=definite "$BIN" 2>&1 >/dev/null)
		vgout=$(echo "$vgout" | grep -E -A2 \
			"Invalid read|Invalid write|Invalid free|Mismatched free|definitely lost|uninitialised")
		if [ -n "$vgout" ]; then
			vgbad=$((vgbad+1))
			printf '          valgrind:\n'
			echo "$vgout" | head -8 | sed 's/^/            /'
		fi
	fi
}

twice() {                # twice "리스트값들" "두 번째로 만든 큐의 기대값"
	local vals="$1" want="$2" inp got

	inp=$(menu "$vals" "2\n2\n0\n")
	run "$inp"
	died "2연속:$vals" && return

	got=$(pick "만들어진 큐" "$OUT" 2)
	if judge "2연속:$vals" "두 번째 큐" "$got" "$want"; then
		pass=$((pass+1)); printf '  OK    [2연속:%s]\n' "$vals"
	fi
}

echo "=== 기본 ==="
check "2 4 5 6" "2 4 5 6" "2 4 6"
check "1 1 3"   "1 1 3"   "$EMPTY"

echo "=== 내가 만든 경계 케이스 ==="
# ? 자리를 채우고 앞의 # 을 지우면서 하나씩 돌려보세요.
#
# (1) 리스트가 비어 있을 때. 큐 만들기와 홀수 빼기가 둘 다 빈 것을 받습니다.
# check "" "?" "?"
#
# (2) 원소가 하나뿐인데 그게 짝수일 때. 아무것도 안 빠져야 합니다.
# check "2" "?" "?"
#
# (3) 원소가 하나뿐인데 그게 홀수일 때. 큐가 텅 비게 됩니다.
# check "3" "?" "?"
#
# (4) 전부 짝수일 때. 한 바퀴 다 돌고 나서 순서가 그대로인지가 핵심입니다.
# check "2 4 6 8" "?" "?"
#
# (5) 전부 홀수일 때. 큐를 비우고 나서도 루프가 남은 횟수를 마저 도는 자리입니다.
# check "1 3 5 7" "?" "?"
#
# (6) 짝수가 맨 앞에만 하나 있을 때. 살아남은 원소가 앞으로 돌아와야 합니다.
# check "2 1 3 5" "?" "?"
#
# (7) 짝수가 맨 뒤에만 하나 있을 때. (6) 과 방향이 반대입니다.
# check "1 3 5 2" "?" "?"
#
# (8) 0 이 섞여 있을 때. 0 을 짝수로 보는지 확인합니다.
# check "0 1 2" "?" "?"
#
# (9) 음수 홀수가 섞여 있을 때. C 에서 -3 % 2 가 무엇인지 먼저 생각해보세요.
# check "-2 -3 -4 -5" "?" "?"
#
# (10) 같은 값이 여러 번 나올 때. 하나만 지우고 마는지 봅니다.
# check "3 3 4 3" "?" "?"

echo "=== 큐 만들기를 두 번 연속 ==="
# 2 를 눌러 큐를 만든 뒤, 곧바로 2 를 한 번 더 누릅니다.
# 두 번째 시점에 연결 리스트가 어떤 상태인지부터 정하고, 그러면 큐가
# 어떻게 되어야 맞는지를 정해서 적으세요. 정답이 하나가 아닙니다.
# twice "2 4 6" "?"

echo
printf '  통과 %d / 실패 %d' "$pass" "$fail"
[ "$hang" -gt 0 ] && printf ' (그중 멈춤 %d)' "$hang"
[ "$VG" = 1 ] && printf ' / valgrind 문제 %d' "$vgbad"
echo
[ "$fail" -eq 0 ] && { [ "$VG" = 0 ] || [ "$vgbad" -eq 0 ]; }
