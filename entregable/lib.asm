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
global _listClear
global listPrint
global _ptrPrint
global hashTableNew
global hashTableAdd
global hashTableDeleteSlot
global hashTableDelete

section .rodata:
    STR_FMT:  db "%s", 0
    STR_NULL: db "NULL", 0

    DEFAULT_FMT: db "%p", 0

    CHAR_LEFT_BRACKET:  db '[', 0
    CHAR_RIGHT_BRACKET: db ']', 0
    CHAR_COMMA:         db ',', 0

;                                   String
; ==============================================================================

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
    
    ; Pido cantidad de memoria igual a la longitud del string + 1
    ; (uno más para el caracter de terminación)
    ; pString ya está en rdi
    call strLen     ; rax = len(pString)
    inc rax         ; rax++
    mov rdi, rax
    call malloc     ; rax = ptr a nuevo string
    mov r13, rax    ; preservo el puntero al nuevo string

    ; Copio el contenido de pString a el nuevo string llamando a
    ;  int32_t _strCopy(char* dst, char* src, int offset_dst)
    mov rdi, rax    ; dst   = ptr a nuevo string
    mov rsi, r12    ; src   = pString
    xor rdx, rdx    ; offset = 0    
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
    mov r8, LSH_MASK
    and rdx, r8
    ; Limpio rax para usarlo como offset de src
    xor rax, rax

    .loop:
        ; Copio el caracter actual de src a dst usando un 
        ; registro intermedio de 8 bits
        mov r8b, [rsi + rax]
        mov [rdi + rdx], r8b

        cmp byte [rsi + rax], ASCII_NULL   ; Si estoy leyendo el caracter nulo,
        je .end                            ; termine.

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
    call strLen      ; rax = len(A)
    mov r14, rax     ; r14 = len(A)

    mov rdi, r13
    call strLen     ; rax = len(B)
    add r14, rax    ; r14 = len(A) + len(B)
    inc r14         ; r14++ (para el null terminator)

    ; Reservo la memoria
    mov rdi, r14
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
    je .b           ; solo borro uno
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
    jmp free
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
        mov rdx, r8     ; rdx = pString o NULL
        call fprintf

    add rsp, 8
    ret


;                                    List
; ==============================================================================
;
;                                   size    off     end
; typedef struct s_list{
;     struct s_listElem *first;     8       0       7
;     struct s_listElem *last;      8       8       15
; } list_t;                         16      -       -
;
;                                   size    off     end
; typedef struct s_listElem{
;     void *data;                   8       0       7
;     struct s_listElem *next;      8       8       15
;     struct s_listElem *prev;      8       16      24
; } listElem_t;                     24      -       -

%define NULL 0x0
%define ptr qword

%define LIST_OFFSET_FIRST 0
%define LIST_OFFSET_LAST  8
%define LIST_SIZE         16

%define LIST_ELEM_OFFSET_DATA 0
%define LIST_ELEM_OFFSET_NEXT 8
%define LIST_ELEM_OFFSET_PREV 16
%define LIST_ELEM_SIZE        24

listNew:
    ; list_t* listNew()
    ;  Crea una nueva list_t vacı́a donde los punteros a first y last estén 
    ;  inicializados en cero.

    sub rsp, 8

    ; Creo una nueva lista
    mov rdi, LIST_SIZE
    call malloc         ; rax = l
    
    ; Inicializo first y last en 0
    mov qword [rax + LIST_OFFSET_FIRST], NULL
    mov qword [rax + LIST_OFFSET_LAST], NULL

    add rsp, 8
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

_listRemoveElem:
    ; void _listRemoveElem(list_t* l, funcDelete_t* fd, listElem_t* e)
    ;  Remueve el elemento elem de la lista l.
    ;  Si fd no es cero, la utiliza para borrar su dato.
    
    ; rdi = l
    ; rsi = fd
    ; rdx = e

    ; Si el elemento a borrar es null, no hago nada
    cmp rdx, NULL
    jne .not_null
    ret
    .not_null:

    push r12
    mov r12, rdx    ; r12 = e

    ; Muevo los punteros de su anterior y siguiente

    cmp r12, [rdi + LIST_OFFSET_FIRST]      ; if e = l->first
    jne .not_fst
    ; Era el primero, el nuevo primero es su siguiente, de tenerlo
    mov r8, [r12 + LIST_ELEM_OFFSET_NEXT]   ; r8 = e->next
    mov [rdi + LIST_OFFSET_FIRST], r8       ; l->first = e->next
    jmp .fst_end
    .not_fst:
        ; Como no era el primero, tiene prev
        ; (e->prev)->next = e->next
        mov r8, [r12 + LIST_ELEM_OFFSET_NEXT]   ; r8 = e->next
        mov r9, [r12 + LIST_ELEM_OFFSET_PREV]   ; r9 = e->prev
        mov [r9 + LIST_ELEM_OFFSET_NEXT], r8    ; (e->prev)->next = e->next
    .fst_end:

    cmp r12, [rdi + LIST_OFFSET_LAST]       ; if e = l->last
    jne .not_lst
    ; Era el ultimo, el nuevo ultimo es su anterior, de tenerlo
    mov r8, [r12 + LIST_ELEM_OFFSET_PREV]   ; r8 = e->prev
    mov [rdi + LIST_OFFSET_LAST], r8        ; l->last = e->prev
    jmp .lst_end
    .not_lst:
        ; Como no era el ultimo, tiene siguiente
        ; (e->next)->prev = e->prev
        mov r8, [r12 + LIST_ELEM_OFFSET_PREV]   ; r8 = e->prev
        mov r9, [r12 + LIST_ELEM_OFFSET_NEXT]   ; r9 = e->next
        mov [r9 + LIST_ELEM_OFFSET_PREV], r8    ; (e->next)->prev = e->prev
    .lst_end:

    ; Veo de remover el dato
    cmp rsi, NULL   ; if fd != NULL
    je .null_fd
    ; Remuevo el dato llamando a
    ;  void (funcDelete_t)(void* ptr);
    mov rdi, [r12 + LIST_ELEM_OFFSET_DATA]      ; ptr = e->data
    call rsi                                    ; call fd
    .null_fd:

    ; Hago free del nodo
    mov rdi, r12
    call free

    pop r12
    ret


listRemove:
    ; void listRemove(list_t* pList, void* data, funcCmp_t* fc, funcDelete_t* fd)
    ;  Borra todos los nodos de la lista cuyo dato sea igual al contenido de 
    ;  data según la función de comparación apuntada por fc. 
    ;  Si fd no es cero, utiliza la función para borrar los datos en cuestión.

    ; rdi = pList
    ; rsi = data
    ; rdx = fc
    ; rcx = fd

    push r12
    push r13
    push r14
    push r15
    push rbx ; Alineado a 16

    mov r12, rdi ; r12 = pList
    mov r13, rsi ; r13 = data
    mov r14, rdx ; r14 = fc
    mov r15, rcx ; r15 = fd

    mov rbx, [r12 + LIST_OFFSET_FIRST] ; rbx = list->first (actual)
    ; Recorro los nodos de la lista
    .loop:
        cmp rbx, NULL
        je .endloop

        ; Los datos son iguales?
        ; Llamo a fc
        ;  int32_t (funcCmp_t)(void*, void*);
        mov rdi, r13                            ; rdi = data
        mov rsi, [rbx + LIST_ELEM_OFFSET_DATA]  ; rsi = actual -> data
        call r14    ; rax = resultado cmp

        ; Si son iguales, el resultado es 0
        cmp rax, 0
        jne .continue
        ; Son iguales, lo borro llamando a
        ;   void _listRemoveElem(list_t* l, funcDelete_t* fd, listElem_t* e)
        mov rdi, r12    ; rdi = pList
        mov rsi, r15    ; rsi = fd
        mov rdx, rbx    ; rdx = actual
        call _listRemoveElem

        .continue:
            ; Avanzo el puntero
            mov rbx, [rbx + LIST_ELEM_OFFSET_NEXT] ; actual = actual->next
            jmp .loop

    .endloop:

    ; Reestablezco
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    ret

listRemoveFirst:
    ; void listRemoveFirst(list_t* pList, funcDelete_t* fd)
    ;  Borra el primer nodo de la lista. Si fd no es cero, utiliza la función 
    ;  para borrar el dato correspondiente.

    ; rdi = pList
    ; rsi = fd

    sub rsp, 8 ; Alineado a 16

    ; Llamo a
    ;  void _listRemoveElem(list_t* l, funcDelete_t* fd, listElem_t* e)
    ; rdi = pList
    ; rsi = fd
    mov rdx, [rdi + LIST_OFFSET_FIRST]  ; e = list.first
    call _listRemoveElem

    add rsp, 8
    ret

listRemoveLast:
    ; void listRemoveLast(list_t* pList, funcDelete_t* fd)
    ;  Borra el último nodo de la lista. Si fd no es cero, utiliza la función 
    ;  para borrar el dato correspondiente.

    ; rdi = pList
    ; rsi = fd

    sub rsp, 8 ; Alineado a 16

    ; Llamo a
    ;  void _listRemoveElem(list_t* l, funcDelete_t* fd, listElem_t* e)
    mov rdx, [rdi + LIST_OFFSET_LAST]  ; e = list.last
    call _listRemoveElem

    add rsp, 8
    ret

listDelete:
    ; void listDelete(list_t* pList, funcDelete_t* fd)
    ;  Borra la lista completa con todos sus nodos. Si fd no es cero, utiliza
    ;  la función para borrar sus datos correspondientes.
    
    ; rdi = pList
    ; rsi = fd

    push r12
    push r13
    sub rsp, 8

    mov r12, rdi ; r12 = pList
    mov r13, rsi ; r13 = fd

    ; Hago listRemoveFirst hasta que no haya nodos
    .loop:
        cmp qword [r12 + LIST_OFFSET_FIRST], NULL
        je .endloop

        ; Llamo a 
        ;   void listRemoveFirst(list_t* l, funcDelete_t* fd)
        mov rdi, r12    ; rdi = pList
        mov rsi, r13    ; rsi = fd
        call listRemoveFirst

        jmp .loop
    .endloop:

    ; Borro la lista
    mov rdi, r12    ; rdi = pList
    call free

    ; Reestablezco
    add rsp, 8
    pop r13
    pop r12
    ret

_listClear:
    ; void _listClear(list_t* pList, funcDelete_t* fd)
    ;  Borra todos los nodos de la lista, pero no borra la lista en sí.
    ;  Si fd no es cero, la utiliza para borrar sus datos correspondientes.
    
    ; rdi = pList
    ; rsi = fd

    push r12
    push r13
    push rbx

    mov r12, rdi ; r12 = pList
    mov r13, rsi ; r13 = fd

    mov rbx, [r12 + LIST_OFFSET_FIRST] ; rbx = list->first (actual)
    ; Recorro los nodos de la lista
    .loop:
        cmp rbx, NULL
        je .endloop

        ; Lo borro llamando a
        ;   void _listRemoveElem(list_t* l, funcDelete_t* fd, listElem_t* e)
        mov rdi, r12    ; rdi = pList
        mov rsi, r13    ; rsi = fd
        mov rdx, rbx    ; rdx = actual
        call _listRemoveElem

        ; Avanzo el puntero
        mov rbx, [rbx + LIST_ELEM_OFFSET_NEXT]
        jmp .loop
    .endloop:

    ; Seteo los punteros de la lista
    mov ptr [r12 + LIST_OFFSET_FIRST], NULL     ; list->first = null
    mov ptr [r12 + LIST_OFFSET_LAST], NULL      ; list->last = null

    ; Reestablezco
    pop rbx
    pop r13
    pop r12
    ret


_ptrPrint:
    ; void _ptrPrint(void* e, FILE *pFile);
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
    mov r14, _ptrPrint

    ; Imprimo cada elemento
    .loop:
        cmp r15, NULL   ; while actual != NULL
        je .endloop

        ; Imprimo el elemento
        mov rdi, [r15 + LIST_ELEM_OFFSET_DATA]
        mov rsi, r13
        call r14

        ; Evito imprimir el separador para el último
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

;                                   Hash Table
; ==============================================================================
;
;                                   size    off     end
; typedef struct s_hashTable{
;     struct s_list **listArray;    8       0       7
;     uint32_t size;                4       8       12
;     funcHash_t* funcHash;         8       16      24
; } hashTable_t;                    24

%define HASH_TABLE_SIZE             24
%define HASH_TABLE_OFFSET_ARRAY     0
%define HASH_TABLE_OFFSET_SIZE      8
%define HASH_TABLE_OFFSET_FN_HASH   16
%define HASH_TABLE_ARRAY_ELEM_SIZE  8
hashTableNew:
    ; hashTable_t* hashTableNew(uint32_t size, funcHash_t* funcHash)
    ;  Crea un nuevo hashTable_t con una función de hash funcHash y un arreglo
    ;  de tamaño size completándolo con listas vacı́as.

    ; rdi = size
    ; rsi = funcHash

    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    ; Preservo los parámetros para no perderlos al llamar a malloc
    mov r12, rdi    ; r12 = size
    mov r13, rsi    ; r13 = funcHash

    ; Creo el nuevo hashTable
    mov rdi, HASH_TABLE_SIZE
    call malloc     ; rax = nuevo hash table
    mov r14, rax    ; r14 = nuevo hash table

    ; Creo el arreglo de listas
    ; size_arr = size * ptr_size
    lea rdi, [r12 * HASH_TABLE_ARRAY_ELEM_SIZE]
    call malloc     ; rax = nuevo arreglo de listas
    mov r15, rax    ; r15 = nuevo arreglo de listas

    ; Seteo los atributos de la tabla de hash
    mov [r14 + HASH_TABLE_OFFSET_ARRAY],    r15  ; table->list = list
    mov [r14 + HASH_TABLE_OFFSET_SIZE],     r12  ; table->size = size
    mov [r14 + HASH_TABLE_OFFSET_FN_HASH],  r13  ; table->funcHash = funcHash

    ; Inicializo las listas
    .loop:
        cmp r12, 0  ; if size < 0
        jl .endloop ; break

        ; Creo una nueva lista
        call listNew    ; rax = l (ptr a nueva lista)
        
        ; Guardo su puntero en el índice actual
        ; puntero al inicio + tamaño del dato * index
        mov [r15 + 8 * r12], rax    ; list[size] = l

        dec r12     ; size--
        jmp .loop
    .endloop:

    mov rax, r14    ; return t

    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    ret

hashTableAdd:
    ; void hashTableAdd(hashTable_t* pTable, void* data)
    ;  Agrega un nuevo elemento que contenga data en el slot determinado por
    ;  la función de hash. El elemento nuevo se agrega al final de la lista 
    ;  que corresponde a dicho slot.
    
    ; rdi = pTable
    ; rsi = data

    push r12
    push r13
    sub rsp, 8

    mov r12, rdi ; r12 = pTable
    mov r13, rsi ; r13 = data

    ; Llamo a la función de hash para tener el slot 
    ;  int32_t funcHash_t(void *)
    mov rdi, r13
    mov rsi, [r12 + HASH_TABLE_OFFSET_FN_HASH]
    call rsi    ; eax = hash result

    ; Tengo que interpretarlo mod t->size
    xor rdx, rdx
    mov ebx, [r12 + HASH_TABLE_OFFSET_SIZE] ; ebx = size
    div ebx ; edx = r (remainder)

    ; Quiero agregar un nuevo elemento al final de la lista t->array[r]
    ;   void listAddLast(list_t* pList, void* data)
    mov rdi, [r12 + HASH_TABLE_OFFSET_ARRAY]            ; rdi = t->array
    mov rdi, [rdi + rdx * HASH_TABLE_ARRAY_ELEM_SIZE]   ; rdi = t->array[r]
    mov rsi, r13                                        ; rsi = data
    call listAddLast

    add rsp, 8
    pop r13
    pop r12
    ret
    
hashTableDeleteSlot:
    ; void hashTableDeleteSlot(hashTable_t* pTable, uint32_t slot, funcDelete_t* fd)
    ;  Borra todos los elementos del slot indicado. Si el valor de fd no es 
    ;  cero, utiliza la función para borrar los datos dados.
    
    ; rdi = pTable
    ; esi = slot
    ; rdx = fd

    sub rsp, 8

    ; Limpio la parte alta de rsi
    mov r8, LSH_MASK
    and rsi, r8

    ; Hago clear de la lista que se encuentra en ese slot
    ;   void _listClear(list_t* pList, funcDelete_t* fd)
    mov rdi, [rdi + HASH_TABLE_OFFSET_ARRAY]           ; rdi = table->slots
    mov rdi, [rdi + rsi * HASH_TABLE_ARRAY_ELEM_SIZE]  ; rdi = table->slots[slot]
    mov rsi, rdx    ; rsi = fd
    call _listClear

    add rsp, 8
    ret

hashTableDelete:
    ; void hashTableDelete(hashTable_t* pTable, funcDelete_t* fd)
    ;  Borra todas las estructuras apuntadas desde hashTable_t. 
    ;  Si fd no es cero, utiliza la función para borrar sus datos.

    ; rdi = pTable
    ; rsi = fd
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    mov r12, rdi    ; r12 = pTable
    mov r13, rsi    ; r13 = fd
    mov r14, [r12 + HASH_TABLE_OFFSET_ARRAY]    ; r14 = table->slots
    mov r15, [r12 + HASH_TABLE_OFFSET_SIZE]     ; r15 = i (indice de lista)
    dec r15

    ; Recorro todos los slots y llamo a listDelete
    .loop:
        cmp r15, 0      ; while i >= 0
        jl .endloop

        ; Borro la lista llamando a
        ;   void listDelete(list_t* pList, funcDelete_t* fd)
        mov rdi, [r14 + r15 * HASH_TABLE_ARRAY_ELEM_SIZE] ; rdi = table->slots[i]
        mov rsi, r13    ; rsi = fd
        call listDelete

        dec r15         ; i--
        jmp .loop
    .endloop:

    ; Borro la tabla
    mov rdi, r12
    call free

    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    ret
