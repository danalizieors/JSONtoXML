all: build

build:
	flex scan.l
	bison -y -d gram.y
	gcc y.tab.c lex.yy.c -o main
	./main
	rm lex.yy.c y.tab.c y.tab.h main

