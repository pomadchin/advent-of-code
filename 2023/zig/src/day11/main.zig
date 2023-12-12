const std = @import("std");
const util = @import("util");

const Str = util.Str;
const Allocator = std.mem.Allocator;

const Pos = util.Tuple(&.{ usize, usize });
const PosI = util.Tuple(&.{ i64, i64 });

const GridBounds = struct { rows: usize, cols: usize };

fn posToI(p: Pos) PosI {
    return .{ @as(i64, @intCast(p[0])), @as(i64, @intCast(p[1])) };
}

fn dist(p1: Pos, p2: Pos) usize {
    var p1i = posToI(p1);
    var p2i = posToI(p2);

    return @as(usize, @intCast(util.abs(p1i[0] - p2i[0]) + util.abs(p1i[1] - p2i[1])));
}

fn buildGrid(input: Str, grid: *std.AutoHashMap(Pos, u8)) !GridBounds {
    var rows: usize = 0;
    var cols: usize = 0;

    var lines = util.splitStr(input, "\n");
    while (lines.next()) |line| {
        cols = @max(cols, line.len);
        for (0..cols) |c| try grid.put(.{ rows, c }, line[c]);
        rows += 1;
    }

    return GridBounds{ .rows = rows, .cols = cols };
}

fn emptyRows(grid: *std.AutoHashMap(Pos, u8), gridBounds: GridBounds, allocator: Allocator) !std.ArrayList(usize) {
    var res = std.ArrayList(usize).init(allocator);
    outer: for (0..gridBounds.rows) |r| {
        for (0..gridBounds.cols) |c| {
            // galaxy found skip
            if (grid.get(.{ r, c })) |v| if (v == '#') continue :outer;
        }

        try res.append(r);
    }
    return res;
}

fn emptyCols(grid: *std.AutoHashMap(Pos, u8), gridBounds: GridBounds, allocator: Allocator) !std.ArrayList(usize) {
    var res = std.ArrayList(usize).init(allocator);
    outer: for (0..gridBounds.cols) |c| {
        for (0..gridBounds.rows) |r| {
            // galaxy found skip
            if (grid.get(.{ r, c })) |v| if (v == '#') continue :outer;
        }

        try res.append(c);
    }
    return res;
}

fn galaxyPoints(grid: *std.AutoHashMap(Pos, u8), gridBounds: GridBounds, allocator: Allocator) !std.ArrayList(Pos) {
    var res = std.ArrayList(Pos).init(allocator);
    for (0..gridBounds.rows) |r| {
        for (0..gridBounds.cols) |c| {
            var p = .{ r, c };
            if (grid.get(p)) |v| {
                if (v == '#') try res.append(p);
            }
        }
    }
    return res;
}

pub fn solve(input: Str, multiplier: usize) !usize {
    var arena = util.arena_gpa;
    defer arena.deinit();
    var allocator = arena.allocator();

    var grid = std.AutoHashMap(Pos, u8).init(allocator);
    defer grid.deinit();

    var gridBounds = try buildGrid(input, &grid);

    var rowsE = try emptyRows(&grid, gridBounds, allocator);
    var colsE = try emptyCols(&grid, gridBounds, allocator);
    var points = try galaxyPoints(&grid, gridBounds, allocator);

    var combinationsList = try util.combinations(Pos, 2, points.items, allocator);

    var res: usize = 0;
    for (combinationsList.items) |item| {
        var p = item.items[0];
        var q = item.items[1];

        var emptyRowsIntersectionLen = util.listRangeIntersectionCount(usize, &rowsE, @min(p[0], q[0]), @max(p[0], q[0]) + 1);
        var emptyColsIntersectionLen = util.listRangeIntersectionCount(usize, &colsE, @min(p[1], q[1]), @max(p[1], q[1]) + 1);

        // dist = (x2 - x1) + (y2 - y1) + len(between rows that have no #) + len(rows that have no #)
        res += (dist(p, q) + multiplier * emptyRowsIntersectionLen + multiplier * emptyColsIntersectionLen);
    }

    return res;
}

pub fn part1(input: Str) !usize {
    return try solve(input, 1);
}

pub fn part2(input: Str) !usize {
    return try solve(input, 1000000 - 1);
}

pub fn main() !void {}

test "example-part1" {
    const actual = try part1(@embedFile("example1.txt"));
    const expected = @as(usize, 374);

    try util.expectEqual(expected, actual);
}

test "input-part1" {
    const actual = try part1(@embedFile("input1.txt"));
    const expected = @as(usize, 10033566);

    try util.expectEqual(expected, actual);
}

test "example-part2" {
    const actual = try part2(@embedFile("example1.txt"));
    const expected = @as(usize, 82000210);

    try util.expectEqual(expected, actual);
}

test "input-part2" {
    const actual = try part2(@embedFile("input1.txt"));
    const expected = @as(usize, 560822911938);

    try util.expectEqual(expected, actual);
}
