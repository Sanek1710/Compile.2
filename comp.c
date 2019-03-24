#include "comp.h"
#include "y.tab.h"

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


int FREE = 2;
int IN_MEM = 0;

const char *reg[2] = { "eax", "ebx" };
int CUR_REG_NUM = 0;

void
MOV(const char *str, TERM_TYPE type)
{
    const char *
    format = (type == t_num) ? ("mov  %s, %s\n")
                             : ("mov  %s, [%s]\n");

    if (!FREE)
    {
        CUR_REG_NUM = IN_MEM%2;
        printf("push %s\n", reg[CUR_REG_NUM]);
        printf(format, reg[CUR_REG_NUM], str);
        IN_MEM++;
    }
    else
    {
        CUR_REG_NUM = (IN_MEM + FREE)%2;
        printf(format, reg[CUR_REG_NUM], str);
        FREE--;
    }
}

void
OP(int op_id)
{
    if (FREE)
    {
        FREE--;
        IN_MEM--;
        printf("pop  %s\n", reg[IN_MEM%2]);
    }

    CUR_REG_NUM = IN_MEM%2;
    const char * reg_lft = reg[CUR_REG_NUM];
    const char * reg_rgt = reg[(CUR_REG_NUM + 1)%2];

    printf("%d  %s, %s\n", op_id, reg_lft, reg_rgt);

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
PREF(int op_id, const char *var)
{
    printf("%d  %s\n", op_id, CUR_REG());
    printf("mov  [%s], %s\n", var, CUR_REG());
}

void
POST(int op_id, const char *var)
{
    printf("push %s\n", CUR_REG());
    printf("%d  %s\n", op_id, CUR_REG());
    printf("mov  [%s], %s\n", var, CUR_REG());
    printf("pop %s\n", CUR_REG());
}