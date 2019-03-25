#include "stack.h"

STACK
stack_new()
{
	STACK st;

	st.count = 0;
	st.max_count = 32;
	st.list = (int*)malloc(st.max_count * sizeof(int));

	return st;
}

int
stack_push(STACK *st, int num)
{
	st->list[st->count] = num;
	st->count++;

	if (st->max_count == st->count)
	{
		st->max_count += 32;
		st->list = (int*)realloc(st->list, st->max_count * sizeof(int));
	}
}

int
stack_pop(STACK *st)
{
	if (st->count == 0) return 0;
	st->count--;

	return st->list[st->count];
}

void
stack_clear(STACK *st)
{
	st->count = 0;
}

void
stack_delete(STACK *st)
{
	free(st->list);
	st->max_count = 0;
}