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

    return 0;
}

/** Lista **/

void listPrintReverse(list_t* pList, FILE *pFile, funcPrint_t* fp) {

}

/** HashTable **/

uint32_t strHash(char* pString) {
  if(strLen(pString) != 0)
      return (uint32_t)pString[0] - 'a';
  else
      return 0;
}

void hashTableRemoveAll(hashTable_t* pTable, void* data, funcCmp_t* fc, funcDelete_t* fd) {

}

void hashTablePrint(hashTable_t* pTable, FILE *pFile, funcPrint_t* fp) {

}
