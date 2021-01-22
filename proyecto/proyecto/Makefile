a.out: proyecto.tab.c lex.yy.c tabla.c
		gcc proyecto.tab.c lex.yy.c tabla.c -ll

lex.yy.c: proyecto.l proyecto.tab.c
		flex proyecto.l

proyecto.tab.c: proyecto.y
		bison -d proyecto.y

clean:
		rm -f a.out proyecto.tab.* lex.yy.*
		clear

run: a.out
		./a.out
