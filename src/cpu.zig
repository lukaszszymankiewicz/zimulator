const std = @import("std");

const hw = @import("hardware.zig");
const r = @import("reg.zig");
const t = @import("types.zig");
const instruction_t = @import("ins.zig").instruction_t;
const instruction_collection = @import("ins.zig").instructions;

pub const CPU = struct {
    REG: [hw.SREG_SIZE + hw.RAM_SIZE]t.DataType,

    pub fn init() CPU {
        var cpu = CPU{
            .REG = [_]t.DataType{0} ** (hw.SREG_SIZE + hw.RAM_SIZE),
        };
        // set special fixed registers
        cpu.REG[r.ONS] = 1;
        return cpu;
    }

    // TODO: to the microcode module
    pub fn run_microcode(self: *CPU, instruction: instruction_t, n: usize) void {
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

    // TODO: to the flag setter module
    pub fn set_flags(self: *CPU, accs: []i32, instruction: instruction_t) void {
        self.REG[r.CF] = instruction.CXFS(accs[0..instruction.NMCS+1], self.REG[r.CF]);
        self.REG[r.HF] = instruction.HXFS(accs[0..instruction.NMCS+1], self.REG[r.HF]);
        self.REG[r.NF] = instruction.NXFS(accs[0..instruction.NMCS+1], self.REG[r.HF]);
        self.REG[r.ZF] = instruction.ZXFS(accs[0..instruction.NMCS+1], self.REG[r.ZF]);
    }

    pub fn get_vram(self: *CPU) []t.DataType {
        // TODO: create fix values for this range
        return self.REG[(hw.PROG_START + 0x9000)..(hw.PROG_START + 0x9FFF)];
    }

    // TODO: to the register module
    pub fn get_instruction(self: *CPU) instruction_t {
        const h: u32 = @intCast(self.REG[r.PCH]);
        const l: u32 = @intCast(self.REG[r.PCL]);

        const ins_idx: u32 =  self.REG[hw.PROG_START + (h << 8) + l];

        return instruction_collection[ins_idx];
    }

    pub fn run_single_instruction(self: *CPU) void {
        const instruction = self.get_instruction();

        var accs = self.get_acc_buffer();

        for (0..instruction.NMCS) |i| {
            self.run_microcode(instruction, i);
            self.fill_acc_buffer(&accs, i);
        }

        self.set_flags(&accs, instruction);
    }
};
