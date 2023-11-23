const std = @import("std");
const util = @import("util");

pub fn solve(input: []const u8) ![3]u32 {
    var lines = std.mem.split(u8, input, "\n");
    _ = lines;

    var max: [3]u32 = .{ 0, 0, 0 };

    return max;
}

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!

    // const max = try solve(@embedFile("input.txt"));
    // const total = @reduce(.Add, @as(@Vector(3, u32), max));
    // std.debug.print("Part 1: {d}\n", .{max[0]});
    // std.debug.print("Part 2: {any} = {d}\n", .{ max, total });
}

test "test-input" {
    // const max = try solve(@embedFile("test.txt"));
    const max = try solve(&[_]u8{ 'a', 'b', 'c' });
    const total = @reduce(.Add, @as(@Vector(3, u32), max));
    try std.testing.expectEqual(max[0], 0);
    try std.testing.expectEqual(total, 0);
}
