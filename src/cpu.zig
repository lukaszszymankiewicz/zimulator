const std = @import("std");
const mc = @import("mc.zig");

// HARDWARE
pub const RAM_SIZE: u32 = 256 * 256;
pub const RAM_BEG: u32 = 256;
pub const SREG_SIZE: u32 = 256;

// REGISTER INDEXES
pub const IM: u32 = 0b0000_0000;
pub const A: u32 = 0b0000_0001;
pub const B: u32 = 0b0000_0010;
pub const C: u32 = 0b0000_0011;
pub const D: u32 = 0b0000_0100;
pub const E: u32 = 0b0000_0101;
pub const H: u32 = 0b0000_0110;
pub const L: u32 = 0b0000_0111;

pub const CF: u32 = 0b0000_1000;
pub const HF: u32 = 0b0000_1001;
pub const NF: u32 = 0b0000_1010;
pub const ZF: u32 = 0b0000_1011;

pub const S: u32 = 0b0000_1100;
pub const P: u32 = 0b0000_1101;

pub const BC: u32 = 0b0010_0011;
pub const DE: u32 = 0b0100_0101;
pub const HL: u32 = 0b0110_0111;
pub const SP: u32 = 0b1100_1101;

// INSTRUCTIONS
pub const NOP: u32 = 0b0000_0000;
pub const LD_BC_D16: u32 = 0b0000_0001;
pub const LD_BC_A: u32 = 0b0000_0010;
pub const INC_BC: u32 = 0b0000_0011;

pub const LD_DE_D16: u32 = 0b0001_0001;
pub const LD_DE_A: u32 = 0b0001_0010;
pub const INC_DE: u32 = 0b0001_0011;
pub const LD_HL_D16: u32 = 0b0010_0001;
pub const LD_HLPLUS_A: u32 = 0b0010_0010;

pub const INC_HL: u32 = 0b0010_0011;
pub const INC_SP: u32 = 0b0011_0011;

pub const LD_SP_D16: u32 = 0b0011_0001;
pub const LD_HLMINUS_A: u32 = 0b0011_0010;

pub const ADD_A_B: u32 = 0b1000_0000;
pub const ADD_A_C: u32 = 0b1000_0001;
pub const ADD_A_D: u32 = 0b1000_0010;
pub const ADD_A_E: u32 = 0b1000_0011;
pub const ADD_A_H: u32 = 0b1000_0100;
pub const ADD_A_L: u32 = 0b1000_0101;
pub const ADD_A_HL: u32 = 0b1000_0110;
pub const ADD_A_A: u32 = 0b1000_0111;

pub const ADC_A_B: u32 = 0b1000_1000;
pub const ADC_A_C: u32 = 0b1000_1001;
pub const ADC_A_D: u32 = 0b1000_1010;
pub const ADC_A_E: u32 = 0b1000_1011;
pub const ADC_A_H: u32 = 0b1000_1100;
pub const ADC_A_L: u32 = 0b1000_1101;
pub const ADC_A_HL: u32 = 0b1000_1110;
pub const ADC_A_A: u32 = 0b1000_1111;

pub const SUB_B: u32 = 0b1001_0000;
pub const SUB_C: u32 = 0b1001_0001;
pub const SUB_D: u32 = 0b1001_0010;
pub const SUB_E: u32 = 0b1001_0011;
pub const SUB_H: u32 = 0b1001_0100;
pub const SUB_L: u32 = 0b1001_0101;
pub const SUB_HL: u32 = 0b1001_0110;
pub const SUB_A: u32 = 0b1001_0111;

// GBA INSTRUCTION TABLE
pub const OP_CODE = 0;
pub const OP_SIZE = 1;
pub const OP_MC = 2;
pub const OP_VAL_A = 3;
pub const OP_VAL_B = 4;
pub const OP_FMC_C = 5;
pub const OP_FMC_H = 6;
pub const OP_FMC_N = 7;
pub const OP_FMC_Z = 8;

const NA = 255;
const MEM_TYPE = SREG_SIZE;

pub const instructions = [_][9]u32{
    [_]u32{ NOP, 1, mc._NOP, NA, NA, mc._NOP, mc._NOP, mc._NOP, mc._NOP },
    [_]u32{ LD_BC_D16, 3, mc._LD_REG_D16, NA, BC, mc._NOP, mc._NOP, mc._NOP, mc._NOP },
    [_]u32{ LD_BC_A, 1, mc._LD_MEM_A, A, BC, mc._NOP, mc._NOP, mc._NOP, mc._NOP },
    [_]u32{ INC_BC, 1, mc._INC_REG, NA, BC, mc._NOP, mc._NOP, mc._NOP, mc._NOP },
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
    [_]u32{ LD_DE_D16, 3, mc._LD_REG_D16, NA, DE, mc._NOP, mc._NOP, mc._NOP, mc._NOP },
    [_]u32{ LD_DE_A, 1, mc._LD_MEM_A, A, DE, mc._NOP, mc._NOP, mc._NOP, mc._NOP },
    [_]u32{ INC_DE, 1, mc._INC_REG, NA, DE, mc._NOP, mc._NOP, mc._NOP, mc._NOP },
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
    [_]u32{ LD_HL_D16, 3, mc._LD_REG_D16, NA, HL, mc._NOP, mc._NOP, mc._NOP, mc._NOP },
    [_]u32{ LD_HLPLUS_A, 1, mc._LD_HLPLUS_A, A, HL, mc._NOP, mc._NOP, mc._NOP, mc._NOP },
    [_]u32{ INC_HL, 1, mc._INC_REG, NA, HL, mc._NOP, mc._NOP, mc._NOP, mc._NOP },
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
    [_]u32{ LD_SP_D16, 3, mc._LD_REG_D16, NA, SP, mc._NOP, mc._NOP, mc._NOP, mc._NOP },
    [_]u32{ LD_HLMINUS_A, 1, mc._LD_HLMINUS_A, A, HL, mc._NOP, mc._NOP, mc._NOP, mc._NOP },
    [_]u32{ INC_SP, 1, mc._INC_REG, NA, SP, mc._NOP, mc._NOP, mc._NOP, mc._NOP },
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

pub const CPU = struct {
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

    pub fn get_regs(self: *CPU) []u16 {
        return self.REG[0 .. SREG_SIZE + 1];
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
        self.set_reg_val(SP, self.REG[S] << 8 | self.REG[P]);
    }

    pub fn run_ins(self: *CPU, program: [3]u32) void {
        const i = program[0];
        const lb = program[1];
        const hb = program[2];

        self.correct_double_regs();

        const reg: u32 = instructions[i][OP_VAL_A];
        const val: u32 = instructions[i][OP_VAL_B];
        const im: u16 = @intCast(lb + (hb << 8));

        self.set_reg_val(IM, im);

        const a: *u16 = self.get_reg(reg);

        const regs: []u16 = self.get_regs();
        const memory: []u16 = self.get_memory();

        mc.MC.calc(instructions[i][OP_MC], instructions[i][OP_FMC_C], instructions[i][OP_FMC_H], instructions[i][OP_FMC_N], instructions[i][OP_FMC_Z], a, val, regs, memory);
    }
};
