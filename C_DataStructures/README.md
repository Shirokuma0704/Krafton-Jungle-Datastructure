# C 자료구조 문제 (KRAFTON Jungle / NTU CE1007)

출처: https://github.com/krafton-jungle/Data-Structures

각 폴더 안에 문제지 PDF가 같이 들어있어요. 코드보다 PDF를 먼저 읽는 게 순서입니다.

## 이 파일들이 어떻게 생겼냐면

한 파일이 문제 하나이고, 파일마다 `main()`이 따로 있어요. 그래서 실행 파일도 27개가 따로 만들어집니다.

파일 안에서 내가 채울 곳은 딱 여기입니다:

```c
int insertSortedLL(LinkedList *ll, int item)
{
    /* add your code here */
}
```

`printList`, `findNode`, `push`, `pop`, `removeAll` 같은 기본 동작은 **이미 다 짜여 있어요.**
그건 건드리지 말고 가져다 쓰면 됩니다. `main()`도 이미 대화형 메뉴로 만들어져 있어서,
빌드하고 실행하면 숫자를 입력하면서 직접 테스트할 수 있어요.

프로토타입(함수 이름·인자·리턴 타입)은 바꾸지 말라고 파일마다 적혀 있습니다.
채점이나 비교가 그 시그니처 기준이라 그래요.

## CLion에서 여는 방법

이 `C_DataStructures` 폴더를 **폴더째로** CLion에서 열면 됩니다.
(상위 `week4`나 저장소 루트 말고 여기를 열어야 `CMakeLists.txt`를 찾아요.)

열면 CLion이 `CMakeLists.txt`를 읽고 27개 타깃을 전부 등록합니다.
오른쪽 위 실행 설정 드롭다운에서 `Q1_A_LL` 처럼 문제 이름을 고르고 실행하면 그 문제만 돌아가요.

빌드 산출물은 `cmake-build-debug/`에 쌓이는데 `.gitignore`에 넣어놨습니다.

## 개발 환경 (WSL2 + Ubuntu 22.04)

발제문이 `Ubuntu 22.04 LTS (x86_64) 이상`을 요구해서 WSL2에 우분투를 올려두고 씁니다.
Windows용 MinGW로도 빌드는 되지만 `valgrind`가 없고, MinGW와 glibc는 해제한 메모리를
재사용하는 방식이 달라서 Windows에서 멀쩡하던 게 우분투에서 터지는 일이 있어요.

설치되어 있는 것: `gcc 11.4` / `gdb 12.1` / `valgrind 3.18.1` / `cmake 3.22.1`

우분투 셸로 들어가려면:

```bash
wsl -d Ubuntu-22.04
```

## 메모리 검사 (valgrind)

이번 과제의 핵심이 `malloc` / `free`라서 이게 제일 중요한 도구입니다.
`free` 빠뜨린 곳, 이미 해제한 메모리를 다시 건드린 곳, 초기화 안 하고 읽은 값을
**줄 번호까지 찍어서** 알려줘요. 눈으로 코드를 읽어서는 안 보이는 것들입니다.

CLion에서는 실행 버튼 옆 드롭다운의 `Run with Valgrind Memcheck`를 누르면 되고,
터미널에서 직접 돌리려면:

```bash
valgrind --leak-check=full ./Q1_A_LL
```

끝에 이렇게 나오면 통과입니다:

```
All heap blocks were freed -- no leaks are possible
ERROR SUMMARY: 0 errors from 0 contexts
```

## 순서

원본 저장소가 추천하는 순서예요. 뒤로 갈수록 앞의 것을 재료로 씁니다.

`Linked_List` → `Stack_and_Queue` → `Binary_Tree` → `Binary_Search_Tree`

## 진행 체크리스트

### Linked_List (7문제)

| 파일 | 구현할 함수 | 완료 |
|---|---|---|
| Q1_A_LL.c | `insertSortedLL` | |
| Q2_A_LL.c | `alternateMergeLinkedList` | |
| Q3_A_LL.c | `moveOddItemsToBack` | |
| Q4_A_LL.c | `moveEvenItemsToBack` | |
| Q5_A_LL.c | `frontBackSplitLinkedList` | |
| Q6_A_LL.c | `moveMaxToFront` | |
| Q7_A_LL.c | `RecursiveReverse` | |

### Stack_and_Queue (7문제)

| 파일 | 구현할 함수 | 완료 |
|---|---|---|
| Q1_C_SQ.c | `createQueueFromLinkedList`, `removeOddValues` | |
| Q2_C_SQ.c | `createStackFromLinkedList`, `removeEvenValues` | |
| Q3_C_SQ.c | `isStackPairwiseConsecutive` | |
| Q4_C_SQ.c | `reverse` | |
| Q5_C_SQ.c | `recursiveReverse` | |
| Q6_C_SQ.c | `removeUntil` | |
| Q7_C_SQ.c | `balanced` | |

### Binary_Tree (8문제)

| 파일 | 구현할 함수 | 완료 |
|---|---|---|
| Q1_E_BT.c | `identical` | |
| Q2_E_BT.c | `maxHeight` | |
| Q3_E_BT.c | `countOneChildNodes` | |
| Q4_E_BT.c | `sumOfOddNodes` | |
| Q5_E_BT.c | `mirrorTree` | |
| Q6_E_BT.c | `printSmallerValues` | |
| Q7_E_BT.c | `smallestValue` | |
| Q8_E_BT.c | `hasGreatGrandchild` | |

### Binary_Search_Tree (5문제)

| 파일 | 구현할 함수 | 완료 |
|---|---|---|
| Q1_F_BST.c | `levelOrderTraversal` | |
| Q2_F_BST.c | `inOrderTraversal` | |
| Q3_F_BST.c | `preOrderIterative` | |
| Q4_F_BST.c | `postOrderIterativeS1` | |
| Q5_F_BST.c | `postOrderIterativeS2` (+ 보조 함수 하나) | |
