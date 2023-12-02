const std = @import("std");
const util = @import("util");

const Tuple = util.Tuple;
const Str = util.Str;

pub fn part1(input: Str) !i32 {
    var lines = util.split(u8, input, "\n");
    var res: i32 = 0;

    while (lines.next()) |line| {
        var len: usize = line.len;

        if (len == 0) continue;

        var left: ?u8 = null;
        var right: ?u8 = left;

        for (0..len) |i| {
            if (left != null) break;

            if (util.isDigit(line[i])) {
                left = line[i];
                break;
            }
        }

        var i: usize = len - 1;
        while (i >= 0) : (i -= 1) {
            if (right != null) break;

            if (util.isDigit(line[i])) {
                right = line[i];
                break;
            }
        }

        var digit = try util.parseInt(i32, &[_]u8{ left.?, right.? }, 10);
        res += digit;
    }

    return res;
}

pub fn part2(input: Str) !i32 {
    const DIGITS = [9]Tuple(&.{ Str, u8 }){
        .{ "one", '1' }, .{ "two", '2' }, .{ "three", '3' }, .{ "four", '4' }, .{ "five", '5' }, .{ "six", '6' }, .{ "seven", '7' }, .{ "eight", '8' }, .{ "nine", '9' },
    };

    var lines = util.split(u8, input, "\n");
    var res: i32 = 0;

    while (lines.next()) |line| {
        var len = line.len;

        if (len == 0) continue;

        var left: ?u8 = null;
        var right: ?u8 = left;

        outer: for (0..len) |i| {
            if (left != null) break;

            if (util.isDigit(line[i])) {
                left = line[i];
                break;
            }

            for (DIGITS) |tup| {
                var str_repr = tup[0];
                if ((i + str_repr.len < len) and util.eql(u8, line[i .. i + str_repr.len], str_repr)) {
                    left = tup[1];
                    break :outer;
                }
            }
        }

        var i: usize = line.len - 1;
        outer: while (i >= 0) : (i -= 1) {
            if (right != null) break;

            if (util.isDigit(line[i])) {
                right = line[i];
                break;
            }

            for (DIGITS) |tup| {
                var str_repr = tup[0];
                if (i >= str_repr.len and util.eql(u8, line[(i - str_repr.len + 1) .. i + 1], str_repr)) {
                    right = tup[1];
                    break :outer;
                }
            }
        }

        var digit = try util.parseInt(i32, &[_]u8{ left.?, right.? }, 10);
        res += digit;
    }

    return res;
}

pub fn main() !void {}

test "example-part1" {
    const actual = try part1(@embedFile("example1.txt"));
    const expected: i32 = 142;

    try util.expectEqual(expected, actual);
}

test "example-part2" {
    const actual = try part2(@embedFile("example2.txt"));
    const expected: i32 = 281;

    try util.expectEqual(expected, actual);
}

test "puzzle-part1" {
    const actual = try part1(@embedFile("puzzle1.txt"));
    const expected: i32 = 54634;

    try util.expectEqual(expected, actual);
}

test "puzzle-part2" {
    const actual = try part2(@embedFile("puzzle2.txt"));
    const expected: i32 = 53855;

    try util.expectEqual(expected, actual);
}
