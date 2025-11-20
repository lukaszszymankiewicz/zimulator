const std = @import("std");

const t = @import("types.zig");

const FOURTH_BIT_OVERFLOW = 0b0001_0000;

pub fn FS_NOP(_: []i32, old: t.DataType) t.DataType {
    return old;
}

pub fn FS_0(_: []i32, _: t.DataType) t.DataType {
    return 0;
}

pub fn FS_1(_: []i32, _: t.DataType) t.DataType {
    return 1;
}

pub fn FS_CX(accs: []i32, _: t.DataType) t.DataType {
    var hc: t.DataType = 0;

    for (1..accs.len) |i| {
        hc |= @intFromBool(accs[i] < accs[i - 1]);
    }

    return @intCast(hc);
}

pub fn FS_CXNEG(accs: []i32, _: t.DataType) t.DataType {
    return @intFromBool(accs[0] < accs[accs.len - 1]);
}

pub fn FS_HX(accs: []i32, _: t.DataType) t.DataType {
    var hc: t.DataType = 0;

    for (1..accs.len) |i| {
        hc |= @intFromBool((accs[i] & FOURTH_BIT_OVERFLOW) != (accs[i - 1] & FOURTH_BIT_OVERFLOW));
    }

    return @intCast(hc);
}

pub fn FS_ZX(accs: []i32, _: t.DataType) t.DataType {
    return @intFromBool(accs[accs.len - 1] == 0);
}
