const std = @import("std");

const hw = @import("hardware.zig");
const r = @import("reg.zig");
const t = @import("types.zig");

const instruction_t = @import("ins.zig").instruction_t;
const instruction_collection = @import("ins.zig").instructions;

pub const CPU = struct {
    REG: [hw.SREG_SIZE + hw.RAM_SIZE + hw.PROG_SIZE]t.DataType,

    pub fn init() CPU {
        var cpu: CPU = CPU{
            .REG = [_]t.DataType{0} ** (hw.SREG_SIZE + hw.RAM_SIZE + hw.PROG_SIZE),
        };
        cpu.REG[r.ONS] = 1;
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
        accs[0] = @intCast(self.REG[r.A]);
        return accs;
    }

    pub fn fill_acc_buffer(self: *CPU, buf: []i32, i: usize) void {
        buf[i + 1] = @as(i32, self.REG[r.A]);
    }

    pub fn set_C_flag(self: *CPU, buf: []i32, instruction: instruction_t) void {
        self.REG[r.CF] = instruction.CXFS(buf, self.REG[r.CF]);
    }

    pub fn set_H_flag(self: *CPU, buf: []i32, instruction: instruction_t) void {
        self.REG[r.HF] = instruction.HXFS(buf, self.REG[r.HF]);
    }

    pub fn set_N_flag(self: *CPU, buf: []i32, instruction: instruction_t) void {
        self.REG[r.NF] = instruction.NXFS(buf, self.REG[r.HF]);
    }

    pub fn set_Z_flag(self: *CPU, buf: []i32, instruction: instruction_t) void {
        self.REG[r.ZF] = instruction.ZXFS(buf, self.REG[r.ZF]);
    }

    pub fn read_program(self: *CPU, program: []t.DataType) void {
        for (0..program.len) |i| {
            self.REG[hw.SREG_SIZE + hw.RAM_SIZE + i] = program[i];
        }
        self.REG[r.PCH] = 0;
        self.REG[r.PCL] = 0;
    }

    pub fn run_ins(self: *CPU, program: []t.DataType) void {
        self.read_program(program);

        // read instruction from PC
        const idx = self.REG[hw.SREG_SIZE + hw.RAM_SIZE + self.REG[r.PC]];
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

        std.debug.print("\nCF: {d}\n", .{self.REG[r.CF]});
        std.debug.print("\nHF: {d}\n", .{self.REG[r.HF]});
        std.debug.print("\nNF: {d}\n", .{self.REG[r.NF]});
        std.debug.print("\nZF: {d}\n", .{self.REG[r.ZF]});
    }
};
