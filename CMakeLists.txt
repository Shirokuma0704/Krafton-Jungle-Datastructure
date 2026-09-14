# CLion이 이 파일을 읽고 빌드 방법을 알아냅니다.
# 이 파일은 프로젝트 루트(Week4/)에 있어야 합니다. 하위 폴더에 두면 CLion이
# 프로젝트를 CMake 프로젝트로 인식하지 못하고, 파일 단위 임시 컴파일로 떨어집니다.
# 그러면 실행 파일이 소스 폴더 옆에 그대로 쌓입니다.
#
# 문제 파일마다 main()이 따로 있어서, 파일 하나당 실행 파일 하나를 만듭니다.
# 만들어진 실행 파일은 전부 cmake-build-debug/ 안으로 들어갑니다.
# 새 .c 파일을 추가했는데 목록에 안 보이면 CLion 오른쪽 위 "Reload CMake Project"를 누르면 됩니다.

cmake_minimum_required(VERSION 3.20)
project(Week4_C_DataStructures C)

set(CMAKE_C_STANDARD 11)

# 경고를 켜둡니다. C에서 조용히 넘어가면 나중에 런타임에 터지는 것들을
# 컴파일 단계에서 미리 보여줍니다. (초기화 안 한 변수, 리턴값 빠진 함수 등)
if (NOT MSVC)
    add_compile_options(-Wall -Wextra)
endif ()

# C_DataStructures 하위 폴더의 Q*.c 를 전부 찾아서 각각 독립 실행 파일로 등록
file(GLOB_RECURSE QUESTION_SOURCES CONFIGURE_DEPENDS
        "${CMAKE_CURRENT_SOURCE_DIR}/C_DataStructures/*/Q*.c")

foreach (SOURCE_FILE ${QUESTION_SOURCES})
    # C_DataStructures/Linked_List/Q1_A_LL.c  ->  타깃 이름 Q1_A_LL
    get_filename_component(TARGET_NAME ${SOURCE_FILE} NAME_WE)
    add_executable(${TARGET_NAME} ${SOURCE_FILE})
endforeach ()


# --- 검산기 .sh 를 CTest 로 등록합니다 -----------------------------------
# 이렇게 해두면 CLion 이 실행 구성을 알아서 만들어줘요. 셸 스크립트 구성을
# 손으로 만들면서 인터프리터 경로를 매번 고칠 필요가 없어집니다.
# (CLion 오른쪽 위 "Reload CMake Project" 를 한 번 눌러주면 목록에 뜹니다)
#
# 터미널에서 한꺼번에 돌리고 싶으시면:
#     ctest --test-dir cmake-build-debug --output-on-failure
#
# 스크립트가 하나라도 실패하면 종료 코드 1 로 끝나니까, CTest 가 빨간불을 켭니다.

find_program(BASH_EXECUTABLE
        NAMES bash bash.exe
        HINTS "C:/Program Files/Git/bin"
              "C:/Program Files/Git/usr/bin"
              "$ENV{LOCALAPPDATA}/Programs/Git/bin"
        DOC "검산기 .sh 를 돌릴 bash")

if (BASH_EXECUTABLE)
    enable_testing()

    file(GLOB TEST_SCRIPTS CONFIGURE_DEPENDS
            "${CMAKE_CURRENT_SOURCE_DIR}/C_DataStructures/*/q*test.sh")

    foreach (SCRIPT ${TEST_SCRIPTS})
        # C_DataStructures/Stack_and_Queue/q4test.sh  ->  Stack_and_Queue.q4test
        get_filename_component(SCRIPT_NAME ${SCRIPT} NAME_WE)
        get_filename_component(SCRIPT_DIR ${SCRIPT} DIRECTORY)
        get_filename_component(SECTION ${SCRIPT_DIR} NAME)

        add_test(NAME ${SECTION}.${SCRIPT_NAME}
                COMMAND "${BASH_EXECUTABLE}" "${SCRIPT}")
    endforeach ()
else ()
    message(STATUS "bash 를 못 찾아서 검산기를 CTest 에 안 걸었습니다. "
                   "Git for Windows 경로가 위 HINTS 와 다르면 한 줄 추가해주세요.")
endif ()
