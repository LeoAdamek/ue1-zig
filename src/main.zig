const std = @import("std");
const lib = @import("ue1/emulator");

pub fn main() !void {
    // Create a new emulator state.
    var state = lib.State.init();

    // Initialize some memory
    state.memory = 0b0010_0011;

    // Tick an Instruction.
    state = try state.tick(lib.Instruction.STO, 0);
}
