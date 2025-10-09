const std = @import("std");

const EIGHT_BIT_OVERFLOW = 0b1_0000_0000;
const FOURTH_BIT_OVERFLOW = 0b0001_0000;
const FOURTH_BIT_CONVERSION = 0b0000_1111;
const SAFE_FOURTH_BIT_CONVERSION = 0b1_0000_1111;
const EIGHT_BIT_CONVERSION = 0b0000_0000_1111_1111;

pub const CF: u32 = 0b0000_1000;
pub const HF: u32 = 0b0000_1001;
pub const NF: u32 = 0b0000_1010;
pub const ZF: u32 = 0b0000_1011;

// const CF: u32 = 0;
// const HF: u32 = 1;
// const NF: u32 = 2;
// const ZF: u32 = 3;

// MICROCODE FUNCTION IDEXES
pub const _NOP: u32 = 0;
pub const _NOR: u32 = 1;
pub const _RET0: u32 = 2;
pub const _RET1: u32 = 3;
pub const _ADD_A_REG: u32 = 2;
pub const _ADD_A_MEM: u32 = 3;
pub const _SUB_A_REG: u32 = 4;
pub const _SUB_A_MEM: u32 = 5;
pub const _ADC_A_REG: u32 = 6;
pub const _ADC_A_MEM: u32 = 7;
pub const _SBC_A_REG: u32 = 8;
pub const _LD_REG_D16: u32 = 9;

const C = struct {
    const funs = [_]*const fn (u16, u16, []u16) u16{ C.NOP, C.NOR, C.RET0 };

    fn NOP(_: u16, _: u16, flags: []u16) u16 {
        return flags[CF];
    }

    fn NOR(new: u16, old: u16, _: []u16) u16 {
        return @intFromBool((new & EIGHT_BIT_OVERFLOW) != (old & EIGHT_BIT_OVERFLOW));
    }

    fn RET0(_: u16, _: u16, _: []u16) u16 {
        return 0;
    }

    pub fn calc(i: usize, new: u16, old: u16, flags: []u16) void {
        const func = C.funs[i];
        flags[CF] = func(new, old, flags);
    }
};

const H = struct {
    const funs = [_]*const fn (u16, u16, []u16) u16{ H.NOP, H.NOR, H.RET0, H.RET1 };

    fn NOP(_: u16, _: u16, flags: []u16) u16 {
        return flags[HF];
    }

    fn NOR(new: u16, old: u16, _: []u16) u16 {
        return @intFromBool((new & FOURTH_BIT_OVERFLOW) != (old & FOURTH_BIT_OVERFLOW));
    }

    fn RET0(_: u16, _: u16, _: []u16) u16 {
        return 0;
    }

    fn RET1(_: u16, _: u16, _: []u16) u16 {
        return 1;
    }

    pub fn calc(i: usize, new: u16, old: u16, flags: []u16) void {
        const func = H.funs[i];
        flags[HF] = func(new, old, flags);
    }
};

const N = struct {
    const funs = [_]*const fn (u16, []u16) u16{ N.NOP, N.NOP, N.RET0, N.RET1 };

    fn NOP(_: u16, flags: []u16) u16 {
        return flags[NF];
    }

    fn RET0(_: u16, _: []u16) u16 {
        return 0;
    }

    fn RET1(_: u16, _: []u16) u16 {
        return 1;
    }

    pub fn calc(i: usize, acc: u16, flags: []u16) void {
        const func = N.funs[i];
        flags[NF] = func(acc, flags);
    }
};

const Z = struct {
    const funs = [_]*const fn (u16, []u16) u16{ Z.NOP, Z.NOR, Z.RET0, Z.RET1 };

    fn NOP(_: u16, flags: []u16) u16 {
        return flags[ZF];
    }

    fn NOR(acc: u16, _: []u16) u16 {
        return @intFromBool((acc & EIGHT_BIT_CONVERSION) == 0);
    }

    fn RET0(_: u16, _: []u16) u16 {
        return 0;
    }

    fn RET1(_: u16, _: []u16) u16 {
        return 1;
    }

    pub fn calc(i: usize, acc: u16, flags: []u16) void {
        const func = Z.funs[i];
        flags[ZF] = func(acc, flags);
    }
};

pub const MC = struct {
    const funs = [_]*const fn (*u16, u32, []u16, []u16) void{
        MC.NOP,
        MC.NOP,
        MC.ADD_A_REG,
        MC.ADD_A_MEM,
        MC.SUB_A_REG,
        MC.SUB_A_MEM,
        MC.ADC_A_REG,
        MC.ADC_A_MEM,
        MC.SBC_A_REG,
        MC.LD_REG_D16,
    };

    fn paranoic_cleaning(a: *u16) void {
        a.* = a.* | EIGHT_BIT_CONVERSION;
    }

    fn add_overflow_bit(a: *u16) void {
        a.* = a.* | EIGHT_BIT_OVERFLOW;
    }

    fn trunc(a: *u16) void {
        a.* = a.* & EIGHT_BIT_CONVERSION;
    }

    fn NOP(_: *u16, _: u32, _: []u16, _: []u16) void {}

    fn ADD_A_REG(acc: *u16, reg: u32, regs: []u16, _: []u16) void {
        acc.* = (acc.*) + (regs[reg] & EIGHT_BIT_CONVERSION);
    }

    fn ADD_A_MEM(acc: *u16, reg: u32, regs: []u16, mem: []u16) void {
        std.debug.print("\nREG idx : {b} \n", .{reg});
        std.debug.print("\nREG idx : {d} \n", .{reg});
        std.debug.print("\nREG val : {d} \n", .{mem[regs[reg]]});
        acc.* = (acc.*) + (mem[regs[reg]] & EIGHT_BIT_CONVERSION);
    }

    fn SUB_A_REG(acc: *u16, reg: u32, regs: []u16, _: []u16) void {
        acc.* = acc.* - (regs[reg] & EIGHT_BIT_CONVERSION);
    }

    fn SUB_A_MEM(acc: *u16, reg: u32, regs: []u16, mem: []u16) void {
        acc.* = acc.* - (mem[regs[reg]] & EIGHT_BIT_CONVERSION);
    }

    fn ADC_A_REG(acc: *u16, reg: u32, regs: []u16, _: []u16) void {
        acc.* = (acc.*) + (regs[reg] & EIGHT_BIT_CONVERSION) + regs[CF];
    }

    fn ADC_A_MEM(acc: *u16, reg: u32, regs: []u16, mem: []u16) void {
        acc.* = (acc.*) + (mem[regs[reg]] & EIGHT_BIT_CONVERSION) + regs[CF];
    }

    fn SBC_A_REG(acc: *u16, reg: u32, regs: []u16, _: []u16) void {
        acc.* = acc.* - (regs[reg] & EIGHT_BIT_CONVERSION) - regs[CF];
    }

    fn LD_REG_D16(_: *u16, reg: u32, regs: []u16, _: []u16) void {
        const acc: u16 = regs[0];
        std.debug.print("\nAGG to set: {b} \n", .{acc});
        std.debug.print("\nREG to set: {b} \n", .{reg});
        std.debug.print("\nHB to set: {b} \n", .{((acc) & 0b1111_1111_0000_0000) >> 8});
        std.debug.print("\nLB to set: {b} \n", .{acc & 0b0000_0000_1111_1111});
        std.debug.print("\nHB REG idx: {b} \n", .{(reg & 0b1111_0000) >> 4});
        std.debug.print("\nLB REG idx: {b} \n", .{reg & 0b0000_1111});
        regs[(reg & 0b1111_0000) >> 4] = acc & 0b0000_0000_1111_1111;
        regs[reg & 0b0000_1111] = (acc & 0b1111_1111_0000_0000) >> 8;
    }

    pub fn calc(mc: u32, c_mc: u32, h_mc: u32, n_mc: u32, z_mc: u32, a: *u16, reg: u32, regs: []u16, memory: []u16) void {
        MC.add_overflow_bit(a);
        const mc_func = MC.funs[mc];

        const a_hc = a.*;
        const a_c = a.*;

        // calc result and raw HC
        mc_func(a, reg, regs, memory);

        // set regs
        C.calc(c_mc, a.*, a_c, regs);
        H.calc(h_mc, a.*, a_hc, regs);
        N.calc(n_mc, a.*, regs);
        Z.calc(z_mc, a.*, regs);

        // cleanup
        MC.trunc(a);
    }
};
