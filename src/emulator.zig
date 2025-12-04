const std = @import("std");

const hw = @import("hardware.zig");
const cpu = @import("cpu.zig");
const r = @import("reg.zig");
const tm = @import("tilemap.zig");
const t = @import("types.zig");
const instruction_t = @import("ins.zig").instruction_t;
const instruction_collection = @import("ins.zig").instructions;

const rl = @cImport({
    @cInclude("raylib.h");
});

const BUFFER_SIZE: u32 = 16;
const ROM_FILE: []const u8 = "src/hello";
const APP_NAME: []const u8 = "ZIMULATOR";

const SCREEN_WIDTH = 600;
const SCREEN_HEIGHT = 576;
const GB_SCREEN_WIDTH = 160;
const GB_SCREEN_HEIGHT = 144;
const TILE_WIDTH: u32 = 8;
const TILE_HEIGHT: u32 = 8;
const TILE_IN_ROW: u32 = 32;
const TILE_IN_COL: u32 = 18;
const FPS = 60;
const SCALE = 4; // just for presentation purposes

pub const Emulator = struct {
    processor: cpu.CPU,

    pub fn init() Emulator {
        const e = Emulator{
            .processor = cpu.CPU.init()
        };
        return e;
    }

    pub fn read_rom(self: *Emulator) !void {
        const file = try std.fs.cwd().openFile("src/hello", .{});
        const stat = try file.stat();
        defer file.close();

        var buffered_file = std.io.bufferedReader(file.reader());
        var byte: [BUFFER_SIZE]t.DataType = undefined;

        const end = stat.size / BUFFER_SIZE;
        
        for (0..end) |i| {
            _ = try buffered_file.read(&byte);
            const left = hw.PROG_START + (i * BUFFER_SIZE);
            const right = hw.PROG_START + (i * BUFFER_SIZE) + BUFFER_SIZE + 1;

            std.mem.copyForwards(t.DataType, self.processor.REG[left..right], &byte);
        }
    }

    pub fn draw_tiles(_: *Emulator, tilemap: []t.DataType, tex: rl.Texture2D) void {
        for (tilemap, 0..) |tile, i| {

            const row = i / TILE_IN_ROW;
            const col = i % TILE_IN_ROW;

            const src: rl.Rectangle = rl.Rectangle{
                .x=@floatFromInt(tile * TILE_WIDTH),
                .y=0.0,
                .width=@floatFromInt(TILE_WIDTH),
                .height=@floatFromInt(TILE_HEIGHT)
            };

            const dest: rl.Rectangle = rl.Rectangle{
                .x=@floatFromInt(col * TILE_WIDTH * SCALE),
                .y=@floatFromInt(row * TILE_HEIGHT * SCALE),
                .width=@floatFromInt(TILE_WIDTH * SCALE),
                .height=@floatFromInt(TILE_HEIGHT * SCALE)
            };

            const origin: rl.Vector2 = rl.Vector2{ .x=0.0, .y=0.0 };

            rl.DrawTexturePro(tex, src, dest, origin, 0.0, rl.RAYWHITE);
        }
    }

    pub fn run(self: *Emulator) !void {
        // this is just a PoC. Emulator runs one frame and renders the screen (rather than running in full loop)
        self.run_cpu_cycle();

        rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "ZIMULATOR");
        rl.SetTargetFPS(FPS);

        const vram: rl.Image = try tm.create_tilemap(self.processor.get_vram());
        const tiletex: rl.Texture2D = rl.LoadTextureFromImage(vram);
        defer rl.CloseWindow();
        const tilemap = self.processor.get_tilemap();

        while (!rl.WindowShouldClose()) {
            rl.BeginDrawing();
            defer rl.EndDrawing();
            rl.ClearBackground(rl.WHITE);
            self.draw_tiles(tilemap, tiletex);
        }

       defer rl.UnloadTexture(tiletex);
       defer rl.UnloadImage(vram);
    }

    pub fn run_cpu_cycle(self: *Emulator) void {
        var idx: u16 = 0;

        while (true) {
            self.processor.run_single_instruction();
            idx = idx +% 1;

            if (idx == 0) {
                break;
            }
        }
    }
};

pub fn main() !void {
    var e: Emulator = Emulator.init();
    try e.read_rom();
    try e.run();
}
