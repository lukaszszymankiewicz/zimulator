const std = @import("std");

const hw = @import("hardware.zig");
const cpu = @import("cpu.zig");
const r = @import("reg.zig");
const t = @import("types.zig");
const instruction_t = @import("ins.zig").instruction_t;
const instruction_collection = @import("ins.zig").instructions;

const rl = @cImport({
    @cInclude("raylib.h");
});


const TILE_WIDTH: t.DataType = 8;
const TILE_HEIGHT: t.DataType = 8;
const N_TILES: t.DataType = 5*16-8;
const N_BIT_PER_TILE: t.DataType = 16;

const SCREEN_WIDTH: t.HardwareSize = 128;
const SCREEN_HEIGHT: t.HardwareSize = 128;

pub fn create_tilemap(raw_data: []t.DataType) !rl.Image {
    var pixels = try std.heap.page_allocator.alloc(t.DataType, SCREEN_WIDTH * SCREEN_HEIGHT);

    for (0..N_TILES) |tile_idx| {
        var row: u32 = 0; 

        while (row < 16) {
            const second_byte = raw_data[tile_idx * N_BIT_PER_TILE + row + 1];
            const first_byte = raw_data[tile_idx * N_BIT_PER_TILE + row];

            inline for (0..8) |px| {
                const idx: usize = ((row/2)*128) + ((8-px)+(tile_idx*TILE_WIDTH)) + ((tile_idx/16) * (128*7));
                const color_a: t.DataType = @intCast(((second_byte >> px) & 1) * 180);
                const color_b: t.DataType = @intCast(((first_byte >> px) & 1) * 75);
                pixels[idx] = 255 - color_a - color_b;
                
            }
            row += 2;
        }
    }

    return rl.Image{
        .data = pixels.ptr,
        .width = @intCast(128),
        .height = @intCast(128),
        .format = rl.PIXELFORMAT_UNCOMPRESSED_GRAYSCALE,
        .mipmaps = 1 
    };
}
