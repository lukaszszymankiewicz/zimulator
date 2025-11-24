const std = @import("std");

const hw = @import("hardware.zig");
const r = @import("reg.zig");
const t = @import("types.zig");

const instruction_t = @import("ins.zig").instruction_t;
const instruction_collection = @import("ins.zig").instructions;

pub const CPU = struct {
    REG: [hw.SREG_SIZE + hw.RAM_SIZE + hw.PROG_SIZE]t.DataType,

    pub fn init() CPU {
        var cpu = CPU{
            .REG = [_]t.DataType{0} ** (hw.SREG_SIZE + hw.RAM_SIZE + hw.PROG_SIZE),
        };
        // set special fixed registers
        cpu.REG[r.ONS] = 1;
        return cpu;
    }

    pub fn run_microcode(self: *CPU, instruction: instruction_t, n: usize) void {
        // TODO: to to struct method?
        const fun = instruction.MCS[n];
        const arg = instruction.ARGS[n];
        fun(&self.REG, arg);
    }

    pub fn get_acc_buffer(self: *CPU) [8]i32 {
        var accs: [8]i32 = undefined;
        accs[0] = @intCast(self.REG[r.A]);
        return accs;
    }

    pub fn fill_acc_buffer(self: *CPU, buf: []i32, i: usize) void {
        buf[i + 1] = @as(i32, self.REG[r.A]);
    }

    pub fn set_flags(self: *CPU, buf: []i32, instruction: instruction_t) void {
        self.REG[r.CF] = instruction.CXFS(buf, self.REG[r.CF]);
        self.REG[r.HF] = instruction.HXFS(buf, self.REG[r.HF]);
        self.REG[r.NF] = instruction.NXFS(buf, self.REG[r.HF]);
        self.REG[r.ZF] = instruction.ZXFS(buf, self.REG[r.ZF]);
    }

    pub fn get_rr(self: *CPU, reg: t.DataType) t.HardwareSize {
        const h: u32 = @intCast(self.REG[reg]);
        const l: u32 = @intCast(self.REG[reg + 1]);
        return (h << 8) + l;
    }

    pub fn read_program(self: *CPU, program: []t.DataType) void {
        const pc: t.HardwareSize = self.get_rr(r.PC);

        for (0..program.len) |i| {
            self.REG[hw.PROG_START + pc + i] = program[i];
        }
    }

    pub fn run_ins(self: *CPU, program: []t.DataType) void {
        self.read_program(program);
        const pc: t.HardwareSize = self.get_rr(r.PC);

        // read instruction from PC
        const idx = self.REG[hw.PROG_START + pc];
        const instruction: instruction_t = instruction_collection[idx];
        const n = instruction.NMCS;

        // some while loop? or is it too soon?
        // TODO: make it dynamic
        var accs = self.get_acc_buffer();

        for (0..n) |i| {
            self.run_microcode(instruction, i);
            self.fill_acc_buffer(&accs, i);
        }

        self.set_flags(accs[0 .. n + 1], instruction);
    }
};
