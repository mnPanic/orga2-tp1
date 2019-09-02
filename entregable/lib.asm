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

; String
; ======

%define ASCII_NULL 0
; least significant half mask
%define LSH_MASK 0x00000000FFFFFFFF

section .rodata:
    STR_FMT:  db "%s", 0
    STR_NULL: db "NULL", 0

    DEFAULT_FMT: db "%p", 0

    CHAR_LEFT_BRACKET:  db '[', 0
    CHAR_RIGHT_BRACKET: db ']', 0
    CHAR_COMMA:         db ',', 0

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


; List
; ====
;                                   size    off     end
; typedef struct s_list{
;     struct s_listElem *first;     8       0       7
;     struct s_listElem *last;      8       16      23
; } list_t;                         24 (3B) -       -
;
;                                   size    off     end
; typedef struct s_listElem{
;     void *data;                   8       0       7
;     struct s_listElem *next;      8       8       15
;     struct s_listElem *prev;      8       16      23
; } listElem_t;                     24 (3B) -       -

%define NULL 0x0
%define ptr qword

%define LIST_OFFSET_FIRST 0
%define LIST_OFFSET_LAST  8
%define LIST_SIZE         3

%define LIST_ELEM_OFFSET_DATA 0
%define LIST_ELEM_OFFSET_NEXT 8
%define LIST_ELEM_OFFSET_PREV 16
%define LIST_ELEM_SIZE        3

listNew:
    ; list_t* listNew()
    ;  Crea una nueva list_t vacı́a donde los punteros a first y last estén 
    ;  inicializados en cero.

    ; Armo stack frame para estar alineado
    push rbp
    mov rbp, rsp

    ; Creo una nueva lista
    mov rdi, LIST_SIZE
    call malloc         ; rax = l
    
    ; Inicializo first y last en 0
    mov ptr [rax + LIST_OFFSET_FIRST], NULL
    mov ptr [rax + LIST_OFFSET_LAST], NULL

    pop rbp
    ret

; Rutina auxiliar
_listAddElem:
    ; void _listAddElem(list_t* l, void* data, listElem_t* prev, listElem_t* next)
    ;  Agrega un elemento a una lista, que tendrá
    ;   - prev: Elemento previo
    ;   - next: Elemento siguiente
    ;   - data: Datos
    ;  Si la lista no tiene primero, lo agrega como primero,
    ;  y si no tiene último, como último.

    ; rdi = l
    ; rsi = data
    ; rdx = prev
    ; rcx = next

    push r12
    push r13
    push r14
    push r15
    sub rsp, 8      ; Alineado

    mov r12, rdi    ; r12 = l
    mov r13, rsi    ; r13 = data
    mov r14, rdx    ; r14 = prev
    mov r15, rcx    ; r15 = next

    ; Creo el nuevo nodo
    mov rdi, LIST_ELEM_SIZE
    call malloc                 ; rax = e

    ; Seteo su info
    mov [rax + LIST_ELEM_OFFSET_DATA], r13  ; e.data = data
    mov [rax + LIST_ELEM_OFFSET_PREV], r14  ; e.prev = prev 
    mov [rax + LIST_ELEM_OFFSET_NEXT], r15  ; e.next = next

    ; Lo pongo como siguiente de su anterior
    cmp r14, NULL
    je .prev_null
    mov [r14 + LIST_ELEM_OFFSET_NEXT], rax
    .prev_null:

    ; Lo pongo como anterior de su siguiente
    cmp r15, NULL
    je .next_null
    mov [r15 + LIST_ELEM_OFFSET_PREV], rax
    .next_null:

    ; Si su siguiente era el primero de la lista, este es el nuevo primero
    cmp ptr [r12 + LIST_OFFSET_FIRST], r15
    jne .not_fst
    mov [r12 + LIST_OFFSET_FIRST], rax
    .not_fst:

    ; Si su anterior era el ultimo de la lista, este es el nuevo ultimo
    cmp ptr [r12 + LIST_OFFSET_LAST], r14
    jne .not_lst
    mov [r12 + LIST_OFFSET_LAST], rax
    .not_lst:

    ; Reestablezco registros
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    ret

listAddFirst:
    ; void listAddFirst(list_t* pList, void* data)
    ;  Agrega al principio de la lista un nuevo nodo que almacena data.

    ; rdi = pList
    ; rsi = data
    
    sub rsp, 8 ; Alineado

    ; Llamo a
    ;  void _listAddElem(list_t* l, void* data, listElem_t* prev, listElem_t* next)
    ; pList ya esta en rdi
    ; data  ya esta en rsi
    mov rdx, NULL                       ; prev = NULL
    mov rcx, [rdi + LIST_OFFSET_FIRST]  ; next = pList -> first
    call _listAddElem
  
    add rsp, 8
    ret


listAddLast:
    ; void listAddLast(list_t* pList, void* data)
    ;  Agrega un nuevo nodo al final de la lista que almacena data.

    ; rdi = pList
    ; rsi = data

    sub rsp, 8 ; Alineado
    ; Llamo a
    ;  void _listAddElem(list_t* l, void* data, listElem_t* prev, listElem_t* next)
    ; pList ya esta en rdi
    ; data  ya esta en rsi
    mov rdx, [rdi + LIST_OFFSET_LAST]   ; prev = pList -> last
    mov rcx, NULL                       ; next = NULL (pues es el último)
    call _listAddElem

    add rsp, 8
    ret

listAdd:
    ; void listAdd(list_t* pList, void* data, funcCmp_t* fc)
    ;  Agrega un nuevo nodo que almacene data, respetando el orden dado por la 
    ;  función fc.
    ;  Supone que la lista viene ordenada crecientemente, debiéndose mantener 
    ;  esta condición luego de la inserción de data.

    ; rdi = pList
    ; rsi = data
    ; rdx = fc

    push r12
    push r13
    push r14
    push r15
    push rbx

    mov r12, rdi                        ; r12 = pList
    mov r13, rsi                        ; r13 = data
    mov r14, rdx                        ; r14 = fc
    mov r15, [r12 + LIST_OFFSET_FIRST]  ; r15 = actual
    mov rbx, NULL                       ; rbx = prev
    
    ; Recorro hasta que es menor al actual (o llego al final)
    .loop:
        ; Llegue al final?
        cmp r15, NULL
        je .endloop

        ; Quiero llamar a
        ;  int32_t (funcCmp_t)(void* a, void* b);
        mov rdi, r13                            ; a = data
        mov rsi, [r15 + LIST_ELEM_OFFSET_DATA]  ; b = actual->data 
        call r14    ; rax = resultado de la comp
        ; fc(a, b) retorna
        ;   0 si son iguales
        ;   1 si a < b
        ;  −1 si b < a

        ; Estoy en la posicion que cumple con el orden?
        cmp rax, 1
        je .endloop

        ; Debo seguir mirando
        mov rbx, r15
        mov r15, [r15 + LIST_ELEM_OFFSET_NEXT]
        jmp .loop
    .endloop:

    ; Estoy en una posición tal que
    ;  fn(data, r15.data) = 1
    ; Lo agrego acá llamando a 
    ;  void _listAddElem(list_t* l, void* data, listElem_t* prev, listElem_t* next)
    mov rdi, r12 ; l    = pList
    mov rsi, r13 ; data = data
    mov rdx, rbx ; prev = prev
    mov rcx, r15 ; next = actual
    call _listAddElem

    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    ret

listRemove:
    ret

listRemoveFirst:
    ret

listRemoveLast:
    ret

listDelete:
    ret

_defaultPrint:
    ; void _defaultPrint(void* e, FILE *pFile);
    ;  Escribe el puntero al dato con el formato "%p"
    
    ; rdi = e
    ; rsi = pFile

    sub rsp, 8 ; Alineado a 16

    ; Quiero llamar a 
    ;  int fprintf(FILE *stream, const char *format, ...);
    mov r8, rdi ; r8 = e

    mov rdi, rsi            ; stream = pfile
    mov rsi, DEFAULT_FMT    ; format = "%p"
    mov rdx, r8             ; ... = e
    call fprintf

    add rsp, 8
    ret

listPrint:
    ; void listPrint(list_t* pList, FILE *pFile, funcPrint_t* fp)
    ;  Escribe en el stream indicado por pFile la lista almacenada en pList. 
    ;  Para cada dato llama a la función fp, y si esta es cero, escribe el 
    ;  puntero al dato con el formato "%p". 
    ;  El formato de la lista será: 
    ;    [x_0,...,x_{n−1}]
    ;  Suponiendo que x_i es el resultado de escribir el i-ésimo elemento.

    ; rdi = pList
    ; rsi = pFile
    ; rdx = fp

    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    mov r12, rdi                        ; r12 = pList
    mov r13, rsi                        ; r13 = pFile
    mov r14, rdx                        ; r14 = fp
    mov r15, [rdi + LIST_OFFSET_FIRST]  ; r15 = actual

    ; Imprimo '['
    mov rdi, CHAR_LEFT_BRACKET
    mov rsi, r13
    call strPrint

    ; Si fp es cero, uso el print default
    cmp r14, NULL
    jne .loop
    mov r14, _defaultPrint

    ; Imprimo cada elemento
    .loop:
        cmp r15, NULL   ; while actual != NULL
        je .endloop

        ; Imprimo el elemento
        mov rdi, [r15 + LIST_ELEM_OFFSET_DATA]
        mov rsi, r13
        call strPrint

        mov r15, [r15 + LIST_ELEM_OFFSET_NEXT]
        cmp r15, NULL ; Si no tiene siguiente, no imprimo ','
        je .loop

        ; Imprimo ','
        mov rdi, CHAR_COMMA
        mov rsi, r13
        call strPrint
        jmp .loop
    .endloop:

    ; Imprimo ']'
    mov rdi, CHAR_RIGHT_BRACKET
    mov rsi, r13
    call strPrint

    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    ret

hashTableNew:
    ret

hashTableAdd:
    ret
    
hashTableDeleteSlot:
    ret

hashTableDelete:
    ret
