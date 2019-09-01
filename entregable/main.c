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

    /* listAdd */
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