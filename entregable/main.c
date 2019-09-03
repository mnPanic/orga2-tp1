#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <math.h>

#include "lib.h"

void test_hashTable(FILE *pfile){
    // TODO
}

void test_string(FILE *pfile) {
    fprintf(pfile, "string\n");
    fprintf(pfile, "======\n");

    char* prueba = "esto es una prueba";
    
    /* strLen */
    fprintf(pfile, "# strLen\n");
    fprintf(pfile, "len(%s) = %i\n", prueba, strLen(prueba));
    // res: len(esto es una prueba) = 18

    fprintf(pfile, "len(%s) = %i\n", "", strLen(""));
    // res: len() = 0

    /* strClone */
    fprintf(pfile, "# strClone\n");
    char* str = "hola manola";
    char* cn = strClone(str);
    fprintf(pfile, "strClone(%s) = %s\n", str, cn);
    free(cn);
    // res: strClone(hola manola) = hola manola

    /* strCmp */
    fprintf(pfile, "# strCmp\n");
    fprintf(pfile, "strCmp(a, b) = %i\n", strCmp("a", "b"));
    // strCmp(a, b) = 1
    fprintf(pfile, "strCmp(w, a) = %i\n", strCmp("w", "a"));
    // strCmp(w, a) = -1
    fprintf(pfile, "strCmp(x, x) = %i\n", strCmp("x", "x"));
    // strCmp(x, x) = 0
    fprintf(pfile, "strCmp(abcde, abcd) = %i\n", strCmp("abcde", "abcd"));
    // strCmp(abcde, abcd) = -1
    fprintf(pfile, "strCmp(abc, abcd) = %i\n", strCmp("abc", "abcd"));
    // strCmp(abc, abcd) = 1
    fprintf(pfile, "strCmp(abcdef, ) = %i\n", strCmp("abcdef", ""));
    // strCmp(abcdef,) = -1
    fprintf(pfile, "strCmp(, abcdef) = %i\n", strCmp("", "abcdef"));
    // strCmp(, abcdef) = 1

    /* strConcat */
    fprintf(pfile, "# strConcat\n");
    char * a = strClone("a"); // el free lo hace concat
    fprintf(pfile, "strConcat(a, a) = %s\n", strConcat(a, a));
    // strConcat(a, a) = aa
    fprintf(pfile, "strConcat(abas, hola espacio) = %s\n", strConcat(strClone("abas"), strClone("hola espacio")));
    // strConcat(abas, hola espacio) = abashola espacio
    fprintf(pfile, "strConcat(aa, aa) = %s\n", strConcat(strClone("aa"), strClone("aa")));
    // strConcat(aa, aa) = aaaa
    fprintf(pfile, "strConcat(aa, ) = %s\n", strConcat(strClone("aa"), strClone("")));
    // strConcat(aa, ) = aa

    /* strPrint */
    fprintf(pfile, "# strPrint\n");
    strPrint("hola hola", pfile);
    fprintf(pfile, "\n");
    // hola hola
    strPrint("", pfile);
    fprintf(pfile, "\n");
    // NULL

    /* strSubstring */
    fprintf(pfile, "# strSubstring\n");
    fprintf(pfile, "strSubstring('ABC', 1, 1) = %s\n", strSubstring(strClone("ABC"), 1, 1));
    // strSubstring("ABC", 1, 1) = "B",
    fprintf(pfile, "strSubstring('ABC', 10, 0) = %s\n", strSubstring(strClone("ABC"), 10, 0));
    // strSubstring("ABC", 10, 0) = "ABC",
    fprintf(pfile, "strSubstring('ABC', 2, 10) = %s\n", strSubstring(strClone("ABC"), 2, 10));
    // strSubstring("ABC", 2, 10) = "C"

}

void test_list(FILE *pfile) {
    fprintf(pfile, "\n");
    fprintf(pfile, "list\n");
    fprintf(pfile, "====\n");

    /* listAddFirst */
    fprintf(pfile, "# listAddFirst\n");
    list_t* l = listNew();
    listPrint(l, pfile, (funcPrint_t*)&strPrint); fprintf(pfile, "\n");
    // []

    listAddFirst(l, strClone("pepe"));
    listPrint(l, pfile, (funcPrint_t*)&strPrint); fprintf(pfile, "\n");
    // [pepe]

    listAddFirst(l, strClone("muy atento"));
    listPrint(l, pfile, (funcPrint_t*)&strPrint); fprintf(pfile, "\n");
    // [muy atento,pepe]

    /* listAddLast */
    fprintf(pfile, "# listAddLast\n");
    list_t* l2 = listNew();
    listPrint(l2, pfile, (funcPrint_t*)&strPrint); fprintf(pfile, "\n");
    // []

    listAddLast(l2, strClone("pepe"));
    listPrint(l2, pfile, (funcPrint_t*)&strPrint); fprintf(pfile, "\n");
    // [pepe]

    listAddLast(l2, strClone("muy atento"));
    listPrint(l2, pfile, (funcPrint_t*)&strPrint); fprintf(pfile, "\n");
    // [pepe,muy atento]

    /* listAdd */
    fprintf(pfile, "# listAdd\n");
    list_t* l3 = listNew();
    listPrint(l3, pfile, (funcPrint_t*)&strPrint); fprintf(pfile, "\n");
    // []
    listAdd(l3, strClone("b"), (funcCmp_t*)&strCmp);
    listPrint(l3, pfile, (funcPrint_t*)&strPrint); fprintf(pfile, "\n");
    // [b]
    listAdd(l3, strClone("w"), (funcCmp_t*)&strCmp);
    listPrint(l3, pfile, (funcPrint_t*)&strPrint); fprintf(pfile, "\n");
    // [b,w]
    listAdd(l3, strClone("j"), (funcCmp_t*)&strCmp);
    listPrint(l3, pfile, (funcPrint_t*)&strPrint); fprintf(pfile, "\n");
    // [b,j,w]
    listAdd(l3, strClone("a"), (funcCmp_t*)&strCmp);
    listPrint(l3, pfile, (funcPrint_t*)&strPrint); fprintf(pfile, "\n");
    // [a,b,j,w]

    /* listRemoveFirst */
    fprintf(pfile, "# listRemoveFirst\n");
    list_t* l4 = listNew();
    listAddFirst(l4, strClone("tercero"));
    listAddFirst(l4, strClone("segundo"));
    listAddFirst(l4, strClone("primero"));
    listPrint(l4, pfile, (funcPrint_t*)&strPrint); fprintf(pfile, "\n");
    // [primero,segundo,tercero]
    listRemoveFirst(l4, (funcDelete_t*)&strDelete);
    listPrint(l4, pfile, (funcPrint_t*)&strPrint); fprintf(pfile, "\n");
    // [segundo,tercero]
    listRemoveFirst(l4, (funcDelete_t*)&strDelete);
    listPrint(l4, pfile, (funcPrint_t*)&strPrint); fprintf(pfile, "\n");
    // [tercero]
    listRemoveFirst(l4, (funcDelete_t*)&strDelete);
    listPrint(l4, pfile, (funcPrint_t*)&strPrint); fprintf(pfile, "\n");
    // []

    /* listRemoveLast */
    fprintf(pfile, "# listRemoveLast\n");
    list_t* l5 = listNew();
    listAddFirst(l5, strClone("tercero"));
    listAddFirst(l5, strClone("segundo"));
    listAddFirst(l5, strClone("primero"));
    listPrint(l5, pfile, (funcPrint_t*)&strPrint); fprintf(pfile, "\n");
    // [primero,segundo,tercero]
    listRemoveLast(l5, (funcDelete_t*)&strDelete);
    listPrint(l5, pfile, (funcPrint_t*)&strPrint); fprintf(pfile, "\n");
    // [primero,segundo]
    listRemoveLast(l5, (funcDelete_t*)&strDelete);
    listPrint(l5, pfile, (funcPrint_t*)&strPrint); fprintf(pfile, "\n");
    // [primero]
    listRemoveLast(l5, (funcDelete_t*)&strDelete);
    listPrint(l5, pfile, (funcPrint_t*)&strPrint); fprintf(pfile, "\n");
    // []

    /* listRemove */
    fprintf(pfile, "# listRemove\n");
    list_t* l6 = listNew();
    listAddFirst(l6, strClone("a"));
    listAddLast(l6, strClone("b"));
    listAddLast(l6, strClone("a"));
    listAddLast(l6, strClone("a"));
    listAddLast(l6, strClone("d"));
    listAddLast(l6, strClone("d"));
    listAddLast(l6, strClone("a"));
    listAddLast(l6, strClone("a"));
    listAddLast(l6, strClone("e"));
    listAddLast(l6, strClone("a"));
    listPrint(l6, pfile, (funcPrint_t*)&strPrint); fprintf(pfile, "\n");
    // [a,b,a,a,d,d,a,a,e,a]

    listRemove(l6, "a", (funcCmp_t*)&strCmp, (funcDelete_t*)&strDelete);
    listPrint(l6, pfile, (funcPrint_t*)&strPrint); fprintf(pfile, "\n");
    // [b,d,d,e]

    /* listDelete */
    fprintf(pfile, "# listDelete\n");
    list_t* l7 = listNew();
    for(int i = 0; i < 20; i++){
        listAddFirst(l7, strClone("a"));
    }
    listPrint(l7, pfile, (funcPrint_t*)&strPrint); fprintf(pfile, "\n");
    // [a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a]
    listDelete(l7, (funcDelete_t*)&strDelete);
    listPrint(l7, pfile, (funcPrint_t*)&strPrint); fprintf(pfile, "\n");
    // []
    
    /* listPrintReverse */
    fprintf(pfile, "# listPrintReverse\n");
    char* strs[10] = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j"};
    list_t* l8 = listNew();
    for(int i = 0; i < 10; i++) {
        listAddLast(l8, strClone(strs[i]));
    }
    listPrint(l8, pfile, (funcPrint_t*)&strPrint); fprintf(pfile, "\n");
    // [a,b,c,d,e,f,g,h,i,j]
    listPrintReverse(l8, pfile, (funcPrint_t*)&strPrint); fprintf(pfile, "\n");
    // [j,i,h,g,f,e,d,c,b,a]
}

int main (void){
    FILE *pfile = fopen("salida.caso.propios.txt","w");
    test_hashTable(pfile);

    /* Tests custom */
    test_string(pfile);
    test_list(pfile);

    fclose(pfile);
    return 0;
}