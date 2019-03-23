%{
void yyerror(char *s);
#include <stdio.h>
#include <stdlib.h>

extern void yyset_in (FILE *  _in_str );
extern int yyget_lineno();
extern int yylex (void);

int FREE = 2;
int IN_MEM = 0;

const char *reg[2] = { "eax", "ebx" };
int CUR_REG_NUM = 0;


void
MOV(const char *str)
{
    if (!FREE) 
    {
        CUR_REG_NUM = IN_MEM%2;
        printf("push %s\n", reg[CUR_REG_NUM]);
        printf("mov  %s, [%s]\n", reg[CUR_REG_NUM], str);
        IN_MEM++;
    }
    else 
    {
        CUR_REG_NUM = (IN_MEM + FREE)%2;
        printf("mov  %s, [%s]\n", reg[CUR_REG_NUM], str);
        FREE--;
    }
}

void
OP(const char *str)
{
    if (FREE)
    {
        FREE--;
        IN_MEM--;
        printf("pop  %s\n", reg[IN_MEM%2]);
    }

    printf("%s  %s\n", str, (IN_MEM%2) ? "ebx, eax" : "eax, ebx");
    CUR_REG_NUM = IN_MEM%2;

    FREE++;
}

const char *
CUR_REG()
{
    return reg[CUR_REG_NUM];
}

void
RESET_EXP()
{
    IN_MEM = 0; FREE = 2;
}

void
PREF(const char *op, const char *var)
{
    printf("%s  %s\n", op, CUR_REG()); 
    printf("mov  [%s], %s\n", var, CUR_REG());
}

void
POST(const char *op, const char *var)
{
    printf("push %s\n", CUR_REG());
    printf("%s  %s\n", op, CUR_REG());
    printf("mov  [%s], %s\n", var, CUR_REG());
    printf("pop %s\n", CUR_REG());
}

%}

%union { int num; char id; const char *str; }

%start CODE
%token <str> Num
%token While
%token If 
%token Else
%token Print
%token Return
%token <str> Var 

%token Inc Dec
%token Mvadd Mvsub Mvmlt Mvdiv Mvmod Mvor Mvand Mvxor Mvlsh Mvrsh
%token Add Sub Mlt Div Mod Lsh Rsh
%token Moreq Leseq Equal Noteq More Less
%token Move
%token Or And Not
%token Bitor Bitand Bitxor Bitnot

%type <str> LVAL RVAL XVAL EXP10

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

LINE    : ';'                   { RESET_EXP(); }                
        | EXP ';'               { RESET_EXP(); }                                            
        | Print EXP ';'         { RESET_EXP(); }       
        | Return ';'            { RESET_EXP(); }                   
        ;

EXP     : LVAL Move  EXP        { printf("= "); }
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

EXP0    : EXP0 Or     EXP1      { OP("|| "); }  
        | EXP1 
        ;
EXP1    : EXP1 And    EXP2      { OP("&& "); }  
        | EXP2 
        ;
EXP2    : EXP2 Bitor  EXP3      { OP("|  "); }  
        | EXP3 
        ;
EXP3    : EXP3 Bitxor EXP4      { OP("^  "); }  
        | EXP4 
        ;
EXP4    : EXP4 Bitand EXP5      { OP("&  "); }  
        | EXP5 
        ;
EXP5    : EXP5 Equal  EXP6      { OP("== "); }  
        | EXP5 Noteq  EXP6      { OP("!= "); }   
        | EXP6 
        ;
EXP6    : EXP6 Less   EXP7      { OP("<  "); }        
        | EXP6 More   EXP7      { OP(">  "); }         
        | EXP6 Moreq  EXP7      { OP(">= "); }      
        | EXP6 Leseq  EXP7      { OP("<= "); }       
        | EXP7 
        ;
EXP7    : EXP7 Lsh    EXP8      { OP("<< "); }      
        | EXP7 Rsh    EXP7      { OP(">> "); }      
        | EXP8 
        ;
EXP8    : EXP8 Add    EXP9      { OP("+  "); }
        | EXP8 Sub    EXP9      { OP("-  "); }
        | EXP9 
        ;
EXP9    : EXP9 Mlt    EXP10     { OP("*  "); }
        | EXP9 Div    EXP10     { OP("/  "); }
        | EXP9 Mod    EXP10     { OP("%  "); }
        | EXP10                 {  }
        ;
EXP10   : XVAL                  { $$ = $1; }
        | '(' EXP0 ')'          { $$ = "exp"; }
        | Add EXP10             { $$ = $2; }
        | Sub EXP10             { $$ = $2; printf("-    %s\n", CUR_REG()); }
        | Not EXP10             { $$ = $2; printf("!    %s\n", CUR_REG()); }
        | Bitnot EXP10          { $$ = $2; printf("~    %s\n", CUR_REG()); }
        ;

XVAL    : RVAL                  { $$ = $1; }
        | LVAL                  { $$ = $1; }
        ;

RVAL    : Var          Inc      { $$ = $1; MOV($1); POST("inc", $1); }
        | Var          Dec      { $$ = $1; MOV($1); POST("dec", $1); }
        | '(' LVAL ')' Inc      { $$ = $2; POST("inc", $2); }
        | '(' LVAL ')' Dec      { $$ = $2; POST("dec", $2); }
        | Num                   { $$ = $1; MOV($1); }
        ;

LVAL    : Var                   { $$ = $1; MOV($1); }
        | Inc LVAL              { $$ = $2; PREF("inc", $2); }
        | Dec LVAL              { $$ = $2; PREF("dec", $2); }
        | '(' LVAL ')'          { $$ = $2; }
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
  fprintf(stderr, "%s\n" , s);
}

int
yywrap()
{
  return(1);
}