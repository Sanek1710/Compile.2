all: comp

comp: y.tab.c lex.yy.c
	gcc y.tab.c lex.yy.c comp.c stack.c -o comp

y.tab.c: comp.y
	yacc -d comp.y

lex.yy.c: comp.l
	lex comp.l

clean:
	rm comp lex.yy.c y.tab.h y.tab.c


rebuild: clean all
	