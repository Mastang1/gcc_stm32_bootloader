# gcc_stm32_bootloader
This is a project to learn how to create a boot-loader.

# Theory
1. area
   1. boot-loader area: 0x08000000-0x08001000 4KB
   2. application area: 0x08001100-0x08005000 15KB

跳转到 App 那一刻：
  1. Bootloader 关闭中断、关看门狗
  2. 设置 App 的主栈指针 MSP = App 向量表第0个字（App 自己定义的栈顶）
  3. 跳转到 App 的 Reset Handler

App 链接脚本里直接写：
  RAM (rwx) : ORIGIN = 0x20000000, LENGTH = 64K   ← 整个 64K 都给 App！

App 启动文件里会重新初始化 .data/.bss，原来的 Bootloader 数据全被覆盖
