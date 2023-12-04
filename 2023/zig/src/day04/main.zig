const std = @import("std");
const util = @import("util");
const bufIter = @import("buf-iter");

const Str = util.Str;
const assert = std.debug.assert;

fn pointsForMatches(matches: u32) u32 {
    if (matches == 0) {
        return 0;
    }
    return @as(u32, 1) << @intCast(matches - 1);
}

// Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
fn matchesForLine(line: Str) !u32 {
    var buf: [3]Str = undefined;
    var parts = util.splitAnyIntoBuf(line, ":|", &buf);
    assert(parts.len == 3);

    var intBufW: [50]u8 = undefined;
    var intBufN: [50]u8 = undefined;
    var winners = try util.extractIntsIntoBuf(u8, parts[1], &intBufW);
    var nums = try util.extractIntsIntoBuf(u8, parts[2], &intBufN);

    var matches: u32 = 0;
    for (nums) |num| {
        if (util.indexOf(u8, winners, num) != null) matches += 1;
    }
    return matches;
}

pub fn part1(input: Str) !u32 {
    var res: u32 = 0;
    var lines = util.splitStr(input, "\n");

    while (lines.next()) |line| res += pointsForMatches(try matchesForLine(line));

    return res;
}

pub fn part2(input: Str) !u32 {
    var res: u32 = 0;
    var lines = util.splitStr(input, "\n");

    var copiesBuf: [300]u32 = undefined;
    @memset(copiesBuf[0..], 1);
    var copies: []u32 = copiesBuf[0..];

    while (lines.next()) |line| {
        const occurrences = copies[0];
        copies = copies[1..];

        res += occurrences;

        var matches = try matchesForLine(line);

        var i: u32 = 0;
        while (i < matches) : (i += 1) copies[i] += occurrences;
    }

    return res;
}

pub fn main() !void {}

test "example-part1" {
    const actual = try part1(@embedFile("example1.txt"));
    const expected = @as(u32, 13);

    try util.expectEqual(expected, actual);
}

test "example-part2" {
    const actual = try part2(@embedFile("example1.txt"));
    const expected = @as(u32, 30);

    try util.expectEqual(expected, actual);
}

test "input-part1" {
    const actual = try part1(@embedFile("input1.txt"));
    const expected = @as(u32, 27845);

    try util.expectEqual(expected, actual);
}

test "input-part2" {
    const actual = try part2(@embedFile("input1.txt"));
    const expected = @as(u32, 9496801);

    try util.expectEqual(expected, actual);
}
