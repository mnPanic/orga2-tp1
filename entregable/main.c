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

}

int main (void){
    FILE *pfile = fopen("salida.caso.propios.txt","w");
    test_hashTable(pfile);

    /* Tests custom */
    test_string(pfile);

    fclose(pfile);
    return 0;
}