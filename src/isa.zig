//! ISA definitions for the UE-1.
//!
//! Defines the available instructions of the UE-1 as well
//! as functions to convert from/to stored instruction values

const std = @import("std");

/// Address type: The UE1 uses 4-bit addresses.
/// However it only has 8 bits of memory, and therefore the MSB
/// of the address is unused. It exists for convenience. 
pub const Address = u3;

pub const Error = error {
    InvalidInstruction,
};

/// Instructions for the UE-1
pub const Instruction = enum {
    const Self = @This();

    /// No-Operation
    NOP0,

    /// Load bit from memory address into scratch register.
    LD, 

    /// Add (with carry) the value at the given memory address to the scratch register.
    ADD, 

    // Subtract (with carry) the value at the given memory address from the scratch register.
    SUB, 
    // Set the scratch register to 1
    ONE, 

    // NAND the scratch register with the value at the given memory address.
    NAND, 

    // OR the scratch register with the value at the given memory address.
    OR,

    // XOR the scratch register with the value at the given memory address.
    XOR,

    // Store the value of the scratch register at the given memory address.
    STO, 

    // Store the complement of the scratch register at the given memory address.
    STOC,
    IEN, // Input Enable
    OEN, // Output Enable
    IOC, // IO Control
    RTN, // Return
    SKZ,
    NOPF,

    // Halt the system and discontinue processing
    HLT,

    pub fn fromOpcode(opcode: Address) !Self {
        return @enumFromInt(opcode);
    }

    pub fn fromMenumonic(_: []const u8) !Self {
        return Error.InvalidInstruction;
    }

    pub fn requiresMemoryLocation(self: *const Self) bool {
        return switch(self) {
            Instruction.NOP0, Instruction.NOP0F, Instruction.OEN, Instruction.ONE, Instruction.HLT => false,
            else => true
        };
    }
};
