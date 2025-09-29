const std = @import("std");
const mc = @import("mc.zig");

// HARDWARE
const RAM_SIZE: u32 = 256 * 256;
const RAM_BEG: u32 = 128;
const SREG_SIZE: u32 = 128;

// REGISTER INDEXES
const DUMMY: u32 = 0b0000_0000;
const A: u32 = 0b0000_0001;
const B: u32 = 0b0000_0010;
const C: u32 = 0b0000_0011;
const D: u32 = 0b0000_0100;
const E: u32 = 0b0000_0101;
const H: u32 = 0b0000_0110;
const L: u32 = 0b0000_0111;
const CF: u32 = 0b0000_1000;
const HF: u32 = 0b0000_1001;
const NF: u32 = 0b0000_1010;
const ZF: u32 = 0b0000_1011;
const BC: u32 = 0b0001_0000;
const DE: u32 = 0b0010_0000;
const HL: u32 = 0b0011_0000;
const SP: u32 = 0b0100_0000;

// INSTRUCTIONS
const NOP: u32 = 0b0000_0000;
const LD_BC_D16: u32 = 0b0000_0001;
// ... TODO
const ADD_A_B: u32 = 0b1000_0000;
const ADD_A_C: u32 = 0b1000_0001;
const ADD_A_D: u32 = 0b1000_0010;
const ADD_A_E: u32 = 0b1000_0011;
const ADD_A_H: u32 = 0b1000_0100;
const ADD_A_L: u32 = 0b1000_0101;
const ADD_A_HL: u32 = 0b1000_0110;
const ADD_A_A: u32 = 0b1000_0111;

const ADC_A_B: u32 = 0b1000_1000;
const ADC_A_C: u32 = 0b1000_1001;
const ADC_A_D: u32 = 0b1000_1010;
const ADC_A_E: u32 = 0b1000_1011;
const ADC_A_H: u32 = 0b1000_1100;
const ADC_A_L: u32 = 0b1000_1101;
const ADC_A_HL: u32 = 0b1000_1110;
const ADC_A_A: u32 = 0b1000_1111;

const SUB_B: u32 = 0b1001_0000;
const SUB_C: u32 = 0b1001_0001;
const SUB_D: u32 = 0b1001_0010;
const SUB_E: u32 = 0b1001_0011;
const SUB_H: u32 = 0b1001_0100;
const SUB_L: u32 = 0b1001_0101;
const SUB_HL: u32 = 0b1001_0110;
const SUB_A: u32 = 0b1001_0111;

// GBA INSTRUCTION TABLE
const OP_CODE = 0;
const OP_SIZE = 1;
const OP_MC = 2;
const OP_VAL_A = 3;
const OP_VAL_B = 4;
const OP_FMC_C = 5;
const OP_FMC_H = 6;
const OP_FMC_N = 7;
const OP_FMC_Z = 8;

const NA = 0;
const MEM_TYPE = SREG_SIZE;

const instructions = [_][9]u32{
    [_]u32{ NOP, 1, mc._NOP, NA, NA, mc._NOP, mc._NOP, mc._NOP, mc._NOP },
    [_]u32{ 1, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 2, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 3, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 4, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 5, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 6, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 7, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 8, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 9, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 10, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 11, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 12, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 13, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 14, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 15, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 16, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 17, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 18, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 19, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 20, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 21, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 22, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 23, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 24, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 25, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 26, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 27, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 28, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 29, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 30, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 31, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 32, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 33, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 34, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 35, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 36, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 37, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 38, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 39, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 40, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 41, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 42, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 43, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 44, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 45, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 46, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 47, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 48, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 49, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 50, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 51, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 52, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 53, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 54, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 55, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 56, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 57, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 58, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 59, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 60, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 61, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 62, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 63, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 64, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 65, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 66, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 67, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 68, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 69, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 70, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 71, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 72, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 73, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 74, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 75, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 76, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 77, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 78, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 79, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 80, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 81, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 82, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 83, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 84, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 85, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 86, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 87, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 88, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 89, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 90, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 91, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 92, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 93, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 94, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 95, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 96, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 97, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 98, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 99, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 100, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 101, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 102, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 103, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 104, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 105, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 106, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 107, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 108, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 109, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 110, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 111, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 112, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 113, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 114, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 115, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 116, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 117, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 118, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 119, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 120, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 121, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 122, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 123, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 124, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 125, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 126, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u32{ 127, 1, 0, 0, 0, 0, 0, 0, 0 },

    [_]u32{ ADD_A_B, 1, mc._ADD_A_REG, A, B, mc._NOR, mc._NOR, mc._RET0, mc._NOR },
    [_]u32{ ADD_A_C, 1, mc._ADD_A_REG, A, C, mc._NOR, mc._NOR, mc._RET0, mc._NOR },
    [_]u32{ ADD_A_D, 1, mc._ADD_A_REG, A, D, mc._NOR, mc._NOR, mc._RET0, mc._NOR },
    [_]u32{ ADD_A_E, 1, mc._ADD_A_REG, A, E, mc._NOR, mc._NOR, mc._RET0, mc._NOR },
    [_]u32{ ADD_A_H, 1, mc._ADD_A_REG, A, H, mc._NOR, mc._NOR, mc._RET0, mc._NOR },
    [_]u32{ ADD_A_L, 1, mc._ADD_A_REG, A, L, mc._NOR, mc._NOR, mc._RET0, mc._NOR },
    [_]u32{ ADD_A_HL, 1, mc._ADD_A_MEM, A, HL, mc._NOR, mc._NOR, mc._RET0, mc._NOR },
    [_]u32{ ADD_A_A, 1, mc._ADD_A_REG, A, A, mc._NOR, mc._NOR, mc._RET0, mc._NOR },
    // ADC
    [_]u32{ ADC_A_B, 1, mc._ADC_A_REG, A, B, mc._NOR, mc._NOR, mc._RET0, mc._NOR },
    [_]u32{ ADC_A_C, 1, mc._ADC_A_REG, A, C, mc._NOR, mc._NOR, mc._RET0, mc._NOR },
    [_]u32{ ADC_A_D, 1, mc._ADC_A_REG, A, D, mc._NOR, mc._NOR, mc._RET0, mc._NOR },
    [_]u32{ ADC_A_E, 1, mc._ADC_A_REG, A, E, mc._NOR, mc._NOR, mc._RET0, mc._NOR },
    [_]u32{ ADC_A_H, 1, mc._ADC_A_REG, A, H, mc._NOR, mc._NOR, mc._RET0, mc._NOR },
    [_]u32{ ADC_A_L, 1, mc._ADC_A_REG, A, L, mc._NOR, mc._NOR, mc._RET0, mc._NOR },
    [_]u32{ ADC_A_HL, 1, mc._ADC_A_MEM, A, HL, mc._NOR, mc._NOR, mc._RET0, mc._NOR },
    [_]u32{ ADC_A_A, 1, mc._ADC_A_REG, A, A, mc._NOR, mc._NOR, mc._RET0, mc._NOR },
    // SUB
    [_]u32{ SUB_B, 1, mc._SUB_A_REG, A, B, mc._NOR, mc._NOR, mc._RET1, mc._NOR },
    [_]u32{ SUB_C, 1, mc._SUB_A_REG, A, C, mc._NOR, mc._NOR, mc._RET1, mc._NOR },
    [_]u32{ SUB_D, 1, mc._SUB_A_REG, A, D, mc._NOR, mc._NOR, mc._RET1, mc._NOR },
    [_]u32{ SUB_E, 1, mc._SUB_A_REG, A, E, mc._NOR, mc._NOR, mc._RET1, mc._NOR },
    [_]u32{ SUB_H, 1, mc._SUB_A_REG, A, H, mc._NOR, mc._NOR, mc._RET1, mc._NOR },
    [_]u32{ SUB_L, 1, mc._SUB_A_REG, A, L, mc._NOR, mc._NOR, mc._RET1, mc._NOR },
    [_]u32{ SUB_HL, 1, mc._SUB_A_MEM, A, HL, mc._NOR, mc._NOR, mc._RET1, mc._NOR },
    [_]u32{ SUB_A, 1, mc._SUB_A_REG, A, A, mc._NOR, mc._NOR, mc._RET1, mc._NOR },
};

const CPU = struct {
    REG: [SREG_SIZE + RAM_SIZE]u16,

    pub fn init() CPU {
        return CPU{ .REG = [_]u16{0} ** (SREG_SIZE + RAM_SIZE) };
    }

    pub fn clean_reg(self: *CPU) void {
        for (0..self.REG.len) |i| {
            self.REG[i] = 0b0000_0000;
        }
    }

    pub fn get_reg(self: *CPU, i: u32) *u16 {
        return &(self.REG[i]);
    }

    pub fn get_flags(self: *CPU) []u16 {
        return self.REG[CF .. ZF + 1];
    }

    pub fn get_memory(self: *CPU) []u16 {
        return self.REG[SREG_SIZE .. SREG_SIZE + RAM_SIZE];
    }

    pub fn get_reg_val(self: *CPU, i: u32) u16 {
        return self.REG[i];
    }

    pub fn set_reg_val(self: *CPU, i: u32, val: u16) void {
        self.REG[i] = val;
    }

    fn correct_double_regs(self: *CPU) void {
        self.set_reg_val(BC, self.REG[B] << 8 | self.REG[C]);
        self.set_reg_val(DE, self.REG[D] << 8 | self.REG[E]);
        self.set_reg_val(HL, self.REG[H] << 8 | self.REG[L]);
    }

    fn run_ins(self: *CPU, program: [3]u32) void {
        const i = program[0];
        // const lb = program[1];
        // const hb = program[2];

        self.correct_double_regs();

        const reg: u32 = instructions[i][OP_VAL_A];
        const val: u32 = instructions[i][OP_VAL_B];

        const a: *u16 = self.get_reg(reg);
        // const imm: u16 = lb + hb << 8;
        const b: u16 = self.get_reg_val(val);
        const flags: []u16 = self.get_flags();
        const memory: []u16 = self.get_memory();

        mc.MC.calc(instructions[i][OP_MC], instructions[i][OP_FMC_C], instructions[i][OP_FMC_H], instructions[i][OP_FMC_N], instructions[i][OP_FMC_Z], a, b, flags, memory);
    }
};

//////////////////
test "Check if `clean_reg` works" {
    var cpu = CPU.init();

    cpu.clean_reg();

    try std.testing.expect(cpu.get_reg_val(A) == 0);
    try std.testing.expect(cpu.get_reg_val(B) == 0);
    try std.testing.expect(cpu.get_reg_val(C) == 0);
    try std.testing.expect(cpu.get_reg_val(D) == 0);
    try std.testing.expect(cpu.get_reg_val(E) == 0);
    try std.testing.expect(cpu.get_reg_val(H) == 0);
    try std.testing.expect(cpu.get_reg_val(L) == 0);
    try std.testing.expect(cpu.get_reg_val(BC) == 0);
    try std.testing.expect(cpu.get_reg_val(DE) == 0);
    try std.testing.expect(cpu.get_reg_val(HL) == 0);
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
        //      INS  A            B            C  D  E, H, L, C, H, N, Z, E_REG, E_V,     C, H  N  Z
        [_]u32{ NOP, 0b1111_1111, 0b0000_0001, 0, 0, 0, 0, 0, 1, 1, 1, 1, A, 0b1111_1111, 1, 1, 1, 1 },
        [_]u32{ NOP, 0b1111_1111, 0b0000_0001, 0, 0, 0, 0, 0, 1, 0, 1, 0, B, 0b0000_0001, 1, 0, 1, 0 },
        [_]u32{ NOP, 0b0111_1110, 0b0000_0001, 0, 0, 0, 0, 0, 0, 1, 0, 1, A, 0b0111_1110, 0, 1, 0, 1 },
        // ADD
        [_]u32{ ADD_A_B, 0b1111_1111, 0b0000_0001, 0, 0, 0, 0, 0, 0, 0, 0, 0, A, 0b0000_0000, 1, 1, 0, 1 },
        [_]u32{ ADD_A_B, 0b1111_1111, 0b0000_1001, 0, 0, 0, 0, 0, 0, 0, 0, 0, A, 0b0000_1000, 1, 1, 0, 0 },
        [_]u32{ ADD_A_C, 0b0000_0000, 0, 0b0000_0000, 0, 0, 0, 0, 0, 0, 0, 0, A, 0b0000_0000, 0, 0, 0, 1 },
        [_]u32{ ADD_A_D, 0b0000_0001, 0, 0, 0b0000_0010, 0, 0, 0, 0, 0, 0, 0, A, 0b0000_0011, 0, 0, 0, 0 },
        [_]u32{ ADD_A_E, 0b0000_1001, 0, 0, 0, 0b0000_0010, 0, 0, 0, 0, 0, 0, A, 0b0000_1011, 0, 0, 0, 0 },
        [_]u32{ ADD_A_H, 0b0000_0001, 0, 0, 0, 0, 0b0000_1111, 0, 0, 0, 0, 0, A, 0b0001_0000, 0, 1, 0, 0 },
        [_]u32{ ADD_A_L, 0b0000_0001, 0, 0, 0, 0, 0, 0b0000_1111, 0, 0, 0, 0, A, 0b0001_0000, 0, 1, 0, 0 },
        [_]u32{ ADD_A_B, 0b0100_0001, 0b0010_1111, 0, 0, 0, 0, 0, 0, 0, 0, 0, A, 0b0111_0000, 0, 1, 0, 0 },
        [_]u32{ ADD_A_C, 0b1111_0001, 0, 0b0001_1111, 0, 0, 0, 0, 0, 0, 0, 0, A, 0b0001_0000, 1, 1, 0, 0 },
        [_]u32{ ADD_A_D, 0b1111_1111, 0, 0, 0b1111_1111, 0, 0, 0, 0, 0, 0, 0, A, 0b1111_1110, 1, 1, 0, 0 },
        [_]u32{ ADD_A_A, 0b0000_0001, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, A, 0b0000_0010, 0, 0, 0, 0 },
        [_]u32{ ADD_A_A, 0b0000_0011, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, A, 0b0000_0110, 0, 0, 0, 0 },
        [_]u32{ ADD_A_A, 0b0001_0101, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, A, 0b0010_1010, 0, 0, 0, 0 },
        // SUB
        [_]u32{ SUB_B, 0b0001_0101, 0b0000_0001, 0, 0, 0, 0, 0, 0, 0, 0, 0, A, 0b0001_0100, 0, 0, 1, 0 },
        [_]u32{ SUB_B, 0b0000_0111, 0b0000_1111, 0, 0, 0, 0, 0, 0, 0, 0, 0, A, 0b1111_1000, 1, 1, 1, 0 },
        [_]u32{ SUB_B, 0b0000_0000, 0b0000_0000, 0, 0, 0, 0, 0, 0, 0, 0, 0, A, 0b0000_0000, 0, 0, 1, 1 },
        [_]u32{ SUB_C, 0b0001_0101, 0, 0b0001_0101, 0, 0, 0, 0, 0, 0, 0, 0, A, 0b0000_0000, 0, 0, 1, 1 },
        [_]u32{ SUB_D, 0b0111_1111, 0, 0, 0b0101_0101, 0, 0, 0, 0, 0, 0, 0, A, 0b0010_1010, 0, 0, 1, 0 },
        [_]u32{ SUB_E, 0b0111_1111, 0, 0, 0, 0b0101_0101, 0, 0, 0, 0, 0, 0, A, 0b0010_1010, 0, 0, 1, 0 },
        [_]u32{ SUB_H, 0b0111_1111, 0, 0, 0, 0, 0b0101_0101, 0, 0, 0, 0, 0, A, 0b0010_1010, 0, 0, 1, 0 },
        [_]u32{ SUB_L, 0b0000_0000, 0, 0, 0, 0, 0, 0b0000_0001, 0, 0, 0, 0, A, 0b1111_1111, 1, 1, 1, 0 },
        [_]u32{ SUB_A, 0b0000_0000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, A, 0b0000_0000, 0, 0, 1, 1 },
        [_]u32{ SUB_A, 0b0000_0001, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, A, 0b0000_0000, 0, 0, 1, 1 },
        [_]u32{ SUB_A, 0b0000_1111, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, A, 0b0000_0000, 0, 0, 1, 1 },
        [_]u32{ SUB_A, 0b1000_1000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, A, 0b0000_0000, 0, 0, 1, 1 },
        [_]u32{ SUB_A, 0b1111_1111, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, A, 0b0000_0000, 0, 0, 1, 1 },
        // ADC
        [_]u32{ ADC_A_B, 0b1111_1111, 0b0000_0001, 0, 0, 0, 0, 0, 1, 0, 0, 0, A, 0b0000_0001, 1, 1, 0, 0 },
        [_]u32{ ADC_A_C, 0b0000_0000, 0, 0b0000_0000, 0, 0, 0, 0, 0, 0, 0, 0, A, 0b0000_0000, 0, 0, 0, 1 },
        [_]u32{ ADC_A_D, 0b0000_0001, 0, 0, 0b0000_0010, 0, 0, 0, 1, 0, 0, 0, A, 0b0000_0100, 0, 0, 0, 0 },
        [_]u32{ ADC_A_E, 0b0000_1001, 0, 0, 0, 0b0000_0010, 0, 0, 0, 0, 0, 0, A, 0b0000_1011, 0, 0, 0, 0 },
        [_]u32{ ADC_A_H, 0b0000_0001, 0, 0, 0, 0, 0b0000_1111, 0, 1, 0, 0, 0, A, 0b0001_0001, 0, 1, 0, 0 },
        [_]u32{ ADC_A_L, 0b0000_0001, 0, 0, 0, 0, 0, 0b0000_1111, 0, 0, 0, 0, A, 0b0001_0000, 0, 1, 0, 0 },
        [_]u32{ ADC_A_B, 0b0100_0001, 0b0010_1111, 0, 0, 0, 0, 0, 1, 0, 0, 0, A, 0b0111_0001, 0, 1, 0, 0 },
        [_]u32{ ADC_A_C, 0b1111_0001, 0, 0b0001_1111, 0, 0, 0, 0, 0, 0, 0, 0, A, 0b0001_0000, 1, 1, 0, 0 },
        [_]u32{ ADC_A_D, 0b1111_1111, 0, 0, 0b1111_1111, 0, 0, 0, 1, 0, 0, 0, A, 0b1111_1111, 1, 1, 0, 0 },
        [_]u32{ ADC_A_A, 0b0000_0001, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, A, 0b0000_0010, 0, 0, 0, 0 },
        [_]u32{ ADC_A_A, 0b0000_0011, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, A, 0b0000_0111, 0, 0, 0, 0 },
        [_]u32{ ADC_A_A, 0b0001_0101, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, A, 0b0010_1010, 0, 0, 0, 0 },
    };

    std.debug.print("\nXXX_A_REG family test \n", .{});

    // run test cases
    for (test_cases, 0..) |case, idx| {
        // PREP
        var cpu = CPU.init();

        cpu.clean_reg();

        // GIVEN
        for (1..12) |i| {
            const val: u16 = @intCast(case[i]);
            cpu.set_reg_val(@intCast(i), val);
        }

        // WHEN
        const ins_idx = case[INS];
        std.debug.print("case: {d}, op 0x{X} ", .{ idx, case[OP_CODE] });
        cpu.run_ins(.{ ins_idx, 0, 0 });

        // THEN
        try std.testing.expect(cpu.get_reg_val(case[EXP_REG]) == case[EXP_VAL]);
        try std.testing.expect(cpu.get_reg_val(CF) == case[EXP_C]);
        try std.testing.expect(cpu.get_reg_val(HF) == case[EXP_H]);
        try std.testing.expect(cpu.get_reg_val(NF) == case[EXP_N]);
        try std.testing.expect(cpu.get_reg_val(ZF) == case[EXP_Z]);

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
        [_]u32{ ADD_A_HL, 1, 0, 0, 0, 0, 1, 9, 0, 1, 0, 0, 265, 99, A, 100, 0, 0, 0, 0 },
        [_]u32{ ADD_A_HL, 255, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 512, 1, A, 0, 1, 0, 0, 1 },
        [_]u32{ ADD_A_HL, 15, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 256, 1, A, 16, 0, 0, 0, 0 },
        [_]u32{ ADD_A_HL, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 768, 0, A, 0, 0, 0, 0, 1 },
        [_]u32{ ADD_A_HL, 50, 0, 0, 0, 0, 1, 100, 0, 0, 0, 0, 356, 25, A, 75, 0, 0, 0, 0 },
        [_]u32{ ADD_A_HL, 100, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 1024, 255, A, 99, 1, 0, 0, 0 },
        [_]u32{ ADD_A_HL, 255, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 1280, 255, A, 254, 1, 0, 0, 0 },
        [_]u32{ ADD_A_HL, 240, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 1536, 16, A, 0, 1, 0, 0, 1 },
        [_]u32{ ADD_A_HL, 8, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 1792, 8, A, 16, 0, 0, 0, 0 },
        [_]u32{ ADD_A_HL, 10, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 2048, 5, A, 15, 0, 0, 0, 0 },
        // ADC
        [_]u32{ ADC_A_HL, 1, 0, 0, 0, 0, 1, 9, 1, 1, 0, 0, 265, 99, A, 101, 0, 0, 0, 0 },
        [_]u32{ ADC_A_HL, 255, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 512, 1, A, 1, 1, 1, 0, 0 },
        [_]u32{ ADC_A_HL, 15, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 256, 1, A, 17, 0, 1, 0, 0 },
        [_]u32{ ADC_A_HL, 0, 0, 0, 0, 0, 3, 0, 1, 0, 0, 0, 768, 0, A, 1, 0, 0, 0, 0 },
        [_]u32{ ADC_A_HL, 50, 0, 0, 0, 0, 1, 100, 1, 0, 0, 0, 356, 25, A, 76, 0, 0, 0, 0 },
        [_]u32{ ADC_A_HL, 100, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 1024, 255, A, 99, 1, 0, 0, 0 },
        [_]u32{ ADC_A_HL, 255, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 1280, 255, A, 254, 1, 0, 0, 0 },
        [_]u32{ ADC_A_HL, 240, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 1536, 16, A, 0, 1, 0, 0, 1 },
        [_]u32{ ADC_A_HL, 8, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 1792, 8, A, 16, 0, 0, 0, 0 },
        [_]u32{ ADC_A_HL, 10, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 2048, 5, A, 15, 0, 0, 0, 0 },
        // SUB
        [_]u32{ SUB_HL, 21, 0, 0, 0, 0, 1, 9, 0, 0, 0, 0, 265, 1, A, 20, 0, 0, 1, 0 },
        [_]u32{ SUB_HL, 21, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 512, 21, A, 0, 0, 0, 1, 1 },
        [_]u32{ SUB_HL, 127, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 768, 85, A, 42, 0, 0, 1, 0 },
        [_]u32{ SUB_HL, 127, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 256, 85, A, 42, 0, 0, 1, 0 },
        [_]u32{ SUB_HL, 127, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 1024, 85, A, 42, 0, 0, 1, 0 },
        [_]u32{ SUB_HL, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 1280, 1, A, 255, 1, 0, 1, 0 },
        [_]u32{ SUB_HL, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 1536, 0, A, 0, 0, 0, 1, 1 },
        [_]u32{ SUB_HL, 1, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 1792, 0, A, 1, 0, 0, 1, 0 },
        [_]u32{ SUB_HL, 15, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 2048, 0, A, 15, 0, 0, 1, 0 },
        [_]u32{ SUB_HL, 136, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 2304, 136, A, 0, 0, 0, 1, 1 },
        [_]u32{ SUB_HL, 255, 0, 0, 0, 0, 10, 0, 0, 0, 0, 0, 2560, 255, A, 0, 0, 0, 1, 1 },
    };

    std.debug.print("\nXXX_A_HL family test \n", .{});

    // run test cases
    for (test_cases, 0..) |case, idx| {
        // PREP
        var cpu = CPU.init();

        cpu.clean_reg();

        // GIVEN
        for (1..12) |i| {
            const val: u16 = @intCast(case[i]);
            cpu.set_reg_val(@intCast(i), val);
        }

        const add = case[MEM_AD];
        const mem_val: u16 = @intCast(case[MEM_VAL]);
        cpu.set_reg_val(add + SREG_SIZE, mem_val);

        // WHEN
        const ins_idx = case[INS];
        std.debug.print("case: {d}, op 0x{X} ", .{ idx, case[OP_CODE] });
        cpu.run_ins(.{ ins_idx, 0, 0 });

        // THEN
        try std.testing.expect(cpu.get_reg_val(case[EXP_REG]) == case[EXP_VAL]);
        try std.testing.expect(cpu.get_reg_val(CF) == case[EXP_C]);
        try std.testing.expect(cpu.get_reg_val(HF) == case[EXP_H]);
        try std.testing.expect(cpu.get_reg_val(NF) == case[EXP_N]);
        try std.testing.expect(cpu.get_reg_val(ZF) == case[EXP_Z]);

        std.debug.print("PASSED\n", .{});
    }
}
