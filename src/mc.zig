const std = @import("std");

const EIGHT_BIT_OVERFLOW = 0b1_0000_0000;
const FOURTH_BIT_OVERFLOW = 0b0001_0000;
const FOURTH_BIT_CONVERSION = 0b0000_1111;
const SAFE_FOURTH_BIT_CONVERSION = 0b1_0000_1111;
const EIGHT_BIT_CONVERSION = 0b0000_0000_1111_1111;

const CF: u32 = 0;
const HF: u32 = 1;
const NF: u32 = 2;
const ZF: u32 = 3;

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

const H = struct {
    const funs = [_]*const fn (u16, []u16) u16{ H.NOP, H.NOR, H.RET0, H.RET1 };

    fn NOP(_: u16, flags: []u16) u16 {
        return flags[HF];
    }

    fn NOR(raw_hc: u16, _: []u16) u16 {
        return @intFromBool((raw_hc & FOURTH_BIT_OVERFLOW) == FOURTH_BIT_OVERFLOW);
    }

    fn RET0(_: u16, _: []u16) u16 {
        return 0;
    }

    fn RET1(_: u16, _: []u16) u16 {
        return 1;
    }

    pub fn calc(i: usize, raw_hc: u16, flags: []u16) void {
        const func = H.funs[i];
        flags[HF] = func(raw_hc, flags);
    }
};

pub const MC = struct {
    const funs = [_]*const fn (*u16, u16, []u16, []u16) void{
        MC.NOP,
        MC.NOP,
        MC.ADD_A_REG,
        MC.ADD_A_MEM,
        MC.SUB_A_REG,
        MC.SUB_A_MEM,
        MC.ADC_A_REG,
        MC.ADC_A_MEM,
        MC.SBC_A_REG,
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

    fn NOP(_: *u16, _: u16, _: []u16, _: []u16) void {}

    fn ADD_A_REG(acc: *u16, reg: u16, _: []u16, _: []u16) void {
        acc.* = (acc.*) + reg;
    }

    fn ADD_A_MEM(acc: *u16, reg: u16, _: []u16, mem: []u16) void {
        acc.* = (acc.*) + mem[reg];
    }

    fn SUB_A_REG(acc: *u16, reg: u16, _: []u16, _: []u16) void {
        acc.* = acc.* - reg;
    }

    fn SUB_A_MEM(acc: *u16, reg: u16, _: []u16, mem: []u16) void {
        acc.* = acc.* - mem[reg];
    }

    fn ADC_A_REG(acc: *u16, reg: u16, flags: []u16, _: []u16) void {
        acc.* = (acc.*) + flags[0] + reg;
    }

    fn ADC_A_MEM(acc: *u16, reg: u16, flags: []u16, mem: []u16) void {
        acc.* = (acc.*) + flags[0] + mem[reg];
    }

    fn SBC_A_REG(acc: *u16, reg: u16, flags: []u16, _: []u16) void {
        acc.* = acc.* - reg - flags[0];
    }

    pub fn calc(mc: u32, c_mc: u32, h_mc: u32, n_mc: u32, z_mc: u32, a: *u16, reg: u16, flags: []u16, memory: []u16) void {
        MC.add_overflow_bit(a);
        const mc_func = MC.funs[mc];

        // calc raw_ HC
        var a_hc = (a.*) & SAFE_FOURTH_BIT_CONVERSION;
        const a_c = a.*;
        const reg_hc = reg & FOURTH_BIT_CONVERSION;

        // calc result and raw HC
        mc_func(a, reg, flags, memory);
        mc_func(&a_hc, reg_hc, flags, memory);

        // set flags
        C.calc(c_mc, a.*, a_c, flags);
        H.calc(h_mc, a_hc, flags);
        N.calc(n_mc, a.*, flags);
        Z.calc(z_mc, a.*, flags);

        // cleanup
        MC.trunc(a);
    }
};
