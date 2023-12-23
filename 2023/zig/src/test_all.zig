const std = @import("std");

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("zig build run_all is a noop, try running zig build test_all \n", .{});

    try bw.flush(); // don't forget to flush!
}

test {
    _ = @import("util");
    _ = @import("buf-iter");
    _ = @import("queue");
    _ = @import("deque");
    _ = @import("stack");
    _ = @import("main.zig");
    _ = @import("day01/main.zig");
    _ = @import("day02/main.zig");
    _ = @import("day03/main.zig");
    _ = @import("day04/main.zig");
    _ = @import("day05/main.zig");
    _ = @import("day06/main.zig");
    _ = @import("day07/main.zig");
    _ = @import("day08/main.zig");
    _ = @import("day09/main.zig");
    _ = @import("day10/main.zig");
    _ = @import("day11/main.zig");
    _ = @import("day12/main.zig");
    _ = @import("day13/main.zig");
    _ = @import("day14/main.zig");
    _ = @import("day15/main.zig");
    _ = @import("day16/main.zig");
    _ = @import("day17/main.zig");
    _ = @import("day18/main.zig");
    _ = @import("day19/main.zig");
    _ = @import("day20/main.zig");
    _ = @import("day21/main.zig");
    _ = @import("day22/main.zig");
    _ = @import("day23/main.zig");
    _ = @import("day24/main.zig");
    _ = @import("day25/main.zig");
}
