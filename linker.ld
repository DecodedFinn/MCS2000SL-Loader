SECTIONS
{
  . = 0x10000;    /* Start address */

  .text : {
    *(.text.main)    /* main() code first */
    *(.text*)        /* then any other text sections */
  }

  .data : {
    *(.data*)
  }

  .bss : {
    *(.bss*)
  }
}
