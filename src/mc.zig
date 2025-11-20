const std = @import("std");

const hw = @import("hardware.zig");
const r = @import("reg.zig");
const t = @import("types.zig");

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
    const h: u32 = @intCast(state[r.PCH]);
    const l: u32 = @intCast(state[r.PCL]);
    INC_RR(state, r.PC);
    state[reg] = state[hw.SREG_SIZE + hw.RAM_SIZE + (h << 8) + l];
}

pub fn LD_R_MM(state: []t.DataType, reg: t.IndexType) void {
    const h: u32 = @intCast(state[r.TMH]);
    const l: u32 = @intCast(state[r.TML]);
    state[reg] = state[hw.SREG_SIZE + (h << 8) + l];
}

pub fn LD_MM(state: []t.DataType, reg: t.IndexType) void {
    const h: u32 = @intCast(state[reg]);
    const l: u32 = @intCast(state[reg + 1]);
    state[r.TM] = state[hw.SREG_SIZE + (h << 8) + l];
}

pub fn LD_R(state: []t.DataType, reg: t.IndexType) void {
    state[r.TM] = state[reg];
}

pub fn MV_R(state: []t.DataType, reg: t.IndexType) void {
    state[reg] = state[r.TM];
}

pub fn MV_MM(state: []t.DataType, reg: t.IndexType) void {
    const h: u32 = @intCast(state[reg]);
    const l: u32 = @intCast(state[reg + 1]);
    state[(h << 8) + l + 256] = state[r.A];
}
