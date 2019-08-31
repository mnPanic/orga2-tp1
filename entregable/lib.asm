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

%define ASCII_NULL 0
; least significant half mask
%define LSH_MASK 0x00000000FFFFFFFF

section .text
strLen:
    ; uint32_t strLen(char* pString)
    ;  Retorna la cantidad de caracteres, contando desde el primer caracter
    ;  hasta el último sin el caracter nulo (cero).

    ; res     = rax
    ; pString = rdi

    xor rax, rax    ; Vacio rax por si tiene basura

    ; Recorro desde pString hasta el caracter nulo, cuando llego, termine
    .loop:
    cmp byte [rdi], ASCII_NULL
    je .end

    inc rax     ; Incremento longitud
    inc rdi     ; Avanzo puntero
    jmp .loop

    .end:
    ret

strClone:
    ; char* strClone(char* pString);
    ;   Genera una copia del string pasado por parámetro. El puntero pasado 
    ;   siempre es válido aunque podrí́a corresponderse a la string vacı́a.
    ; rax = res
    ; rdi = pString

    push rbp
    mov rbp, rsp
    push r12        ; Preservo r12
    push r13        ; Preservo r13

    mov r12, rdi    ; r12 = pString
    
    ; Pido cantidad de memoria igual a la longitud del string
    ; pString ya está en rdi
    call strLen     ; rax = len(pString)
    mov rdi, rax
    call malloc     ; rax = ptr a nuevo string

    ; Copio el contenido de pString a el nuevo string llamando a _strCopy
    mov rdi, r12    ; str    = pString
    mov rsi, rax    ; into   = ptr a nuevo string
    xor rdx, rdx    ; offset = 0    
    mov r13, rax    ; preservo rax
    call _strCopy

    mov rax, r13    ; Retorno la dirección del nuevo string

    ; Reestablezco la pila
    pop r13
    pop r12
    pop rbp
    ret

; Rutina auxiliar
_strCopy:
    ; void _strCopy(char* str, into, int off)
    ;   Copia los caracteres de str a into, desde el offset off hasta el fin
    ;   del string, codificado por el caracter nulo.
    ;   Supone que into es suficientemente grande.
    
    ; rdi = str
    ; rsi = into
    ; edx  = off

    ; Limpio la parte alta de rdx (offset) para usarla como indice
    and rdx, LSH_MASK

    .loop:
        cmp byte [rdi + rdx], ASCII_NULL   ; Si estoy leyendo el caracter nulo,
        je .end                            ; termine.

        ; Copio el caracter actual de str a into usando un 
        ; registro intermedio de 8 bits
        mov al, [rdi + rdx]
        mov [rsi + rdx], al

        ; Incremento el offset
        inc rdx
        jmp .loop

    .end:
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
