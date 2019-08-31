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

section .rodata:
    STR_FMT:  db "%s", 0
    STR_NULL: db "NULL", 0

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
    mov rdi, rax    ; dst   = ptr a nuevo string
    mov rsi, r12    ; src   = pString
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
    ; int32_t _strCopy(char* dst, char* src, int offset_dst)
    ;   Copia el contenido de src a dst desde el offset_dst especificado.
    ;   Devuelve la cantidad de caracteres copiados (i.e len(from))
    ;   Supone que into es suficientemente grande.

    ; rdi = dst (d = destination)
    ; rsi = src (s = source)
    ; edx = offset_dst
    ; rax = offset_src

    ; Limpio la parte alta de rdx (offset) para usarla como offset de dst
    and rdx, LSH_MASK
    ; Limpio rax para usarlo como offset de src
    xor rax, rax

    .loop:
        cmp byte [rsi + rax], ASCII_NULL   ; Si estoy leyendo el caracter nulo,
        je .end                            ; termine.

        ; Copio el caracter actual de src a dst usando un 
        ; registro intermedio de 8 bits
        mov r8b, [rsi + rax]
        mov [rdi + rdx], r8b

        inc rdx ; offset_dst++
        inc rax ; offset_src++
        jmp .loop

    .end:
        ret

strCmp:
    ; int32_t strCmp(char* pStringA, char* pStringB)
    ;  Compara dos strings en orden lexicográfico. Retorna:
    ;    0 si son iguales
    ;    1 si a < b
    ;   −1 si b < a
    ;
    ; Noto que como el fin de cadena es 0, la cadena vacía es la mas chica
    ; Realizo las comparaciones por la codificación ascii

    ; rdi = pStringA
    ; rsi = pStringB

    ; Stack frame
    push rbp
    mov rbp, rsp
    ; Preservo r12 y r13
    push r12
    push r13        

    mov r12, rdi ; r12 = pStringA
    mov r13, rsi ; r13 = pStringB
    
    xor rcx, rcx ; uso rcx como offset

    .loop:
        cmp byte [r12 + rcx], ASCII_NULL    ; Recorro hasta que A sea null
        je .endloop
        ; Comparo A y B mediante un registro intermedio de 8 bits
        mov al, [r12 + rcx]
        cmp byte al, [r13 + rcx]
        jb .a  ; a < b
        ja .b  ; a > b
        ; a = b, sigo
        inc rcx
        jmp .loop

    .endloop:
        ; Si al haber recorrido todo A sigo teniendo caracteres en B,
        ; Entonces b es mayor
        cmp byte [r13 + rcx], ASCII_NULL
        jne .a
        ; Son iguales
        jmp .eq

    .a:
        mov rax, 1
        jmp .fin
    .b:
        mov rax, -1
        jmp .fin
    .eq:
        xor rax, rax
        jmp .fin

    .fin:
        ; Reestablezco registros
        pop r13
        pop r12
        pop rbp
        ret

strConcat:
    ; char* strConcat(char* pStringA, char* pStringB)
    ;  Genera un nuevo string con la concatenación de a y b.
    ;  Libera la memoria ocupada por estos últimos.
    ;  Nota: Puede haber aliasing

    ; rdi = pStringA
    ; rsi = pStringB

    ; Preservo registros
    push r12
    push r13
    push r14

    mov r12, rdi    ; r12 = pStringA
    mov r13, rsi    ; r13 = pStringB

    ; Obtengo el largo del nuevo string (C)
    ; pStringA ya está en rdi
    call strLen     ; rax = len(A)
    mov r8, rax     ; r8  = len(A)

    mov rdi, r13
    call strLen     ; rax = len(B)
    add r8, rax     ; r8  = len(A) + len(B)

    ; Reservo la memoria
    mov rdi, r8
    call malloc     ; rax = pStringC
    mov r14, rax    ; r14 = pStringC

    ; Copio los contenidos de A y B con _strCopy
    ; _strCopy(dst: C, src: A, offset: 0)
    mov rdi, r14    ; dst = C
    mov rsi, r12    ; src = A
    xor rdx, rdx    ; off = 0
    call _strCopy   ; rax = consumed = len(A)

    ; _strCopy(dst: C, src: B, offset: len(A))
    mov rdi, r14    ; dst = C
    mov rsi, r13    ; src = B
    mov rdx, rax    ; off = consumed = len(A)
    call _strCopy

    ; Libero la memoria de A y B (puede haber aliasing)
    cmp r12, r13    ; Si A y B apuntan a lo mismo,
    jmp .b          ; solo borro uno
    ; Borro A
    mov rdi, r12
    call free
    
    .b:
        ; Borro B
        mov rdi, r13
        call free
    
    ; Retorno C
    mov rax, r14

    ; Reestablezco stack y registros
    pop r14
    pop r13
    pop r12
    ret

strDelete:
    ; void strDelete(char* pString)
    ;  Borra el string pasado por parámetro. Es equivalente a la función free.

    ; rdi = pString
    
    ; Alineo a 16
    sub rsp, 8
    
    call free

    add rsp, 8
    pop rbp
    ret
 
strPrint:
    ; void strPrint(char* pString, FILE *pFile)
    ;  Escribe el string en el stream indicado a través de pFile. 
    ;  Si el string es vacı́o debe escribir “NULL”.

    ; rdi = pString
    ; rsi = pFile

    ; Quiero llamar a 
    ;  int fprintf(FILE *stream, const char *format, ...);
    ;   rdi = FILE
    ;   rsi = fmt
    ;   rdx = pString (o NULL)

    ; Me alineo a 16
    sub rsp, 8

    mov r8, rdi         ; r8 = pString
    mov rdi, rsi        ; rdi = pFile
    mov rsi, STR_FMT    ; rsi = FMT

    ; Veo si el string es vacio
    cmp byte [r8], ASCII_NULL
    jne .continue
    mov r8, STR_NULL    ; Cambio el contenido por "NULL"
    .continue:
        mov rdx, r8
        call fprintf

    add rsp, 8
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
