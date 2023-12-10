const std = @import("std");
const util = @import("util");
const queue = @import("queue");

const Str = util.Str;
const Allocator = std.mem.Allocator;

const Direction = util.Tuple(&.{ i32, i32 });
const Pos = util.Tuple(&.{ usize, usize });
const PosD = struct { pos: Pos, dist: usize };

fn directionOutside(d: Direction, rows: usize, cols: usize) bool {
    return d[0] < 0 or d[0] >= rows or d[1] < 0 or d[1] >= cols;
}

fn eqlDirection(l: Direction, r: Direction) bool {
    return (l[0] == r[0]) and (l[1] == r[1]);
}

fn isNegative(dir: Direction) bool {
    return (dir[0] < 0) or (dir[1] < 0);
}

fn sumPD(pos: Pos, dir: Direction) Direction {
    var pd = posToDirection(pos);
    return .{ pd[0] + dir[0], pd[1] + dir[1] };
}

fn neg(dir: Direction) Direction {
    return .{ -dir[0], -dir[1] };
}

fn posToDirection(pos: Pos) Direction {
    return .{ @as(i32, @intCast(pos[0])), @as(i32, @intCast(pos[1])) };
}

fn directionToPos(dir: Direction) Pos {
    return .{ @as(usize, @intCast(dir[0])), @as(usize, @intCast(dir[1])) };
}

fn allocArrayDirection(allocator: Allocator) std.ArrayList(Direction) {
    return std.ArrayList(Direction).init(allocator);
}

fn allocArrayStr(allocator: Allocator) std.ArrayList(Str) {
    return std.ArrayList(Str).init(allocator);
}

pub fn adjInit(allocator: Allocator) !std.AutoHashMap(u8, std.ArrayList(Direction)) {
    var map = std.AutoHashMap(u8, std.ArrayList(Direction)).init(allocator);

    var dot = allocArrayDirection(allocator);
    var v = allocArrayDirection(allocator);
    var h = allocArrayDirection(allocator);
    var l = allocArrayDirection(allocator);
    var j = allocArrayDirection(allocator);
    var _7 = allocArrayDirection(allocator);
    var f = allocArrayDirection(allocator);

    try v.appendSlice(&[_]Direction{ .{ 1, 0 }, .{ -1, 0 } });
    try h.appendSlice(&[_]Direction{ .{ 0, 1 }, .{ 0, -1 } });
    try l.appendSlice(&[_]Direction{ .{ 0, 1 }, .{ -1, 0 } });
    try j.appendSlice(&[_]Direction{ .{ 0, -1 }, .{ -1, 0 } });
    try _7.appendSlice(&[_]Direction{ .{ 0, -1 }, .{ 1, 0 } });
    try f.appendSlice(&[_]Direction{ .{ 0, 1 }, .{ 1, 0 } });

    try map.put('.', dot);
    try map.put('|', v);
    try map.put('-', h);
    try map.put('L', l);
    try map.put('J', j);
    try map.put('7', _7);
    try map.put('F', f);

    return map;
}

pub fn part1(input: Str) !usize {
    var arena = util.arena_gpa;
    defer arena.deinit();
    var allocator = arena.allocator();

    var adj = try adjInit(allocator);

    var tiles = std.AutoHashMap(Pos, u8).init(allocator);
    defer tiles.deinit();

    var rows: usize = 0;
    var cols: usize = 0;

    var lines = util.splitStr(input, "\n");
    while (lines.next()) |line| {
        cols = @max(cols, line.len);
        for (0..cols) |c| try tiles.put(.{ rows, c }, line[c]);
        rows += 1;
    }

    // std.debug.print("\nrows: {d}, cols: {d}\n", .{ rows, cols });

    var s: Pos = .{ 0, 0 };
    outer: for (0..rows) |r| {
        for (0..cols) |c| {
            var idx = .{ r, c };
            if (tiles.get(idx)) |value| {
                if (value == 'S') {
                    s = idx;
                    break :outer;
                }
            }
        }
    }

    // possible surroundings of S
    var sAdj = allocArrayDirection(allocator);
    defer sAdj.deinit();

    // adjacent to S items
    var all = allocArrayDirection(allocator);
    defer all.deinit();
    try all.appendSlice(adj.get('|').?.items);
    try all.appendSlice(adj.get('-').?.items);

    // construt S adjacent items
    for (all.items) |dp| {
        var nextD = sumPD(s, dp);
        if (isNegative(nextD)) continue;
        var nextP = directionToPos(nextD);

        if (!tiles.contains(nextP)) continue;

        for (adj.get(tiles.get(nextP).?).?.items) |dpa| {
            if (eqlDirection(neg(dp), dpa)) try sAdj.append(dp);
        }
    }

    // replace S with a corresponding pipe
    var it = adj.iterator();
    while (it.next()) |next| {
        var key = next.key_ptr.*;
        var value = next.value_ptr.*;

        if (try util.sameElementsAs(Direction, value.items, sAdj.items, allocator)) {
            try tiles.put(s, key);
            break;
        }
    }

    // std.debug.print("S: {any}, {c}\n", .{ s, tiles.get(s).? });

    var q = queue.Queue(PosD).init(allocator);
    try q.enqueue(PosD{ .pos = s, .dist = 0 });

    var dists = std.AutoHashMap(Pos, usize).init(allocator);
    defer dists.deinit();

    while (q.nonEmpty()) {
        var e: PosD = q.dequeue().?;
        var p = e.pos;
        var d = e.dist;
        if (!tiles.contains(p) or dists.contains(p)) continue;
        // std.debug.print("\np: {any}, d: {d}, items: {any}\n", .{ p, d, adj.get(tiles.get(p).?).?.items });
        try dists.put(p, d);

        for (adj.get(tiles.get(p).?).?.items) |dp| {
            var nextD = sumPD(p, dp);

            if (directionOutside(nextD, rows, cols)) continue;

            var nextP = directionToPos(nextD);

            if (!tiles.contains(nextP)) continue;

            try q.enqueue(PosD{ .pos = nextP, .dist = d + 1 });
        }
    }

    var vit = dists.valueIterator();
    var res: usize = 0;
    while (vit.next()) |item| res = @max(res, item.*);

    return res;
}

// everything for row [i] up until col (j)
// send rays out of everything unvisited to count number of crossings
fn count_crossings(tiles: *std.AutoHashMap(Pos, u8), visited: *std.AutoHashMap(Pos, void), r: usize, cols: usize) usize {
    var res: usize = 0;
    for (0..cols) |c| {
        // skip not visited
        var pos = .{ r, c };
        if (!visited.contains(pos)) continue;
        if (tiles.get(pos)) |tile| {
            switch (tile) {
                'J', 'L', '|' => res += 1,
                else => {},
            }
        }
    }

    return res;
}

// https://rosettacode.org/wiki/Ray-casting_algorithm
pub fn part2(input: Str) !usize {
    var arena = util.arena_gpa;
    defer arena.deinit();
    var allocator = arena.allocator();

    var adj = try adjInit(allocator);

    var tiles = std.AutoHashMap(Pos, u8).init(allocator);
    defer tiles.deinit();

    var rows: usize = 0;
    var cols: usize = 0;

    var lines = util.splitStr(input, "\n");
    while (lines.next()) |line| {
        cols = @max(cols, line.len);
        for (0..cols) |c| try tiles.put(.{ rows, c }, line[c]);
        rows += 1;
    }

    var s: Pos = .{ 0, 0 };
    outer: for (0..rows) |r| {
        for (0..cols) |c| {
            var idx = .{ r, c };
            if (tiles.get(idx)) |value| {
                if (value == 'S') {
                    s = idx;
                    break :outer;
                }
            }
        }
    }

    // possible surroundings of S
    var sAdj = allocArrayDirection(allocator);
    defer sAdj.deinit();

    // adjacent to S items
    var all = allocArrayDirection(allocator);
    defer all.deinit();
    try all.appendSlice(adj.get('|').?.items);
    try all.appendSlice(adj.get('-').?.items);

    // construt S adjacent items
    for (all.items) |dp| {
        var nextD = sumPD(s, dp);
        if (isNegative(nextD)) continue;
        var nextP = directionToPos(nextD);

        if (!tiles.contains(nextP)) continue;

        for (adj.get(tiles.get(nextP).?).?.items) |dpa| {
            if (eqlDirection(neg(dp), dpa)) try sAdj.append(dp);
        }
    }

    // replace S with a corresponding pipe
    var it = adj.iterator();
    while (it.next()) |next| {
        var key = next.key_ptr.*;
        var value = next.value_ptr.*;

        if (try util.sameElementsAs(Direction, value.items, sAdj.items, allocator)) {
            try tiles.put(s, key);
            break;
        }
    }

    var q = queue.Queue(Pos).init(allocator);
    try q.enqueue(s);

    var visited = std.AutoHashMap(Pos, void).init(allocator);
    defer visited.deinit();

    while (q.nonEmpty()) {
        var p: Pos = q.dequeue().?;

        if (!tiles.contains(p) or visited.contains(p)) continue;
        try visited.put(p, {});

        for (adj.get(tiles.get(p).?).?.items) |dp| {
            var nextD = sumPD(p, dp);

            if (directionOutside(nextD, rows, cols)) continue;

            var nextP = directionToPos(nextD);

            if (!tiles.contains(nextP)) continue;

            try q.enqueue(nextP);
        }
    }

    var res: usize = 0;
    for (0..rows) |r| {
        for (0..cols) |c| {
            var pos = .{ r, c };
            // use only unvisited points
            if (visited.contains(pos)) continue;
            // shoot rays to count crossings
            var x = count_crossings(&tiles, &visited, r, c);
            if (x > 0) {
                // enclosed if even
                if (x % 2 == 1) res += 1;
            }
        }
    }

    return res;
}

pub fn main() !void {}

test "example-part1" {
    const actual = try part1(@embedFile("example1.txt"));
    const expected = @as(usize, 8);

    try util.expectEqual(expected, actual);
}

test "input-part1" {
    const actual = try part1(@embedFile("input1.txt"));
    const expected = @as(usize, 6979);

    try util.expectEqual(expected, actual);
}

test "example-part2" {
    const actual = try part2(@embedFile("example2.txt"));
    const expected = @as(usize, 4);

    try util.expectEqual(expected, actual);
}

test "input-part2" {
    const actual = try part2(@embedFile("input1.txt"));
    const expected = @as(usize, 443);

    try util.expectEqual(expected, actual);
}
