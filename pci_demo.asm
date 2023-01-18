;/********************************************************************************
;* pci_demo.asm: Demonstration av PCI-avbrott i assembler. En lysdiod ansluten
;*               till pin 8 (PORTB0) togglas via nedtryckning av en tryckknapp
;*               ansluten till pin 13 (PORTB5).
;********************************************************************************/

; Makrodefinitioner:
.EQU LED1    = PORTB0 ; Lysdiod 1 ansluten till pin 8 (PORTB0).
.EQU BUTTON1 = PORTB5 ; Tryckknapp 1 ansluten till pin 13 (PORTB0).

.EQU RESET_vect  = 0x00 ; Reset-vektor, h�r startar programmet.
.EQU PCINT0_vect = 0x06 ; Avbrottsvektor f�r PCI-avbrott p� I/O-port B.

;/********************************************************************************
;* .CSEG: Programminnet, h�r lagras programkoden.
;********************************************************************************/
.CSEG

;/********************************************************************************
;* RESET_vect: Programmets startadress. Vi hoppar till subrutinen main f�r att
;*             starta programmet.
;********************************************************************************/
.ORG RESET_vect
   RJMP main

;/********************************************************************************
;* PCINT0_vect: Avbrottsvektor f�r PCI-avbrott p� I/O-port B. Vi hoppar till
;*              motsvarande avbrottsrutin ISR_PCINT0 f�r att hantera avbrottet.
;********************************************************************************/
.ORG PCINT0_vect
   RJMP ISR_PCINT0

;/********************************************************************************
;* ISR_PCINT0: Avbrottsrutin f�r PCI-avbrott p� I/O-port B som �ger rum vid
;*             nedtryckning och uppsl�ppning av tryckknappen. Vid nedtryckning
;*             togglas lysdioden, annars g�r ingenting.
;********************************************************************************/
ISR_PCINT0:
   IN R24, PINB
   ANDI R24, (1 << BUTTON1)
   BREQ ISR_PCINT0_end
   OUT PINB, R16 
ISR_PCINT0_end:
   RETI

;/********************************************************************************
;* main: Initierar systemet vid start. Programmet h�lls sedan ig�ng s� l�nge
;*       matningssp�nning tillf�rs.
; ********************************************************************************/
main:

;/********************************************************************************
;* setup: Initierar I/O-portar samt aktiverar PCI-avbrott p� tryckknappens pin.
;*        F�ljande inneh�ll skrivs till CPU-register R16 - R17 och bih�lls sedan
;*        under programmets g�ng.
;*
;*        R16 = (1 << LED1)
;*        R17 = (1 << BUTTON1)
;*       
;*        F�r att aktivera PCI-avbrott I/O-port B ettst�lls biten PCIE0
;*        (Pin Change Interrupt Enable 0) i kontrollregistret PCICR
;*        (Pin Change Interrupt Control Register). Eftersom PCIE0 utg�r bit 0
;*        i detta register, precis som LED1, anv�nds d�rmed inneh�llet i
;*        CPU-register R16 = (1 << LED1) f�r att ettst�lla denna bit. 
;*
;*        F�r att enbart aktivera PCI-avbrott p� tryckknappens pin ettst�lls
;*        biten PCINT5 i maskregister PCMSK0 (Pin Change Mask Register 0).
;*        D� PCINT5 utg�r bit i detta register, precis som BUTTON1, anv�nds 
;*        inneh�llet i CPU-register R17 = (1 << BUTTON) f�r att ettst�lla 
;*        denna bit. 
;********************************************************************************/
setup:
   LDI R16, (1 << LED1)
   OUT DDRB, R16
   LDI R17, (1 << BUTTON1)
   OUT PORTB, R17
   SEI
   STS PCICR, R16 
   STS PCMSK0, R17 

;/********************************************************************************
;* main_loop: Tom loop som h�ller ig�ng programmet s� l�nge matningssp�nning
;*            tillf�rs.
; ********************************************************************************/
main_loop:
   RJMP main_loop