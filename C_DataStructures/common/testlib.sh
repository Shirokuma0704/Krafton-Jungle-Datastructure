# 검산기 공용 도구예요. 문제별 스크립트에서 이렇게 불러 씁니다.
#
#     #!/usr/bin/env bash
#     set -u
#     cd "$(dirname "$0")"
#     SRC=Q4_C_SQ.c
#     . ../common/testlib.sh
#
#     check() { ... }          # 이 문제의 메뉴를 어떻게 누를지
#     check "1 2 3" "3 2 1"    # 케이스들
#     summary
#
# 여기 들어온 건 "어느 문제든 똑같은 것"들만이에요.
# gcc 찾기, 컴파일, stdin 흘려넣기, 타임아웃, 출력 비교, valgrind, 집계요.
#
# 안 들어온 건 두 가지예요. 메뉴를 어떤 순서로 누를지, 그리고 기대값이 뭔지.
# 그 둘은 문제마다 다르고, 무엇보다 그걸 정하는 게 연습이라서요 ( ᵕ—ᴗ—)

# --- 설정 ---------------------------------------------------------------
: "${SRC:?SRC 에 소스 파일 이름을 먼저 넣어주세요. 예) SRC=Q4_C_SQ.c}"
: "${LIMIT:=5}"          # 한 케이스에 허용할 초. 무한 루프를 여기서 끊습니다.

EMPTY="비어 있음"        # 출력이 비어 있어야 할 때 기대값 자리에 쓰세요.

VG=0
[ "${1:-}" = "-v" ] && VG=1

pass=0; fail=0; vgbad=0; hang=0
OUT=""; RC=0

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
	echo "  - CLion 설치 경로가 위 목록과 다르면 find_gcc 에 한 줄 추가하세요."
	exit 1
}

# Windows 에서는 실행 파일에 .exe 가 붙습니다.
EXE=""
case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) EXE=".exe";; esac

WORK=$(mktemp -d) || exit 1
trap 'rm -rf "$WORK"' EXIT
BIN="$WORK/test$EXE"

"$GCC" -g -Wall -Wextra -std=c11 \
	-Wno-unused-but-set-variable -Wno-unused-parameter \
	"$SRC" -o "$BIN"
[ -x "$BIN" ] || { echo "컴파일 실패"; exit 1; }

if [ "$VG" = 1 ] && ! command -v valgrind >/dev/null 2>&1; then
	echo "valgrind 가 없습니다. 기대값 대조만 합니다. (valgrind 는 WSL 쪽에 있습니다)"
	VG=0
fi

# --- 프로그램을 두드리는 도구들 -----------------------------------------

# 메뉴 입력 문자열을 만듭니다. 값들을 1 로 하나씩 넣고, 뒤에 원하는 메뉴를 붙여요.
menu() {                 # menu "값들" "뒤에 붙일 메뉴들"
	local vals="$1" tail="$2" inp="" x
	for x in $vals; do inp+="1\n$x\n"; done
	printf '%s' "$inp$tail"
}

# 출력에서 원하는 줄을 뽑습니다. 프롬프트가 같은 줄에 붙어 나오니까
# 마지막 ": " 까지를 잘라냅니다. 그래서 "만들어진 큐: 1 2 3" 도,
# "스택이 두 개씩 연속입니다." 같은 문장도 같은 방식으로 뽑혀요.
pick() {                 # pick "찾을라벨" "출력전체" [몇번째]
	# LC_ALL=C 로 묶어둔 이유가 있어요. WSL 의 C.UTF-8 로케일에서 GNU sed 4.8 은
	# 줄이 한글로 시작하면 "^.*" 를 매치하지 못합니다. 그러면 아무것도 안 잘려서
	# 프롬프트가 통째로 남아요. 바이트 단위로 보게 하면 멀쩡히 동작합니다.
	# 자르는 기준인 ": " 가 ASCII 라서 바이트로 봐도 안전하고요.
	( export LC_ALL=C
	  echo "$2" | grep "$1" | sed -n "${3:-1}p" | sed 's/^.*: //' | sed 's/[[:space:]]*$//' )
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

ok() {                   # ok "케이스이름"
	pass=$((pass+1)); printf '  OK    [%s]\n' "$1"
}

# 같은 입력을 valgrind 로 한 번 더 돌립니다. -v 를 줬을 때만 동작해요.
vgcheck() {              # vgcheck "메뉴입력" "케이스이름"
	[ "$VG" = 1 ] || return 0
	local vgout
	vgout=$(printf "$1" | valgrind -q --leak-check=full \
		--errors-for-leak-kinds=definite "$BIN" 2>&1 >/dev/null)
	vgout=$(echo "$vgout" | grep -E -A2 \
		"Invalid read|Invalid write|Invalid free|Mismatched free|definitely lost|uninitialised")
	if [ -n "$vgout" ]; then
		vgbad=$((vgbad+1))
		printf '          valgrind [%s]:\n' "$2"
		echo "$vgout" | head -8 | sed 's/^/            /'
	fi
}

summary() {
	echo
	printf '  통과 %d / 실패 %d' "$pass" "$fail"
	[ "$hang" -gt 0 ] && printf ' (그중 멈춤 %d)' "$hang"
	[ "$VG" = 1 ] && printf ' / valgrind 문제 %d' "$vgbad"
	echo
	[ "$fail" -eq 0 ] && { [ "$VG" = 0 ] || [ "$vgbad" -eq 0 ]; }
}
