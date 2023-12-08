const std = @import("std");
const util = @import("util");
const queue = @import("queue");

const Str = util.Str;
const assert = util.assert;

pub fn part1(input: Str) !i64 {
    var lines = util.splitStr(input, "\n");
    var lineTime = lines.next().?;
    var lineDist = lines.next().?;
    var timeBuf: [5]i64 = undefined;
    var distBuf: [5]i64 = undefined;
    var times = try util.extractIntsIntoBuf(i64, lineTime, &timeBuf);
    var distances = try util.extractIntsIntoBuf(i64, lineDist, &distBuf);

    var res: i64 = 1;
    for (times, 0..) |time, i| {
        var count: i64 = 0;

        var hold: i64 = 0;
        var dist = distances[i];
        while (hold < time) : (hold += 1) {
            if (((time - hold) * hold) > dist) count += 1;
        }

        res *= count;
    }

    return res;
}

pub fn part2(input: Str) !i64 {
    var lines = util.splitStr(input, "\n");
    var lineTime = lines.next().?;
    var lineDist = lines.next().?;
    var timeBuf: [5]i64 = undefined;
    var distBuf: [5]i64 = undefined;
    var times = try util.extractIntsIntoBuf(i64, lineTime, &timeBuf);
    var distances = try util.extractIntsIntoBuf(i64, lineDist, &distBuf);

    var time: f64 = @floatFromInt(times[0]);
    var dist: f64 = @floatFromInt(distances[0]);

    // speed after the button is pressed for t milliseconds is t, and distance is speed * time
    // equation is forme (total time - time) * time > distance or (tt - t)t > d:
    // tt * t - t * t - d = 0 =>
    // t^2 - t * tt + d || ax^2 + bx + c = 0 || D = b^2 − 4ac || x1,2 = (-b +- sqrt(D))/ 2a || a = 1; b = -tt; c = +d
    // t = (t +- sqrt(t * t - 4d)) / 2
    // res = floor(t2) - ceil(t1) + 1

    var t1: i64 = @intFromFloat(@ceil((time - std.math.sqrt(time * time - 4 * dist)) / 2));
    var t2: i64 = @intFromFloat(@floor((time + std.math.sqrt(time * time - 4 * dist)) / 2));

    return t2 - t1 + 1;
}

pub fn main() !void {}

test "example-part1" {
    const actual = try part1(@embedFile("example1.txt"));
    const expected = @as(i64, 288);

    try util.expectEqual(expected, actual);
}

test "example-part2" {
    // const actual = try part1(@embedFile("example2.txt"));
    const actual = try part2(@embedFile("example2.txt"));
    const expected = @as(i64, 71503);

    try util.expectEqual(expected, actual);
}

test "input-part1" {
    const actual = try part1(@embedFile("input1.txt"));
    const expected = @as(i64, 2612736);

    try util.expectEqual(expected, actual);
}

test "input-part2" {
    // const actual = try part1(@embedFile("example2.txt"));
    const actual = try part2(@embedFile("input2.txt"));
    const expected = @as(i64, 29891250);

    try util.expectEqual(expected, actual);
}
