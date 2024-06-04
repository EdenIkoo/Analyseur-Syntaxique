%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "tree.h"
    int yylex();
    void yyerror(char *msg);

    extern char *yytext;
    extern unsigned int lineno;

    Node *tree;

    extern char *yytext;
    extern unsigned int lineno;

%}
%union{
    Node *node;
    char byte;
    int num;
    char ident[64];
    char comp[3];
}

%type <node> Prog DeclVars DeclFoncts Declarateurs DeclVarsLocale DeclaLocale DeclFonct EnTeteFonct Parametres ListTypVar Corps SuiteInstr Instr Exp TB FB M E T F LValue Arguments ListExp
%token <byte> CHARACTER DIVSTAR ADDSUB
%token <num> NUM  
%token <ident> IDENT TYPE
%token <comp> EQ ORDER

%token OR AND VOID WHILE IF ELSE RETURN

%left ADDSUB
%left DIVSTAR
%left AND
%left OR
%right '(' ')'
%left ELSE

%%
Prog:  DeclVars DeclFoncts 	{$$ = makeNode(Prog);
                                Node *node1 = makeNode(DeclVars);
                                addChild($$, node1);
                                addChild(node1, $1);
                                Node *node2 = makeNode(DeclFoncts);
                                addChild($$, node2);
                                addChild(node2, $2);
                                tree = $$;}
    ;

DeclVars:
       DeclVars TYPE Declarateurs ';' {Node *node1 = makeNode(Type); 
                                        strcpy(node1->value.ident, $2);
                                            if($1) {
                                                $$ = $1;
                                            } else{
                                                $$ = node1;
                                                addChild(node1, $3);
                                            }
                                            if($1) {
                                             	Node *node2 = makeNode(Type);
                                                strcpy(node2->value.ident, $2);
                                                addSibling($$, node2);
                                                addChild(node2, $3);
                                            }
                                        }

    |                                 {$$ = NULL;}
    ;

Declarateurs:
       Declarateurs ',' IDENT 			{$$ = $1; 
                                            Node *n = makeNode(Ident);
                                            strcpy(n->value.ident, $3);
                                            addSibling($$, n);}
    |  Declarateurs ',' IDENT '[' NUM ']'   {
                                            $$ = $1;
                                            Node *n = makeNode(Ident);
                                            addSibling($$, n);
                                            strcpy(n->value.ident, $3);
                                            addChild($$, n);
                                            n->value.num = $5;
                                            }
    |  IDENT                            {$$ = makeNode(Ident);
                                            strcpy($$->value.ident, $1);}
    |  IDENT '[' NUM ']'    {  
                            $$ = makeNode(Ident);
                            strcpy($$->value.ident, $1);
                            Node *n = makeNode(Ident);
                            addChild($$, n);
                            n->value.num = $3;
                            }
    ;
    ;

DeclVarsLocale:
        DeclVarsLocale TYPE DeclaLocale ';'   {Node *node1 = makeNode(Type); 
                                                strcpy(node1->value.ident, $2);
                                                if($1) {
                                                    $$ = $1;
                                                } else{
                                                    $$ = node1;
                                                    addChild(node1, $3);
                                                }
                                                if($1) {
                                             	    Node *node2 = makeNode(Type);
                                                    strcpy(node2->value.ident, $2);
                                                    addSibling($$, node2);
                                                    addChild(node2, $3);
                                                }
                                                }

    |   DeclVarsLocale TYPE IDENT '=' Exp ';' {$$ = makeNode(Type);
                                                strcpy($$->value.ident, $2);
                                                Node *n = makeNode(Ident);
                                                strcpy(n->value.ident, $3);
                                                addChild($$, n);
                                                addChild(n, $5);
                                            }
                                            
    |                                          {$$ = NULL;}
    ;

DeclaLocale:
        DeclaLocale ',' IDENT              {$$ = $1; 
                                            Node *n = makeNode(Ident);
                                            strcpy(n->value.ident, $3);
                                            addSibling($$, n);}

    |   IDENT                           {$$ = makeNode(Ident);
                                            strcpy($$->value.ident, $1);}

    |   DeclaLocale ',' IDENT '=' Exp      {$$ = makeNode(DeclaLocale);
                                            Node *n = makeNode(Ident);
                                            strcpy(n->value.ident, $3);
                                            addChild($$, n);
                                            addChild(n, $5);
                                        }
    ;

DeclFoncts:                                 
       DeclFoncts DeclFonct   {$$ = $1;
                                  addSibling($$, $2);}
    |  DeclFonct               {$$ = $1;}
    ;

DeclFonct:
       EnTeteFonct Corps    {$$ = $1; 
                               addChild($$, $2);}
    ;

EnTeteFonct:
       TYPE IDENT '(' Parametres ')'	{$$ = makeNode(Type);
                                            strcpy($$->value.ident, $1);
                                            Node* n = makeNode(Ident);
                                            strcpy(n->value.ident, $2); 
                                            addChild($$, n); 
                                            Node* m = makeNode(Parametres);
                                            addChild(n, m); addChild(m, $4);}

    |  VOID IDENT '(' Parametres ')'	{$$ = makeNode(Void); 
                                            Node* n = makeNode(Ident);
                                            strcpy(n->value.ident, $2);
                                            addChild($$, n); 
                                            Node* m = makeNode(Parametres); 
                                            addChild(n, m); 
                                            addChild(m, $4);}
    ;

Parametres:
       VOID 		{$$ = makeNode(Void);}
    |  ListTypVar 	{$$ = $1;}
    |               {$$ = makeNode(Void);}
    ;

ListTypVar:
       ListTypVar ',' TYPE IDENT 	{Node* n = makeNode(Type);
                                        strcpy(n->value.ident, $3);
                                        addSibling($$, n);  
                                        Node* m = makeNode(Ident);
                                        strcpy(m->value.ident, $4);
                                        addChild(n, m);}
    |  ListTypVar ',' TYPE IDENT '['']' {
                                        $$ = makeNode(Type);
                                        strcpy($$->value.ident, $3);
                                        addSibling($$, $1);
                                        Node* j = makeNode(Ident);
                                        addChild($$, j);
                                        strcpy(j->value.ident, $4);}

    |  TYPE IDENT 					{$$ = makeNode(Type); 
                                        strcpy($$->value.ident, $1); 
                                        Node* o = makeNode(Ident);
                                        strcpy(o->value.ident, $2);
                                        addChild($$, o);}
    |  TYPE IDENT '['']'    {
                            $$ = makeNode(Type);
                            strcpy($$->value.comp, $1);
                            Node* i = makeNode(Ident);
                            addChild($$, i);
                            strcpy(i->value.ident, $2);
                            }
    ;

Corps: 
        '{' DeclVarsLocale SuiteInstr '}' {$$ = makeNode(DeclVarsLocale); 
                                        addChild($$, $2);
                                        addSibling($$, $3);}
    ;

SuiteInstr:
       SuiteInstr Instr                     {$$ = ($1 ? $1 : $2); 
                                              if ($1) addSibling($$, $2);}
    |                                       {$$ = NULL;}
    ;

Instr:
      LValue '=' Exp ';'               {$$ = makeNode(LValue); 
                                        addChild($$, $1);
                                        addChild($1, $3);}

    |  IF '(' Exp ')' Instr                 {$$ = makeNode(If); 
                                              addChild($$, $3);
                                              addChild($3, $5);}

    |  IF '(' Exp ')' Instr ELSE Instr      {$$ = makeNode(If); 
                                              addChild($$, $3);
                                              addChild($3, $5);
                                              Node* n = makeNode(Else);
                                              addChild($$, n);
                                              addChild(n, $7);}

    |  WHILE '(' Exp ')' Instr              {$$ = makeNode(While); 
                                              addChild($$, $3);
                                              addChild($3, $5); }

    |  IDENT '(' Arguments  ')' ';'         {$$ = makeNode(Fonction);
                                              strcpy($$->value.ident, $1);
                                              addChild($$, $3);}

    |  RETURN Exp ';'                       {$$ = makeNode(Return); 
                                              addChild($$, $2);}

    |  RETURN ';'                           {$$ = makeNode(Return);}
    |  '{' SuiteInstr '}'                   {$$ = $2;}
    |  ';'                                  {$$ = NULL;}    
    ;

Exp :
        Exp OR TB                           {$$ = makeNode(Or); 
                                              addChild($$, $1); 
                                              addChild($$, $3);}
    |  TB                                   {$$ = $1;}
    ;

TB  :  
        TB AND FB                           {$$ = makeNode(And); 
                                              addChild($$, $1); 
                                              addChild($1, $3);}
    |  FB                                   {$$ = $1;}
    ;

FB  :  
        FB EQ M                             {$$ = makeNode(Equal);
                                              strcpy($$->value.comp, $2); 
                                              addChild($$, $1); 
                                              addChild($1, $3);}
    |  M                                    {$$ = $1;}
    ;

M   :  
        M ORDER E                           {$$ = makeNode(Order);
                                              strcpy($$->value.comp, $2);  
                                              addChild($$, $1); 
                                              addChild($1, $3);}
    |  E                                    {$$ = $1;}
    ;

E   :  
        E ADDSUB T                          {$$ = makeNode(Addsub);
                                              $$->value.byte = $2;  
                                              addChild($$, $1); 
                                              addChild($1, $3);}
    |  T                                    {$$ = $1;}
    ;  

T   :
        T DIVSTAR F                         {$$ = makeNode(Divstar);
                                              $$->value.byte = $2;  
                                              addChild($$, $1); 
                                              addChild($1, $3);}
    |  F                                    {$$ = $1;}
    ;

F   :  
        ADDSUB F                            {$$ = makeNode(Addsub);
                                              $$->value.byte = $1; 
                                              addChild($$, $2);}

    |  '(' Exp ')'                          {$$ = $2;}

    |  NUM                                  {$$ = makeNode(Number);
                                             $$->value.num = $1;}

    |  CHARACTER                            {$$ = makeNode(Character);
                                             $$->value.byte = $1;}

    |  LValue                               {$$ = $1;}
    
    |  IDENT '(' Arguments  ')'             {$$ = makeNode(Fonction);
                                              strcpy($$->value.ident, $1);
                                              addChild($$, $3);}
    ;
    
LValue:
        IDENT 		{$$ = makeNode(Ident);
                    strcpy($$->value.ident, $1);}
    ;

Arguments:
       ListExp 	{$$ = $1;}
    |			{$$ = NULL;}
    ;

ListExp:
       ListExp ',' Exp 	{$$ = $1; addSibling($$, $3);}
    |  Exp 				{$$ = $1;}
    ;

%%

void yyerror(char *s) {
    fprintf(stderr, "%s near line %d\n", s, lineno);
}

int main(int argc, char *argv[]){
    int i = yyparse();

    if(argc > 1){
        if(!strcmp(argv[1], "-h") || !strcmp(argv[1], "--help")){
            printf("%s\n", yytext);
        }
        if(!strcmp(argv[1], "-t") || !strcmp(argv[1], "--tree")){
        	printTree(tree);
            deleteTree(tree);
            return 0;
        }
    }
    return i;
}
