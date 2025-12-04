const std = @import("std");

const t = @import("types.zig");

pub const A: t.IndexType = 0b0000_0001;
pub const B: t.IndexType = 0b0000_0010;
pub const C: t.IndexType = B + 1;
pub const BC: t.IndexType = B;
pub const D: t.IndexType = 0b0000_0100;
pub const E: t.IndexType = D + 1;
pub const DE: t.IndexType = D;
pub const H: t.IndexType = 0b0000_0110;
pub const L: t.IndexType = H + 1;
pub const HL: t.IndexType = H;
pub const CF: t.IndexType = 0b0000_1000;
pub const HF: t.IndexType = 0b0000_1001;
pub const NF: t.IndexType = 0b0000_1010;
pub const ZF: t.IndexType = 0b0000_1011;
pub const S: t.IndexType = 0b0000_1100;
pub const P: t.IndexType = 0b0000_1101;
pub const SP: t.IndexType = S;
pub const PCH: t.IndexType = 0b1000_0000;
pub const PCL: t.IndexType = 0b1000_0001;
pub const PC: t.IndexType = PCH;
pub const ONS: t.IndexType = 0b0110_1111;
pub const TMH: t.IndexType = 0b1111_1110;
pub const TML: t.IndexType = 0b1111_1111;
pub const TM: t.IndexType = TMH;
