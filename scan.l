%{
	#include <stdio.h>
	#include "y.tab.h"
%}

STRING		\"(\\.|[^\"])*\"
NUMBER		-?(0|[0-9]+)(\.[0-9]+)?((e|E)(\+|-)?[0-9]+)?

%%

{STRING}	{yylval.string = strdup(yytext); return STRING;}
{NUMBER}	{yylval.string = strdup(yytext); return NUMBER;}
true		{yylval.string = strdup(yytext); return TRUET;}
false		{yylval.string = strdup(yytext); return FALSET;}
null		{yylval.string = strdup(yytext); return NULLT;}
\{		return LB;
\}		return RB;
\[		return LSB;
\]		return RSB;
:		return COLON;
,		return COMMA;
[ \t\n]		;
.		fprintf(stderr, "Lexer error: %s\n", yytext);

%%

int yywrap() {
	return 1;
}

