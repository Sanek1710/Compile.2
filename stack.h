#ifndef _STACK_H
#define _STACK_H

#include <stdlib.h>

typedef struct STACK
{
	int count;
	int max_count;
	int *list;
}STACK;

STACK stack_new();
int  stack_push(STACK *st, int num);
int  stack_pop(STACK *st);
void stack_clear(STACK *st);
void stack_delete(STACK *st);


#endif // !_STACK_H