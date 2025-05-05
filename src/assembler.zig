const std = @import("std");
const Instruction = @import("isa").Instruction;
const Address = @import("isa").Address;

pub const Assembler = struct {
    const Self = @This();
    const Result = std.meta.Tuple(&[_]type{ Instruction, Address });

    source: std.io.AnyReader,
    buffer: [16]u8,

    pub fn init(reader: std.ioReader) Self {
        return .{
            .source = reader,
            .buffer = [16]u8{},
        };
    }

    pub fn next(self: *Self) !Result {
        const instructionLength = try self.source.readUntilDelimiter(&self.buffer, ' ');
        const instruction = try Instruction.fromMneumonic(self.buffer[0..instructionLength]);

        var addr: Address = 0;

        if (instruction.requiresMemoryLocation()) {
            const iml = try self.source.readUntilDelimiter(&self.buffer, '\n');
            addr = try std.fmt.parseUnsigned(Address, self.buffer[0..iml], 0);
        }

        return .{ instruction, addr };
    }
};
