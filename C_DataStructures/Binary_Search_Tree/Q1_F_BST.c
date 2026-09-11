
//////////////////////////////////////////////////////////////////////////////////

/* CE1007/CZ1007 자료구조
실습 시험: F 섹션 - 이진 탐색 트리 문제
목적: 1번 문제에 필요한 함수 구현하기 */

//////////////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <stdlib.h>

#define BUFFER_SIZE 1024
///////////////////////////////////////////////////////////////////////////////////

typedef struct _bstnode{
	int item;
	struct _bstnode *left;
	struct _bstnode *right;
} BSTNode;   // BSTNode 의 정의는 바꾸지 마세요

typedef struct _QueueNode {
	BSTNode *data;
	struct _QueueNode *nextPtr;
}QueueNode; // QueueNode 의 정의는 바꾸지 마세요


typedef struct _queue
{
	QueueNode *head;
	QueueNode *tail;
}Queue; // queue 의 정의는 바꾸지 마세요

///////////////////////////////////////////////////////////////////////////////////

// 이 함수들의 원형(prototype)은 바꾸지 마세요
void levelOrderTraversal(BSTNode *node);

void insertBSTNode(BSTNode **node, int value);

BSTNode* dequeue(QueueNode **head, QueueNode **tail);
void enqueue(QueueNode **head, QueueNode **tail, BSTNode *node);
int isEmpty(QueueNode *head);
void removeAll(BSTNode **node);

///////////////////////////// main() /////////////////////////////////////////////

int main()
{
	int c, i;
	c = 1;

	//이진 탐색 트리를 빈 트리로 초기화한다
	BSTNode *root;
	root = NULL;

	printf("1: 이진 탐색 트리에 정수 넣기;\n");
	printf("2: 이진 탐색 트리 레벨 순회 출력;\n");
	printf("0: 종료;\n");


	while (c != 0)
	{
		printf("원하는 번호를 입력하세요(1/2/0): ");
		scanf("%d", &c);

		switch (c)
		{
		case 1:
			printf("이진 탐색 트리에 넣을 정수를 입력하세요: ");
			scanf("%d", &i);
			insertBSTNode(&root, i);
			break;
		case 2:
			printf("이진 탐색 트리 레벨 순회 결과: ");
			levelOrderTraversal(root); // 이 함수를 직접 작성해야 합니다
			printf("\n");
			break;
		case 0:
			removeAll(&root);
			break;
		default:
			printf("알 수 없는 선택입니다;\n");
			break;
		}

	}

	return 0;
}

//////////////////////////////////////////////////////////////////////////////////

void levelOrderTraversal(BSTNode* root)
{

    /* 여기에 코드를 작성하세요 */
}

///////////////////////////////////////////////////////////////////////////////

void insertBSTNode(BSTNode **node, int value){
	if (*node == NULL)
	{
		*node = malloc(sizeof(BSTNode));

		if (*node != NULL) {
			(*node)->item = value;
			(*node)->left = NULL;
			(*node)->right = NULL;
		}
	}
	else
	{
		if (value < (*node)->item)
		{
			insertBSTNode(&((*node)->left), value);
		}
		else if (value >(*node)->item)
		{
			insertBSTNode(&((*node)->right), value);
		}
		else
			return;
	}
}

//////////////////////////////////////////////////////////////////////////////////

// 노드를 큐에 넣는다
void enqueue(QueueNode **headPtr, QueueNode **tailPtr, BSTNode *node)
{
	// 메모리를 동적 할당한다
	QueueNode *newPtr = malloc(sizeof(QueueNode));

	// newPtr 이 NULL 이 아니면
	if (newPtr != NULL) {
		newPtr->data = node;
		newPtr->nextPtr = NULL;

		// 큐가 비어 있으면 head 자리에 넣는다
		if (isEmpty(*headPtr)) {
			*headPtr = newPtr;
		}
		else { // 꼬리에 넣는다
			(*tailPtr)->nextPtr = newPtr;
		}

		*tailPtr = newPtr;
	}
	else {
		printf("노드가 삽입되지 않았습니다");
	}
}

BSTNode* dequeue(QueueNode **headPtr, QueueNode **tailPtr)
{
	BSTNode *node = (*headPtr)->data;
	QueueNode *tempPtr = *headPtr;
	*headPtr = (*headPtr)->nextPtr;

	if (*headPtr == NULL) {
		*tailPtr = NULL;
	}

	free(tempPtr);

	return node;
}

int isEmpty(QueueNode *head)
{
	return head == NULL;
}

void removeAll(BSTNode **node)
{
	if (*node != NULL)
	{
		removeAll(&((*node)->left));
		removeAll(&((*node)->right));
		free(*node);
		*node = NULL;
	}
}
