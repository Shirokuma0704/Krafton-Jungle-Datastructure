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
