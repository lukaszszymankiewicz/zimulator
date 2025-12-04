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
const N_BIT_PER_TILE: t.DataType = 16;

const N_TILES: t.HardwareSize = 5*16-7;
const SCREEN_WIDTH: t.HardwareSize = @intCast(TILE_WIDTH * N_TILES);
const SCREEN_HEIGHT: t.HardwareSize = @intCast(TILE_HEIGHT);

const LIHGT_GREY_COLOR = 75;
const DARK_GREY_COLOR = 180;

pub fn create_tilemap(raw_data: []t.DataType) !rl.Image {
    var pixels = try std.heap.page_allocator.alloc(t.DataType, SCREEN_WIDTH * SCREEN_HEIGHT);
    
    // basically it is a Game Boy way of encoding images
    // it can be done to use only one loop...
    // propably TODO:
    for (0..N_TILES) |tile_idx| {
        var row: u32 = 0; 

        while (row < N_BIT_PER_TILE) {
            const second_byte = raw_data[tile_idx * N_BIT_PER_TILE + row + 1];
            const first_byte = raw_data[tile_idx * N_BIT_PER_TILE + row];

            inline for (0..TILE_WIDTH) |px| {
                const idx: usize = ((row/2)*SCREEN_WIDTH) + ((TILE_WIDTH-px-1)+(tile_idx*TILE_WIDTH));
                const bit_a: t.DataType = @intCast((second_byte >> px) & 1);
                const bit_b: t.DataType = @intCast((first_byte >> px) & 1);

                pixels[idx] = 255 - (bit_b * LIHGT_GREY_COLOR) - (bit_a * DARK_GREY_COLOR);
                
            }
            row += 2;
        }
    }

    return rl.Image{
        .data = pixels.ptr,
        .width = @intCast(SCREEN_WIDTH),
        .height = @intCast(SCREEN_HEIGHT),
        .format = rl.PIXELFORMAT_UNCOMPRESSED_GRAYSCALE,
        .mipmaps = 1 
    };
}
