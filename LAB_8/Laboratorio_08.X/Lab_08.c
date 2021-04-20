/******************************************************************************
 * Laboratorio 08
 ******************************************************************************
 * File:   Lab_08.c
 * Author: Marco
 * 
 *
 * Created on April 12, 2021, 3:35 PM
 */

//  Bits de configuracion   //
// CONFIG1
#pragma config FOSC = INTRC_NOCLKOUT// Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
#pragma config PWRTE = OFF      // Power-up Timer Enable bit (PWRT disabled)
#pragma config MCLRE = OFF      // RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
#pragma config CP = OFF         // Code Protection bit (Program memory code protection is disabled)
#pragma config CPD = OFF        // Data Code Protection bit (Data memory code protection is disabled)
#pragma config BOREN = OFF      // Brown Out Reset Selection bits (BOR disabled)
#pragma config IESO = OFF       // Internal External Switchover bit (Internal/External Switchover mode is disabled)
#pragma config FCMEN = OFF      // Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
#pragma config LVP = OFF        // Low Voltage Programming Enable bit (RB3 pin has digital I/O, HV on MCLR must be used for programming)

// CONFIG2
#pragma config BOR4V = BOR40V   // Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
#pragma config WRT = OFF        // Flash Program Memory Self Write Enable bits (Write protection off)

// #pragma config statements should precede project file includes.
// Use project enums instead of #define for ON and OFF.

#define _XTAL_FREQ 4000000
#include <xc.h>
#include <stdint.h>
//-----------------------------------------------------------------------------
//                            Variables 
//-----------------------------------------------------------------------------
        // Se crea una matriz para la traduccion
char tabla[10] = {0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110,
    0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01101111};
int multi;      // Variable del multiplexeo
char centenas;  // Variables pra la divisiones
char decenas;
char unidades;
char res;
char contador;  // Variable que posee el valor del puerto
char pot2;

//-----------------------------------------------------------------------------
//                            Prototipos 
//-----------------------------------------------------------------------------
void setup(void);   // Defino las funciones antes de crearlas
char division(void);

//-----------------------------------------------------------------------------
//                            Interrupciones
//-----------------------------------------------------------------------------
void __interrupt() isr(void)
{
    if(T0IF == 1)   // Verificar la bandera del timer0
    {   
        PORTBbits.RB2 = 0;      // Apago el transistor 2
        PORTBbits.RB0 = 1;      // Prendo transistor 0
        PORTD = (tabla[centenas]);  // Ingreso de centenas
        multi = 0b00000001;     // Prendo una flag
        
        if (multi == 0b00000001) // reviso que flag esta prendida
        {
            PORTBbits.RB0 = 0;  // Prendo un tnsistor y apgo el otro
            PORTBbits.RB1 = 1;
            PORTD = (tabla[decenas]);   // Despliego decenas
            multi = 0b00000010;         // Cambio de lugar la flag
        }
        if (multi == 0b00000010)    // Reviso que flag esta prendida
        {
            PORTBbits.RB1 = 0;      // Prendo un transistor y apago otro
            PORTBbits.RB2 = 1;
            PORTD = (tabla[unidades]);  // Muevo unidades a un dispay
            multi = 0b00000000;     // apago las banderas
        }
        INTCONbits.T0IF = 0;    // Limpio la interrupcion del timer0
        TMR0 = 255;     // Configuro el valor de reinicio del timer0
    }
       if(PIR1bits.ADIF == 1)
       {
           if(ADCON0bits.CHS == 0)
               PORTC = ADRESH;
           
           else
               contador = ADRESH;
           
           PIR1bits.ADIF = 0;           
       }
    }

//-----------------------------------------------------------------------------
//                            Main
//-----------------------------------------------------------------------------
void main(void) {
    
    setup();    // Llamo a mi configuracion
    ADCON0bits.GO = 1;     // Bita para que comience la conversion
    
    while(1)    // Equivale al loop
    {
        if(ADCON0bits.GO == 0){
            if(ADCON0bits.CHS == 1)
                ADCON0bits.CHS = 0;
            else
                ADCON0bits.CHS = 1;
            
            __delay_us(100);
            ADCON0bits.GO = 1;
        }
       division(); 
    }
}

void setup(void){
    
    // Configuraciones de puertos digitales
    ANSEL = 0b00000011;
    ANSELH = 0b11111111;
    
    // Configurar bits de salida o entradaas
    TRISAbits.TRISA0 = 1;
    TRISAbits.TRISA1 = 1;
    TRISBbits.TRISB0 = 0;
    TRISBbits.TRISB1 = 0;
    TRISBbits.TRISB2 = 0;
    TRISC = 0x00;
    TRISD = 0x00;
    
    // Se limpian los puertos
    PORTA = 0x00;
    PORTB = 0x00;
    PORTC = 0x00;
    PORTD = 0x00;
    
    // Se configura el oscilador
    OSCCONbits.IRCF2 = 0;
    OSCCONbits.IRCF1 = 1;
    OSCCONbits.IRCF0 = 0;   // Se configura a 250kHz
    OSCCONbits.SCS = 1;
    
    // Timer0
    OPTION_REGbits.T0CS = 0;
    OPTION_REGbits.PSA = 0;
    OPTION_REGbits.PS2 = 1;
    OPTION_REGbits.PS1 = 1;
    OPTION_REGbits.PS0 = 1;
    
    // Configuacion de las interrupciones
    INTCONbits.GIE = 1;
    INTCONbits.T0IE = 1;
    INTCONbits.T0IF = 0;
    INTCONbits.PEIE = 1;    // Periferical interrupt
    PIE1bits.ADIE = 1;      // Activar la interrupcion del ADC
    PIR1bits.ADIF = 0;      // Bandera del ADC
    
    // Configuracion del ADC
    ADCON0bits.ADCS0 = 1;
    ADCON0bits.ADCS1 = 1; // Se configura el oscilador interno
    ADCON0bits.ADON = 1;        // Activar el ADC
    
    ADCON0bits.CHS = 0;         // Canal 0
    
    ADCON1bits.ADFM = 0;        // Justificado a la izquierda
    ADCON1bits.VCFG0 = 0;
    ADCON1bits.VCFG1 = 0;
}

char division(void) {
//    contador = pot2;       // contador ahora valo lo mismo que portc
    centenas = contador/100;    // Lo divide siempre, pero solo toma enteros
    res = contador%100;     // Utiliza el residuo de la division
    decenas = res/10;   // El residuo se deivide entre 10
    unidades = res%10;  // luego se mueve ese residuo a unidades
}

