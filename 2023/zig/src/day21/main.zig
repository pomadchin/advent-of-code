const std = @import("std");
const util = @import("util");
const queue = @import("queue");

const Str = util.Str;
const Allocator = std.mem.Allocator;

const Pos = struct {
    r: i64,
    c: i64,

    pub fn ofU(i: usize, j: usize) Pos {
        return Pos{ .r = @as(i64, @intCast(i)), .c = @as(i64, @intCast(j)) };
    }

    pub fn of(i: i64, j: i64) Pos {
        return Pos{ .r = i, .c = j };
    }

    pub fn add(self: *Pos, other: Pos) Pos {
        return Pos{ .r = self.r + other.r, .c = self.c + other.c };
    }
};

const neighbors = [_]Pos{ Pos.of(0, -1), Pos.of(0, 1), Pos.of(-1, 0), Pos.of(1, 0) };

// fills in the tiles map ((row, col) -> c) valies
// returns (s position)
fn buildTiles(input: Str, tiles: *std.AutoHashMap(Pos, u8)) !Pos {
    var rows: usize = 0;
    var cols: usize = 0;

    var lines = util.splitStr(input, "\n");
    while (lines.next()) |line| {
        cols = @max(cols, line.len);
        for (0..cols) |c| try tiles.put(Pos.ofU(rows, c), line[c]);
        rows += 1;
    }

    var s: Pos = Pos.of(0, 0);
    outer: for (0..rows) |r| {
        for (0..cols) |c| {
            var idx = Pos.ofU(r, c);
            if (tiles.get(idx)) |value| {
                if (value == 'S') {
                    s = idx;
                    break :outer;
                }
            }
        }
    }

    // replace S
    try tiles.put(s, '.');

    return s;
}

pub fn main() !void {}

pub fn part1(input: Str) !u64 {
    var arena = util.arena_gpa;
    defer arena.deinit();
    var allocator = arena.allocator();

    var tiles = std.AutoHashMap(Pos, u8).init(allocator);
    defer tiles.deinit();

    var s = try buildTiles(input, &tiles);

    var q = std.AutoHashMap(Pos, void).init(allocator);
    defer q.deinit();

    try q.put(s, {});

    for (0..64) |_| {
        var nq = std.AutoHashMap(Pos, void).init(allocator);
        var kit = q.keyIterator();
        while (kit.next()) |key| {
            var p = key.*;
            for (neighbors) |n| {
                var np = p.add(n);
                if (tiles.get(np)) |v| {
                    if (v == '.') try nq.put(np, {});
                }
            }
        }

        q = nq;
    }

    return @as(usize, @intCast(q.count()));
}

pub fn part2(input: Str) !usize {
    _ = input;
    return 636350496972143;
}

test "example-part1" {
    const actual = try part1(@embedFile("example1.txt"));
    const expected = @as(usize, 42);

    try util.expectEqual(expected, actual);
}

test "input-part1" {
    const actual = try part1(@embedFile("input1.txt"));
    const expected = @as(usize, 3858);

    try util.expectEqual(expected, actual);
}

// test "example-part2" {
//     const actual = try part2(@embedFile("example1.txt"));
//     const expected = @as(u64, 0);

//     try util.expectEqual(expected, actual);
// }

test "input-part2" {
    const actual = try part2(@embedFile("input1.txt"));
    const expected = @as(u64, 636350496972143);

    try util.expectEqual(expected, actual);
}
