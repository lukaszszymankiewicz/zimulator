const std = @import("std");

// MICROCODE
fn mc_nop(_: *u16, _: u16, _: []u16) u16 {
    return 0;
}

fn mc_add_a_reg(acc: *u16, reg: u16, _: []u16) u16 {
    acc.* += reg;
    return 0;
}

fn mc_adc_a_reg(acc: *u16, reg: u16, flags: []u16) u16 {
    acc.* += reg;
    acc.* += flags[0]; // update with C flag
    return 0;
}

fn mc_sub_a_reg(acc: *u16, reg: u16, _: []u16) u16 {
    // add dummy bit to simulate overflow
    const a: u16 = acc.* | 0b1_0000_0000;
    // proceed with the calculation
    const res: u16 = a - reg;
    acc.* = res;
    return 0;
}

fn mc_sbc_a_reg(acc: *u16, reg: u16, flags: []u16) u16 {
    // add dummy bit to simulate overflow
    const a: u16 = acc.* | 0b1_0000_0000;
    // proceed with the calculation
    const res: u16 = a - reg - flags[0];
    acc.* = res;
    return 0;
}

fn fmc_H(acc: *u16, reg: u16, _: []u16) u16 {
    const hc: u16 = ((acc.* & 0b0000_1111) + (reg & 0b0000_1111)) & 0b0001_0000;

    return @intFromBool(hc == 0b0001_0000);
}

fn fmc_C_NOP(_: *u16, _: u16, flags: []u16) u16 {
    return flags[0];
}

fn fmc_H_NOP(_: *u16, _: u16, flags: []u16) u16 {
    return flags[1];
}

fn fmc_N_NOP(_: *u16, _: u16, flags: []u16) u16 {
    return flags[2];
}

fn fmc_Z_NOP(_: *u16, _: u16, flags: []u16) u16 {
    return flags[3];
}

fn fmc_C(acc: *u16, _: u16, _: []u16) u16 {
    return @intFromBool(acc.* >= 0b1_0000_0000);
}

fn fmc_Z(acc: *u16, _: u16, _: []u16) u16 {
    return @intFromBool(acc.* == 0);
}

fn fmc_N0(_: *u16, _: u16, _: []u16) u16 {
    return 0;
}

fn fmc_N1(_: *u16, _: u16, _: []u16) u16 {
    return 1;
}

// MICROCODE
const I_MC_NOP: u8 = 0;
const I_MC_ADD_A_REG: u8 = 1;
const I_MC_ADC_A_REG: u8 = 2;
const I_MC_SUB_A_REG: u8 = 3;
const I_FMC_C_NOP: u8 = 4;
const I_FMC_C: u8 = 5;
const I_FMC_H_NOP: u8 = 6;
const I_FMC_H: u8 = 7;
const I_FMC_N_NOP: u8 = 8;
const I_FMC_N0: u8 = 9;
const I_FMC_N1: u8 = 10;
const I_FMC_Z_NOP: u8 = 11;
const I_FMC_Z: u8 = 12;

const MC = [_]*const fn (*u16, u16, []u16) u16{
    mc_nop,
    mc_add_a_reg,
    mc_adc_a_reg,
    mc_sub_a_reg,
    fmc_C_NOP,
    fmc_C,
    fmc_H_NOP,
    fmc_H,
    fmc_N_NOP,
    fmc_N0,
    fmc_N1,
    fmc_Z_NOP,
    fmc_Z,
};

// INSTRUCTIONS
const NOP: u8 = 0b0000_0000;
const ADD_A_B: u8 = 0b1000_0000;
const ADD_A_C: u8 = 0b1000_0001;
const ADD_A_D: u8 = 0b1000_0010;
const ADD_A_E: u8 = 0b1000_0011;
const ADD_A_H: u8 = 0b1000_0100;
const ADD_A_L: u8 = 0b1000_0101;
const ADD_A_HL: u8 = 0b1000_0110;
const ADD_A_A: u8 = 0b1000_0111;

const ADC_A_B: u8 = 0b1000_1000;
const ADC_A_C: u8 = 0b1000_1001;
const ADC_A_D: u8 = 0b1000_1010;
const ADC_A_E: u8 = 0b1000_1011;
const ADC_A_H: u8 = 0b1000_1100;
const ADC_A_L: u8 = 0b1000_1101;
const ADC_A_HL: u8 = 0b1000_1110;
const ADC_A_A: u8 = 0b1000_1111;

const SUB_A_B: u8 = 0b1001_0000;
const SUB_A_C: u8 = 0b1001_0001;
const SUB_A_D: u8 = 0b1001_0010;
const SUB_A_E: u8 = 0b1001_0011;
const SUB_A_H: u8 = 0b1001_0100;
const SUB_A_L: u8 = 0b1001_0101;

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

const instructions = [_][9]u8{
    [_]u8{ NOP, 1, I_MC_NOP, NOP, NOP, I_FMC_C_NOP, I_FMC_H_NOP, I_FMC_N_NOP, I_FMC_Z_NOP },
    [_]u8{ 1, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 2, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 3, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 4, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 5, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 6, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 7, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 8, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 9, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 10, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 11, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 12, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 13, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 14, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 15, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 16, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 17, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 18, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 19, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 20, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 21, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 22, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 23, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 24, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 25, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 26, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 27, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 28, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 29, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 30, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 31, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 32, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 33, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 34, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 35, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 36, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 37, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 38, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 39, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 40, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 41, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 42, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 43, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 44, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 45, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 46, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 47, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 48, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 49, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 50, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 51, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 52, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 53, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 54, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 55, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 56, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 57, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 58, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 59, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 60, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 61, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 62, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 63, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 64, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 65, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 66, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 67, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 68, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 69, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 70, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 71, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 72, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 73, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 74, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 75, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 76, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 77, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 78, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 79, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 80, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 81, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 82, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 83, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 84, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 85, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 86, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 87, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 88, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 89, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 90, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 91, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 92, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 93, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 94, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 95, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 96, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 97, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 98, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 99, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 100, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 101, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 102, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 103, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 104, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 105, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 106, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 107, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 108, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 109, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 110, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 111, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 112, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 113, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 114, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 115, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 116, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 117, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 118, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 119, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 120, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 121, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 122, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 123, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 124, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 125, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 126, 1, 0, 0, 0, 0, 0, 0, 0 },
    [_]u8{ 127, 1, 0, 0, 0, 0, 0, 0, 0 },

    [_]u8{ ADD_A_B, 1, I_MC_ADD_A_REG, A, B, I_FMC_C, I_FMC_H, I_FMC_N0, I_FMC_Z },
    [_]u8{ ADD_A_C, 1, I_MC_ADD_A_REG, A, C, I_FMC_C, I_FMC_H, I_FMC_N0, I_FMC_Z },
    [_]u8{ ADD_A_D, 1, I_MC_ADD_A_REG, A, D, I_FMC_C, I_FMC_H, I_FMC_N0, I_FMC_Z },
    [_]u8{ ADD_A_E, 1, I_MC_ADD_A_REG, A, E, I_FMC_C, I_FMC_H, I_FMC_N0, I_FMC_Z },
    [_]u8{ ADD_A_H, 1, I_MC_ADD_A_REG, A, H, I_FMC_C, I_FMC_H, I_FMC_N0, I_FMC_Z },
    [_]u8{ ADD_A_L, 1, I_MC_ADD_A_REG, A, L, I_FMC_C, I_FMC_H, I_FMC_N0, I_FMC_Z },
    [_]u8{ ADD_A_HL, 1, I_MC_ADD_A_REG, A, HL, I_FMC_C, I_FMC_H, I_FMC_N0, I_FMC_Z },
    [_]u8{ ADD_A_A, 1, I_MC_ADD_A_REG, A, A, I_FMC_C, I_FMC_H, I_FMC_N0, I_FMC_Z },

    [_]u8{ ADC_A_B, 1, I_MC_ADC_A_REG, A, B, I_FMC_C, I_FMC_H, I_FMC_N0, I_FMC_Z },
    [_]u8{ ADC_A_C, 1, I_MC_ADC_A_REG, A, C, I_FMC_C, I_FMC_H, I_FMC_N0, I_FMC_Z },
    [_]u8{ ADC_A_D, 1, I_MC_ADC_A_REG, A, D, I_FMC_C, I_FMC_H, I_FMC_N0, I_FMC_Z },
    [_]u8{ ADC_A_E, 1, I_MC_ADC_A_REG, A, E, I_FMC_C, I_FMC_H, I_FMC_N0, I_FMC_Z },
    [_]u8{ ADC_A_H, 1, I_MC_ADC_A_REG, A, H, I_FMC_C, I_FMC_H, I_FMC_N0, I_FMC_Z },
    [_]u8{ ADC_A_L, 1, I_MC_ADC_A_REG, A, L, I_FMC_C, I_FMC_H, I_FMC_N0, I_FMC_Z },
    [_]u8{ ADC_A_HL, 1, I_MC_ADC_A_REG, A, HL, I_FMC_C, I_FMC_H, I_FMC_N0, I_FMC_Z },
    [_]u8{ ADC_A_A, 1, I_MC_ADC_A_REG, A, A, I_FMC_C, I_FMC_H, I_FMC_N0, I_FMC_Z },

    [_]u8{ SUB_A_B, 1, I_MC_SUB_A_REG, A, B, I_FMC_C, I_FMC_H, I_FMC_N1, I_FMC_Z },
    [_]u8{ SUB_A_C, 1, I_MC_SUB_A_REG, A, C, I_FMC_C, I_FMC_H, I_FMC_N1, I_FMC_Z },
    [_]u8{ SUB_A_D, 1, I_MC_SUB_A_REG, A, D, I_FMC_C, I_FMC_H, I_FMC_N1, I_FMC_Z },
    [_]u8{ SUB_A_E, 1, I_MC_SUB_A_REG, A, E, I_FMC_C, I_FMC_H, I_FMC_N1, I_FMC_Z },
    [_]u8{ SUB_A_H, 1, I_MC_SUB_A_REG, A, H, I_FMC_C, I_FMC_H, I_FMC_N1, I_FMC_Z },
    [_]u8{ SUB_A_L, 1, I_MC_SUB_A_REG, A, L, I_FMC_C, I_FMC_H, I_FMC_N1, I_FMC_Z },
};

// REGISTER INDEXES
const DUMMY: u8 = 0b0000_0000;
const A: u8 = 0b0000_0001;
const B: u8 = 0b0000_0010;
const C: u8 = 0b0000_0011;
const D: u8 = 0b0000_0100;
const E: u8 = 0b0000_0101;
const H: u8 = 0b0000_0110;
const L: u8 = 0b0000_0111;
const CF: u8 = 0b0000_1000;
const HF: u8 = 0b0000_1001;
const NF: u8 = 0b0000_1010;
const ZF: u8 = 0b0000_1011;
const BC: u8 = 0b0010_0011;
const DE: u8 = 0b0100_0101;
const HL: u8 = 0b0110_0111;
const SP: u8 = 0b0111_0111;

const CPU = struct {
    REG: [12]u16,

    pub fn init() CPU {
        return CPU{ .REG = [_]u16{0} ** 12 };
    }

    pub fn clean_reg(self: *CPU) void {
        for (0..self.REG.len) |i| {
            self.REG[i] = 0b0000_0000;
        }
    }

    pub fn get_reg(self: *CPU, i: u8) *u16 {
        return &(self.REG[i]);
    }

    pub fn set_reg(self: *CPU, i: u8, val: u16) void {
        self.REG[i] = val;
    }

    pub fn get_flags(self: *CPU) []u16 {
        return self.REG[CF .. ZF + 1];
    }

    pub fn get_reg_val(self: *CPU, i: u8) u16 {
        const high_bit = self.REG[(0b1111_0000 & i) >> 4];
        const low_bit = self.REG[(0b0000_1111 & i)];

        return (high_bit << 8) | low_bit;
    }

    pub fn set_reg_val(self: *CPU, flag: u8, val: u16) void {
        self.REG[flag] = val;
    }

    fn truncate_to_u8(self: *CPU, i: u8) void {
        self.REG[i] &= 0b0000_0000_1111_1111;
    }

    fn run_ins(self: *CPU, i: u8) void {
        const reg: u8 = instructions[i][OP_VAL_A];
        const val: u8 = instructions[i][OP_VAL_B];

        const in_fun = MC[instructions[i][OP_MC]];
        const cf_fun = MC[instructions[i][OP_FMC_C]];
        const hf_fun = MC[instructions[i][OP_FMC_H]];
        const nf_fun = MC[instructions[i][OP_FMC_N]];
        const zf_fun = MC[instructions[i][OP_FMC_Z]];

        const a: *u16 = self.get_reg(reg);
        const b: u16 = self.get_reg_val(val);
        const flags: []u16 = self.get_flags();

        self.set_reg_val(HF, hf_fun(a, b, flags));

        _ = in_fun(a, b, flags);

        self.set_reg_val(CF, cf_fun(a, b, flags));

        self.truncate_to_u8(reg);

        self.set_reg_val(ZF, zf_fun(a, b, flags));
        self.set_reg_val(NF, nf_fun(a, b, flags));
        self.set_reg_val(DUMMY, 0);
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

test "Check if `add_a_r8`, `adc_a_r8`, `sub_a_r8` work " {
    // PREP
    const INS: u8 = 0;
    const EXP_REG: u8 = 12;
    const EXP_VAL: u8 = 13;
    const EXP_C: u8 = 14;
    const EXP_H: u8 = 15;
    const EXP_N: u8 = 16;
    const EXP_Z: u8 = 17;

    const test_cases = [_][18]u8{
        //     INS      A            B            C  D  E, H, L, C, H, N, Z, E_REG, E_V,     C, H  N  Z
        // NOP
        [_]u8{ NOP, 0b1111_1111, 0b0000_0001, 0, 0, 0, 0, 0, 1, 1, 1, 1, A, 0b1111_1111, 1, 1, 1, 1 },
        [_]u8{ NOP, 0b1111_1111, 0b0000_0001, 0, 0, 0, 0, 0, 1, 0, 1, 0, B, 0b0000_0001, 1, 0, 1, 0 },
        // add
        [_]u8{ ADD_A_B, 0b1111_1111, 0b0000_0001, 0, 0, 0, 0, 0, 0, 0, 0, 0, A, 0b0000_0000, 1, 1, 0, 1 },
        [_]u8{ ADD_A_C, 0b0000_0000, 0, 0b0000_0000, 0, 0, 0, 0, 0, 0, 0, 0, A, 0b0000_0000, 0, 0, 0, 1 },
        [_]u8{ ADD_A_D, 0b0000_0001, 0, 0, 0b0000_0010, 0, 0, 0, 0, 0, 0, 0, A, 0b0000_0011, 0, 0, 0, 0 },
        [_]u8{ ADD_A_E, 0b0000_1001, 0, 0, 0, 0b0000_0010, 0, 0, 0, 0, 0, 0, A, 0b0000_1011, 0, 0, 0, 0 },
        [_]u8{ ADD_A_H, 0b0000_0001, 0, 0, 0, 0, 0b0000_1111, 0, 0, 0, 0, 0, A, 0b0001_0000, 0, 1, 0, 0 },
        [_]u8{ ADD_A_L, 0b0000_0001, 0, 0, 0, 0, 0, 0b0000_1111, 0, 0, 0, 0, A, 0b0001_0000, 0, 1, 0, 0 },
        [_]u8{ ADD_A_B, 0b0100_0001, 0b0010_1111, 0, 0, 0, 0, 0, 0, 0, 0, 0, A, 0b0111_0000, 0, 1, 0, 0 },
        [_]u8{ ADD_A_C, 0b1111_0001, 0, 0b0001_1111, 0, 0, 0, 0, 0, 0, 0, 0, A, 0b0001_0000, 1, 1, 0, 0 },
        [_]u8{ ADD_A_D, 0b1111_1111, 0, 0, 0b1111_1111, 0, 0, 0, 0, 0, 0, 0, A, 0b1111_1110, 1, 1, 0, 0 },
        [_]u8{ ADD_A_A, 0b0000_0001, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, A, 0b0000_0010, 0, 0, 0, 0 },
        [_]u8{ ADD_A_A, 0b0000_0011, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, A, 0b0000_0110, 0, 0, 0, 0 },
        [_]u8{ ADD_A_A, 0b0001_0101, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, A, 0b0010_1010, 0, 0, 0, 0 },
        // sub
        [_]u8{ SUB_A_B, 0b0001_0101, 0b0000_0001, 0, 0, 0, 0, 0, 0, 0, 0, 0, A, 0b0001_0100, 1, 0, 1, 0 },
        [_]u8{ SUB_A_C, 0b0001_0101, 0, 0b0001_0101, 0, 0, 0, 0, 0, 0, 0, 0, A, 0b0000_0000, 1, 0, 1, 1 },
        [_]u8{ SUB_A_D, 0b0111_1111, 0, 0, 0b0101_0101, 0, 0, 0, 0, 0, 0, 0, A, 0b0010_1010, 1, 1, 1, 0 },
        [_]u8{ SUB_A_E, 0b0111_1111, 0, 0, 0, 0b0101_0101, 0, 0, 0, 0, 0, 0, A, 0b0010_1010, 1, 1, 1, 0 },
        [_]u8{ SUB_A_H, 0b0111_1111, 0, 0, 0, 0, 0b0101_0101, 0, 0, 0, 0, 0, A, 0b0010_1010, 1, 1, 1, 0 },
        [_]u8{ SUB_A_L, 0b0000_0000, 0, 0, 0, 0, 0, 0b0000_0001, 0, 0, 0, 0, A, 0b1111_1111, 0, 0, 1, 0 },
        // adc
        [_]u8{ ADC_A_B, 0b1111_1111, 0b0000_0001, 0, 0, 0, 0, 0, 1, 0, 0, 0, A, 0b0000_0001, 1, 1, 0, 0 },
        [_]u8{ ADC_A_C, 0b0000_0000, 0, 0b0000_0000, 0, 0, 0, 0, 0, 0, 0, 0, A, 0b0000_0000, 0, 0, 0, 1 },
        [_]u8{ ADC_A_D, 0b0000_0001, 0, 0, 0b0000_0010, 0, 0, 0, 1, 0, 0, 0, A, 0b0000_0100, 0, 0, 0, 0 },
        [_]u8{ ADC_A_E, 0b0000_1001, 0, 0, 0, 0b0000_0010, 0, 0, 0, 0, 0, 0, A, 0b0000_1011, 0, 0, 0, 0 },
        [_]u8{ ADC_A_H, 0b0000_0001, 0, 0, 0, 0, 0b0000_1111, 0, 1, 0, 0, 0, A, 0b0001_0001, 0, 1, 0, 0 },
        [_]u8{ ADC_A_L, 0b0000_0001, 0, 0, 0, 0, 0, 0b0000_1111, 0, 0, 0, 0, A, 0b0001_0000, 0, 1, 0, 0 },
        [_]u8{ ADC_A_B, 0b0100_0001, 0b0010_1111, 0, 0, 0, 0, 0, 1, 0, 0, 0, A, 0b0111_0001, 0, 1, 0, 0 },
        [_]u8{ ADC_A_C, 0b1111_0001, 0, 0b0001_1111, 0, 0, 0, 0, 0, 0, 0, 0, A, 0b0001_0000, 1, 1, 0, 0 },
        [_]u8{ ADC_A_D, 0b1111_1111, 0, 0, 0b1111_1111, 0, 0, 0, 1, 0, 0, 0, A, 0b1111_1111, 1, 1, 0, 0 },
        [_]u8{ ADC_A_A, 0b0000_0001, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, A, 0b0000_0010, 0, 0, 0, 0 },
        [_]u8{ ADC_A_A, 0b0000_0011, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, A, 0b0000_0111, 0, 0, 0, 0 },
        [_]u8{ ADC_A_A, 0b0001_0101, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, A, 0b0010_1010, 0, 0, 0, 0 },
        // add r16
        [_]u8{ ADD_A_HL, 0b0000_0000, 0, 0, 0, 0, 0b0000_0001, 0b0000_0001, 0, 0, 0, 0, A, 0b0000_0001, 1, 0, 0, 0 },
        [_]u8{ ADD_A_HL, 0b0000_0110, 0, 0, 0, 0, 0b0000_0001, 0b0010_0001, 0, 0, 0, 0, A, 0b0010_0111, 1, 0, 0, 0 },
        [_]u8{ ADD_A_HL, 0b0000_0000, 0, 0, 0, 0, 0b0000_0000, 0b0000_0000, 0, 0, 0, 0, A, 0b0000_0000, 0, 0, 0, 1 },
        [_]u8{ ADD_A_HL, 0b0000_0001, 0, 0, 0, 0, 0b0000_0000, 0b0000_0010, 0, 0, 0, 0, A, 0b0000_0011, 0, 0, 0, 0 },
        [_]u8{ ADD_A_HL, 0b0000_1001, 0, 0, 0, 0, 0b0000_0000, 0b0000_0010, 0, 0, 0, 0, A, 0b0000_1011, 0, 0, 0, 0 },
        [_]u8{ ADD_A_HL, 0b0000_0001, 0, 0, 0, 0, 0b0000_0000, 0b0000_1111, 0, 0, 0, 0, A, 0b0001_0000, 0, 1, 0, 0 },
        [_]u8{ ADD_A_HL, 0b0000_0001, 0, 0, 0, 0, 0b0000_0000, 0b0000_1111, 0, 0, 0, 0, A, 0b0001_0000, 0, 1, 0, 0 },
        [_]u8{ ADD_A_HL, 0b0100_0001, 0, 0, 0, 0, 0b0000_0000, 0b0010_1111, 0, 0, 0, 0, A, 0b0111_0000, 0, 1, 0, 0 },
        [_]u8{ ADD_A_HL, 0b1111_0001, 0, 0, 0, 0, 0b0000_0000, 0b0001_1111, 0, 0, 0, 0, A, 0b0001_0000, 1, 1, 0, 0 },
        [_]u8{ ADD_A_HL, 0b1111_1111, 0, 0, 0, 0, 0b0000_0000, 0b1111_1111, 0, 0, 0, 0, A, 0b1111_1110, 1, 1, 0, 0 },
    };

    // run test cases
    for (test_cases, 0..) |case, idx| {
        // PREP
        var cpu = CPU.init();

        cpu.clean_reg();

        // GIVEN
        for (1..cpu.REG.len) |i| {
            cpu.set_reg(@intCast(i), case[@intCast(i)]);
        }

        // WHEN
        const ins_idx = case[INS];
        std.debug.print("case: {d}, op 0x{X} ", .{ idx, case[OP_CODE] });
        cpu.run_ins(ins_idx);

        // THEN
        try std.testing.expect(cpu.get_reg_val(case[EXP_REG]) == case[EXP_VAL]);
        try std.testing.expect(cpu.get_reg_val(CF) == case[EXP_C]);
        try std.testing.expect(cpu.get_reg_val(HF) == case[EXP_H]);
        try std.testing.expect(cpu.get_reg_val(NF) == case[EXP_N]);
        try std.testing.expect(cpu.get_reg_val(ZF) == case[EXP_Z]);

        std.debug.print("PASSED\n", .{});
    }
}
