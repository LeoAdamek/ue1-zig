const std = @import("std");
const testing = std.testing;
const isa = @import("isa");
const log = std.log.scoped(.ue1);

pub const Error = error{
    UnimplementedInstruction,
    InvalidMemoryAddress,
};

pub const Address = isa.Address;
pub const Instruction = isa.Instruction;

pub const Registers = packed struct {
    scratch: u1,
    carry: u1,
    output_enabled: u1,
    input_enabled: u1,

    const Self = @This();

    pub fn init() Self {
        return .{
            .scratch = 0,
            .carry = 0,
            .output_enabled = 0,
            .input_enabled = 0,
        };
    }
};

const One = @as(u8, 1);

pub const State = struct {
    const Self = @This();

    /// The UE1 contains 8 bits of memory which are individually addressed
    /// on the 1-bit data bus.
    memory: u8,

    /// Scratch Register
    registers: Registers,

    pub fn init() Self {
        return .{
            .memory = 0,
            .registers = Registers.init(),
        };
    }

    /// Perform an emulation tick on the emulator state, returning the new state.
    /// 
    /// UE1 instructions *always* contain an instruction and an address.
    pub fn tick(self: *const Self, inst: Instruction, addr: Address) !Self {
        var newmem = self.memory;
        var newreg = self.registers;

        log.debug("Instruction: {}", .{ inst });
        log.debug("Memory:      {b:08}", .{ self.memory });

        // Memory value
        const memval = self.memory & (One << addr);

        // Scratch Value
        const scrval = @as(u8, self.registers.scratch) << addr;

        switch (inst) {
            // No action required in the case of a NOP0 or HLT.
            // HLT must be handled by the caller.
            Instruction.NOP0, Instruction.HLT => return .{
                .memory = newmem,
                .registers = newreg,
            },

            Instruction.LD => {
                newreg.scratch = @intFromBool( memval > 1 );
            },

            Instruction.STO => {
                log.debug("Store {b} @ {b:08}", .{ self.registers.scratch, addr });

                newmem |= scrval;

                log.debug("Current Memory: {b:08}", .{self.memory});
                log.debug("New Memory:     {b:08}", .{newmem});
            },

            Instruction.ADD => {
                const val = @intFromBool( memval > 0 );
                    
                newreg.carry    = self.registers.scratch & val;
                newreg.scratch ^= val;

                log.debug(
                    "Addition: {} + {} (M[{}]) = {} (C = {})",
                    .{ self.registers.scratch, val, addr, newreg.scratch, newreg.carry }
                );
            },

            Instruction.OR   => newreg.scratch  = @intFromBool(scrval | memval >  0),
            Instruction.NAND => newreg.scratch  = @intFromBool(scrval & memval == 0),
            Instruction.XOR  => newreg.scratch  = @intFromBool(scrval ^ memval >  0),
            Instruction.ONE  => newreg.scratch  = 1,
            Instruction.OEN  => newreg.output_enabled = 1,
            Instruction.IEN  => newreg.input_enabled  = 1,
    
            else => return Error.UnimplementedInstruction,
        }

        // Return the new state.
        return .{
            .memory = newmem,
            .registers = newreg,
        };
    }
};


test "Execute Instruction: NOP" {
    const state = State.init();
    const result = try state.tick(Instruction.NOP0, 0);

    try testing.expectEqual(state.memory, result.memory);
    try testing.expectEqual(state.registers, result.registers);
}

test "Execute Instruction: STO" {
    var state = State.init();

    state.memory = 0b0000_1111;
    state.registers.scratch = 1;

    var result = try state.tick(Instruction.STO, 0b101);
    try testing.expectEqual(0b0001_1111, result.memory);
    
    state.registers.scratch = 0;
    result = try result.tick(Instruction.STO, 0b000);
    try testing.expectEqual(0b0001_1110, result.memory);

}

test "Execute Insturction: ADD" {
    var state = State.init();

    state.memory = 0b1010_1010;
    
    const newstate = try state.tick(Instruction.ADD, 0b001);

    try testing.expectEqual(1, newstate.registers.scratch);
    try testing.expectEqual(0, newstate.registers.carry);
}

