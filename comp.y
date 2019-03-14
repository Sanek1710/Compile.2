%{
void yyerror(char *s);
#include <stdio.h>
#include <stdlib.h>

extern void yyset_in (FILE *  _in_str );
extern int yyget_lineno();
extern int yylex (void);

%}

%start CODE
%token DECNUM
%token OCTNUM
%token HEXNUM
%token WHILE
%token IF 
%token ELSE
%token PRINT
%token RETURN
%token VAR  
%token INC  
%token DEC  
%token CMP
%token LINOP
%token EVEQ
%token UNOOP
%token BINOP

%%

CODE    : TEXT
        ; 

TEXT    : BLOCK
        | TEXT BLOCK
        ;

tWHILE  : WHILE '(' XEXP ')' BLOCK
        ;

tIF     : IF '(' XEXP ')' BLOCK
        | IF '(' XEXP ')' BLOCK ELSE BLOCK
        ;

BLOCK   : SCOPE
        | LINE
        | tWHILE
        | tIF
        ;

SCOPE   : '{' '}'
        | '{' CODE '}'
        ;

LINE    : ';'
        | XEXP ';'
        | PRINT XEXP ';'
        | RETURN ';'
        ;

XEXP    : LEXP
        | REXP
        ;

LEXP    : LVAL
        | LVAL EVEQ XEXP
        | '(' LEXP ')'
        ;

REXP    : RVAL
        | UNOOP REXP
        | LINOP REXP
        | XEXP BINOP XEXP
        | XEXP LINOP XEXP
        | XEXP CMP XEXP
        | '(' REXP ')'
        ;

LVAL    : VAR
        | INC LVAL
        | DEC LVAL
        | '(' LVAL ')'
        ;

RVAL    : NUM
        | LVAL DEC
        | LVAL INC
        | UNOOP LVAL
        | LINOP LVAL
        | '(' RVAL ')'
        ;

NUM     : DECNUM
        | OCTNUM
        | HEXNUM
        | '(' NUM ')'
        ;
        
%%

int
main(int argc, const char *argv[])
{
  if (argc > 1)
  {
    FILE *f = fopen(argv[1], "r");
    if (f == NULL)
    {
      printf("No such file\n");
      return -1;
    }

    yyset_in (f);
  }

  int Res = yyparse();

  if (Res == 0) printf("OK \n");
  else printf("HE OK\n");

  return(Res);
}

void
yyerror(char *s)
{
  fprintf(stderr, "%s:%d\n" , s, yyget_lineno());
}

int
yywrap()
{
  return(1);
}