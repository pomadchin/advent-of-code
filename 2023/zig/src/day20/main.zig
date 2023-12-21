const std = @import("std");
const util = @import("util");
const queue = @import("queue");

const Str = util.Str;
const Allocator = std.mem.Allocator;

fn send(x: Str, y: Str, high: bool, counts: *[2]u64, conjState: *std.StringHashMap(std.StringHashMap(bool)), q: *queue.Queue(util.Tuple(&.{ Str, bool })), allocator: Allocator) !void {
    var idx: usize = if (high) 1 else 0;
    counts[idx] += 1;
    var mapO = conjState.get(y);
    if (mapO == null) mapO = std.StringHashMap(bool).init(allocator);
    var map = mapO.?;

    try map.put(x, high);
    try conjState.put(y, map);
    try q.enqueue(.{ y, high });
}

pub fn part1(input: Str) !u64 {
    var arena = util.arena_gpa;
    defer arena.deinit();
    var allocator = arena.allocator();

    var adj = std.StringHashMap(util.Tuple(&.{ u8, []Str })).init(allocator);
    var conjState = std.StringHashMap(std.StringHashMap(bool)).init(allocator);
    var flipFlopState = std.StringHashMap(bool).init(allocator);

    var lines = util.splitStr(input, "\n");
    while (lines.next()) |line| {
        var split = util.splitStr(line, " -> ");
        var name = split.next().?;

        var destStr = split.next().?;
        var destStrSplit = util.splitStr(destStr, ", ");
        var destList = std.ArrayList(Str).init(allocator);
        while (destStrSplit.next()) |next| try destList.append(next);
        try adj.put(name[1..name.len], .{ name[0], destList.items });

        for (destList.items) |y| {
            var mapO = conjState.get(y);
            if (mapO == null) mapO = std.StringHashMap(bool).init(allocator);
            var map = mapO.?;

            try map.put(name[1..name.len], false);
            try conjState.put(y, map);
        }
    }

    // 0 = false; 1 = true
    var counts = [2]u64{ 0, 0 };
    var q = queue.Queue(util.Tuple(&.{ Str, bool })).init(allocator);

    for (0..1000) |_| {
        try send("button", "roadcaster", false, &counts, &conjState, &q, allocator);

        while (q.nonEmpty()) {
            var tup: util.Tuple(&.{ Str, bool }) = q.dequeue().?;
            var x = tup[0];
            var high = tup[1];

            if (!adj.contains(x)) continue;

            var adjState: util.Tuple(&.{ u8, []Str }) = adj.get(x).?;
            if (adjState[0] == 'b') {
                for (adjState[1]) |y| try send(x, y, false, &counts, &conjState, &q, allocator);
            } else if (adjState[0] == '%') {
                if (!high) {
                    var sO = flipFlopState.get(x);
                    if (sO == null) sO = false;
                    try flipFlopState.put(x, !sO.?);

                    for (adjState[1]) |y| try send(x, y, flipFlopState.get(x).?, &counts, &conjState, &q, allocator);
                }
            } else if (adjState[0] == '&') {
                var res = true;
                var mp = conjState.get(x).?;
                var it = mp.valueIterator();
                while (it.next()) |nxt| res = res and nxt.*;
                res = !res;

                for (adjState[1]) |y| {
                    try send(x, y, res, &counts, &conjState, &q, allocator);
                }
            }
        }
    }

    return counts[0] * counts[1];
}

pub fn part2(input: Str) !u64 {
    var arena = util.arena_gpa;
    defer arena.deinit();
    var allocator = arena.allocator();

    var res = std.ArrayList(u64).init(allocator);
    defer res.deinit();

    var adj = std.StringHashMap([]Str).init(allocator);
    defer adj.deinit();

    var lines = util.splitStr(input, "\n");
    while (lines.next()) |line| {
        var split = util.splitStr(line, " -> ");
        var name = split.next().?;

        var destStr = split.next().?;
        var destStrSplit = util.splitStr(destStr, ", ");
        var destList = std.ArrayList(Str).init(allocator);
        while (destStrSplit.next()) |next| try destList.append(next);
        try adj.put(name, destList.items);
    }

    var list = adj.get("broadcaster").?;
    for (list) |m| {
        var m2 = m;
        var bin = std.ArrayList(u8).init(allocator);
        defer bin.deinit();

        while (true) {
            var gkey = try util.concatSlices(u8, "%", m2, allocator);
            var g = adj.get(gkey).?;

            if (g.len == 2) {
                try bin.append('1');
            } else {
                var g0k = try util.concatSlices(u8, "%", g[0], allocator);
                if (!adj.contains(g0k)) try bin.append('1') else try bin.append('0');
            }

            var nextL = std.ArrayList(Str).init(allocator);
            for (adj.get(gkey).?) |next| {
                var gnk = try util.concatSlices(u8, "%", next, allocator);
                if (adj.contains(gnk)) try nextL.append(next);
            }

            if (nextL.items.len == 0) break;

            m2 = nextL.items[0];
        }

        var binr = try util.reverseList(u8, bin, allocator);
        defer binr.deinit();

        try res.append(try util.parseInt(u64, binr.items, 2));
    }

    return util.lcmSlice(u64, res.items);
}

pub fn main() !void {}

test "example-part1" {
    const actual = try part1(@embedFile("example1.txt"));
    const expected = @as(u64, 32000000);

    try util.expectEqual(expected, actual);
}

test "input-part1" {
    const actual = try part1(@embedFile("input1.txt"));
    const expected = @as(u64, 800830848);

    try util.expectEqual(expected, actual);
}

test "example-part2" {
    const actual = try part2(@embedFile("example1.txt"));
    const expected = @as(u64, 4);

    try util.expectEqual(expected, actual);
}

test "input-part2" {
    const actual = try part2(@embedFile("input1.txt"));
    const expected = @as(u64, 244055946148853);

    try util.expectEqual(expected, actual);
}
