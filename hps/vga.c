#define BOARD                 "DE1-SoC"

/* Address */

/* Memory */
#define DDR_BASE              0x00000000 // 0x00000000 - 0x3FFFFFFF, HPS 1GB SDRAM (DDR3)
#define SDRAM_BASE            0xC0000000 // 0xC0000000 - 0xC3FFFFFF, FPGA 64MB SDRAM
#define FPGA_ONCHIP_BASE      0xC8000000 // 0xC8000000 - 0xC803FFFF, FPGA 256KB on-chip: default pixel buffer
#define FPGA_CHAR_BASE        0xC9000000 // 0xC9000000 - 0xC9001FFF, FPGA 8KB on-chip: default char buffer
#define A9_ONCHIP_BASE        0xFFFF0000 // 0xFFFF0000 - 0xFFFFFFFF, HPS 64KB on-chip

/* Cyclone V FPGA devices */
#define LEDR_BASE             0xFF200000
#define HEX3_HEX0_BASE        0xFF200020
#define HEX5_HEX4_BASE        0xFF200030
#define SW_BASE               0xFF200040
#define KEY_BASE              0xFF200050
#define JP1_BASE              0xFF200060
#define JP2_BASE              0xFF200070
#define PS2_BASE              0xFF200100
#define PS2_DUAL_BASE         0xFF200108
#define JTAG_UART_BASE        0xFF201000
#define JTAG_UART_2_BASE      0xFF201008
#define IrDA_BASE             0xFF201020
#define TIMER_BASE            0xFF202000
#define AV_CONFIG_BASE        0xFF203000
#define PIXEL_BUF_CTRL_BASE   0xFF203020
#define CHAR_BUF_CTRL_BASE    0xFF203030
#define AUDIO_BASE            0xFF203040
#define FPGA_SDRAM_TRIGGER    0xFF203050 // 0xFF203050 - 0xFF203053, 3B (for avalon_sdr)
#define VIDEO_IN_BASE         0xFF203060
#define ADC_BASE              0xFF204000

/* Cyclone V HPS devices */
#define HPS_GPIO1_BASE        0xFF709000
#define HPS_TIMER0_BASE       0xFFC08000
#define HPS_TIMER1_BASE       0xFFC09000
#define HPS_TIMER2_BASE       0xFFD00000
#define HPS_TIMER3_BASE       0xFFD01000
#define FPGA_BRIDGE           0xFFD0501C

/* ARM A9 MPCORE devices */
#define   PERIPH_BASE         0xFFFEC000    // base address of peripheral devices
#define   MPCORE_PRIV_TIMER   0xFFFEC600    // PERIPH_BASE + 0x0600

/* Interrupt controller (GIC) CPU interface(s) */
#define MPCORE_GIC_CPUIF      0xFFFEC100    // PERIPH_BASE + 0x100
#define ICCICR                0x00          // offset to CPU interface control reg
#define ICCPMR                0x04          // offset to interrupt priority mask reg
#define ICCIAR                0x0C          // offset to interrupt acknowledge reg
#define ICCEOIR               0x10          // offset to end of interrupt reg
/* Interrupt controller (GIC) distributor interface(s) */
#define MPCORE_GIC_DIST       0xFFFED000    // PERIPH_BASE + 0x1000
#define ICDDCR                0x00          // offset to distributor control reg
#define ICDISER               0x100         // offset to interrupt set-enable regs
#define ICDICER               0x180         // offset to interrupt clear-enable regs
#define ICDIPTR               0x800         // offset to interrupt processor targets regs
#define ICDICFR               0xC00         // offset to interrupt configuration regs



#define ABS(x) (((x) > 0) ? (x) : -(x))

/* Constants */
#define RESOLUTION_X 320
#define RESOLUTION_Y 240


#include <stdlib.h>
/*
#include <math.h>
#include <stdio.h>
#include <time.h>
*/


// Global variables

volatile int pixelBufferStart;
volatile int * pixelCtrlPtr = (int *) PIXEL_BUF_CTRL_BASE;
// volatile int * PS2Ptr = (int *) PS2_KEYBOARD_BASE; // PS/2 port address


// Helper functions
void clearScreen(); // basic clear function
void plotPixel(int x, int y, short int color);
void waitForVsync();




int main(void) {
    initialize();

    /* set front pixel buffer */
    *(pixelCtrlPtr + 1) = 0xC1000000; // store the address in back buffer and then swap
    pixelBufferStart = *pixelCtrlPtr;
    waitForVsync();
    clearScreen();
    
    /* set back pixel buffer */
    *(pixelCtrlPtr + 1) = 0xC2000000; // set it to the same addr as the other buffer to disable double buffering
    pixelBufferStart = *(pixelCtrlPtr + 1);
    waitForVsync();
    clearScreen();

    while (1) {
        waitForVsync();
        pixelBufferStart = *(pixelCtrlPtr + 1); // swap buffer
        clearScreen(); // erase
        
        /*
        // capture input
        unsigned char byte = 0;
        int PS2Data, RVALID;

        PS2Data = *(PS2Ptr); // read the Data register in the PS/2 port
        RVALID = (PS2Data & 0x8000); // extract the RVALID field
        if (RVALID != 0) byte = PS2Data & 0xFF;

        switch (byte) {
            case 0x1D: { // W
                // add
                break;
            }
            default: {}
        }*/

        draw();
    }
}



void draw() {
    // call plotPixel() here
}



void clearScreen() {
    int x, y;
    for(x = 0; x < RESOLUTION_X; x++) {
        for(y = 0; y < RESOLUTION_Y; y++) {
            plotPixel(x, y, 0);
        }
    }
}



void plotPixel(int x, int y, short int color) {
    *(short int *)(pixelBufferStart + (y << 10) + (x << 1)) = color;
    // R[15:11]; G[10:5]; B[4:0]
    // y[17:10]; x[9:1]
}



void waitForVsync() {
    *pixelCtrlPtr = 1;
    register int status = *(pixelCtrlPtr + 3); 
    while (status & 0x01) status = *(pixelCtrlPtr + 3);
}
