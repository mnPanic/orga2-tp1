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

int main (void){
    //FILE *pfile = fopen("salida.caso.propios.txt","w");
    //test_hashTable(pfile);

    /* Tests custom */
    // strLen
    char* s = "esto es una prueba"; // len: 18
    printf("len(%s) = %i\n", s, strLen(s));

    //fclose(pfile);
    return 0;
}