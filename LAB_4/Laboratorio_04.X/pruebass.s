; Archivo:     lab3.s
; Dispositivo: PIC16F887
; Autor:       Alejandro Duarte
; Compilador:  pic-as (v2.30), MPLABX V5.40
;
; Programa:    contador en el puerto A
; Hardware:    LEDS en el puerto B, C, D y E
;
; Creado: 16 feb, 2021
; Última modificación:  feb, 2021

; Assembly source line config statements
    
PROCESSOR 16F887  ; Se elige el microprocesador a usar
#include <xc.inc> ; libreria para el procesador 

; configuratión word 1
  CONFIG  FOSC =  INTRC_NOCLKOUT  ; Oscillator Selection bits (INTOSC oscillator: CLKOUT function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF             ; Watchdog Timer Enable bit (WDT enabled)
  CONFIG  PWRTE = ON           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = OFF            ; RE3/MCLR pin function select bit (RE3/MCLR pin function is MCLR)
  CONFIG  CP = OFF               ; Code Protection bit (Program memory code protection is enabled)
  CONFIG  CPD = OFF              ; Data Code Protection bit (Data memory code protection is enabled)
  
  CONFIG  BOREN = OFF            ; Brown Out Reset Selection bits (BOR enabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is enabled)
  CONFIG  FCMEN = OFF            ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is enabled)
  CONFIG  LVP = ON              ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

; configuration word 2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF            ; Flash Program Memory Self Write Enable bits (0000h to 0FFFh write protected, 1000h to 1FFFh may be modified by EECON control)

  
  
  
INC_DEC MACRO
  BTFSS PORTB,0
  INCF PORTA
  BTFSS PORTB,1
  DECF PORTA
  ENDM
  
  ;-------------------------------varibles--------------------------------------
  
PSECT udata_SHR ;common memory
  W_T:       DS 1
  STATUS_T:  DS 1
;Instrucciones de reset
PSECT resVect, class=code, abs, delta=2
;--------------vector reset----------------
ORG 00h        ;posicion 0000h para el reset
resetVec:
    PAGESEL main
    goto main
   
    
PSECT intVect, class=CODE, ABS, DELTA=2
;------------------------VECTOR DE INTERRUPCION---------------------------------
ORG 04h
    push:
       MOVWF W_T
       SWAPF STATUS, W
       MOVWF STATUS_T
       
    isr:
      BANKSEL PORTB
      ;BTFSC RBIF
      INC_DEC
      BCF RBIF
      
    pop: 
      SWAPF STATUS_T, W
      MOVWF STATUS
      SWAPF W_T, F
      SWAPF W_T, W
      RETFIE
    
; Configuraciones
PSECT code, delta=2, abs
ORG 100h    ; Posicion para el codigo
 
main:
    BANKSEL ANSEL ; Entramos al banco donde esta el registro ANSEL
    CLRF ANSEL
    CLRF ANSELH  ; se establecen los pines como entras y salidas digitales
    
    ;BANKSEL PORTA ; Entramos al banco donde esta el puerto A
    ;CLRF PORTA    ; Se limpa el puerto A 
    BANKSEL TRISA ; Entramos al banco donde esta el TRISA
    BCF TRISA, 0 
    BCF TRISA, 1 
    BCF TRISA, 2 
    BCF TRISA, 3  ; Se ponen los dos primeros pines del puerto A como entradas
    
    ;BANKSEL PORTC ; Entramos al banco donde esta el puerto C
    ;CLRF PORTC    ; Se limpia el puerto C
    BANKSEL TRISC ; Entramos al banco donde esta el TRISC
    BCF TRISC, 0  ; 
    BCF TRISC, 1
    BCF TRISC, 2
    BCF TRISC, 3
    BCF TRISC, 4
    BCF TRISC, 5
    BCF TRISC, 6
    BCF TRISC, 7  ; Se ponen los pines del puerto C como salida
        
    ;BANKSEL PORTD ; Entramos al banco donde esta el puerto D
    ;CLRF PORTD    ; Se limpia el puerto D
    BANKSEL TRISD ; Entramos al banco donde esta el TRISD
    BCF TRISD, 0
    BCF TRISD, 1
    BCF TRISD, 2
    BCF TRISD, 3
    BCF TRISD, 4
    BCF TRISD, 5
    BCF TRISD, 6
    BCF TRISD, 7 ; Se ponen todos pines del puerto D como salida
    
    ;BANKSEL PORTB
    ;CLRF PORTB
    BANKSEL TRISB
    BSF TRISB,0
    BSF TRISB,1
    
    BANKSEL OPTION_REG
    BCF OPTION_REG, 7
    ;BCF T0CS
    ;BCF PSA
    ;BSF PS2
    ;BSF PS1
    ;BCF PS0     
    BANKSEL WPUB
    BSF WPUB,0
    BSF WPUB,1
    BCF WPUB,2
    BCF WPUB,3
    BCF WPUB,4
    BCF WPUB,5
    BCF WPUB,6
    BCF WPUB,7
    
/*; CONFIGUARACION DEL REGISTRO IOCB
    BANKSEL IOCB
    BSF IOCB, 0
    BSF IOCB, 1
    BCF IOCB, 2
    BCF IOCB, 3
    BCF IOCB, 4
    BCF IOCB, 5
    BCF IOCB, 6
    BCF IOCB, 7
    */
BANKSEl IOCB	; Activar interrupciones
    movlw   00000011B	; Activar las interrupciones en RB0 y RB1
    movwf   IOCB	

    
    BANKSEL INTCON
    MOVF PORTB, 0
    BCF  RBIF

; CONFIGURACION DEL REGISTRO INTCON
    BANKSEL INTCON
    BSF  GIE
    BSF  RBIE
    BSF	 T0IF
    
    BANKSEL OSCCON ; Se ingresa al banco donde esta el registro OSCCON
    bcf	    IRCF2   
    bsf	    IRCF1   
    bcf	    IRCF0  ; Se configura el oscilador a una frecuencia de 250kHz 
    bsf	    SCS	   ; Se configura para usar el oscilador interno 
    
    BANKSEL PORTA
    CLRF PORTA
    CLRF PORTB
    CLRF PORTC
    CLRF PORTD
    
    
    

END


