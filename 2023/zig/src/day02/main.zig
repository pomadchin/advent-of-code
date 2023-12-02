const std = @import("std");
const util = @import("util");

const Str = util.Str;

const Game = struct {
    red: u32,
    green: u32,
    blue: u32,
};

// 12 red cubes, 13 green cubes, and 14 blue cubes
const COUNTS = Game{ .red = 12, .green = 13, .blue = 14 };

pub fn parseGame(line: Str) !Game {
    var game = Game{ .red = 0, .green = 0, .blue = 0 };
    var balls = util.splitStr(line, ", ");

    var intBuf: [1]u32 = undefined;
    while (balls.next()) |part| {
        var nums = try util.extractIntsIntoBuf(u32, part, &intBuf);
        util.assert(nums.len == 1);
        const num = nums[0];

        if (std.mem.endsWith(u8, part, "green")) {
            game.green = num;
        } else if (std.mem.endsWith(u8, part, "blue")) {
            game.blue = num;
        } else if (std.mem.endsWith(u8, part, "red")) {
            game.red = num;
        } else {
            unreachable;
        }
    }

    return game;
}

pub fn part1(input: Str) !u32 {
    var res: u32 = 0;
    var lines = util.splitStr(input, "\n");

    var idx: u32 = 1;
    while (lines.next()) |line| {
        var len = line.len;

        if (len == 0) continue;

        var split = util.splitStrDropFirst(line, ": ");
        var gameSets = util.splitStr(split.next().?, "; ");

        var success = true;
        while (gameSets.next()) |gameSet| {
            var game = try parseGame(gameSet);

            if (game.red > COUNTS.red or game.green > COUNTS.green or game.blue > COUNTS.blue) {
                success = false;
                break;
            }
        }

        if (success) res += idx;
        idx += 1;
    }

    return res;
}

pub fn part2(input: Str) !u32 {
    var res: u32 = 0;
    var lines = util.splitStr(input, "\n");

    while (lines.next()) |line| {
        var len = line.len;

        if (len == 0) continue;

        var split = util.splitStrDropFirst(line, ": ");
        var gameSets = util.splitStr(split.next().?, "; ");

        var gameMax = Game{ .red = 0, .green = 0, .blue = 0 };
        while (gameSets.next()) |gameSet| {
            const game = try parseGame(gameSet);

            gameMax.red = @max(game.red, gameMax.red);
            gameMax.green = @max(game.green, gameMax.green);
            gameMax.blue = @max(game.blue, gameMax.blue);
        }

        res += (gameMax.red * gameMax.green * gameMax.blue);
    }

    return res;
}

pub fn main() !void {}

test "example-part1" {
    const actual = try part1(@embedFile("example1.txt"));
    const expected = @as(u32, 8);

    try util.expectEqual(expected, actual);
}

test "example-part2" {
    const actual = try part2(@embedFile("example1.txt"));
    const expected = @as(u32, 2286);

    try util.expectEqual(expected, actual);
}

test "input-part1" {
    const actual = try part1(@embedFile("input1.txt"));
    const expected = @as(u32, 3059);

    try util.expectEqual(expected, actual);
}

test "input-part2" {
    const actual = try part2(@embedFile("input1.txt"));
    const expected = @as(u32, 65371);

    try util.expectEqual(expected, actual);
}
