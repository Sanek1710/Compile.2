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

int MARK_NUM = 0;
char MARK[128];


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

char *
NEW_MARK()
{
    sprintf(MARK, "mark_%03d", MARK_NUM++);
    return MARK;
}

char *
LAST_MARK()
{
  return MARK;
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

    switch(op_id)
    {
      case Add:
      {
        printf("add  %s, %s\n", reg_lft, reg_rgt);
      } break;

      case Sub:
      {
        printf("sub  %s, %s\n", reg_lft, reg_rgt);
      } break;

      case Mlt:
      {
        printf("mlt  %s, %s\n", reg_lft, reg_rgt);
      } break;

      case Div:
      {
        printf("div  %s, %s\n", reg_lft, reg_rgt);
      } break;

      case Mod:
      {
        printf("div  %s, %s\n", reg_lft, reg_rgt);
        printf("mov  %s, %s\n", reg_lft, reg_rgt);
      } break;

      case Lsh:
      {
        printf("shl  %s, %s\n", reg_lft, reg_rgt);
      } break;

      case Rsh:
      {
        printf("shr  %s, %s\n", reg_lft, reg_rgt);
      } break;

      case Moreq:
      {
        printf("cmp  %s, %s\n", reg_lft, reg_rgt);
        printf("jl   .+0x0A\n");
        printf("mov  %s, 1\n", reg_lft);
        printf("jmp  .+0x08\n");
        printf("mov  %s, 0\n", reg_lft);
      } break;

      case Leseq:
      {
        printf("cmp  %s, %s\n", reg_lft, reg_rgt);
        printf("jg   .+0x0A\n");
        printf("mov  %s, 1\n", reg_lft);
        printf("jmp  .+0x08\n");
        printf("mov  %s, 0\n", reg_lft);
      } break;

      case Equal:
      {
        printf("cmp  %s, %s\n", reg_lft, reg_rgt);
        printf("jne  .+0x0A\n");
        printf("mov  %s, 1\n", reg_lft);
        printf("jmp  .+0x08\n");
        printf("mov  %s, 0\n", reg_lft);
      } break;

      case Noteq:
      {
        printf("cmp  %s, %s\n", reg_lft, reg_rgt);
        printf("je   .+0x0A\n");
        printf("mov  %s, 1\n", reg_lft);
        printf("jmp  .+0x08\n");
        printf("mov  %s, 0\n", reg_lft);
      } break;

      case More:
      {
        printf("cmp  %s, %s\n", reg_lft, reg_rgt);
        printf("jle  .+0x0A\n");
        printf("mov  %s, 1\n", reg_lft);
        printf("jmp  .+0x08\n");
        printf("mov  %s, 0\n", reg_lft);
      } break;

      case Less:
      {
        printf("cmp  %s, %s\n", reg_lft, reg_rgt);
        printf("jge  .+0x0A\n");
        printf("mov  %s, 1\n", reg_lft);
        printf("jmp  .+0x08\n");
        printf("mov  %s, 0\n", reg_lft);
      } break;

      case Or:
      {
        printf("tst  %s\n", reg_lft);
        printf("jne  .+0x0E\n");
        printf("tst  %s\n", reg_rgt);
        printf("jne  .+0x0A\n");
        printf("mov  %s, 0\n", reg_lft);
        printf("jmp  .+0x08\n");
        printf("mov  %s, 1\n", reg_lft);
      } break;

      case And:
      {
        printf("tst  %s\n", reg_lft);
        printf("je   .+0x0E\n");
        printf("tst  %s\n", reg_rgt);
        printf("je   .+0x0A\n");
        printf("mov  %s, 1\n", reg_lft);
        printf("jmp  .+0x08\n");
        printf("mov  %s, 0\n", reg_lft);
      } break;

      case Bitor:
      {
        printf("or   %s, %s\n", reg_lft, reg_rgt);
      } break;

      case Bitand:
      {
        printf("and  %s, %s\n", reg_lft, reg_rgt);
      } break;

      case Bitxor:
      {
        printf("xor  %s, %s\n", reg_lft, reg_rgt);
      } break;
    }

    FREE++;
} 

void
UNOOP(int op_id)
{
  switch(op_id)
  {
    case Sub:
    {
      printf("neg  %s\n", CUR_REG());
    } break;

    case Bitnot:
    {
      printf("not  %s\n", CUR_REG());
    } break;

    case Not:
    {
      printf("tst  %s\n", CUR_REG());
      printf("jne  .+0x0A\n");
      printf("mov  %s, 1\n", CUR_REG());
      printf("jmp  .+0x08\n");
      printf("mov  %s, 0\n", CUR_REG());
    } break;
    
    case Add:
    default: break;
  }
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