const std = @import("std");
const util = @import("util");

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

    pub fn add(self: *const Pos, other: Pos) Pos {
        return Pos{ .r = self.r + other.r, .c = self.c + other.c };
    }

    pub fn within(self: *const Pos, rows: usize, cols: usize) bool {
        var rowsi = @as(i64, @intCast(rows));
        var colsi = @as(i64, @intCast(cols));

        return self.r >= 0 and self.r < rowsi and self.c >= 0 and self.c < colsi;
    }
};

const PL = struct { p: Pos, l: usize };
const PLSet = std.AutoHashMap(Pos, void);
const PosA = std.AutoHashMap(Pos, std.AutoArrayHashMap(Pos, usize));

const TilesBuild = struct { start: Pos, end: Pos, rows: usize, cols: usize };

var nU = [_]Pos{Pos.of(-1, 0)};
var nD = [_]Pos{Pos.of(1, 0)};
var nR = [_]Pos{Pos.of(0, 1)};
var nL = [_]Pos{Pos.of(0, -1)};
var nA = [_]Pos{ Pos.of(0, -1), Pos.of(0, 1), Pos.of(-1, 0), Pos.of(1, 0) };
var nE = [_]Pos{};

fn neighbors(c: u8) []Pos {
    switch (c) {
        '^' => return &nU,
        'v' => return &nD,
        '>' => return &nR,
        '<' => return &nL,
        '.' => return &nA,
        else => return &nE,
    }
}

fn buildTiles(input: Str, tiles: *std.AutoHashMap(Pos, u8)) !TilesBuild {
    var rows: usize = 0;
    var cols: usize = 0;

    var lines = util.splitStr(input, "\n");
    while (lines.next()) |line| {
        cols = @max(cols, line.len);
        for (0..cols) |c| {
            if (line[c] != '#') try tiles.put(Pos.ofU(rows, c), line[c]);
        }
        rows += 1;
    }

    var start: Pos = Pos.ofU(0, 1);
    var end: Pos = Pos.ofU(rows - 1, cols - 2);

    return TilesBuild{ .start = start, .end = end, .rows = rows, .cols = cols };
}

fn dfs(v: Pos, visited: *PLSet, tiles: *std.AutoHashMap(Pos, u8), end: Pos) !usize {
    if (!tiles.contains(v) or std.meta.eql(v, end)) return 0;

    var res: usize = 0;

    try visited.put(v, {});
    for (neighbors(tiles.get(v).?)) |n| {
        var u = v.add(n);
        if (!tiles.contains(u) or visited.contains(u)) continue;
        if (tiles.get(u).? == '#') continue;

        res = @max(res, 1 + (try dfs(u, visited, tiles, end)));
    }
    _ = visited.remove(v);

    return res;
}

pub fn part1(input: Str) !usize {
    var arena = util.arena_gpa;
    defer arena.deinit();
    var allocator = arena.allocator();

    var tiles = std.AutoHashMap(Pos, u8).init(allocator);
    defer tiles.deinit();

    var build = try buildTiles(input, &tiles);
    var start = build.start;
    var end = build.end;

    var visited = PLSet.init(allocator);
    defer visited.deinit();

    return try dfs(start, &visited, &tiles, end);
}

fn dfs2(v: Pos, visited: *PLSet, tiles: *std.AutoHashMap(Pos, u8), adj: *PosA, end: Pos) !usize {
    if (!tiles.contains(v) or std.meta.eql(v, end)) return 0;

    var res: usize = 0;

    try visited.put(v, {});
    var neighborsV: std.AutoArrayHashMap(Pos, usize) = adj.get(v).?;
    var it = neighborsV.iterator();
    while (it.next()) |entry| {
        var n = entry.key_ptr.*;
        var dist = entry.value_ptr.*;

        if (visited.contains(n)) continue;

        res = @max(res, dist + try dfs2(n, visited, tiles, adj, end));
    }
    _ = visited.remove(v);

    return res;
}

pub fn part2(input: Str) !usize {
    var arena = util.arena_gpa;
    defer arena.deinit();
    var allocator = arena.allocator();

    var tiles = std.AutoHashMap(Pos, u8).init(allocator);
    defer tiles.deinit();

    var build = try buildTiles(input, &tiles);
    var start = build.start;
    var end = build.end;

    var adj = PosA.init(allocator);

    {
        var it = tiles.keyIterator();
        while (it.next()) |p| try adj.put(p.*, std.AutoArrayHashMap(Pos, usize).init(allocator));
    }

    {
        var it = tiles.keyIterator();
        while (it.next()) |p| {
            var m = adj.get(p.*).?;
            for (nA) |nq| {
                var q = p.*.add(nq);
                if (!tiles.contains(q)) continue;
                try m.put(q, 1);
            }
            try adj.put(p.*, m);
        }
    }

    {
        while (true) {
            var found = false;
            var it = adj.iterator();
            while (it.next()) |entry| {
                var p = entry.key_ptr.*;
                var qs = entry.value_ptr.*;

                if (qs.count() != 2) continue;
                found = true;

                var q1 = adj.get(p).?.keys()[0];
                var q2 = adj.get(p).?.keys()[1];

                var r = adj.get(q1).?.get(p).? + adj.get(p).?.get(q2).?;

                {
                    var m = adj.get(q1).?;
                    try m.put(q2, r);
                    try adj.put(q1, m);
                }

                {
                    var m = adj.get(q2).?;
                    try m.put(q1, r);
                    try adj.put(q2, m);
                }

                _ = adj.remove(p);

                {
                    var m = adj.get(q1).?;
                    _ = m.orderedRemove(p);
                    try adj.put(q1, m);
                }

                {
                    var m = adj.get(q2).?;
                    _ = m.orderedRemove(p);
                    try adj.put(q2, m);
                }

                break;
            }

            if (!found) break;
        }
    }

    var visited = PLSet.init(allocator);
    defer visited.deinit();

    return try dfs2(start, &visited, &tiles, &adj, end);
}

pub fn main() !void {}

test "example-part1" {
    const actual = try part1(@embedFile("example1.txt"));
    const expected = @as(usize, 94);

    try util.expectEqual(expected, actual);
}

test "input-part1" {
    const actual = try part1(@embedFile("input1.txt"));
    const expected = @as(usize, 2218);

    try util.expectEqual(expected, actual);
}

test "example-part2" {
    const actual = try part2(@embedFile("example1.txt"));
    const expected = @as(usize, 154);

    try util.expectEqual(expected, actual);
}

// takes ~20s with no -Doptimize=ReleaseFast flag
// takes ~6s with -Doptimize=ReleaseFast
// skip to make CI happy
// test "input-part2" {
//     const actual = try part2(@embedFile("input1.txt"));
//     const expected = @as(usize, 6674);

//     try util.expectEqual(expected, actual);
// }
