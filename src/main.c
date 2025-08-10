#include "screen.h"

#define SECTION_NAME(name) __attribute__((section(".text." #name)))

SECTION_NAME(main)
void main() {
    InitIO(L'O', L'C');
    clear_screen();

    print_string("This is a example!\n");

    while (1) {}
}
