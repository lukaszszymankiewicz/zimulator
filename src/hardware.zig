const std = @import("std");

const t = @import("types.zig");

pub const SREG_SIZE: t.HardwareSize = 256;
pub const RAM_SIZE: t.HardwareSize = 256 * 256;
pub const PROG_START: t.HardwareSize = SREG_SIZE;
