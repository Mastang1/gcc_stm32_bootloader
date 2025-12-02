ENTRY(_reset_handler)
/*
/*
 * Linker script for STM32F103C8T6 microcontroller
 * Blink LED on pin PC13
BIN = 简单、粗暴，但需要人为指定地址。
ELF/HEX = 完整、安全，OpenOCD 会自动处理地址。

VMA 是运行地址（执行时 CPU 认为代码/数据在这里）
LMA 是加载地址（烧写器/bootloader 把内容放到这里）

BIN 文件:
    objcopy 根据 Flash（LMA 区域）的真实映射，把所有存在的 LMA 数据“拉成一条连续的字节流”。
    ================================================================================
    bin 偏移 0x00000000  = Flash 地址 0x08000000  = .isr_vector
    bin 偏移 0x00000040  = Flash 地址 0x08000040  = .text 
    bin 偏移 0x0000xxxx  = Flash 地址 0x0800xxxx  = .rodata
    bin 偏移 0x0000ABCD  = Flash 地址 0x0800ABCD  = .data 初始化内容
    bin 偏移 0x0000ACF0  = Flash 地址 0x0800ACF0  = 文件结束

    .bss 只占 RAM，且无初始化内容，因此：
                                    没有 LMA 不写入 Flash 不进入 bin
    ================================================================================
openOCD 烧写bin:
    program app.bin 0x08000000
总结说明：
    section .text 产品中基本都放在Flash
    section .rodata 也是放在Flash
    section .data 因为是初始化的全局变量，一般放在Flash, 在运行时会被复制到RAM
    section .bss 未初始化的全局及静态变量，都是0，不用在flash中占用空间，会在初始化时清零
 */
MEMORY
{
    FLASH (rx) : ORIGIN = 0x08000000, LENGTH = 64K
    RAM   (rwx) : ORIGIN = 0x20000000, LENGTH = 20K
}

SECTIONS
{
    .text : {
        KEEP(*(.isr_vector))    /* defined in startup code */
        *(.text*)
        *(.rodata*)
        _etext = .;
    } > FLASH   /* LMA = VMA , FLASH is executable, VMA=0x08000000 */

    .data : {
        _sdata = .;
        *(.data*)
        _edata = .;
    } > RAM AT > FLASH   /* VMA=0x20000000, LMA= follows FLASH */

    .bss : {
        _sbss = .;
        *(.bss*)
        *(COMMON)
        _ebss = .;
    } > RAM /*IN-RAM, which is zero-initialized, so no need to copy from LMA*/

    _stack_top = ORIGIN(RAM) + LENGTH(RAM);
}