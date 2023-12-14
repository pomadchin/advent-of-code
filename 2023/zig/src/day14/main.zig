const std = @import("std");
const util = @import("util");

const Str = util.Str;
const Allocator = std.mem.Allocator;

fn buildGrid(input: Str, allocator: Allocator) !std.ArrayList(Str) {
    var lines = util.splitStr(input, "\n");

    var grid = std.ArrayList(Str).init(allocator);

    while (lines.next()) |line| {
        if (line.len == 0) break;
        try grid.append(line);
    }

    return grid;
}

// north = west after transpose
pub fn west(grid: *std.ArrayList(Str), allocator: Allocator) !std.ArrayList(Str) {
    var res = std.ArrayList(Str).init(allocator);
    var items = grid.items;
    var cols = items[0].len;

    // transposed col = row
    for (items) |row| {
        // shift row to the left, mk a new row
        var rown = try allocator.alloc(u8, cols);
        var p: usize = 0;
        for (0..cols) |i| {
            rown[i] = row[i];

            if (row[i] == '#') p = i + 1;

            if (row[i] == 'O') {
                rown[i] = '.';
                rown[p] = 'O';
                p += 1;
            }
        }

        try res.append(rown);
    }

    return res;
}

pub fn part1(input: Str) !usize {
    var arena = util.arena_gpa;
    defer arena.deinit();
    var allocator = arena.allocator();

    var grid = try buildGrid(input, allocator);
    grid = try util.transposeConst(u8, grid, allocator);
    grid = try west(&grid, allocator);

    var res: usize = 0;
    for (grid.items) |row| {
        var cols = row.len;
        for (0..cols) |i| {
            if (row[i] == 'O') res += cols - i;
        }
    }

    return res;
}

pub fn part2(input: Str) !usize {
    var arena = util.arena_gpa;
    defer arena.deinit();
    var allocator = arena.allocator();

    var grid = try buildGrid(input, allocator);
    defer grid.deinit();

    var memo = std.StringHashMap(usize).init(allocator);
    defer memo.deinit();

    var i: usize = 0;
    while (i < 1000000000) {
        var str = try util.arrayListToStr(grid, allocator);

        // skip cycles
        if (memo.get(str)) |state| {
            var cycle: usize = i - state;
            i += (1000000000 - i) / cycle * cycle;
            if (i == 1000000000) break;
        }

        try memo.put(str, i);

        // north, then west, then south, then east
        // north
        grid = try util.transposeConst(u8, grid, allocator);
        grid = try west(&grid, allocator);
        // turn north back
        grid = try util.transposeConst(u8, grid, allocator);

        // west
        grid = try west(&grid, allocator);

        // south
        grid = try util.reverseList(Str, grid, allocator);
        grid = try util.transposeConst(u8, grid, allocator);
        grid = try west(&grid, allocator);
        // turn south back
        grid = try util.transposeConst(u8, grid, allocator);
        grid = try util.reverseList(Str, grid, allocator);

        // east
        grid = try util.reverseCols(u8, grid, allocator);
        grid = try west(&grid, allocator);
        // turn east back
        grid = try util.reverseCols(u8, grid, allocator);

        i += 1;
    }

    // north
    grid = try util.transposeConst(u8, grid, allocator);

    var res: usize = 0;
    for (grid.items) |row| {
        var cols = row.len;
        for (0..cols) |c| {
            if (row[c] == 'O') res += cols - c;
        }
    }

    return res;
}

pub fn main() !void {}

test "example-part1" {
    const actual = try part1(@embedFile("example1.txt"));
    const expected = @as(usize, 136);

    try util.expectEqual(expected, actual);
}

test "input-part1" {
    const actual = try part1(@embedFile("input1.txt"));
    const expected = @as(usize, 106517);

    try util.expectEqual(expected, actual);
}

test "example-part2" {
    const actual = try part2(@embedFile("example1.txt"));
    const expected = @as(usize, 64);

    try util.expectEqual(expected, actual);
}

test "input-part2" {
    const actual = try part2(@embedFile("input1.txt"));
    const expected = @as(usize, 79723);

    try util.expectEqual(expected, actual);
}
