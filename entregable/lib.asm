
section .rodata
    ASCII_NULL EQU "/0"
section .text

extern malloc
extern free
extern fprintf

global strLen
global strClone
global strCmp
global strConcat
global strDelete
global strPrint
global listNew
global listAddFirst
global listAddLast
global listAdd
global listRemove
global listRemoveFirst
global listRemoveLast
global listDelete
global listPrint
global hashTableNew
global hashTableAdd
global hashTableDeleteSlot
global hashTableDelete

strLen:
    ; uint32_t strLen(char* pString)
    ;  Retorna la cantidad de caracteres, contando desde el primer caracter
    ;  hasta el último sin el caracter nulo (cero).

    ; res     = rax
    ; pString = rdi

    xor rax, rax    ; Vacio rax por si tiene basura

    ; Recorro desde pString hasta el caracter nulo, cuando llego, termine
    .loop:
    test byte [rdi], ASCII_NULL
    jz .end

    inc rax     ; Incremento longitud
    inc rdi     ; Avanzo puntero
    jmp .loop

    .end:
    ret

strClone:
    ret

strCmp:
    ret

strConcat:
    ret

strDelete:
    ret
 
strPrint:
    ret
    
listNew:
    ret

listAddFirst:
    ret

listAddLast:
    ret

listAdd:
    ret

listRemove:
    ret

listRemoveFirst:
    ret

listRemoveLast:
    ret

listDelete:
    ret

listPrint:
    ret

hashTableNew:
    ret

hashTableAdd:
    ret
    
hashTableDeleteSlot:
    ret

hashTableDelete:
    ret
