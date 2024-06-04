%{
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>

	#include "tree.h"
	#include "tpcas.h"

	unsigned int lineno = 1;
%}

%x COMMENT_SHORT
%x COMMENT_LONG

%option nounput
%option noinput
%option noyywrap

%%
"//"								{BEGIN(COMMENT_SHORT);}
<COMMENT_SHORT>.					{;}
<COMMENT_SHORT>[\n]					{lineno++; BEGIN(INITIAL);}
"/*" 								{BEGIN(COMMENT_LONG);}
<COMMENT_LONG>.						{;}
<COMMENT_LONG>[\n]					{lineno++;}
<COMMENT_LONG>"*/" 					{BEGIN(INITIAL);}

[" "|\t] 							{;}

[1-9][0-9]*|0 						{yylval.num = atoi(yytext); return NUM;}
[\*\/%] 							{yylval.byte = yytext[0]; return DIVSTAR;}
"||" 								{return OR;}
"&&"								{return AND;}
"=="|"!="							{strcpy(yylval.comp, yytext); return EQ;}
"+"|"-"								{yylval.byte = yytext[0]; return ADDSUB;}
"<"|"<="|">"|">=" 					{strcpy(yylval.comp, yytext); return ORDER;}

void 								{return VOID;}
while 								{return WHILE;}
if 									{return IF;}
else 								{return ELSE;}
return 								{return RETURN;}

<<EOF>>                     		{return 0;}

"int"|"char"						{strcpy(yylval.ident, yytext); return TYPE;}

['](([\\]n|[\\]t|[\\]\\)|[^\'])[']	{if(yytext[1] == '\\') {
										switch(yytext[2]) {
											case 'n' : yylval.byte = '\n'; break;
											case 't' : yylval.byte = '\t'; break;
											case '\'' : yylval.byte = '\''; break;
										}
									}
									else {
										yylval.byte = yytext[1];
									}
									return CHARACTER;}

[a-zA-Z_][0-9a-zA-Z_]* 				{strcpy(yylval.ident, yytext); return IDENT;}
. 									{return yytext[0];}
[\n] 								{lineno++;}

%%
