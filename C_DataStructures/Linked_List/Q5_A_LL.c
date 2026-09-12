//////////////////////////////////////////////////////////////////////////////////

/* CE1007/CZ1007 자료구조
실습 시험: A 섹션 - 연결 리스트 문제
목적: 5번 문제에 필요한 함수 구현하기 */

//////////////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <stdlib.h>

//////////////////////////////////////////////////////////////////////////////////

typedef struct _listnode{
	int item;
	struct _listnode *next;
} ListNode;			// ListNode 의 정의는 바꾸지 마세요

typedef struct _linkedlist{
	int size;
	ListNode *head;
} LinkedList;			// LinkedList 의 정의는 바꾸지 마세요


///////////////////////// 함수 원형 선언 ////////////////////////////////////

// 이 함수의 원형(prototype)은 바꾸지 마세요
void frontBackSplitLinkedList(LinkedList* ll, LinkedList *resultFrontList, LinkedList *resultBackList);

void printList(LinkedList *ll);
void removeAllItems(LinkedList *l);
ListNode * findNode(LinkedList *ll, int index);
int insertNode(LinkedList *ll, int index, int value);
int removeNode(LinkedList *ll, int index);


///////////////////////////// main() /////////////////////////////////////////////

int main()
{
	int c, i;
	LinkedList ll;
	LinkedList resultFrontList, resultBackList;

	//연결 리스트를 빈 연결 리스트로 초기화한다
	ll.head = NULL;
	ll.size = 0;

	//앞쪽 연결 리스트를 빈 연결 리스트로 초기화한다
	resultFrontList.head = NULL;
	resultFrontList.size = 0;

	// 뒤쪽 연결 리스트를 빈 연결 리스트로 초기화한다
	resultBackList.head = NULL;
	resultBackList.size = 0;

	printf("1: 연결 리스트에 정수 넣기:\n");
	printf("2: 연결 리스트를 frontList 와 backList 둘로 나누기:\n");
	printf("0: 종료:\n");

	while (c != 0)
	{
	    printf("원하는 번호를 입력하세요(1/2/0): ");
		scanf("%d", &c);

		switch (c)
		{
		case 1:
			printf("연결 리스트에 추가할 정수를 입력하세요: ");
			scanf("%d", &i);
			insertNode(&ll, ll.size, i);
			printf("만들어진 연결 리스트: ");
			printList(&ll);
			break;
		case 2:
			printf("둘로 나눈 결과 연결 리스트:\n");
			frontBackSplitLinkedList(&ll, &resultFrontList, &resultBackList); // 이 함수를 직접 작성해야 합니다
			printf("앞쪽 연결 리스트: ");
			printList(&resultFrontList);
			printf("뒤쪽 연결 리스트: ");
			printList(&resultBackList);
			printf("\n");
			removeAllItems(&ll);
			removeAllItems(&resultFrontList);
			removeAllItems(&resultBackList);
			break;
		case 0:
			removeAllItems(&ll);
			removeAllItems(&resultFrontList);
			removeAllItems(&resultBackList);
			break;
		default:
			printf("알 수 없는 선택입니다;\n");
			break;
		}
	}

	return 0;
}

//////////////////////////////////////////////////////////////////////////////////

void frontBackSplitLinkedList(LinkedList *ll, LinkedList *resultFrontList, LinkedList *resultBackList)
{
	int size = ll->size;
	int boundery = size/2;
	if (size % 2 == 1)
		boundery++;

	ListNode *cur;
	cur = ll->head;

	for (int repeat_count = 1; repeat_count <= size; repeat_count++)
	{
		if (repeat_count <= boundery)
			insertNode(resultFrontList, repeat_count-1, cur->item);
		else
			insertNode(resultBackList, repeat_count-boundery-1, cur->item);

		cur = cur->next;
		removeNode(ll,0);
	}

}

///////////////////////////////////////////////////////////////////////////////////

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
