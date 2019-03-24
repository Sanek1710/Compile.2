%{
#include "y.tab.h"

extern void yyerror(char *s);
int atoui_dec(const char *str);
int atoui_oct(const char *str);
int atoui_hex(const char *str);
int check_num(int num);

%}


%%
[1-9][0-9]*					{ yylval.str = strdup(yytext); return check_num(atoui_dec(yytext)); }
0[0-7]*						{ yylval.str = strdup(yytext); return check_num(atoui_oct(yytext)); }
0[xX][0-9A-Fa-f]+			{ yylval.str = strdup(yytext); return check_num(atoui_hex(yytext)); }
while					    { return While; }
if							{ return If; }
else						{ return Else; }
print 						{ return Print; }
return 						{ return Return; }
[a-zA-Z_][0-9a-zA-Z_]* 		{ yylval.str = strdup(yytext); return Var; }

"++"	 					{ return Inc; }
"--"	 					{ return Dec; }

"+="	 					{ return Mvadd; }
"-="	 					{ return Mvsub; }
"*="	 					{ return Mvmlt; }
"/="	 					{ return Mvdiv; }
"%="	 					{ return Mvmod; }
"|="	 					{ return Mvor; }
"&="	 					{ return Mvand; }
"^="	 					{ return Mvxor; }
"<<="	 					{ return Mvlsh; }
">>="	 					{ return Mvrsh; }

"+"		 					{ return Add; }
"-"		 					{ return Sub; }
"*"		 					{ return Mlt; }
"/"		 					{ return Div; }
"%"		 					{ return Mod; }
"<<"	 					{ return Lsh; }
">>"	 					{ return Rsh; }

">="	 					{ return Moreq; }
"<="	 					{ return Leseq; }
"=="	 					{ return Equal; }
"!="	 					{ return Noteq; }

">"		 					{ return More; }
"<"		 					{ return Less; }

"="		 					{ return Move; }

"||"	 					{ return Or; }
"&&"	 					{ return And; }
"!"		 					{ return Not; }

"|"		 					{ return Bitor; }
"&"		 					{ return Bitand; }
"^"		 					{ return Bitxor; }
"~"		 					{ return Bitnot; }

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