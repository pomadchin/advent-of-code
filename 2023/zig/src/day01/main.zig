const std = @import("std");
// const util = @import("util");

const Tuple = std.meta.Tuple;
const Str = []const u8;

pub fn part1(input: []const u8) !i32 {
    var lines = std.mem.split(u8, input, "\n");
    var res: i32 = 0;

    while (lines.next()) |line| {
        var n: usize = line.len;

        if (n == 0) {
            continue;
        }

        var min: ?u8 = null;
        var max: ?u8 = min;

        for (0..n) |i| {
            if (min == null and std.ascii.isDigit(line[i])) {
                min = line[i];
                break;
            }
        }

        var n1: usize = (n - 1);
        while (n1 >= 0) {
            if (max == null and std.ascii.isDigit(line[n1])) {
                max = line[n1];
                break;
            }
            n1 -= 1;
        }

        const pair = [_]u8{ min.?, max.? };
        var digit = try std.fmt.parseInt(i32, &pair, 10);
        res += digit;
    }

    return res;
}

pub fn part2(input: []const u8) !i32 {
    const DIGITS = [9]Tuple(&.{ []const u8, u8 }){
        .{ "one", '1' }, .{ "two", '2' }, .{ "three", '3' }, .{ "four", '4' }, .{ "five", '5' }, .{ "six", '6' }, .{ "seven", '7' }, .{ "eight", '8' }, .{ "nine", '9' },
    };

    var lines = std.mem.split(u8, input, "\n");
    var res: i32 = 0;

    while (lines.next()) |line| {
        var len = line.len;

        if (len == 0) {
            continue;
        }

        var min: ?u8 = null;
        var max: ?u8 = min;

        outer: for (0..len) |i| {
            if (min == null and std.ascii.isDigit(line[i])) {
                min = line[i];
                break :outer;
            }

            if (min == null) {
                // mb it's a string
                for (DIGITS) |tup| {
                    var str_repr = tup[0];
                    if ((i + str_repr.len < len) and std.mem.eql(u8, line[i .. i + str_repr.len], str_repr)) {
                        min = tup[1];
                        break :outer;
                    }
                }
            }
        }

        var i: usize = (line.len - 1);
        outer: while (i >= 0) {
            if (max == null and std.ascii.isDigit(line[i])) {
                max = line[i];
                break :outer;
            }

            if (max == null) {
                // mb it's a string
                for (DIGITS) |tup| {
                    var str_repr = tup[0];
                    if (i >= str_repr.len and std.mem.eql(u8, line[(i - str_repr.len + 1) .. i + 1], str_repr)) {
                        max = tup[1];
                        break :outer;
                    }
                }
            }
            i -= 1;
        }

        const pair = [_]u8{ min.?, max.? };

        var digit = try std.fmt.parseInt(i32, &pair, 10);
        res += digit;
    }

    return res;
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

test "example-part1" {
    const res = try part1(@embedFile("example1.txt"));
    try std.testing.expectEqual(res, 142);
}

test "example-part2" {
    const res = try part2(@embedFile("example2.txt"));
    try std.testing.expectEqual(res, 281);
}

test "puzzle-part1" {
    const res = try part1(@embedFile("puzzle1.txt"));
    try std.testing.expectEqual(res, 54634);
}

test "puzzle-part2" {
    const res = try part2(@embedFile("puzzle2.txt"));
    try std.testing.expectEqual(res, 53855);
}
