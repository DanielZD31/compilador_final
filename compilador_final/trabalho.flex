
%{
#include "trabalho.tab.h"
#include <stdlib.h>

int lin = 1, col = 1;
%}

DIGITO 	[0-9]
LETRA	[A-Za-z_]

%%

" "		                { col += yyleng; }
\n		                { lin++; col = 1; }
"="                          { col += yyleng; return IGUAL; }
"+"                          { col += yyleng; return SOMA; }
"-"                          { col += yyleng; return SUBTRACAO; }
"*"                          { col += yyleng; return MULTIPLICACAO; }
"("                          { col += yyleng; return ABRE_PARENTESES; }
")"                          { col += yyleng; return FECHA_PARENTESES; }
"{"                          { col += yyleng; return ABRE_CHAVES; }
"}"                          { col += yyleng; return FECHA_CHAVES; }
";"                          { col += yyleng; return PONTO_E_VIRGULA; }
"int"                         { col += yyleng; return INTEIRO; }
"main"                        { col += yyleng; return PRINCIPAL; }
"return"                      { col += yyleng; return RETORNO; }
{DIGITO}+                     { col += yyleng; yylval.inteiro = atoi(yytext); return NUMERO; }
{LETRA}({LETRA}|{DIGITO})*     { col += yyleng; yylval.string = strdup(yytext); return IDENTIFICADOR; }
.                             { col += yyleng; return DESCONHECIDO; }

%%