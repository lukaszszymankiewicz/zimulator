const std = @import("std");

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
pub const ZRS: IndexType = 0b0110_1110;
pub const ONS: IndexType = 0b0110_1111;
pub const MEM: IndexType = 0b0111_1110;
pub const PRG: IndexType = 0b0111_1111;
pub const ADH: IndexType = 0b0011_1110;
pub const ADL: IndexType = 0b0011_1111;
pub const TMH: IndexType = 0b1111_1110;
pub const TML: IndexType = 0b1111_1111;
pub const TM: IndexType = TMH;

// TODO: move FlagSetters to other module
pub fn FS_NOP(_: []i32, old: DataType) DataType {
    return old;
}

pub fn FS_0(_: []i32, _: DataType) DataType {
    return 0;
}

pub fn FS_1(_: []i32, _: DataType) DataType {
    return 1;
}

pub fn FS_CX(accs: []i32, _: DataType) DataType {
    var hc: DataType = 0;

    for (1..accs.len) |i| {
        hc |= @intFromBool(accs[i] < accs[i - 1]);
    }

    return @intCast(hc);
}

pub fn FS_CXNEG(accs: []i32, _: DataType) DataType {
    return @intFromBool(accs[0] < accs[accs.len - 1]);
}

pub fn FS_HX(accs: []i32, _: DataType) DataType {
    var hc: DataType = 0;

    for (1..accs.len) |i| {
        hc |= @intFromBool((accs[i] & FOURTH_BIT_OVERFLOW) != (accs[i - 1] & FOURTH_BIT_OVERFLOW));
    }

    return @intCast(hc);
}

pub fn FS_ZX(accs: []i32, _: DataType) DataType {
    return @intFromBool(accs[accs.len - 1] == 0);
}

pub fn NOP(_: []DataType, _: IndexType) void {}

pub fn ADD_R(state: []DataType, reg: IndexType) void {
    state[A] = state[A] +% state[reg];
}

pub fn SUB_R(state: []DataType, reg: IndexType) void {
    state[A] = state[A] -% state[reg];
}

pub fn CP(state: []DataType, reg: IndexType) void {
    state[ZF] = @intFromBool(state[A] -% state[reg] == 0);
}

pub fn INC_RR(state: []DataType, reg: DataType) void {
    // good luck debugging this
    state[reg] +%= @intFromBool(state[reg + 1] +% 1 < state[reg + 1]);
    state[reg + 1] +%= 1;
}

pub fn DEC_RR(state: []DataType, reg: DataType) void {
    // good luck debugging this
    state[reg] -%= @intFromBool(state[reg + 1] -% 1 > state[reg + 1]);
    state[reg + 1] -%= 1;
}

pub fn LD_IM(state: []DataType, reg: IndexType) void {
    const h: u32 = @intCast(state[PCH]);
    const l: u32 = @intCast(state[PCL]);
    INC_RR(state, PC);
    state[reg] = state[SREG_SIZE + RAM_SIZE + (h << 8) + l];
}

pub fn LD_R_MM(state: []DataType, reg: IndexType) void {
    const h: u32 = @intCast(state[TMH]);
    const l: u32 = @intCast(state[TML]);
    state[reg] = state[SREG_SIZE + (h << 8) + l];
}

pub fn LD_MM(state: []DataType, reg: IndexType) void {
    const h: u32 = @intCast(state[reg]);
    const l: u32 = @intCast(state[reg + 1]);
    state[TM] = state[SREG_SIZE + (h << 8) + l];
}

pub fn LD_R(state: []DataType, reg: IndexType) void {
    state[TM] = state[reg];
}

pub fn MV_R(state: []DataType, reg: IndexType) void {
    state[reg] = state[TM];
}

pub fn MV_MM(state: []DataType, reg: IndexType) void {
    const h: u32 = @intCast(state[reg]);
    const l: u32 = @intCast(state[reg + 1]);
    state[(h << 8) + l + 256] = state[A];
}
