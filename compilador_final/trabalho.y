
//COMPILADOR 
// Alunos: DANIEL e GUILHERME

//======================================================================================================
/*
 * Módulo de gerenciamento de pilha, variáveis e geração de código:
 * - Define uma pilha para manipulação de valores durante a execução.
 * - Implementa funções para criar, declarar e manipular variáveis.
 * - Contém lógica para verificar igualdade, diferença e atribuições entre variáveis.
 * - Gera código em Assembly para operações como soma, subtração e comparação.
 * - Utiliza estrutura modular para facilitar a manipulação e geração de saída.
 */
//======================================================================================================

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TOTAL_VARIAVEIS 8
#define TAMANHO_PILHA 8

typedef struct pilha{
	int vet[TAMANHO_PILHA];
	int topo;
}Pilha;

int empilhar_pilha(Pilha *p_pilha, int vlr){
	if (p_pilha->topo == TAMANHO_PILHA){ // Pilha cheia
		return 0;
	}

	p_pilha->vet[p_pilha->topo] = vlr;
	p_pilha->topo++;
	return 1;
}

int desfazer(Pilha *p_pilha){
	if (p_pilha->topo == 0)
		return 0;
	p_pilha->topo--;
	return 1;
}

int * topo_pilha(Pilha *p_pilha){
	if (p_pilha->topo == 0)
		return NULL;
	return &p_pilha->vet[p_pilha->topo-1];
}

extern int lin;
extern int col;
extern int yyleng;
extern char *yytext;
FILE *arquivo;

int valor = 0;
int i, j;
int cont = 0;
char etiquetas_variaveis[TOTAL_VARIAVEIS][TOTAL_VARIAVEIS];
int  resultados_variaveis[TOTAL_VARIAVEIS];

Pilha p_pilha;

int yyerror(char *msg){
	printf("%s (%i, %i) token encontrado: \"%s\"\n", msg, lin, col-yyleng, yytext);
	exit(0);
}
int yylex(void);

void montar_inicio(){
	arquivo = fopen("out.s","w+");
	fprintf(arquivo, ".text\n");
	fprintf(arquivo, "    .global _start\n\n");
    	fprintf(arquivo, "_start:\n\n");
}

void montar_final(){
	fclose(arquivo);

	printf("Arquivo \"out.s\" gerado.\n\n");
}

void retorno(int numero){
	fprintf(arquivo, "    movq    $%d, %%rbx\n", numero);
	fprintf(arquivo, "    movq    $1, %%rax\n");
	fprintf(arquivo, "    int     $0x80\n\n");
}

void soma(){
	fprintf(arquivo, "	popq 	%%rax\n");
	fprintf(arquivo, "	popq 	%%rbx\n");
	fprintf(arquivo, "	addq 	%%rbx, %%rax\n");
	fprintf(arquivo, "	pushq 	%%rax\n\n");
}

void subtracao(){
	fprintf(arquivo, "	popq 	%%rbx\n");
	fprintf(arquivo, "	popq 	%%rax\n");
	fprintf(arquivo, "	subq 	%%rbx, %%rax\n");
	fprintf(arquivo, "	pushq 	%%rax\n\n");
}

void multiplicacao(){
	fprintf(arquivo, "	popq 	%%rax\n");
	fprintf(arquivo, "	popq 	%%rbx\n");
	fprintf(arquivo, "	mulq 	%%rbx\n");
	fprintf(arquivo, "	pushq 	%%rax\n\n");
}

void ad_numero(int a){
	fprintf(arquivo, "	pushq 	$%i\n\n", a);
}

void imprimir_resultado() {
	fprintf(arquivo, "	popq 	%%rbx\n");
	fprintf(arquivo, "    movq    $1, %%rax\n");
	fprintf(arquivo, "    int     $0x80\n\n");
}

int variavel_criada(char variavel[]) {
    for (int i = 0; i < cont; i++) {
        if (strcmp(variavel, etiquetas_variaveis[i]) == 0) {
            return 1; // Variável já declarada
        }
    }
    return 0; // Variável não declarada
}


void criar_variavel(char variavel[] ){
    if (variavel_criada(variavel)) {
        printf("Erro: variável '%s' já declarada.\n", variavel);
        exit(0); // Finaliza o programa em caso de erro
    }	
	// printf("%s\n", variavel);
	for(i = 0; i < strlen(variavel); i++) {
		etiquetas_variaveis[cont][i] = variavel[i];
	}
	etiquetas_variaveis[cont][i] = '\0';
	resultados_variaveis[cont] = -999;

    fprintf(arquivo, ".data\n");
    fprintf(arquivo, "%s: .quad 0\n", variavel); // Reserva espaço para a variável
    fprintf(arquivo, ".text\n");

	cont++;
	
	/* for(i=0; i<5; i++) {
        printf("Variavel %s com valor %d\n",etiquetas_variaveis[i], resultados_variaveis[i]);
    }
	printf("\n\n"); */
	
}

void definir_valor_variavel(char variavel[]){
	for(i=0; i < TOTAL_VARIAVEIS; i++) {
		if (strcmp(variavel, etiquetas_variaveis[i]) == 0){
			resultados_variaveis[i] = *topo_pilha(&p_pilha); 
			desfazer(&p_pilha); 
		}
    }
}

void definir_valor_num_variavel(char variavel[] , int num){
	for(i=0; i < TOTAL_VARIAVEIS; i++) {
		if (strcmp(variavel, etiquetas_variaveis[i]) == 0){
			resultados_variaveis[i] = num;
		}
    }
}

void atribuir_valor_id_variavel(char variavel_que_recebe[] , char variavel_que_da[]){
	for(i=0; i < TOTAL_VARIAVEIS; i++) {
		if (strcmp(variavel_que_recebe, etiquetas_variaveis[i]) == 0){
			for(j=0; j < TOTAL_VARIAVEIS; j++) {
				if (strcmp(variavel_que_da, etiquetas_variaveis[j]) == 0){
					resultados_variaveis[i] = resultados_variaveis[j];
				}
			}
		}
    }
}

void inserir_variavel(char variavel[]){
	int num = -999;

    if (!variavel_criada(variavel)) {
        printf("Erro: variável '%s' não foi declarada.\n", variavel);
        exit(0);
    }	


	for(i=0; i < TOTAL_VARIAVEIS; i++) {
		if (strcmp(variavel, etiquetas_variaveis[i]) == 0){
			num = resultados_variaveis[i];
		}
    }
	fprintf(arquivo, "	pushq 	$%i\n\n", num);
}

void teste_igualdade_numerica(int a, int b){
	if (a == b) fprintf(arquivo, "	pushq 	$1\n\n");
		else 	fprintf(arquivo, "	pushq 	$0\n\n");
}

void teste_igualdade_id_numero(char variavel[], int b){
	for(i=0; i < TOTAL_VARIAVEIS; i++) {
		if (strcmp(variavel, etiquetas_variaveis[i]) == 0){
			if (resultados_variaveis[i] == b) fprintf(arquivo, "	pushq 	$1\n\n");
				else 						 fprintf(arquivo, "	pushq 	$0\n\n");
		}
    }		
}

void comparacao_ids(char variavel_a[] , char variavel_b[]){
	for(i=0; i < TOTAL_VARIAVEIS; i++) {
		if (strcmp(variavel_a, etiquetas_variaveis[i]) == 0){
			for(j=0; j < TOTAL_VARIAVEIS; j++) {
				if (strcmp(variavel_b, etiquetas_variaveis[j]) == 0){
					if (resultados_variaveis[i] == resultados_variaveis[j]) fprintf(arquivo, "	pushq 	$1\n\n");
					else 												  fprintf(arquivo, "	pushq 	$0\n\n");
				}
			}
		}
    }
}

void checar_diferenca_numeros(int a, int b){
	if (a == b) fprintf(arquivo, "	pushq 	$0\n\n");
		else 	fprintf(arquivo, "	pushq 	$1\n\n");
}

void checar_diferenca_id_numeros(char variavel[], int b){
	for(i=0; i < TOTAL_VARIAVEIS; i++) {
		if (strcmp(variavel, etiquetas_variaveis[i]) == 0){
			if (resultados_variaveis[i] == b) fprintf(arquivo, "	pushq 	$0\n\n");
				else 						 fprintf(arquivo, "	pushq 	$1\n\n");
		}
    }		
}

void diferenca_entre_ids(char variavel_a[] , char variavel_b[]){
	for(i=0; i < TOTAL_VARIAVEIS; i++) {
		if (strcmp(variavel_a, etiquetas_variaveis[i]) == 0){
			for(j=0; j < TOTAL_VARIAVEIS; j++) {
				if (strcmp(variavel_b, etiquetas_variaveis[j]) == 0){
					if (resultados_variaveis[i] == resultados_variaveis[j]) fprintf(arquivo, "	pushq 	$0\n\n");
					else 												  fprintf(arquivo, "	pushq 	$1\n\n");
				}
			}
		}
    }
}

//======================================================================================================
/*
 * Analisador Sintático e Semântico:
 * - Define a gramática da linguagem utilizando tokens e regras de precedência.
 * - Tokens representam palavras-chave, operadores e identificadores (e.g., SOMA, SUBTRACAO, NUMERO).
 * - Regras estruturam programas simples com declarações, expressões aritméticas e retorno de valores.
 * - Suporte para:
 *   - Declaração e atribuição de variáveis.
 *   - Operações aritméticas (soma, subtração, multiplicação).
 *   - Agrupamento de expressões com parênteses.
 * - Ações associadas às produções incluem:
 *   - Manipulação de pilhas para operações aritméticas.
 *   - Geração de código para operações e retorno de valores.
 * - Entrada principal (`main`) inicializa o analisador e sinaliza o término da execução.
 */
//======================================================================================================

%}

%union { 
  	char *string; 
  	int inteiro; 
} 

%token INTEIRO PRINCIPAL ABRE_PARENTESES FECHA_PARENTESES ABRE_CHAVES RETORNO PONTO_E_VIRGULA FECHA_CHAVES DESCONHECIDO
%token SOMA SUBTRACAO MULTIPLICACAO IGUAL

%token <string> OPERADOR_RELACIONAL
%token <string> IDENTIFICADOR
%token <inteiro> NUMERO

%left SOMA SUBTRACAO  
%left MULTIPLICACAO
%%

programa	: INTEIRO PRINCIPAL ABRE_PARENTESES FECHA_PARENTESES ABRE_CHAVES {montar_inicio();} bloco FECHA_CHAVES {montar_final();} ;

bloco		: RETORNO expressao PONTO_E_VIRGULA   			{imprimir_resultado();} bloco
			| INTEIRO IDENTIFICADOR PONTO_E_VIRGULA	   		{criar_variavel($2);} bloco
			| declaracao_variavel 								{valor = 0;}			 bloco
			| 
			;
declaracao_variavel : IDENTIFICADOR IGUAL resultado PONTO_E_VIRGULA			{definir_valor_variavel($1);}
			;
resultado     : NUMERO									{empilhar_pilha(&p_pilha, $1);}
			| IDENTIFICADOR									{for(i=0; i < TOTAL_VARIAVEIS; i++) {
														if (strcmp($1, etiquetas_variaveis[i]) == 0){
															valor = resultados_variaveis[i]; empilhar_pilha(&p_pilha, valor); valor = 0;
														}
													}}
			| resultado SOMA resultado							{valor+=*topo_pilha(&p_pilha); desfazer(&p_pilha); valor+=*topo_pilha(&p_pilha); desfazer(&p_pilha); empilhar_pilha(&p_pilha, valor); valor = 0;}
			| resultado SUBTRACAO resultado							{valor+=(0 - *topo_pilha(&p_pilha)); desfazer(&p_pilha); valor+=(*topo_pilha(&p_pilha)); desfazer(&p_pilha); empilhar_pilha(&p_pilha, valor); valor = 0;}
			| resultado MULTIPLICACAO resultado							{valor=*topo_pilha(&p_pilha); desfazer(&p_pilha); valor*=*topo_pilha(&p_pilha); desfazer(&p_pilha); empilhar_pilha(&p_pilha, valor); valor = 0;}
			| ABRE_PARENTESES resultado FECHA_PARENTESES
			;
expressao         : expressao SOMA expressao 						    {soma();} 
			| expressao SUBTRACAO expressao 					    {subtracao();} 
			| expressao MULTIPLICACAO expressao 						    {multiplicacao();}
			| ABRE_PARENTESES expressao FECHA_PARENTESES
			| NUMERO								    {ad_numero($1);  }
			| IDENTIFICADOR								    {inserir_variavel($1);}
			;
%%

int main(){
	yyparse();
	printf("Execução do programa finalizada com sucesso.\n");
}

