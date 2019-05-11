ldr r1, =AA

movs r3, #18
movs r2, r3, ROR #14
str r2, [r1], #4

movs r3, #1600
movs r2, r3, LSL #6
str r2, [r1], #4

movs r3, #-96
movs r2, r3, ASR #14
str r2, [r1], #4

movs r2, r3, LSR #14
str r2, [r1], #4
sub r1, r1, #16
ldr r3, [r1, #4]!
ldr r4, [r1, #4]!
ldr r5, [r1, #4]!
ldr r6, [r1, #4]!

AA: .space 100
