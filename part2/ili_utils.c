#include <asm/desc.h>

void my_store_idt(struct desc_ptr *idtr) {
    asm volatile("sidt %0;" 
                 : "=m" (*idtr)
                 );
}

void my_load_idt(struct desc_ptr *idtr) {
    asm volatile("lidt %0;"
                 :
                 : "m" (*idtr)
                 );
}

void my_set_gate_offset(gate_desc *gate, unsigned long addr) {
    gate->offset_low = addr & 0xffff;
    gate->offset_middle = (addr >> 16) & 0xffff;
    gate->offset_high = (addr >> 32) & 0xffffffff;
}

unsigned long my_get_gate_offset(gate_desc *gate) {
    unsigned long offset;
    offset = gate->offset_low;
    offset |= gate->offset_middle << 16;
    offset |= gate->offset_high << 32;
    return offset;
}
