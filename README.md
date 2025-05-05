UE1 Zig
=======

Assember and interactive emulator for @UEVTC 's homebrew valve computer, in Zig.

@UEVTC already wrote an emulator and assembler for his computer. However,
because it's written in QuickBasic it only runs under DOSBOX. I wanted something
that was modular so the assembler, or emulator, could be re-used.

Due to the very basic design of the UE-1, the emulator and assembler are equally
simple. Memory is a single u8, with the registers implemented using a packed
struct.

