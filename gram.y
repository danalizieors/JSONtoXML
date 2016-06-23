%{
	#include <stdio.h>
	#include <string.h>

	int yylex();
	void yyerror(char *);

	struct Node {
		char *pre;
		char *post;
		struct Node *right;
		struct Node *down;
	};

	struct Node* new_node();
	struct Node* head = NULL;
%}

%union {
	char *string;
	struct Node *node;
}

%token <string> STRING
%token <string> NUMBER
%token <string> TRUET FALSET NULLT
%token LB RB LSB RSB COLON COMMA

%type <node> object keyvalues keyvalue array values value

%%

document
	: object			{head = $1;}
	;

object
	: LB keyvalues RB		{$$ = $2;}
	;

keyvalues
	:				{$$ = NULL;}
	| keyvalue			{$$ = $1;}
	| keyvalue COMMA keyvalues	{$$ = $1; $1->down = $3;}
	;

keyvalue
	: STRING COLON value		{
	$1[strlen($1)-1] = '\0';
	$$ = new_node();
	$$->pre = (char *)malloc(sizeof(char)*strlen($1)+10);
	sprintf($$->pre, "<%s>", $1+1);
	$$->post = (char *)malloc(sizeof(char)*strlen($1)+10);
	sprintf($$->post, "</%s>", $1+1);
	$$->right = $3;
}
	;

array
	: LSB RSB			{$$ = NULL;}
	| LSB values RSB		{$$ = $2;}
	;

values
	: value				{
	$$ = new_node();
	$$->pre = strdup("<item>");
	$$->post = strdup("</item>");
	$$->right = $1;
}
	| value COMMA values		{
	$$ = new_node();
	$$->pre = strdup("<item>");
	$$->post = strdup("</item>");
	$$->right = $1;
	$$->down = $3;
}
	;

value
	: STRING			{$$ = new_node(); $$->pre = $1;}
	| NUMBER			{$$ = new_node(); $$->pre = $1;}
	| object			{$$ = $1;}
	| array				{$$ = $1;}
	| TRUET				{$$ = new_node(); $$->pre = $1;}
	| FALSET			{$$ = new_node(); $$->pre = $1;}
	| NULLT				{$$ = new_node(); $$->pre = $1;}
	;

%%

const struct Node NODE_DEFAULT = { NULL, NULL, NULL, NULL };

struct Node* new_node() {
	struct Node *tmp = (struct Node*)malloc(sizeof(struct Node));
	*tmp = NODE_DEFAULT;
	return tmp;
}

void print_tabs(int n) {
	while (n--) printf("\t");
}

void print_tree(struct Node *tree, int tab) {
	if (tree->pre) {print_tabs(tab); printf("%s\n", tree->pre);}
	if (tree->right) print_tree(tree->right, tab + 1);
	if (tree->post) {print_tabs(tab); printf("%s\n", tree->post);}
	if (tree->down) print_tree(tree->down, tab);
}

void yyerror(char *text) {
   	fprintf(stderr, "Parser error: %s\n", text);
}

int main() {
	yyparse();
	if (head) print_tree(head, 0);
}

