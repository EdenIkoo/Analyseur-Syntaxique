/* tree.h */

typedef enum {
  Prog,
  DeclVars,
  DeclFoncts,
  Declarateurs,
  DeclVarsLocale,
  DeclaLocale,
  DeclFonct,
  Type,
  Ident,
  Void,
  Parametres,
  ListTypVar,
  SuiteInstr,
  Instr,
  LValue,
  If,
  While,
  Else,
  Return,
  And,
  Or,
  Equal,
  Order,
  Addsub,
  Divstar,
  Number,
  Character,
  ListExp,
  Fonction
  /* list all other node labels, if any */
  /* The list must coincide with the string array in tree.c */
  /* To avoid listing them twice, see https://stackoverflow.com/a/10966395 */
} label_t;

typedef struct Node {
  label_t label;
  struct Node *firstChild, *nextSibling;
  int lineno;
  union {
    char byte;
    int num;
    char ident[64];
    char comp[3];
  } value;
} Node;

Node *makeNode(label_t label);
void addSibling(Node *node, Node *sibling);
void addChild(Node *parent, Node *child);
void deleteTree(Node*node);
void printTree(Node *node);

#define FIRSTCHILD(node) node->firstChild
#define SECONDCHILD(node) node->firstChild->nextSibling
#define THIRDCHILD(node) node->firstChild->nextSibling->nextSibling
