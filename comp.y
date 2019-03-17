%{
void yyerror(char *s);
#include <stdio.h>
#include <stdlib.h>

extern void yyset_in (FILE *  _in_str );
extern int yyget_lineno();
extern int yylex (void);

%}

%union { int num; char id; }

%start CODE
%token <num> Num
%token While
%token If 
%token Else
%token Print
%token Return
%token Var 

%token Inc Dec
%token Mvadd Mvsub Mvmlt Mvdiv Mvmod Mvor Mvand Mvxor Mvlsh Mvrsh
%token Add Sub Mlt Div Mod Lsh Rsh
%token Moreq Leseq Equal Noteq More Less
%token Move
%token Or And Not
%token Bitor Bitand Bitxor Bitnot

%%

CODE    : TEXT
        ; 

TEXT    : BLOCK
        | TEXT BLOCK
        ;

WHILE   : While '(' EXP ')' BLOCK
        ;

IF      : If '(' EXP ')' BLOCK
        | If '(' EXP ')' BLOCK Else BLOCK
        ;

BLOCK   : SCOPE
        | LINE
        | WHILE
        | IF
        ;

SCOPE   : '{' '}'
        | '{' CODE '}'
        ;

LINE    : ';'
        | EXP ';'
        | Print EXP ';'
        | Return ';'
        ;

EXP     : LVAL Move  EXP  { printf("= "); }
        | LVAL Mvadd EXP
        | LVAL Mvsub EXP
        | LVAL Mvmlt EXP
        | LVAL Mvdiv EXP
        | LVAL Mvmod EXP
        | LVAL Mvor  EXP
        | LVAL Mvand EXP
        | LVAL Mvxor EXP
        | LVAL Mvlsh EXP
        | LVAL Mvrsh EXP
        | EXP0
        ;

EXP0    : EXP0 Or     EXP1  
        | EXP1 
        ;
EXP1    : EXP1 And    EXP2  
        | EXP2 
        ;
EXP2    : EXP2 Bitor  EXP3  
        | EXP3 
        ;
EXP3    : EXP3 Bitxor EXP4  
        | EXP4 
        ;
EXP4    : EXP4 Bitand EXP5  
        | EXP5 
        ;
EXP5    : EXP5 Equal  EXP6  
        | EXP5 Noteq  EXP6   
        | EXP6 
        ;
EXP6    : EXP6 Less   EXP7  
        | EXP6 More   EXP7   
        | EXP6 Moreq  EXP7   
        | EXP6 Leseq  EXP7 
        | EXP7 
        ;
EXP7    : EXP7 Lsh    EXP8  
        | EXP7 Rsh    EXP8   
        | EXP8 
        ;
EXP8    : EXP8 Add    EXP9  { printf("+ "); }
        | EXP8 Sub    EXP9  { printf("- "); }
        | EXP9 
        ;
EXP9    : EXP9 Mlt    EXP10 { printf("* "); }
        | EXP9 Div    EXP10  
        | EXP9 Mod    EXP10  
        | EXP10 
        ;
EXP10   : XVAL 
        | '(' EXP0 ')' 
        | Add EXP10
        | Sub EXP10
        | Not EXP10
        | Bitnot EXP10
        ;

XVAL    : RVAL 
        | LVAL
        ;

RVAL    : Var          Inc  
        | Var          Dec
        | '(' LVAL ')' Inc  
        | '(' LVAL ')' Dec
        | Num          { printf("%d", $1); }
        ;

LVAL    : Var
        | Inc LVAL          
        | Dec LVAL
        | '(' LVAL ')'
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