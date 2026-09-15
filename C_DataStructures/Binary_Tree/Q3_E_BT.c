//////////////////////////////////////////////////////////////////////////////////

/* CE1007/CZ1007 자료구조
실습 시험: E 섹션 - 이진 트리 문제
목적: 3번 문제에 필요한 함수 구현하기 */

//////////////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <stdlib.h>

//////////////////////////////////////////////////////////////////////////////////
typedef struct _btnode
{
    int item;
    struct _btnode *left;
    struct _btnode *right;
} BTNode;   // BTNode 의 정의는 바꾸지 마세요

/////////////////////////////////////////////////////////////////////////////////

typedef struct _stackNode
{
    BTNode *btnode;
    struct _stackNode *next;
} StackNode;

typedef struct _stack
{
    StackNode *top;
} Stack;

///////////////////////// 함수 원형 선언 ////////////////////////////////////

// 이 함수들의 원형(prototype)은 바꾸지 마세요
int countOneChildNodes(BTNode *node);

BTNode *createBTNode(int item);

BTNode *createTree();
void push( Stack *stack, BTNode *node);
BTNode* pop(Stack *stack);

void printTree(BTNode *node);
void removeAll(BTNode **node);

///////////////////////////// main() /////////////////////////////////////////////

int main()
{
    char e;
    int c,s;
    BTNode *root;

    c = 1;
    root = NULL;


    printf("1: 이진 트리 만들기.\n");
    printf("2: 자식이 정확히 하나인 노드 개수 세기.\n");
    printf("0: 종료;\n");

    while(c != 0)
    {
        printf("원하는 번호를 입력하세요(1/2/0): ");
        if( scanf("%d",&c) > 0)
        {
            switch(c)
            {
            case 1:
                removeAll(&root);
                root = createTree();
                printf("만들어진 이진 트리: ");
                printTree(root);
                printf("\n");
                break;
            case 2:
                s = countOneChildNodes(root);
                printf("자식이 정확히 하나인 노드 개수: %d.\n", s);
                removeAll(&root);
                break;
            case 0:
                removeAll(&root);
                break;
            default:
                printf("알 수 없는 선택입니다;\n");
                break;
            }
        }
        else
        {
            scanf("%c",&e);
        }

    }
    return 0;
}

//////////////////////////////////////////////////////////////////////////////////

int countOneChildNodes(BTNode *node)

{
    int count = 0;

    if (node == NULL)
        return 0;

    if (node->right == NULL || node->left == NULL)
    {
        if (node->right == NULL && node->left == NULL)
            return 0;
        count++;
    }

    if (node->right != NULL)
        count = countOneChildNodes(node->right) + count;

    if (node->left != NULL)
        count = countOneChildNodes(node->left) + count;

    return count;
}

///////////////////////////////////////////////////////////////////////////////////

BTNode *createBTNode(int item)
{
    BTNode *newNode = malloc(sizeof(BTNode));
    newNode->item = item;
    newNode->left = NULL;
    newNode->right = NULL;
    return newNode;
}

//////////////////////////////////////////////////////////////////////////////////


BTNode *createTree()
{
    Stack stack;
    BTNode *root, *temp;
    char s;
    int item;

    stack.top = NULL;
    root = NULL;
    printf("이진 트리에 추가할 정수를 입력하세요. 문자를 넣으면 NULL 로 처리됩니다.\n");
    printf("루트에 넣을 정수: ");
    if(scanf("%d",&item) > 0)
    {
        root = createBTNode(item);
        push(&stack,root);
    }
    else
    {
        scanf("%c",&s);
    }

    while((temp =pop(&stack)) != NULL)
    {

        printf("%d 의 왼쪽 자식에 넣을 정수: ", temp->item);

        if(scanf("%d",&item)> 0)
        {
            temp->left = createBTNode(item);
        }
        else
        {
            scanf("%c",&s);
        }

        printf("%d 의 오른쪽 자식에 넣을 정수: ", temp->item);
        if(scanf("%d",&item)>0)
        {
            temp->right = createBTNode(item);
        }
        else
        {
            scanf("%c",&s);
        }

        if(temp->right != NULL)
            push(&stack,temp->right);
        if(temp->left != NULL)
            push(&stack,temp->left);
    }
    return root;
}

void push( Stack *stack, BTNode *node)
{
    StackNode *temp;

    temp = malloc(sizeof(StackNode));
    if(temp == NULL)
        return;
    temp->btnode = node;
    if(stack->top == NULL)
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

BTNode* pop(Stack *stack)
{
    StackNode *temp, *top;
    BTNode *ptr;
    ptr = NULL;

    top = stack->top;
    if(top != NULL)
    {
        temp = top->next;
        ptr = top->btnode;

        stack->top = temp;
        free(top);
        top = NULL;
    }
    return ptr;
}

void printTree(BTNode *node)
{
    if(node == NULL) return;

    printTree(node->left);
    printf("%d ",node->item);
    printTree(node->right);
}

void removeAll(BTNode **node)
{
    if(*node != NULL)
    {
        removeAll(&((*node)->left));
        removeAll(&((*node)->right));
        free(*node);
        *node = NULL;
    }
}

