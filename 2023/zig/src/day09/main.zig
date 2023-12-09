const std = @import("std");
const util = @import("util");

const Str = util.Str;
const Allocator = std.mem.Allocator;

pub fn seq(ints: std.ArrayList(i64), allocator: Allocator) !i64 {
    if (util.forAll(i64, ints.items, 0)) return 0;

    var diffs = std.ArrayList(i64).init(allocator);
    var i: usize = 0;
    while (i + 1 < ints.items.len) : (i += 1) {
        try diffs.append(ints.items[i + 1] - ints.items[i]);
    }

    return ints.getLast() + try seq(diffs, allocator);
}

pub fn part1(input: Str) !i64 {
    var arena = util.arena_gpa;
    defer arena.deinit();
    var allocator = arena.allocator();

    var res: i64 = 0;

    var lines = util.splitStr(input, "\n");
    while (lines.next()) |line| {
        var intBuf: [50]i64 = undefined;
        var ints = try util.extractIntsIntoBuf(i64, line, &intBuf);

        var intsList = std.ArrayList(i64).init(allocator);
        defer intsList.deinit();
        try intsList.appendSlice(ints);

        res += try seq(intsList, allocator);
    }

    return res;
}

pub fn part2(input: Str) !i64 {
    var arena = util.arena_gpa;
    defer arena.deinit();
    var allocator = arena.allocator();

    var res: i64 = 0;

    var lines = util.splitStr(input, "\n");
    while (lines.next()) |line| {
        var intBuf: [50]i64 = undefined;
        var ints = try util.extractIntsIntoBuf(i64, line, &intBuf);

        var intBufR: [50]i64 = undefined;
        var intsR = util.reverse(i64, &intBufR, ints);

        var intsList = std.ArrayList(i64).init(allocator);
        defer intsList.deinit();
        try intsList.appendSlice(intsR);

        res += try seq(intsList, allocator);
    }

    return res;
}

pub fn main() !void {}

test "example-part1" {
    const actual = try part1(@embedFile("example1.txt"));
    const expected = @as(i64, 114);

    try util.expectEqual(expected, actual);
}

test "input-part1" {
    const actual = try part1(@embedFile("input1.txt"));
    const expected = @as(i64, 1581679977);

    try util.expectEqual(expected, actual);
}

test "example-part2" {
    const actual = try part2(@embedFile("example1.txt"));
    const expected = @as(i64, 2);

    try util.expectEqual(expected, actual);
}

test "input-part2" {
    const actual = try part2(@embedFile("input1.txt"));
    const expected = @as(i64, 889);

    try util.expectEqual(expected, actual);
}
