%{
#include "y.tab.h"

extern void yyerror(char *s);
int atoui_dec(const char *str);
int atoui_oct(const char *str);
int atoui_hex(const char *str);
int check_num(int num);

%}


%%
[1-9][0-9]*					{ yylval.num = atoui_dec(yytext); return check_num(yylval.num); }
0[0-7]*						{ yylval.num = atoui_oct(yytext); return check_num(yylval.num); }
0[xX][0-9A-Fa-f]+			{ yylval.num = atoui_hex(yytext); return check_num(yylval.num); }
while					    { /*printf("While ");*/   return While; }
if							{ /*printf("If ");*/  	  return If; }
else						{ /*printf("Else ");*/    return Else; }
print 						{ /*printf("Print ");*/   return Print; }
return 						{ /*printf("Return ");*/  return Return; }
[a-zA-Z_][0-9a-zA-Z_]* 		{ /*printf("Var ");*/     return Var; }

"++"	 					{ /*printf("Inc ");*/     return Inc; }
"--"	 					{ /*printf("Dec ");*/     return Dec; }

"+="	 					{ /*printf("Mvadd ");*/   return Mvadd; }
"-="	 					{ /*printf("Mvsub ");*/   return Mvsub; }
"*="	 					{ /*printf("Mvmlt ");*/   return Mvmlt; }
"/="	 					{ /*printf("Mvdiv ");*/   return Mvdiv; }
"%="	 					{ /*printf("Mvmod ");*/   return Mvmod; }
"|="	 					{ /*printf("Mvor ");*/    return Mvor; }
"&="	 					{ /*printf("Mvand ");*/   return Mvand; }
"^="	 					{ /*printf("Mvxor ");*/   return Mvxor; }
"<<="	 					{ /*printf("Mvlsh ");*/   return Mvlsh; }
">>="	 					{ /*printf("Mvrsh ");*/   return Mvrsh; }

"+"		 					{ /*printf("Add ");*/     return Add; }
"-"		 					{ /*printf("Sub ");*/     return Sub; }
"*"		 					{ /*printf("Mlt ");*/     return Mlt; }
"/"		 					{ /*printf("Div ");*/     return Div; }
"%"		 					{ /*printf("Mod ");*/     return Mod; }
"<<"	 					{ /*printf("Lsh ");*/     return Lsh; }
">>"	 					{ /*printf("Rsh ");*/     return Rsh; }

">="	 					{ /*printf("Moreq ");*/   return Moreq; }
"<="	 					{ /*printf("Leseq ");*/   return Leseq; }
"=="	 					{ /*printf("Equal ");*/   return Equal; }
"!="	 					{ /*printf("Noteq ");*/   return Noteq; }

">"		 					{ /*printf("More ");*/	  return More; }
"<"		 					{ /*printf("Less ");*/    return Less; }

"="		 					{ /*printf("Move ");*/    return Move; }

"||"	 					{ /*printf("Or ");*/      return Or; }
"&&"	 					{ /*printf("And ");*/     return And; }
"!"		 					{ /*printf("Not ");*/     return Not; }

"|"		 					{ /*printf("Bitor ");*/   return Bitor; }
"&"		 					{ /*printf("Bitand ");*/  return Bitand; }
"^"		 					{ /*printf("Bitxor ");*/  return Bitxor; }
"~"		 					{ /*printf("Bitnot ");*/  return Bitnot; }

[;{}()]						{ return yytext[0]; }
[\n]   						{ yylineno++; }
[ \t\r]   					;
.           				{ yyerror("unexpected char"); return 0; }

%%

int
atoui_dec(const char *str)
{
	int num = 0, old_num;

	while (*str)
	{
		old_num = num;
		num = num * 10 + (*str - '0');

		if (num < old_num) return -1;

		str++;
	}

	return num;
}

int
atoui_oct(const char *str)
{
	int num = 0, old_num;

	while (*str)
	{
		old_num = num;
		num = num * 8 + (*str - '0');

		if (num < old_num) return -1;

		str++;
	}

	return num;
}

int
atoui_hex(const char *str)
{
	int num = 0, old_num;
	str += 2;
	while (*str)
	{
		old_num = num;

		num = num * 16;
		if ('0' <= *str && *str <= '9') num += *str - '0';
		else if ('a' <= *str && *str <= 'f') num += *str - 'a' + 10;
		else if ('A' <= *str && *str <= 'F') num += *str - 'A' + 10;

		if (num < old_num) return -1;

		str++;
	}

	return num;
}

int check_num(int num)
{
	if (num < 0) 
	{
		yyerror("int overflow");
		return 0;
	}
	else
	{
		return Num;
	}
}