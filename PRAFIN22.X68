*-----------------------------------------------------------
* Title      : PRAFIN22
* Written by : Joan Martorell Coll
* Date       : 30/05/2022
* Description: Emulador de la JARVIS
*-----------------------------------------------------------
    ORG $1000
EMEM:   DC.W $2800,$2A03,$50E0,$0B60,$5114,$0C70,$1430,$0E40,$7140,$3001,$32FF,$90D0
        DC.W $8020,$C000,$0002,$0003,$0001,$0003,$0002,$0004,$0000,$0000,$0000
EIR:    DC.W 0 ;eregistro de instruccion
EPC:    DC.W 0 ;econtador de programa
EB0:    DC.W 0 ;eregistro B0
EB1:    DC.W 0 ;eregistro B1
ER2:    DC.W 0 ;eregistro R2
ER3:    DC.W 0 ;eregistro R3
ER4:    DC.W 0 ;eregistro R4
ER5:    DC.W 0 ;eregistro R5
ET6:    DC.W 0 ;eregistro T6
ET7:    DC.W 0 ;eregistro T7
ESR:    DC.W 0 ;eregistro de estado (00000000 00000ZCN)

START:
    CLR.W EPC

FETCH:
    ;--- IFETCH: INICIO FETCH
        ;*** En esta seccion debeis introducir el codigo necesario para cargar
        ;*** en el EIR la siguiente instruccion a ejecutar, indicada por el EPC,
	    ;*** y dejar listo el EPC para que apunte a la siguiente instruccion
	
	    ; ESCRIBID VUESTRO CODIGO AQUI
        LEA.L EMEM, A0      ;leemos instrucción
        ADD EPC, A0         ;añadimos 2 ya que va  
        ADD EPC, A0         ;de 2 en 2 bytes
        
        MOVE.W (A0),EIR     ;añadimos la instrucción
        ADDQ.W #1, EPC      ;añadimos 1 al EPC

    ;--- FFETCH: FIN FETCH
    
    
    ;--- IBRDECOD: INICIO SALTO A DECOD
        ;*** En esta seccion debeis preparar la pila para llamar a la subrutina
        ;*** DECOD, llamar a la subrutina, y vaciar la pila correctamente,
        ;*** almacenando el resultado de la decodificacion en D1
        
    	; ESCRIBID VUESTRO CODIGO AQUI
    	
    	;preparamos la pila
    	MOVE.W #0, -(SP)
    	MOVE.W EIR, -(SP)
    	
        JSR DECOD       ;decodificamos
        
        ;sacamos lo que hay en la pila         
        ADDQ.W #2, SP            
        MOVE.W (SP)+, D1
        
    ;--- FBRDECOD: FIN SALTO A DECOD
    
    
    ;--- IBREXEC: INICIO SALTO A FASE DE EJECUCION
        ;*** Esta seccion se usa para saltar a la fase de ejecucion
        ;*** NO HACE FALTA MODIFICARLA
    MULU #6,D1
    MOVEA.L D1,A1
    JMP JMPLIST(A1)
JMPLIST:
    JMP ETRA
    JMP EADD
    JMP ESUB
    JMP ENAN
    JMP ESTC
    JMP EINC
    JMP ELOA
    JMP ELOAX
    JMP ESTO
    JMP ESTOX
    JMP EBRI
    JMP EBRZ
    JMP EBRN
    JMP ESTP
    ;--- FBREXEC: FIN SALTO A FASE DE EJECUCION
    
    
    ;--- IEXEC: INICIO EJECUCION
        ;*** En esta seccion debeis implementar la ejecucion de cada einstr.
	
	; ESCRIBID EN CADA ETIQUETA LA FASE DE EJECUCION DE CADA INSTRUCCION
	
ETRA:       ;Xb <- [Xa]
    JSR DET_A           ;detectamos aaa
    MOVE.W (A2),D3      ;guardamos aaa
    JSR DET_B           ;detectamos bbb
    MOVE.W D3, (A2)     ;Xb <- [Xa]
    
    ;actualizamos flag z
    JSR FLAG_Z          
    
    BRA FETCH
    
EADD:       ;Xb <- [Xb] + [Xa]
    
    JSR DET_A           ;detectamos aaa
    MOVE.W (A2),D3      ;guardamos aaa
    JSR DET_B           ;detectamos bbb
    MOVE.W (A2),D4      ;guardamos bbb
    ADD.W D3,D4         ;sumamos aaa y bbb
    MOVE.W D4,(A2)      ;Xb <- [Xb] + [Xa]
    
    ;actualizamos flags
    JSR FLAG_Z
    JSR FLAG_C
    JSR FLAG_N
    
    BRA FETCH
    
ESUB:       ;Xb <- [Xb] - [Xa] <==> A - B = A + (B' + 1)


    JSR DET_A           ;detectamos aaa
    MOVE.W (A2),D3      ;guardamos aaa
    NOT D3              ;negamos aaa
    ADDQ.W #1, D3       ;sumamos 1 a aaa
    
    JSR DET_B           ;detectamos bbb
    MOVE.W (A2),D4      ;guardamos bbb
    ADD.W D3, D4        ;sumamos aaa'+1 y bbb
    MOVE.W D4, (A2)     ;Xb <- [Xb] - [Xa]
    
    ;actualizamos flags
    JSR FLAG_Z
    JSR FLAG_C
    JSR FLAG_N

    BRA FETCH
    
ENAN:       ;Xb <- [Xb] nand [Xa]

    JSR DET_A           ;detectamos aaa
    MOVE.W (A2),D3      ;guardamos aaa
    JSR DET_B           ;detectamos bbb
    MOVE.W (A2),D4      ;guardamos aaa
    
    AND.W D3, D4        ;hacemos la operación NAND
    NOT.W D4            ;negamos la solución
    
    MOVE.W D4, (A2)     ;Xb <- [Xb] nand [Xa]
    
    ;actualizamos flags
    JSR FLAG_Z
    JSR FLAG_N

    BRA FETCH
    
ESTC:       ;Xb <- k (Ext. signo)

    JSR DET_K           ;detectamos kkkkkkkk, ahora está en D2
    MOVE.W D2, D3       ;guardamos kkkkkkkk
    JSR DET_B           ;detectamos bbb
    MOVE.W D3, (A2)     ;Xb <- k
    
    ;actualizamos flags
    JSR FLAG_Z
    JSR FLAG_N
    
    BRA FETCH
    
EINC:       ;Xb <- [Xb] + k (Ext. Signo)

    JSR DET_K           ;detectamos kkkkkkkk, ahora está en D2
    MOVE.W D2, D3       ;guardamos kkkkkkkk
    JSR DET_B           ;detectamos bbb
    ADD.W D3, (A2)      ;Xb <- [Xb] + k

    ;actualizamos flags
    JSR FLAG_Z
    JSR FLAG_C
    JSR FLAG_N
    
    BRA FETCH
    
ELOA:       ;T6 <- [M]

    JSR DET_M           ;detectamos mmmmmmmm, ahora está en D2
    MOVE.W D2, A3       ;lo guardamos en el EPC
    ADD.W D2, A3        ;recordemos que la dirección va de dos en dos
    
    MOVE.W EMEM(A3),ET6 ;T6 <- [M]
    
    ;actualizamos flags
    JSR FLAG_Z
    JSR FLAG_N
    
    BRA FETCH
    
ELOAX:      ;Tj <- [M + [Bi]]

    JSR DET_M           ;detectamos mmmmmmmm, ahora está en D2
    MOVE.W D2, D3       ;guardamos mmmmmmmm en D3
    
    JSR DET_Bi          ;detectamos Bi, está en A2
    MOVE.W (A2),A3      ;guardamos Bi en D4
    ADD.W (A2),A3       ;recordemos que la dirección va de dos en dos
    
    ADD.W D3, A3        ;sumamos mmmmmmmm + [Bi]
    ADD.W D3, A3        ;recordemos que la dirección va de dos en dos
    MOVE.W EMEM(A3),D3  ;guardamos la variable introducida
    
    JSR DET_Tj          ;detectamos Tj
    MOVE.W D3, (A2)     ;Tj <- [M + [Bi]]
    
    ;actualizamos flags
    JSR FLAG_Z
    JSR FLAG_N

    BRA FETCH
    
ESTO:       ;M <- [T6]
    
    MOVE.W ET6, A2      ;guardamos dirección de T6
    MOVE.W (A2),D3      ;guardamos lo que hay en la dirección
    
    JSR DET_M           ;detectamos mmmmmmmm, ahora está en D2
    MOVE.W D2, A3       ;lo guardamos en el EPC
    ADD.W D2, A3        ;recordemos que la dirección va de dos en dos
    
    MOVE.W D3, (A3)     ;M <- [T6]
    
    BRA FETCH
    
ESTOX:      ;M + [Bi] <- [Tj]

    JSR DET_Tj          ;detectamos Tj
    MOVE.W (A2),D3      ;guardamos Tj
    
    JSR DET_Bi          ;detectamos Bi
    MOVE.W (A2),A3      ;guardamos Bi en D4
    ADD.W (A2),A3       ;recordemos que la dirección va de dos en dos
    
    JSR DET_M           ;detectamos mmmmmmmm, ahora está en D2
    ADD.W D2, A3        ;sumamos mmmmmmm + [Bi]
    ADD.W D2, A3        ;recordemos que la dirección va de dos en dos
    
    MOVE.W D3, EMEM(A3) ;M + [Bi] <- [Tj]
    
    BRA FETCH
    
EBRI:       ;PC <- M

    JSR DET_M           ;detectamos mmmmmmmm, ahora está en D2
    MOVE.W D2, EPC      ;PC <- M

    BRA FETCH
    
EBRZ:       ;Si Z = 1, PC <- M

    JSR DET_M           ;detectamos mmmmmmmm, ahora está en D2
    
    BTST #2, ESR        ;comprovamos el flag EZ
    BEQ ACT1            ;si es 0, saltamos
    
    MOVE.W D2, EPC      ;PC <- M
    
    ACT1:
        BRA FETCH
    
EBRN:       ;Si N = 1, PC <- M

    JSR DET_M           ;detectamos mmmmmmmm, ahora está en D2
    
    BTST #0, ESR        ;comprovamos el flag EZ
    BEQ ACT1            ;si es 0, saltamos
    
    MOVE.W D2, EPC  ;PC <- M
    
    ACT2:
        BRA FETCH
    
ESTP:
    SIMHALT
    
    ;--- FEXEC: FIN EJECUCION
    

    ;--- ISUBR: INICIO SUBRUTINAS
        ;*** Aqui debeis incluir las subrutinas que necesite vuestra solucion
        ;*** SALVO DECOD, que va en la siguiente seccion

	    ; ESCRIBID VUESTRO CODIGO AQUI
    DET_A:
        MOVE.W EIR, D2      ;guarda EIR en D2
        AND.W #$0070, D2    ;detecta aaa
        LSR #4,D2           ;lo mueve a la derecha
        BRA DET_REG
    DET_B:
        MOVE.W EIR, D2      ;guarda EIR en D2
        AND.W #$0700, D2    ;detecta bbb
        LSR #8, D2          ;lo mueve a la derecha
        BRA DET_REG
    DET_K:
        MOVE.W EIR, D2      ;guarda EIR en D2
        AND.W #$00FF, D2    ;detecta kkkkkkkk
        EXT.W D2            ;extension de signo
        RTS
    DET_M:
        MOVE.W EIR, D2      ;guarda EIR en D2
        AND.W #$0FF0, D2    ;detecta mmmmmmmm
        LSR #4,D2           ;lo mueve a la derecha
        RTS
        
    DET_REG:            ;retorna el eregistro indicado por D2
        CMP.W #$0, D2
        BEQ ES_B0
        CMP.W #$1, D2
        BEQ ES_B1
        CMP.W #$2, D2
        BEQ ES_R2
        CMP.W #$3, D2
        BEQ ES_R3
        CMP.W #$4, D2
        BEQ ES_R4
        CMP.W #$5, D2
        BEQ ES_R5
        CMP.W #$6, D2
        BEQ ES_T6
        CMP.W #$7, D2
        BEQ ES_T7
        
    DET_Bi:
        MOVE.W EIR, D2
        AND.W #$0008, D2    ;detectamos i
        LSR #3,D2           ;movemos 4 posiciones a la derecha
        
        CMP.W #1, D2        ;si D2 = 1, saltamos a B1
        BEQ ES_B1           ;si D2 = 0, saltamos a BO
        
        BRA ES_B0
        
    DET_Tj:
        MOVE.W EIR, D2
        AND.W #$0004, D2    ;detectamos i
        LSR #2,D2           ;movemos 3posiciones a la derecha
        
        CMP.W #1, D2        ;si D2 = 1, saltamos a T7
        BEQ ES_T7           ;si D2 = 0, saltamos a T6
        
        BRA ES_T6
    
    ;funciones que devulven la dirección de cada eregistro
    ES_B0:
        LEA.L EB0, A2
        RTS
    ES_B1:
        LEA.L EB1, A2
        RTS
    ES_R2:
        LEA.L ER2, A2
        RTS
    ES_R3:
        LEA.L ER3, A2
        RTS
    ES_R4:
        LEA.L ER4, A2
        RTS
    ES_R5:
        LEA.L ER5, A2
        RTS
    ES_T6:
        LEA.L ET6, A2
        RTS
    ES_T7:
        LEA.L ET7, A2
        RTS
        
    FLAG_Z:
        ;MIRAMOS EL FLAG Z
        BEQ ES_Z1           ;SALTA A Z0 SI Z = 1
        
        BCLR #2, ESR        ;PONE EL BIT A 0
        RTS
        
        ES_Z1:
            BSET #2, ESR    ;PONE EL BIT A 1
            RTS
            
    FLAG_C:
        ;MIRAMOS EL FLAG C
        BCS ES_C1           ;SALTA A C0 SI C = 1
    
        BCLR #1, ESR        ;PONE EL BIT A 0
        RTS
        
        ES_C1:
        BSET #1,ESR         ;PONE EL BIT A 1
        RTS
        
    FLAG_N:
        ;MIRAMOS EL FLAG N
        BMI ES_N1           ;SALTA A N0 SI N = 1
    
        BCLR #0,ESR         ;PONE EL BIT A 0
        RTS
        
        ES_N1:
            BSET #0, ESR    ;PONE EL BIT A 1
            RTS  

        
    ;--- FSUBR: FIN SUBRUTINAS
    

    ;--- IDECOD: INICIO DECOD
        ;*** Tras la etiqueta DECOD, debeis implementar la subrutina de 
        ;*** decodificacion, que debera ser de libreria, siguiendo la interfaz
        ;*** especificada en el enunciado
DECOD:
	    ; ESCRIBID VUESTRO CODIGO AQUI
        MOVE.W D0, -(SP)
        MOVE.W 6(SP),D0
        
        BTST.L #15, D0
        BEQ BITS_0      ;bits 0xxx
        
    ;bits 1xxx
        BTST.L #14, D0
        BEQ BITS_1_0    ;bits 10xxx  
        
        MOVE.W #13, 8(SP)  ;bits 11xxx (STP)
        BRA ACABADO
    BITS_1_0:
        BTST.L #13, D0
        BEQ BITS_1_0_0  ;bits 100xx  
        
        MOVE.W #12, 8(SP) ;bits 101xx (BRN)
        BRA ACABADO
    BITS_1_0_0:
        BTST.L #12, D0
        BEQ BITS_1_0_0_0    ;bits 1000x
        
        MOVE.W #11, 8(SP)      ;bits 1001x (BRZ)
        BRA ACABADO
    BITS_1_0_0_0:    
        MOVE.W #10, 8(SP)  ;(BRI)
        BRA ACABADO
        
  
    BITS_0:
        BTST.L #14, D0
        BEQ BITS_0_0    ;bits 00xxx

    ;bits 01xxx:
        BTST.L #13, D0
        BEQ BITS_0_1_0  ;bits 010xx

    ;bits 011xx:
        BTST.L #12, D0
        BEQ BITS_0_1_1_0    ;bits 0110x

        MOVE.W #9, 8(SP)       ;bits 0111x (STOX)
        BRA ACABADO
    BITS_0_1_1_0:
        MOVE.W #8, 8(SP)   ;(STO)
        BRA ACABADO
    BITS_0_1_0:
        BTST.L #12, D0
        BEQ BITS_0_1_0_0    ;bits 0100x
 
        MOVE.W #7, 8(SP)       ;bits 0101x (LOAX)
        BRA ACABADO
    BITS_0_1_0_0:
        MOVE.W #6, 8(SP)   ;(LOA)
        BRA ACABADO
    BITS_0_0:
        BTST.L #13, D0
        BEQ BITS_0_0_0  ;bits 000xx
    ;bits 001xx:
        BTST.L #12, D0
        BEQ BITS_0_0_1_0    ;bits 0010x
       
        MOVE.W #5, 8(SP)       ;bits 0011x (INC)
        BRA ACABADO
     BITS_0_0_1_0:
        BTST.L #11, D0
        BEQ BITS_0_0_1_0_0  ;bits 00100

        MOVE.W #4, 8(SP)       ;bits 00101 (STC)
        BRA ACABADO
     BITS_0_0_1_0_0:
        MOVE.W #3, 8(SP)   ;(NAN)
        BRA ACABADO

     BITS_0_0_0:
        BTST.L #12, D0
        BEQ BITS_0_0_0_0    ;bits 0000x
     ;bits 0001x:
        BTST.L #11, D0
        BEQ BITS_0_0_0_1_0  ;bits 00010

        MOVE.W #2, 8(SP)       ;bits 00011 (SUB)
        BRA ACABADO
     BITS_0_0_0_1_0:
        MOVE.W #1, 8(SP)       ;(ADD)
        BRA ACABADO
     BITS_0_0_0_0:
        MOVE.W #0, 8(SP)       ;bits 00001 (TRA)
    
     ACABADO:
        MOVE.W (SP)+,D0
        RTS

    ;--- FDECOD: FIN DECOD
    END    START







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
