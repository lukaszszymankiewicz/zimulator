const std = @import("std");
const ins_mod = @import("ins.zig");
const instruction_t = @import("ins.zig").instruction_t;
const instruction_collection = ins_mod.instructions;

const DataType = u8;
const IndexType = u8;
const InstructionType = u8;
const HardwareSize = u32;

const FOURTH_BIT_OVERFLOW = 0b0001_0000;
const FOURTH_BIT_CONVERSION = 0b0000_1111;

pub const RAM_SIZE: HardwareSize = 256 * 256;
pub const SREG_SIZE: HardwareSize = 256;
pub const PROG_SIZE: HardwareSize = 256 * 256;

// TODO: to common module
// REGISTER INDEXES
pub const IM: IndexType = 0b0000_0000;
pub const A: IndexType = 0b0000_0001;
pub const B: IndexType = 0b0000_0010;
pub const C: IndexType = 0b0000_0011;
pub const D: IndexType = 0b0000_0100;
pub const E: IndexType = 0b0000_0101;
pub const H: IndexType = 0b0000_0110;
pub const L: IndexType = 0b0000_0111;
pub const CF: IndexType = 0b0000_1000;
pub const HF: IndexType = 0b0000_1001;
pub const NF: IndexType = 0b0000_1010;
pub const ZF: IndexType = 0b0000_1011;
pub const S: IndexType = 0b0000_1100;
pub const P: IndexType = 0b0000_1101;
pub const BC: IndexType = B;
pub const DE: IndexType = D;
pub const HL: IndexType = H;
pub const SP: IndexType = S;
pub const PCH: IndexType = 0b1000_0000;
pub const PCL: IndexType = 0b1000_0001;
pub const PC: IndexType = PCH;
pub const MEM: IndexType = 0b0111_1110;
pub const RAM: IndexType = 0b0111_1111;
pub const ADH: IndexType = 0b0011_1110;
pub const ADL: IndexType = 0b0011_1111;
pub const TMH: IndexType = 0b1111_1110;
pub const TML: IndexType = 0b1111_1111;
pub const TM: IndexType = TMH;
pub const ZRS: IndexType = 0b0110_1110;
pub const ONS: IndexType = 0b0110_1111;

pub const CPU = struct {
    REG: [SREG_SIZE + RAM_SIZE + PROG_SIZE]DataType,

    pub fn init() CPU {
        var cpu: CPU = CPU{
            .REG = [_]DataType{0} ** (SREG_SIZE + RAM_SIZE + PROG_SIZE),
        };
        cpu.REG[ONS] = 1;
        return cpu;
    }

    pub fn run_microcode(self: *CPU, instruction: instruction_t, n: usize) void {
        // TODO: to to struct method?
        const fun = instruction.MCS[n];
        const arg = instruction.ARGS[n];
        fun(&self.REG, arg);
    }

    pub fn get_acc_buffer(self: *CPU) [5]i32 {
        var accs: [5]i32 = undefined;
        accs[0] = @intCast(self.REG[A]);
        return accs;
    }

    pub fn fill_acc_buffer(self: *CPU, buf: []i32, i: usize) void {
        buf[i + 1] = @as(i32, self.REG[A]);
    }

    pub fn set_C_flag(self: *CPU, buf: []i32, instruction: instruction_t) void {
        self.REG[CF] = instruction.CXFS(buf, self.REG[CF]);
    }

    pub fn set_H_flag(self: *CPU, buf: []i32, instruction: instruction_t) void {
        self.REG[HF] = instruction.HXFS(buf, self.REG[HF]);
    }

    pub fn set_N_flag(self: *CPU, buf: []i32, instruction: instruction_t) void {
        self.REG[NF] = instruction.NXFS(buf, self.REG[HF]);
    }

    pub fn set_Z_flag(self: *CPU, buf: []i32, instruction: instruction_t) void {
        self.REG[ZF] = instruction.ZXFS(buf, self.REG[ZF]);
    }

    pub fn read_program(self: *CPU, program: []DataType) void {
        for (0..program.len) |i| {
            self.REG[SREG_SIZE + RAM_SIZE + i] = program[i];
        }
        self.REG[PCH] = 0;
        self.REG[PCL] = 0;
    }

    pub fn run_ins(self: *CPU, program: []DataType) void {
        self.read_program(program);

        // read instruction from PC
        const idx = self.REG[SREG_SIZE + RAM_SIZE + self.REG[PC]];
        const instruction: instruction_t = instruction_collection[idx];
        const n = instruction.NMCS;

        // some while loop? or is it too soon?
        // TODO: make it dynamic
        var accs = self.get_acc_buffer();

        for (0..n) |i| {
            self.run_microcode(instruction, i);
            self.fill_acc_buffer(&accs, i);
        }

        self.set_C_flag(accs[0 .. n + 1], instruction);
        self.set_H_flag(accs[0 .. n + 1], instruction);
        self.set_N_flag(accs[0 .. n + 1], instruction);
        self.set_Z_flag(accs[0 .. n + 1], instruction);

        std.debug.print("\nCF: {d}\n", .{self.REG[CF]});
        std.debug.print("\nHF: {d}\n", .{self.REG[HF]});
        std.debug.print("\nNF: {d}\n", .{self.REG[NF]});
        std.debug.print("\nZF: {d}\n", .{self.REG[ZF]});
    }
};
