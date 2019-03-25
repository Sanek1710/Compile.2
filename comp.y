%{
#include "comp.h"
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

WHILE   : WHCOND BLOCK            { printf("jmp mark_%03d\n", POP_MARK(&MARK_FRST)); 
                                    printf("__mark_%03d:\n", POP_MARK(&MARK_SCND)); 
                                    }
        ;

WHCOND  : WHIL '(' EXP ')'        { RESET_EXP(); 
                                    PUSH_MARK(&MARK_SCND); 
                                    printf("tst eax\n"); 
                                    printf("je mark_%03d\n", LAST_MARK()); 
                                  } 
        ;

WHIL    : While                   { PUSH_MARK(&MARK_FRST); printf("__mark_%03d:\n", LAST_MARK()); }
        ;

IF      : IFCOND BLOCK            { printf("__mark_%03d:\n", POP_MARK(&MARK_FRST)); }
        | IFCOND BLOCK ELSE BLOCK { printf("__mark_%03d:\n", POP_MARK(&MARK_SCND)); }
        ;

ELSE    : Else                    { PUSH_MARK(&MARK_SCND);
                                    printf("jmp mark_%03d\n", LAST_MARK());
                                    printf("__mark_%03d:\n", POP_MARK(&MARK_FRST)); }
        ;

IFCOND  : If '(' EXP ')'          { RESET_EXP(); 
                                    PUSH_MARK(&MARK_FRST);
                                    printf("tst eax\n");
                                    printf("je mark_%03d\n", LAST_MARK());
                                  }
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
        | Print EXP ';'         { RESET_EXP(); printf("call print\n"); }
        | Return ';'            { RESET_EXP(); printf("ret\n"); }
        ;

EXP     : Var  Move  EXP        { printf("mov  [%s], %s\n", $1, CUR_REG()); }
        | LVAL Move  EXP        { printf("mov  [%s], %s\n", $1, CUR_REG()); }
        | LVAL Mvadd EXP        { OP(Mvadd); printf("mov  [%s], %s\n", $1, CUR_REG()); }
        | LVAL Mvsub EXP        { OP(Mvsub); printf("mov  [%s], %s\n", $1, CUR_REG()); }
        | LVAL Mvmlt EXP        { OP(Mvmlt); printf("mov  [%s], %s\n", $1, CUR_REG()); }
        | LVAL Mvdiv EXP        { OP(Mvdiv); printf("mov  [%s], %s\n", $1, CUR_REG()); }
        | LVAL Mvmod EXP        { OP(Mvmod); printf("mov  [%s], %s\n", $1, CUR_REG()); }
        | LVAL Mvor  EXP        { OP(Mvor ); printf("mov  [%s], %s\n", $1, CUR_REG()); }
        | LVAL Mvand EXP        { OP(Mvand); printf("mov  [%s], %s\n", $1, CUR_REG()); }
        | LVAL Mvxor EXP        { OP(Mvxor); printf("mov  [%s], %s\n", $1, CUR_REG()); }
        | LVAL Mvlsh EXP        { OP(Mvlsh); printf("mov  [%s], %s\n", $1, CUR_REG()); }
        | LVAL Mvrsh EXP        { OP(Mvrsh); printf("mov  [%s], %s\n", $1, CUR_REG()); }
        | EXP0
        ;

EXP0    : EXP0 Or     EXP1      { OP(Or); }
        | EXP1
        ;
EXP1    : EXP1 And    EXP2      { OP(And); }
        | EXP2
        ;
EXP2    : EXP2 Bitor  EXP3      { OP(Bitor); }
        | EXP3
        ;
EXP3    : EXP3 Bitxor EXP4      { OP(Bitxor); }
        | EXP4
        ;
EXP4    : EXP4 Bitand EXP5      { OP(Bitand); }
        | EXP5
        ;
EXP5    : EXP5 Equal  EXP6      { OP(Equal); }
        | EXP5 Noteq  EXP6      { OP(Noteq); }
        | EXP6
        ;
EXP6    : EXP6 Less   EXP7      { OP(Less); }
        | EXP6 More   EXP7      { OP(More); }
        | EXP6 Moreq  EXP7      { OP(Moreq); }
        | EXP6 Leseq  EXP7      { OP(Leseq); }
        | EXP7
        ;
EXP7    : EXP7 Lsh    EXP8      { OP(Lsh); }
        | EXP7 Rsh    EXP7      { OP(Rsh); }
        | EXP8
        ;
EXP8    : EXP8 Add    EXP9      { OP(Add); }
        | EXP8 Sub    EXP9      { OP(Sub); }
        | EXP9
        ;
EXP9    : EXP9 Mlt    EXP10     { OP(Mlt); }
        | EXP9 Div    EXP10     { OP(Div); }
        | EXP9 Mod    EXP10     { OP(Mod); }
        | EXP10                 { }
        ;
EXP10   : XVAL                  { }
        | '(' EXP0 ')'          { }
        | Add EXP10             { UNOOP(Add); }
        | Sub EXP10             { UNOOP(Sub); }
        | Not EXP10             { UNOOP(Not); }
        | Bitnot EXP10          { UNOOP(Bitnot); }
        ;

XVAL    : RVAL                  { }
        | LVAL                  { }
        ;

RVAL    : Var          Inc      { MOV($1, t_var); POST(Inc, $1); }
        | Var          Dec      { MOV($1, t_var); POST(Dec, $1); }
        | '(' LVAL ')' Inc      { POST(Inc, $2); }
        | '(' LVAL ')' Dec      { POST(Dec, $2); }
        | Num                   { MOV($1, t_num); }
        ;

LVAL    : Var                   { $$ = $1; MOV($1, t_var); }
        | Inc LVAL              { $$ = $2; PREF(Inc, $2); }
        | Dec LVAL              { $$ = $2; PREF(Dec, $2); }
        | '(' LVAL ')'          { $$ = $2; }
        ;
%%
