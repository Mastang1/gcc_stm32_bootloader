.syntax unified
.cpu cortex-m3
.thumb

.global isr_vector
.global _reset_handler

.section .isr_vector,"a",%progbits
isr_vector:
    .word _stack_top           // 栈顶
    .word _reset_handler       // 复位向量
    .word 0                    // NMI
    .word 0                    // Hard Fault
    .rept 76                   // 其余向量填 0 也够用
    .word 0
    .endr

.section .text._reset_handler
.weak _reset_handler
.type _reset_handler, %function
_reset_handler:
    // 复制 .data 到 RAM
    ldr r1, =_etext
    ldr r2, =_sdata
    ldr r3, =_edata
1:  cmp r2, r3
    ittt lt
    ldrlt r0, [r1], #4
    strlt r0, [r2], #4
    blt 1b

    // 清零 .bss
    ldr r1, =_sbss
    ldr r2, =_ebss
    movs r0, #0
2:  cmp r1, r2
    itt lt
    strlt r0, [r1], #4
    blt 2b

    bl main
    b .
.size _reset_handler, . - _reset_handler