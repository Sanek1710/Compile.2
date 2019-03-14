%{
#include "y.tab.h"

extern void yyerror(char *s);

%}


%%
[1-9][0-9]*					{ 	return DECNUM;	}
0[0-7]*						{ 	return OCTNUM;	}			
0[xX][0-9A-Fa-f]+			{ 	return HEXNUM;	}
while					    { 	return WHILE;	}			
if							{ 	return IF;		}
else						{ 	return ELSE;	}
print 						{ 	return PRINT;	}
return 						{ 	return RETURN;	}
[a-zA-Z_][0-9a-zA-Z_]* 		{ 	return VAR;		}
"++"						{ 	return INC;		}
"--"						{ 	return DEC;		}
[><!=]=|[><]				{ 	return CMP;		}
[-+*/%|&^]?=				{ 	return EVEQ;	}
[!~]						{ 	return UNOOP;	}
[|&]{2}|[/%|&^]	      		{ 	return BINOP;	}
[-+]						{ 	return LINOP;	}
[;{}()]						{ return yytext[0];}
[\n]   						{ yylineno++; }
[ \t\r]   					;
.           				{ yyerror("unexpected char"); return 0; }

%%