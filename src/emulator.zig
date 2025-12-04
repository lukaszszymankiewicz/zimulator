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
const SCREEN_HEIGHT = 600;
const FPS = 60;

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

    pub fn run(self: *Emulator) !void {
        self.run_cpu_cycle();

        rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, APP_NAME);
        rl.SetTargetFPS(FPS);

        const tilemap: rl.Image = try tm.create_tilemap(self.processor.get_vram());
        std.time.sleep(2_000_000);
        const screenTexture: rl.Texture2D = rl.LoadTextureFromImage(tilemap);
        defer rl.CloseWindow();

        while (!rl.WindowShouldClose()) {
            rl.BeginDrawing();
            defer rl.EndDrawing();
            rl.ClearBackground(rl.WHITE);
            rl.DrawTextureEx(screenTexture, rl.Vector2{.x=44, .y=44}, 0, 4.0, rl.RAYWHITE);
        }

       defer rl.UnloadTexture(screenTexture);
       defer rl.UnloadImage(tilemap);
    }

    pub fn run_cpu_cycle(self: *Emulator) void {
        // run one cycle and quietly exit
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

// pub fn main() !void {
//     std.debug.print("Hello, World!\n", .{});
//
//     const screenWidth = 800;
//     const screenHeight = 450;
//
//     rl.InitWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
//     defer rl.CloseWindow();
//     rl.SetTargetFPS(60); // Set our game to run at 60 frames-per-second
//
//     while (!rl.WindowShouldClose()) { // Detect window close button or ESC key
//         rl.BeginDrawing();
//         defer rl.EndDrawing();
//         rl.ClearBackground(rl.WHITE);
//         rl.DrawText("Congrats! You created your first window!", 190, 200, 20, rl.LIGHTGRAY);
//     }
// }
