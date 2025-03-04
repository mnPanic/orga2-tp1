#include "lib.h"


int32_t c_strCmp(char* pStringA, char* pStringB) {
    // Compara dos strings en orden lexicográfico. Retorna:
    //    0 si son iguales
    //    1 si a < b
    //   −1 si b < a

    while(pStringA != NULL) {
        if (*pStringA < *pStringB) {
            return 1;
        } else if (*pStringA > *pStringB) {
            return -1;
        }
        // a = b
        // sigo comparando

        pStringA++;
        pStringB++;
    }

    if (pStringB != NULL) {
        // Recorri todo A y fue todo igual a B
        return 1;
    }
    // Son iguales
    return 0;
}


/** STRING **/

char* strSubstring(char* pString, uint32_t inicio, uint32_t fin) {
    // Genera un nuevo string tomando los caracteres desde el ı́ndice inicio
    // hasta el ı́ndice fin inclusive, liberando la memoria ocupada por la string
    // pasada por parámetro. 
    // Considerando len como la cantidad de caracteres del string,
    //  - Si inicio>fin, retorna el mismo string pasado por parámetro. 
    //  - Si inicio>len, entonces retorna la string vacı́a. 
    //  - Si fin>len, se tomará como lı́mite superior la longitud del string. 
    //
    // Ejemplos: 
    //     strSubstring("ABC", 1, 1)  → "B",
    //     strSubstring("ABC", 10, 0) → "ABC",
    //     strSubstring("ABC", 2, 10) → "C"

    // Caso turbio: Si inicio > fin, retorno el mismo string
    if (inicio > fin) {
        return pString;
    }

    // Creo el nuevo string
    uint32_t len = strLen(pString);
    char* s = malloc(fin-inicio+2);

    // Debo tomar pString[i:f] ambos inclusive
    uint32_t i = inicio; // i = indice de pString
    uint32_t j = 0;      // j = indice de s
    while(i <= fin && i < len) {
        s[j] = pString[i];
        i++;
        j++;
    }
    s[j] = '\0';

    // Libero la memoria del string anterior
    free(pString);

    return s;
}

/** Lista **/

void _ptrPrint(void* e, FILE *pFile);

void listPrintReverse(list_t* pList, FILE *pFile, funcPrint_t* fp) {
    // Realiza la misma tarea que la función listPrint pero escribiendo los 
    // elementos de la lista en orden inverso.

    // Si fp es cero uso el print default
    if (fp == NULL) {
        fp = (funcPrint_t*)&_ptrPrint;
    }

    listElem_t* actual = pList->last;

    strPrint("[", pFile);
    while(actual != NULL) {
        fp(actual->data, pFile);

        if(actual->prev != NULL) {
            strPrint(",", pFile);
        }

        actual = actual->prev;
    }

    strPrint("]", pFile);
}

/** HashTable **/

uint32_t strHash(char* pString) {
  if(strLen(pString) != 0)
      return (uint32_t)pString[0] - 'a';
  else
      return 0;
}

void hashTableRemoveAll(hashTable_t* pTable, void* data, funcCmp_t* fc, funcDelete_t* fd) {
    // Borra todas las apariciones de data del slot al que pertenece. 
    // Si el valor de fd no es cero, la utiliza para borrar los datos dados.
    for (uint32_t i = 0; i < pTable->size; i++) {
        list_t* l = pTable->listArray[i];
        listRemove(l, data, fc, fd);
    }
}

void hashTablePrint(hashTable_t* pTable, FILE *pFile, funcPrint_t* fp) {
    // Escribe en el stream indicado por pFile la tabla de listas almacenada 
    // en t. Para cada dato llama a la función fp, y si es cero, escribe el 
    // puntero al dato con el formato "%p". Cada elemento del arreglo contiene 
    // una lista. 
    // Éstas serán escritas en lı́neas distintas respetando el siguiente formato:
    //
    //   i = [x_0 ,...,x_n−1 ]
    //
    // donde x_i es el resultado de escribir el i-ésimo dato.

    // Recorro la tabla printeando cada lista
    for(uint32_t i = 0; i < pTable->size; i++){
        fprintf(pFile, "%i = ", i);
        listPrint((pTable->listArray)[i], pFile, fp);
        fprintf(pFile, "\n");
    }
}
