//////////////////////////////////////////////////////////////////////////////////

/* CE1007/CZ1007 자료구조
실습 시험: C 섹션 - 스택과 큐 문제
목적: 7번 문제에 필요한 함수 구현하기 */

//////////////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <stdlib.h>

#define MIN_INT -1000

//////////////////////////////////////////////////////////////////////////////////

typedef struct _listnode
{
	int item;
	struct _listnode *next;
} ListNode;	// ListNode 의 정의는 바꾸지 마세요

typedef struct _linkedlist
{
	int size;
	ListNode *head;
} LinkedList;	// LinkedList 의 정의는 바꾸지 마세요


typedef struct stack
{
	LinkedList ll;
} Stack; // stack 의 정의는 바꾸지 마세요

///////////////////////// 함수 원형 선언 ////////////////////////////////////

// 이 함수들의 원형(prototype)은 바꾸지 마세요
int balanced(char *expression);

void push(Stack *s, int item);
int pop(Stack *s);
int peek(Stack *s);
int isEmptyStack(Stack *s);
void removeAllItemsFromStack(Stack *s);

void printList(LinkedList *ll);
void removeAllItems(LinkedList *ll);
ListNode * findNode(LinkedList *ll, int index);
int insertNode(LinkedList *ll, int index, int value);
int removeNode(LinkedList *ll, int index);

//////////////////////////// main() //////////////////////////////////////////////

int main()
{
	char  str[256];
	int c;
	c = 1;

	LinkedList ll;
	Stack s;

	// 연결 리스트를 빈 연결 리스트로 초기화한다
	ll.head = NULL;
	ll.size = 0;

	// 스택을 빈 스택으로 초기화한다
	s.ll.head = NULL;
	s.ll.size = 0;

	printf("1: 문자열 입력:\n");
	printf("2: ()[]{} 로 이루어진 식의 괄호가 맞는지 확인:\n");
	printf("0: 종료:\n");


	while (c != 0)
	{
		printf("원하는 번호를 입력하세요(1/2/0): ");
		scanf("%d", &c);

		switch (c)
		{
		case 1:
			printf("괄호가 맞는지 확인할 식을 공백 없이 입력하세요: ");
			scanf("%s", str);
			break;
        case 2:
            if(balanced(str))
                printf("괄호가 안 맞습니다!\n");
            else
                printf("괄호가 맞습니다!\n");
			break;
		case 0:
			break;
		default:
			printf("알 수 없는 선택입니다;\n");
			break;
		}

	}

	return 0;
}

////////////////////////////////////////////////////////////
int balanced(char *expression)
{

	Stack pair;

	pair.ll.head = NULL;
	pair.ll.size = 0;


	int ascii = 0;

	for (int idx = 0; expression[idx] != '\0'; idx++)
	{
		ascii = (int)expression[idx];
		switch (ascii)
		{
		case 40:
			push(&pair, 40);
			break;
		case 41:
			if (pop(&pair) == 40)
				break;
			removeAllItemsFromStack(&pair);
			return 1;

		case 91:
			push(&pair, 91);
			break;
		case 93:
			if (pop(&pair) == 91)
				break;
			removeAllItemsFromStack(&pair);
			return 1;

		case 123:
			push(&pair, 123);
			break;
		case 125:
			if (pop(&pair) == 123)
				break;
			removeAllItemsFromStack(&pair);
			return 1;

		default:
			removeAllItemsFromStack(&pair);
			return 1;
		}
	}

	if (pair.ll.size > 0)
	{
		removeAllItemsFromStack(&pair);
		return 1;
	}
	removeAllItemsFromStack(&pair);
	return 0;
}


/*	for (int idx = 0; expression[idx] != '\0'; idx++)
	{
		ascii = (int)expression[idx];
		switch (ascii)
		{
		case 41:
			if (round > 0)
			{
				round--;
				break;
			}
			return 1;
		case 40:
			round++;
			break;

		case 91:
			braces++;
			break;
		case 93:
			if (braces > 0)
			{
				braces--;
				break;
			}
			return 1;


		case 123:
			square++;
			break;
		case 125:
			if (square > 0)
			{
				square--;
				break;
			}
			return 1;

		default:
			return 1;
		}
	}

	if (square + braces + round == 0)
		return 0;

	return 1;
*/



////////////////////////////////////////////////////////////

void removeAllItemsFromStack(Stack *s)
{
	if (s == NULL)
		return;
	while (s->ll.head != NULL)
	{
		pop(s);
	}
}


void removeAllItems(LinkedList *ll)
{
	ListNode *cur = ll->head;
	ListNode *tmp;

	while (cur != NULL){
		tmp = cur->next;
		free(cur);
		cur = tmp;
	}
	ll->head = NULL;
	ll->size = 0;
}

/////////////////////////////////////////////////////////////////////////////////////////

void push(Stack *s, int item)
{
	insertNode(&(s->ll), 0, item);
}

int pop(Stack *s)
{
	int item;
	if (s->ll.head != NULL)
	{
		item = ((s->ll).head)->item;
		removeNode(&(s->ll), 0);
		return item;
	}
	else
		return MIN_INT;
}

int peek(Stack *s){
    if(isEmptyStack(s))
        return MIN_INT;
    else
        return ((s->ll).head)->item;
}

int isEmptyStack(Stack *s)
{
	if ((s->ll).size == 0)
		return 1;
	else
		return 0;
}


void printList(LinkedList *ll){

	ListNode *cur;
	if (ll == NULL)
		return;

	cur = ll->head;
	if (cur == NULL)
		printf("비어 있음");
	while (cur != NULL)
	{
		printf("%d ", cur->item);
		cur = cur->next;
	}
	printf("\n");
}

ListNode * findNode(LinkedList *ll, int index){

	ListNode *temp;

	if (ll == NULL || index < 0 || index >= ll->size)
		return NULL;

	temp = ll->head;

	if (temp == NULL || index < 0)
		return NULL;

	while (index > 0){
		temp = temp->next;
		if (temp == NULL)
			return NULL;
		index--;
	}

	return temp;
}

int insertNode(LinkedList *ll, int index, int value){

	ListNode *pre, *cur;

	if (ll == NULL || index < 0 || index > ll->size + 1)
		return -1;

	// 리스트가 비어 있거나 첫 번째 노드에 삽입하는 경우, head 포인터를 갱신해야 한다
	if (ll->head == NULL || index == 0){
		cur = ll->head;
		ll->head = malloc(sizeof(ListNode));
		if (ll->head == NULL)
		{
			exit(0);
		}
		ll->head->item = value;
		ll->head->next = cur;
		ll->size++;
		return 0;
	}


	// 목표 위치의 앞 노드와 그 자리의 노드를 찾는다
	// 새 노드를 만들고 링크를 다시 연결한다
	if ((pre = findNode(ll, index - 1)) != NULL){
		cur = pre->next;
		pre->next = malloc(sizeof(ListNode));
		if (pre->next == NULL)
		{
			exit(0);
		}
		pre->next->item = value;
		pre->next->next = cur;
		ll->size++;
		return 0;
	}

	return -1;
}


int removeNode(LinkedList *ll, int index){

	ListNode *pre, *cur;

	// 삭제할 수 있는 가장 큰 인덱스는 size-1 이다
	if (ll == NULL || index < 0 || index >= ll->size)
		return -1;

	// 첫 번째 노드를 삭제하는 경우, head 포인터를 갱신해야 한다
	if (index == 0){
		cur = ll->head->next;
		free(ll->head);
		ll->head = cur;
		ll->size--;
		return 0;
	}

	// 목표 위치의 앞 노드와 뒤 노드를 찾는다
	// 목표 노드를 해제하고 링크를 다시 연결한다
	if ((pre = findNode(ll, index - 1)) != NULL){

		if (pre->next == NULL)
			return -1;

		cur = pre->next;
		pre->next = cur->next;
		free(cur);
		ll->size--;
		return 0;
	}

	return -1;
}
