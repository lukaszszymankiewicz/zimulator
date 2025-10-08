const std = @import("std");
const mc = @import("mc.zig");
const cpu = @import("cpu.zig");

test "Check if `clean_reg` works" {
    var c = cpu.CPU.init();

    c.clean_reg();

    try std.testing.expect(c.get_reg_val(cpu.A) == 0);
    try std.testing.expect(c.get_reg_val(cpu.B) == 0);
    try std.testing.expect(c.get_reg_val(cpu.C) == 0);
    try std.testing.expect(c.get_reg_val(cpu.D) == 0);
    try std.testing.expect(c.get_reg_val(cpu.E) == 0);
    try std.testing.expect(c.get_reg_val(cpu.H) == 0);
    try std.testing.expect(c.get_reg_val(cpu.L) == 0);
    try std.testing.expect(c.get_reg_val(cpu.BC) == 0);
    try std.testing.expect(c.get_reg_val(cpu.DE) == 0);
    try std.testing.expect(c.get_reg_val(cpu.HL) == 0);
}

test "XXX_A_REG family" {
    // PREP
    const INS: u32 = 0;
    const EXP_REG: u32 = 12;
    const EXP_VAL: u32 = 13;
    const EXP_C: u32 = 14;
    const EXP_H: u32 = 15;
    const EXP_N: u32 = 16;
    const EXP_Z: u32 = 17;

    const test_cases = [_][18]u32{
        // NOP
        //      INS      A            B            C  D  E, H, L, C, H, N, Z, E_REG, E_V,     C, H  N  Z
        [_]u32{ cpu.NOP, 0b1111_1111, 0b0000_0001, 0, 0, 0, 0, 0, 1, 1, 1, 1, cpu.A, 0b1111_1111, 1, 1, 1, 1 },
        [_]u32{ cpu.NOP, 0b1111_1111, 0b0000_0001, 0, 0, 0, 0, 0, 1, 0, 1, 0, cpu.B, 0b0000_0001, 1, 0, 1, 0 },
        [_]u32{ cpu.NOP, 0b0111_1110, 0b0000_0001, 0, 0, 0, 0, 0, 0, 1, 0, 1, cpu.A, 0b0111_1110, 0, 1, 0, 1 },
        // ADD
        [_]u32{ cpu.ADD_A_B, 0b1111_1111, 0b0000_0001, 0, 0, 0, 0, 0, 0, 0, 0, 0, cpu.A, 0b0000_0000, 1, 1, 0, 1 },
        [_]u32{ cpu.ADD_A_B, 0b1111_1111, 0b0000_1001, 0, 0, 0, 0, 0, 0, 0, 0, 0, cpu.A, 0b0000_1000, 1, 1, 0, 0 },
        [_]u32{ cpu.ADD_A_C, 0b0000_0000, 0, 0b0000_0000, 0, 0, 0, 0, 0, 0, 0, 0, cpu.A, 0b0000_0000, 0, 0, 0, 1 },
        [_]u32{ cpu.ADD_A_D, 0b0000_0001, 0, 0, 0b0000_0010, 0, 0, 0, 0, 0, 0, 0, cpu.A, 0b0000_0011, 0, 0, 0, 0 },
        [_]u32{ cpu.ADD_A_E, 0b0000_1001, 0, 0, 0, 0b0000_0010, 0, 0, 0, 0, 0, 0, cpu.A, 0b0000_1011, 0, 0, 0, 0 },
        [_]u32{ cpu.ADD_A_H, 0b0000_0001, 0, 0, 0, 0, 0b0000_1111, 0, 0, 0, 0, 0, cpu.A, 0b0001_0000, 0, 1, 0, 0 },
        [_]u32{ cpu.ADD_A_L, 0b0000_0001, 0, 0, 0, 0, 0, 0b0000_1111, 0, 0, 0, 0, cpu.A, 0b0001_0000, 0, 1, 0, 0 },
        [_]u32{ cpu.ADD_A_B, 0b0100_0001, 0b0010_1111, 0, 0, 0, 0, 0, 0, 0, 0, 0, cpu.A, 0b0111_0000, 0, 1, 0, 0 },
        [_]u32{ cpu.ADD_A_C, 0b1111_0001, 0, 0b0001_1111, 0, 0, 0, 0, 0, 0, 0, 0, cpu.A, 0b0001_0000, 1, 1, 0, 0 },
        [_]u32{ cpu.ADD_A_D, 0b1111_1111, 0, 0, 0b1111_1111, 0, 0, 0, 0, 0, 0, 0, cpu.A, 0b1111_1110, 1, 1, 0, 0 },
        [_]u32{ cpu.ADD_A_A, 0b0000_0001, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, cpu.A, 0b0000_0010, 0, 0, 0, 0 },
        [_]u32{ cpu.ADD_A_A, 0b0000_0011, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, cpu.A, 0b0000_0110, 0, 0, 0, 0 },
        [_]u32{ cpu.ADD_A_A, 0b0001_0101, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, cpu.A, 0b0010_1010, 0, 0, 0, 0 },
        // SUB
        [_]u32{ cpu.SUB_B, 0b0001_0101, 0b0000_0001, 0, 0, 0, 0, 0, 0, 0, 0, 0, cpu.A, 0b0001_0100, 0, 0, 1, 0 },
        [_]u32{ cpu.SUB_B, 0b0000_0111, 0b0000_1111, 0, 0, 0, 0, 0, 0, 0, 0, 0, cpu.A, 0b1111_1000, 1, 1, 1, 0 },
        [_]u32{ cpu.SUB_B, 0b0000_0000, 0b0000_0000, 0, 0, 0, 0, 0, 0, 0, 0, 0, cpu.A, 0b0000_0000, 0, 0, 1, 1 },
        [_]u32{ cpu.SUB_C, 0b0001_0101, 0, 0b0001_0101, 0, 0, 0, 0, 0, 0, 0, 0, cpu.A, 0b0000_0000, 0, 0, 1, 1 },
        [_]u32{ cpu.SUB_D, 0b0111_1111, 0, 0, 0b0101_0101, 0, 0, 0, 0, 0, 0, 0, cpu.A, 0b0010_1010, 0, 0, 1, 0 },
        [_]u32{ cpu.SUB_E, 0b0111_1111, 0, 0, 0, 0b0101_0101, 0, 0, 0, 0, 0, 0, cpu.A, 0b0010_1010, 0, 0, 1, 0 },
        [_]u32{ cpu.SUB_H, 0b0111_1111, 0, 0, 0, 0, 0b0101_0101, 0, 0, 0, 0, 0, cpu.A, 0b0010_1010, 0, 0, 1, 0 },
        [_]u32{ cpu.SUB_L, 0b0000_0000, 0, 0, 0, 0, 0, 0b0000_0001, 0, 0, 0, 0, cpu.A, 0b1111_1111, 1, 1, 1, 0 },
        [_]u32{ cpu.SUB_A, 0b0000_0000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, cpu.A, 0b0000_0000, 0, 0, 1, 1 },
        [_]u32{ cpu.SUB_A, 0b0000_0001, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, cpu.A, 0b0000_0000, 0, 0, 1, 1 },
        [_]u32{ cpu.SUB_A, 0b0000_1111, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, cpu.A, 0b0000_0000, 0, 0, 1, 1 },
        [_]u32{ cpu.SUB_A, 0b1000_1000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, cpu.A, 0b0000_0000, 0, 0, 1, 1 },
        [_]u32{ cpu.SUB_A, 0b1111_1111, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, cpu.A, 0b0000_0000, 0, 0, 1, 1 },
        // ADC
        [_]u32{ cpu.ADC_A_B, 0b1111_1111, 0b0000_0001, 0, 0, 0, 0, 0, 1, 0, 0, 0, cpu.A, 0b0000_0001, 1, 1, 0, 0 },
        [_]u32{ cpu.ADC_A_C, 0b0000_0000, 0, 0b0000_0000, 0, 0, 0, 0, 0, 0, 0, 0, cpu.A, 0b0000_0000, 0, 0, 0, 1 },
        [_]u32{ cpu.ADC_A_D, 0b0000_0001, 0, 0, 0b0000_0010, 0, 0, 0, 1, 0, 0, 0, cpu.A, 0b0000_0100, 0, 0, 0, 0 },
        [_]u32{ cpu.ADC_A_E, 0b0000_1001, 0, 0, 0, 0b0000_0010, 0, 0, 0, 0, 0, 0, cpu.A, 0b0000_1011, 0, 0, 0, 0 },
        [_]u32{ cpu.ADC_A_H, 0b0000_0001, 0, 0, 0, 0, 0b0000_1111, 0, 1, 0, 0, 0, cpu.A, 0b0001_0001, 0, 1, 0, 0 },
        [_]u32{ cpu.ADC_A_L, 0b0000_0001, 0, 0, 0, 0, 0, 0b0000_1111, 0, 0, 0, 0, cpu.A, 0b0001_0000, 0, 1, 0, 0 },
        [_]u32{ cpu.ADC_A_B, 0b0100_0001, 0b0010_1111, 0, 0, 0, 0, 0, 1, 0, 0, 0, cpu.A, 0b0111_0001, 0, 1, 0, 0 },
        [_]u32{ cpu.ADC_A_C, 0b1111_0001, 0, 0b0001_1111, 0, 0, 0, 0, 0, 0, 0, 0, cpu.A, 0b0001_0000, 1, 1, 0, 0 },
        [_]u32{ cpu.ADC_A_D, 0b1111_1111, 0, 0, 0b1111_1111, 0, 0, 0, 1, 0, 0, 0, cpu.A, 0b1111_1111, 1, 1, 0, 0 },
        [_]u32{ cpu.ADC_A_A, 0b0000_0001, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, cpu.A, 0b0000_0010, 0, 0, 0, 0 },
        [_]u32{ cpu.ADC_A_A, 0b0000_0011, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, cpu.A, 0b0000_0111, 0, 0, 0, 0 },
        [_]u32{ cpu.ADC_A_A, 0b0001_0101, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, cpu.A, 0b0010_1010, 0, 0, 0, 0 },
    };

    std.debug.print("\nXXX_A_REG family test \n", .{});

    // run test cases
    for (test_cases, 0..) |case, idx| {
        // PREP
        var c = cpu.CPU.init();

        c.clean_reg();

        // GIVEN
        for (1..12) |i| {
            const val: u16 = @intCast(case[i]);
            c.set_reg_val(@intCast(i), val);
        }

        // WHEN
        const ins_idx = case[INS];
        std.debug.print("case: {d}, op 0x{X} ", .{ idx, case[cpu.OP_CODE] });
        c.run_ins(.{ ins_idx, 0, 0 });

        // THEN
        try std.testing.expect(c.get_reg_val(case[EXP_REG]) == case[EXP_VAL]);
        try std.testing.expect(c.get_reg_val(cpu.CF) == case[EXP_C]);
        try std.testing.expect(c.get_reg_val(cpu.HF) == case[EXP_H]);
        try std.testing.expect(c.get_reg_val(cpu.NF) == case[EXP_N]);
        try std.testing.expect(c.get_reg_val(cpu.ZF) == case[EXP_Z]);

        std.debug.print("PASSED\n", .{});
    }
}

test "XXX_A_HL family" {
    // PREP
    const INS: u32 = 0;
    const MEM_AD: u32 = 12;
    const MEM_VAL: u32 = 13;
    const EXP_REG: u32 = 14;
    const EXP_VAL: u32 = 15;
    const EXP_C: u32 = 16;
    const EXP_H: u32 = 17;
    const EXP_N: u32 = 18;
    const EXP_Z: u32 = 19;

    const test_cases = [_][20]u32{
        // ADD
        //      INS       A  B  C  D  E, H, L, C, H, N, Z, MEM, VAL,E, V,   C, H  N  Z
        [_]u32{ cpu.ADD_A_HL, 1, 0, 0, 0, 0, 1, 9, 0, 1, 0, 0, 265, 99, cpu.A, 100, 0, 0, 0, 0 },
        [_]u32{ cpu.ADD_A_HL, 255, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 512, 1, cpu.A, 0, 1, 0, 0, 1 },
        [_]u32{ cpu.ADD_A_HL, 15, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 256, 1, cpu.A, 16, 0, 0, 0, 0 },
        [_]u32{ cpu.ADD_A_HL, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 768, 0, cpu.A, 0, 0, 0, 0, 1 },
        [_]u32{ cpu.ADD_A_HL, 50, 0, 0, 0, 0, 1, 100, 0, 0, 0, 0, 356, 25, cpu.A, 75, 0, 0, 0, 0 },
        [_]u32{ cpu.ADD_A_HL, 100, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 1024, 255, cpu.A, 99, 1, 0, 0, 0 },
        [_]u32{ cpu.ADD_A_HL, 255, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 1280, 255, cpu.A, 254, 1, 0, 0, 0 },
        [_]u32{ cpu.ADD_A_HL, 240, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 1536, 16, cpu.A, 0, 1, 0, 0, 1 },
        [_]u32{ cpu.ADD_A_HL, 8, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 1792, 8, cpu.A, 16, 0, 0, 0, 0 },
        [_]u32{ cpu.ADD_A_HL, 10, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 2048, 5, cpu.A, 15, 0, 0, 0, 0 },
        // ADC
        [_]u32{ cpu.ADC_A_HL, 1, 0, 0, 0, 0, 1, 9, 1, 1, 0, 0, 265, 99, cpu.A, 101, 0, 0, 0, 0 },
        [_]u32{ cpu.ADC_A_HL, 255, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 512, 1, cpu.A, 1, 1, 1, 0, 0 },
        [_]u32{ cpu.ADC_A_HL, 15, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 256, 1, cpu.A, 17, 0, 1, 0, 0 },
        [_]u32{ cpu.ADC_A_HL, 0, 0, 0, 0, 0, 3, 0, 1, 0, 0, 0, 768, 0, cpu.A, 1, 0, 0, 0, 0 },
        [_]u32{ cpu.ADC_A_HL, 50, 0, 0, 0, 0, 1, 100, 1, 0, 0, 0, 356, 25, cpu.A, 76, 0, 0, 0, 0 },
        [_]u32{ cpu.ADC_A_HL, 100, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 1024, 255, cpu.A, 99, 1, 0, 0, 0 },
        [_]u32{ cpu.ADC_A_HL, 255, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 1280, 255, cpu.A, 254, 1, 0, 0, 0 },
        [_]u32{ cpu.ADC_A_HL, 240, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 1536, 16, cpu.A, 0, 1, 0, 0, 1 },
        [_]u32{ cpu.ADC_A_HL, 8, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 1792, 8, cpu.A, 16, 0, 0, 0, 0 },
        [_]u32{ cpu.ADC_A_HL, 10, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 2048, 5, cpu.A, 15, 0, 0, 0, 0 },
        // SUB
        [_]u32{ cpu.SUB_HL, 21, 0, 0, 0, 0, 1, 9, 0, 0, 0, 0, 265, 1, cpu.A, 20, 0, 0, 1, 0 },
        [_]u32{ cpu.SUB_HL, 21, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 512, 21, cpu.A, 0, 0, 0, 1, 1 },
        [_]u32{ cpu.SUB_HL, 127, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 768, 85, cpu.A, 42, 0, 0, 1, 0 },
        [_]u32{ cpu.SUB_HL, 127, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 256, 85, cpu.A, 42, 0, 0, 1, 0 },
        [_]u32{ cpu.SUB_HL, 127, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 1024, 85, cpu.A, 42, 0, 0, 1, 0 },
        [_]u32{ cpu.SUB_HL, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 1280, 1, cpu.A, 255, 1, 0, 1, 0 },
        [_]u32{ cpu.SUB_HL, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 1536, 0, cpu.A, 0, 0, 0, 1, 1 },
        [_]u32{ cpu.SUB_HL, 1, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 1792, 0, cpu.A, 1, 0, 0, 1, 0 },
        [_]u32{ cpu.SUB_HL, 15, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 2048, 0, cpu.A, 15, 0, 0, 1, 0 },
        [_]u32{ cpu.SUB_HL, 136, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 2304, 136, cpu.A, 0, 0, 0, 1, 1 },
        [_]u32{ cpu.SUB_HL, 255, 0, 0, 0, 0, 10, 0, 0, 0, 0, 0, 2560, 255, cpu.A, 0, 0, 0, 1, 1 },
    };

    std.debug.print("\nXXX_A_HL family test \n", .{});

    // run test cases
    for (test_cases, 0..) |case, idx| {
        // PREP
        var c = cpu.CPU.init();

        c.clean_reg();

        // GIVEN
        for (1..12) |i| {
            const val: u16 = @intCast(case[i]);
            c.set_reg_val(@intCast(i), val);
        }

        const add = case[MEM_AD];
        const mem_val: u16 = @intCast(case[MEM_VAL]);
        c.set_reg_val(add + cpu.SREG_SIZE, mem_val);

        // WHEN
        const ins_idx = case[INS];
        std.debug.print("case: {d}, op 0x{X} ", .{ idx, case[cpu.OP_CODE] });
        c.run_ins(.{ ins_idx, 0, 0 });

        // THEN
        try std.testing.expect(c.get_reg_val(case[EXP_REG]) == case[EXP_VAL]);
        try std.testing.expect(c.get_reg_val(cpu.CF) == case[EXP_C]);
        try std.testing.expect(c.get_reg_val(cpu.HF) == case[EXP_H]);
        try std.testing.expect(c.get_reg_val(cpu.NF) == case[EXP_N]);
        try std.testing.expect(c.get_reg_val(cpu.ZF) == case[EXP_Z]);

        std.debug.print("PASSED\n", .{});
    }
}
