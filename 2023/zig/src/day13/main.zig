const std = @import("std");
const util = @import("util");

const Str = util.Str;
const Allocator = std.mem.Allocator;

fn checkRows(grid: std.ArrayList(Str), rowU: usize, rowD: usize) bool {
    var items = grid.items;
    var rows = items.len;

    var ru = rowU;
    var rd = rowD;
    while (ru >= 0 and rd < rows) {
        if (!std.mem.eql(u8, items[ru], items[rd])) return false;
        if (ru == 0) break;

        ru -= 1;
        rd += 1;
    }

    return true;
}

fn checkCols(grid: std.ArrayList(Str), colL: usize, colR: usize, allocator: Allocator) !bool {
    var items = grid.items;
    var cols = items[0].len;

    var cl = colL;
    var cr = colR;
    while (cl >= 0 and cr < cols) {
        var columnL = try util.getColumn(u8, cl, grid, allocator);
        defer allocator.free(columnL);

        var columnR = try util.getColumn(u8, cr, grid, allocator);
        defer allocator.free(columnL);

        if (!std.mem.eql(u8, columnL, columnR)) return false;
        if (cl == 0) break;

        cl -= 1;
        cr += 1;
    }

    return true;
}

fn checkRowsDiff(grid: std.ArrayList(Str), rowU: usize, rowD: usize) bool {
    var items = grid.items;
    var rows = items.len;

    var ru = rowU;
    var rd = rowD;
    var diff: usize = 0;
    while (ru >= 0 and rd < rows) {
        diff += util.sliceDiffCount(u8, items[ru], items[rd]);
        if (ru == 0) break;

        ru -= 1;
        rd += 1;
    }

    return diff == 1;
}

fn checkColsDiff(grid: std.ArrayList(Str), colL: usize, colR: usize, allocator: Allocator) !bool {
    var items = grid.items;
    var cols = items[0].len;

    var cl = colL;
    var cr = colR;
    var diff: usize = 0;
    while (cl >= 0 and cr < cols) {
        var columnL = try util.getColumn(u8, cl, grid, allocator);
        defer allocator.free(columnL);

        var columnR = try util.getColumn(u8, cr, grid, allocator);
        defer allocator.free(columnL);

        diff += util.sliceDiffCount(u8, columnL, columnR);
        if (cl == 0) break;

        cl -= 1;
        cr += 1;
    }

    return diff == 1;
}

fn buildGridList(input: Str, allocator: Allocator) !std.ArrayList(std.ArrayList(Str)) {
    var lines = util.splitStr(input, "\n");

    var grids = std.ArrayList(std.ArrayList(Str)).init(allocator);

    var currGrid = std.ArrayList(Str).init(allocator);
    defer currGrid.clearAndFree();

    while (lines.next()) |line| {
        if (line.len == 0) {
            try grids.append(try currGrid.clone());
            currGrid.clearRetainingCapacity();
            continue;
        }

        try currGrid.append(line);
    }

    if (currGrid.capacity > 0) {
        try grids.append(try currGrid.clone());
        currGrid.clearRetainingCapacity();
    }

    return grids;
}

pub fn part1(input: Str) !usize {
    var arena = util.arena_gpa;
    defer arena.deinit();
    var allocator = arena.allocator();

    var grids = try buildGridList(input, allocator);
    defer grids.clearAndFree();

    var res: usize = 0;
    for (grids.items) |grid| {
        var rows = grid.items.len;
        var cols = grid.items[0].len;
        var solved = false;
        for (0..rows - 1) |r| {
            if (checkRows(grid, r, r + 1)) {
                res += (r + 1) * 100;
                solved = true;
                break;
            }
        }

        if (solved) continue;

        for (0..cols - 1) |c| {
            if (try checkCols(grid, c, c + 1, allocator)) {
                res += (c + 1);
                break;
            }
        }
    }

    return res;
}

pub fn part2(input: Str) !usize {
    var arena = util.arena_gpa;
    defer arena.deinit();
    var allocator = arena.allocator();

    var grids = try buildGridList(input, allocator);
    defer grids.clearAndFree();

    var res: usize = 0;
    for (grids.items) |grid| {
        var rows = grid.items.len;
        var cols = grid.items[0].len;
        var solved = false;
        for (0..rows - 1) |r| {
            if (checkRowsDiff(grid, r, r + 1)) {
                res += (r + 1) * 100;
                solved = true;
                break;
            }
        }

        if (solved) continue;

        for (0..cols - 1) |c| {
            if (try checkColsDiff(grid, c, c + 1, allocator)) {
                res += (c + 1);
                break;
            }
        }
    }

    return res;
}

pub fn main() !void {}

test "example-part1" {
    const actual = try part1(@embedFile("example1.txt"));
    const expected = @as(usize, 405);

    try util.expectEqual(expected, actual);
}

test "input-part1" {
    const actual = try part1(@embedFile("input1.txt"));
    const expected = @as(usize, 33356);

    try util.expectEqual(expected, actual);
}

test "example-part2" {
    const actual = try part2(@embedFile("example1.txt"));
    const expected = @as(usize, 400);

    try util.expectEqual(expected, actual);
}

test "input-part2" {
    const actual = try part2(@embedFile("input1.txt"));
    const expected = @as(usize, 28475);

    try util.expectEqual(expected, actual);
}
