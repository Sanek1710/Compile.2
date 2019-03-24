#ifndef _COMP_H_
#define _COMP_H_

#include <stdio.h>
#include <stdlib.h>


extern void yyerror(char *s);
extern void yyset_in (FILE *  _in_str );
extern int  yyget_lineno();
extern int  yylex(void);
extern int  yyparse(void);


const char * CUR_REG();

typedef enum TERM_TYPE
{
	t_num,
	t_var
}TERM_TYPE;

void MOV(const char *str, TERM_TYPE type);
void OP(int op_id);
void PREF(int op_id, const char *var);
void POST(int op_id, const char *var);
void RESET_EXP();

#endif