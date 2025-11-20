const std = @import("std");

const hw = @import("hardware.zig");
const r = @import("reg.zig");
const t = @import("types.zig");

fn _rr(state: []t.DataType, reg: t.IndexType) u32 {
    const h: u32 = @intCast(state[reg]);
    const l: u32 = @intCast(state[reg + 1]);

    return (h << 8) + l;
}

pub fn NOP(_: []t.DataType, _: t.IndexType) void {}

pub fn ADD_R(state: []t.DataType, reg: t.IndexType) void {
    state[r.A] = state[r.A] +% state[reg];
}

pub fn SUB_R(state: []t.DataType, reg: t.IndexType) void {
    state[r.A] = state[r.A] -% state[reg];
}

pub fn CP(state: []t.DataType, reg: t.IndexType) void {
    state[r.ZF] = @intFromBool(state[r.A] -% state[reg] == 0);
}

pub fn INC_RR(state: []t.DataType, reg: t.IndexType) void {
    // good luck debugging this
    state[reg] +%= @intFromBool(state[reg + 1] +% 1 < state[reg + 1]);
    state[reg + 1] +%= 1;
}

pub fn DEC_RR(state: []t.DataType, reg: t.IndexType) void {
    // good luck debugging this
    state[reg] -%= @intFromBool(state[reg + 1] -% 1 > state[reg + 1]);
    state[reg + 1] -%= 1;
}

pub fn LD_IM(state: []t.DataType, reg: t.IndexType) void {
    const rr = _rr(state, r.PC);
    INC_RR(state, r.PC);

    state[reg] = state[hw.SREG_SIZE + hw.RAM_SIZE + rr];
}

pub fn LD_R_MM(state: []t.DataType, reg: t.IndexType) void {
    const rr = _rr(state, r.TM);
    state[reg] = state[hw.SREG_SIZE + rr];
}

pub fn MV_R(state: []t.DataType, reg: t.IndexType) void {
    state[reg] = state[r.TM];
}

pub fn LD_MM(state: []t.DataType, reg: t.IndexType) void {
    const rr = _rr(state, reg);
    state[r.TM] = state[hw.SREG_SIZE + rr];
}

pub fn LD_R(state: []t.DataType, reg: t.IndexType) void {
    state[r.TM] = state[reg];
}

pub fn MV_MM(state: []t.DataType, reg: t.IndexType) void {
    const rr = _rr(state, reg);
    state[hw.SREG_SIZE + rr] = state[r.A];
}

pub fn JP_Z(state: []t.DataType, reg: t.IndexType) void {
    state[r.PCH] = (state[reg] * state[r.ZF]) + (state[r.PCH] * ((~state[r.ZF]) & 0b0000_0001));
    state[r.PCL] = (state[reg + 1] * state[r.ZF]) + (state[r.PCL] * ((~state[r.ZF]) & 0b0000_0001));
}
