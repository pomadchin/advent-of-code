const std = @import("std");
const util = @import("util");

const Str = util.Str;
const KV = struct { []const u8, i32 };

pub fn part1(input: Str, counts: anytype) !usize {
    var res: usize = 0;
    var lines = util.splitStr(input, "\n");

    var idx: usize = 1;
    while (lines.next()) |line| {
        var len = line.len;

        if (len == 0) continue;

        var s = util.split(u8, line, ": ");
        _ = s.next().?; // drop first

        var gameSets = util.splitStr(s.next().?, "; ");

        var success = true;
        outer: while (gameSets.next()) |gameSet| {
            var balls = util.splitStr(gameSet, ", ");

            var bag = util.StrMap(usize).init(util.gpa);
            defer bag.deinit();

            while (balls.next()) |ball| {
                var ballTuple = util.splitStr(ball, " ");

                var count = try util.parseInt(usize, ballTuple.next().?, 10);
                var color = ballTuple.next().?;

                try bag.put(color, count);
            }

            var bagIterator = bag.keyIterator();
            while (bagIterator.next()) |key| {
                if (counts.get(key.*).? < bag.get(key.*).?) {
                    success = false;
                    break :outer;
                }
            }
        }

        if (success) res += idx;
        idx += 1;
    }

    return res;
}

pub fn part2(input: Str) !usize {
    var res: usize = 0;
    var lines = util.splitStr(input, "\n");

    while (lines.next()) |line| {
        var len = line.len;

        if (len == 0) continue;

        var s = util.splitStr(line, ": ");
        _ = s.next().?; // drop first

        var gameSets = util.splitStr(s.next().?, "; ");

        var bag = util.StrMap(usize).init(util.gpa);
        defer bag.deinit();

        while (gameSets.next()) |gameSet| {
            var balls = util.splitStr(gameSet, ", ");

            while (balls.next()) |ball| {
                var ballTuple = util.splitStr(ball, " ");

                var count = try util.parseInt(usize, ballTuple.next().?, 10);
                var color = ballTuple.next().?;

                if (bag.get(color)) |c| {
                    if (count > c) try bag.put(color, count);
                } else {
                    try bag.put(color, count);
                }
            }
        }

        var acc: usize = 1;
        var bagIterator = bag.valueIterator();
        while (bagIterator.next()) |value| acc *= value.*;

        res += acc;
    }

    return res;
}

pub fn main() !void {}

test "example-part1" {
    const counts = std.ComptimeStringMap(i32, [_]KV{ .{ "red", 12 }, .{ "green", 13 }, .{ "blue", 14 } });

    const actual = try part1(@embedFile("example1.txt"), counts);
    const expected = @as(usize, 8);

    try std.testing.expectEqual(expected, actual);
}

test "example-part2" {
    const actual = try part2(@embedFile("example1.txt"));
    const expected = @as(usize, 2286);

    try std.testing.expectEqual(expected, actual);
}

test "input-part1" {
    const counts = std.ComptimeStringMap(i32, [_]KV{ .{ "red", 12 }, .{ "green", 13 }, .{ "blue", 14 } });

    const actual = try part1(@embedFile("input1.txt"), counts);
    const expected = @as(usize, 3059);

    try std.testing.expectEqual(expected, actual);
}

test "input-part2" {
    const actual = try part2(@embedFile("input1.txt"));
    const expected = @as(usize, 65371);

    try std.testing.expectEqual(expected, actual);
}
