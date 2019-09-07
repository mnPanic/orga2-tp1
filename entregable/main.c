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

// Llama a frpintf y borra el parámetro
void fprintfd(FILE* pfile, char* fmt, char* param) {
    fprintf(pfile, fmt, param);
    strDelete(param);
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
    fprintfd(pfile, "strConcat(a, a) = %s\n", strConcat(a, a));
    // strConcat(a, a) = aa
    fprintfd(pfile, "strConcat(abas, hola espacio) = %s\n", strConcat(strClone("abas"), strClone("hola espacio")));
    // strConcat(abas, hola espacio) = abashola espacio
    fprintfd(pfile, "strConcat(aa, aa) = %s\n", strConcat(strClone("aa"), strClone("aa")));
    // strConcat(aa, aa) = aaaa
    fprintfd(pfile, "strConcat(aa, ) = %s\n", strConcat(strClone("aa"), strClone("")));
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
    fprintfd(pfile, "strSubstring('ABC', 1, 1) = %s\n", strSubstring(strClone("ABC"), 1, 1));
    // strSubstring("ABC", 1, 1) = "B",
    fprintfd(pfile, "strSubstring('ABC', 10, 0) = %s\n", strSubstring(strClone("ABC"), 10, 0));
    // strSubstring("ABC", 10, 0) = "ABC",
    fprintfd(pfile, "strSubstring('ABC', 2, 10) = %s\n", strSubstring(strClone("ABC"), 2, 10));
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

    listDelete(l, (funcDelete_t*)&strDelete);
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

    listDelete(l2, (funcDelete_t*)&strDelete);
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
    listDelete(l3, (funcDelete_t*)&strDelete);
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
    listDelete(l4, (funcDelete_t*)&strDelete);

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
    listDelete(l5, (funcDelete_t*)&strDelete);
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
    listDelete(l6, (funcDelete_t*)&strDelete);

    /* listDelete */
    fprintf(pfile, "# listDelete\n");
    list_t* l7 = listNew();
    for(int i = 0; i < 20; i++){
        listAddFirst(l7, strClone("a"));
    }
    listPrint(l7, pfile, (funcPrint_t*)&strPrint); fprintf(pfile, "\n");
    // [a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a,a]
    listDelete(l7, (funcDelete_t*)&strDelete);
    
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

    listDelete(l8, (funcDelete_t*)&strDelete);
}

void test_hash_table(FILE* pfile) {
    fprintf(pfile, "\n");
    fprintf(pfile, "hash table\n");
    fprintf(pfile, "==========\n");

    char* ss[8] = {
        "abeja",    // 'a' = 97     s = 0       % 3 = 0
        "pepe",     // 'p' = 112    s = 15      % 3 = 0
        "beba",     // 'b' = 98     s = 1       % 3 = 1
        "moby",     // 'm' = 109    s = 12      % 3 = 0
        "flor",     // 'f' = 102    s = 5       % 3 = 2
        "verde",    // 'v' = 118    s = 21      % 3 = 0
        "hoja",     // 'h' = 104    s = 7       % 3 = 1
        "rojo",     // 'r' = 114    s = 17      % 3 = 2
    };

    /* hashTableNew */
    fprintf(pfile, "# hashTableNew\n");
    hashTable_t* t = hashTableNew(5, (funcHash_t*)&strHash);
    hashTablePrint(t, pfile, (funcPrint_t*)&strPrint);
    /*
    0 = []
    1 = []
    2 = []
    3 = []
    4 = []
    */
    hashTableDelete(t, (funcDelete_t*)&strDelete);

    /* hashTableAdd */
    fprintf(pfile, "# hashTableAdd\n");
    hashTable_t* t2 = hashTableNew(3, (funcHash_t*)&strHash);
    hashTableAdd(t2, strClone(ss[1]));
    hashTablePrint(t2, pfile, (funcPrint_t*)&strPrint);
    /*
    0 = [pepe]
    1 = []
    2 = []
    */
    hashTableDelete(t2, (funcDelete_t*)&strDelete);

    /* hashTableDeleteSlot */
    fprintf(pfile, "# hashTableDeleteSlot\n");
    hashTable_t* t3 = hashTableNew(3, (funcHash_t*)&strHash);
    for(int i = 0; i < 8; i++) {
        hashTableAdd(t3, strClone(ss[i]));
    }
    hashTablePrint(t3, pfile, (funcPrint_t*)&strPrint);
    for (int i = 0; i < 3; i++) {
        hashTableDeleteSlot(t3, i, (funcDelete_t*)&strDelete);
        hashTablePrint(t3, pfile, (funcPrint_t*)&strPrint);
    }
    /*
    0 = [abeja,pepe,moby,verde]
    1 = [beba,hoja]
    2 = [flor,rojo]
    0 = []
    1 = [beba,hoja]
    2 = [flor,rojo]
    0 = []
    1 = []
    2 = [flor,rojo]
    0 = []
    1 = []
    2 = []
    */
    hashTableDelete(t3, (funcDelete_t*)&strDelete);
}

int main (void){
    FILE *pfile = fopen("salida.caso.propios.txt","w");
    test_hashTable(pfile);

    /* Tests custom */
    test_string(pfile);
    test_list(pfile);
    test_hash_table(pfile);

    fclose(pfile);
    return 0;
}