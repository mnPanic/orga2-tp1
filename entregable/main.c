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
}

int main (void){
    FILE *pfile = fopen("salida.caso.propios.txt","w");
    test_hashTable(pfile);

    /* Tests custom */
    test_string(pfile);

    fclose(pfile);
    return 0;
}