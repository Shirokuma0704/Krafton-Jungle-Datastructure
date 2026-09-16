//////////////////////////////////////////////////////////////////////////////////

/* CE1007/CZ1007 자료구조
실습 시험: F 섹션 - 이진 탐색 트리 문제
목적: 5번 문제에 필요한 함수 구현하기
		 Implementing 'remove node' operation for BST*/
//////////////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <stdlib.h>

//////////////////////////////////////////////////////////////////////////////////

typedef struct _bstnode{
	int item;
	struct _bstnode *left;
	struct _bstnode *right;
} BSTNode;   // BSTNode 의 정의는 바꾸지 마세요

typedef struct _stackNode{
	BSTNode *data;
	struct _stackNode *next;
}StackNode; // StackNode 의 정의는 바꾸지 마세요

typedef struct _stack
{
	StackNode *top;
}Stack; // Stack 의 정의는 바꾸지 마세요

///////////////////////// 함수 원형 선언 ////////////////////////////////////

// 이 함수들의 원형(prototype)은 바꾸지 마세요
void postOrderIterativeS2(BSTNode *root);

void insertBSTNode(BSTNode **node, int value);

void push(Stack *stack, BSTNode *node);
BSTNode *pop(Stack *s);
BSTNode *peek(Stack *s);
int isEmpty(Stack *s);
void removeAll(BSTNode **node);
BSTNode* removeNodeFromTree(BSTNode *root, int value);

///////////////////////////// main() /////////////////////////////////////////////

int main()
{
	int c, i;
	c = 1;

	//이진 탐색 트리를 빈 트리로 초기화한다
	BSTNode * root;
	root = NULL;

	printf("1: 이진 탐색 트리에 정수 넣기;\n");
	printf("2: 이진 탐색 트리 후위 순회 출력;\n");
	printf("3: 이진 탐색 트리에서 정수 삭제 (검산용);\n");
	printf("0: 종료;\n");


	while (c != 0)
	{
		printf("원하는 번호를 입력하세요(1/2/3/0): ");
		scanf("%d", &c);

		switch (c)
		{
		case 1:
			printf("이진 탐색 트리에 넣을 정수를 입력하세요: ");
			scanf("%d", &i);
			insertBSTNode(&root, i);
			break;
		case 2:
			printf("이진 탐색 트리 후위 순회 결과: ");
			postOrderIterativeS2(root); // 이 함수를 직접 작성해야 합니다
			printf("\n");
			break;
		case 3:   /* 검산용으로 붙인 메뉴예요. 원본 템플릿에는 없습니다.
		             APAS 에는 함수 몸통만 내니까 여기는 건드려도 괜찮아요 */
			printf("삭제할 정수를 입력하세요: ");
			scanf("%d", &i);
			root = removeNodeFromTree(root, i);
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

void postOrderIterativeS2(BSTNode *root)
{
	 /* 여기에 코드를 작성하세요 */
	Stack nodes, visited_root;
	nodes.top = NULL;
	visited_root.top = NULL;


	if (root == NULL)
		return;

	push(&nodes, root);

	BSTNode *cur;


	while (nodes.top != NULL)
	{
		cur = peek(&nodes);

		if (cur->left != NULL || cur->right != NULL) //Root 판정
		{
			if (peek(&visited_root) != cur || peek(&visited_root) == NULL)
				push(&visited_root,cur);
			else
			{
				pop(&visited_root);
				pop(&nodes);
				printf("%d ", cur->item);
				continue;
			}
		}

		if (cur->left == NULL && cur->right == NULL)  //끝점 판별
		{
			pop(&nodes);
			printf("%d ", cur->item);
			continue;
		}

		if (cur->right != NULL)
			push(&nodes, cur->right);

		if (cur->left != NULL)
			push(&nodes, cur->left);
	}
}



/* 이진 탐색 트리와 키 값을 받아서 그 키를 삭제하고
   새 루트를 돌려주는 함수다. 재귀로 작성하세요. */
BSTNode* removeNodeFromTree(BSTNode *root, int value)
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

void push(Stack *stack, BSTNode * node)
{
	StackNode *temp;

	temp = malloc(sizeof(StackNode));

	if (temp == NULL)
		return;
	temp->data = node;

	if (stack->top == NULL)
	{
		stack->top = temp;
		temp->next = NULL;
	}
	else
	{
		temp->next = stack->top;
		stack->top = temp;
	}
}


BSTNode * pop(Stack * s)
{
	StackNode *temp, *t;
	BSTNode * ptr;
	ptr = NULL;

	t = s->top;
	if (t != NULL)
	{
		temp = t->next;
		ptr = t->data;

		s->top = temp;
		free(t);
		t = NULL;
	}

	return ptr;
}

BSTNode * peek(Stack * s)
{
	StackNode *temp;
	temp = s->top;
	if (temp != NULL)
		return temp->data;
	else
		return NULL;
}

int isEmpty(Stack *s)
{
	if (s->top == NULL)
		return 1;
	else
		return 0;
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
