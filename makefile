all: comp

comp: y.tab.c lex.yy.c
	gcc y.tab.c lex.yy.c varlist.h -o comp

y.tab.c: comp.y
	yacc -d comp.y

lex.yy.c: comp.l
	lex comp.l

clean:
	rm comp lex.yy.c y.tab.h y.tab.c
