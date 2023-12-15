const std = @import("std");
const util = @import("util");

const Str = util.Str;
const Allocator = std.mem.Allocator;

fn hash(str: Str) usize {
    var res: usize = 0;
    for (str) |c| {
        res += @as(usize, @intCast(c));
        res *= 17;
        res %= 256;
    }
    return res;
}

pub fn part1(input: Str) !usize {
    var lines = util.splitStr(input, ",");

    var res: usize = 0;
    while (lines.next()) |line| res += hash(line);

    return res;
}

pub fn part2(input: Str) !usize {
    var arena = util.arena_gpa;
    defer arena.deinit();
    var allocator = arena.allocator();

    var map = std.AutoHashMap(usize, std.StringArrayHashMap(usize)).init(allocator);
    defer map.deinit();

    var lines = util.splitStr(input, ",");
    while (lines.next()) |line| {
        if (util.sliceContains(u8, line, '=')) {
            var split = util.splitStr(line, "=");

            var label = split.next().?;
            var labelKey = hash(label);

            var s = split.next().?;

            var intBuf: [1]usize = undefined;
            var value = (try util.extractIntsIntoBuf(usize, s, &intBuf))[0];

            var box: std.StringArrayHashMap(usize) = undefined;
            if (map.contains(labelKey)) box = map.get(labelKey).? else box = std.StringArrayHashMap(usize).init(allocator);
            try box.put(label, value);

            try map.put(labelKey, box);
        } else if (util.sliceContains(u8, line, '-')) {
            var split = util.splitStr(line, "-");

            var label = split.next().?;
            var labelKey = hash(label);

            if (map.contains(labelKey)) {
                var box: std.StringArrayHashMap(usize) = map.get(labelKey).?;
                _ = box.orderedRemove(label);
                try map.put(labelKey, box);
            }
        }
    }

    var res: usize = 0;
    var it = map.iterator();
    while (it.next()) |entry| {
        var i = entry.key_ptr.*;
        var box = entry.value_ptr.*;

        for (box.values(), 0..) |val, j| res += (1 + i) * (1 + j) * val;
    }

    return res;
}

pub fn main() !void {}

test "example-part1" {
    const actual = try part1(@embedFile("example1.txt"));
    const expected = @as(usize, 1320);

    try util.expectEqual(expected, actual);
}

test "input-part1" {
    const actual = try part1(@embedFile("input1.txt"));
    const expected = @as(usize, 507291);

    try util.expectEqual(expected, actual);
}

test "example-part2" {
    const actual = try part2(@embedFile("example1.txt"));
    const expected = @as(usize, 145);

    try util.expectEqual(expected, actual);
}

test "input-part2" {
    const actual = try part2(@embedFile("input1.txt"));
    const expected = @as(usize, 296921);

    try util.expectEqual(expected, actual);
}
