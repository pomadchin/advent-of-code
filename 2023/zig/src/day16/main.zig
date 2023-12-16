const std = @import("std");
const util = @import("util");
const queue = @import("queue");

const Str = util.Str;
const Allocator = std.mem.Allocator;

const Direction = util.Tuple(&.{ i32, i32 });
const Pos = util.Tuple(&.{ usize, usize });
const PosD = struct { pos: Pos, dir: Direction };

const GridBounds = struct { rows: usize, cols: usize };

const UP = .{ -1, 0 };
const DOWN = .{ 1, 0 };
const RIGHT = .{ 0, 1 };
const LEFT = .{ 0, -1 };

fn directionInside(d: Direction, rows: usize, cols: usize) bool {
    return !directionOutside(d, rows, cols);
}

fn directionOutside(d: Direction, rows: usize, cols: usize) bool {
    return d[0] < 0 or d[0] >= rows or d[1] < 0 or d[1] >= cols;
}

fn sumPD(pos: Pos, dir: Direction) Direction {
    var pd = posToDirection(pos);
    return .{ pd[0] + dir[0], pd[1] + dir[1] };
}

fn posToDirection(pos: Pos) Direction {
    return .{ @as(i32, @intCast(pos[0])), @as(i32, @intCast(pos[1])) };
}

fn directionToPos(dir: Direction) Pos {
    return .{ @as(usize, @intCast(dir[0])), @as(usize, @intCast(dir[1])) };
}

// fills in the tiles map ((row, col) -> c) valies
// returns (s position, rows, cols)
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

// empty space (.), mirrors (/ and \), and splitters (| and -).

pub fn solve(grid: *std.AutoHashMap(Pos, u8), gridBounds: GridBounds, start: PosD, allocator: Allocator) !usize {
    var rows = gridBounds.rows;
    var cols = gridBounds.cols;

    var visited = std.AutoHashMap(PosD, void).init(allocator);
    defer visited.deinit();

    var q = queue.Queue(PosD).init(allocator);
    try q.enqueue(start);

    while (q.nonEmpty()) {
        var e: PosD = q.dequeue().?;
        var p = e.pos;
        var d = e.dir;
        if (!grid.contains(p) or visited.contains(e)) continue;
        try visited.put(e, {});

        var value = grid.get(p).?;
        switch (value) {
            '/' => {
                var nd = .{ -d[1], -d[0] };
                var np = sumPD(p, nd);
                if (directionOutside(np, rows, cols)) continue;
                try q.enqueue(PosD{ .pos = directionToPos(np), .dir = nd });
            },
            '\\' => {
                var nd = .{ d[1], d[0] };
                var np = sumPD(p, nd);
                if (directionOutside(np, rows, cols)) continue;
                try q.enqueue(PosD{ .pos = directionToPos(np), .dir = nd });
            },
            '|' => {
                if (d[0] == 0) {
                    var npU = sumPD(p, UP);
                    var npD = sumPD(p, DOWN);

                    if (directionInside(npU, rows, cols)) try q.enqueue(PosD{ .pos = directionToPos(npU), .dir = UP });
                    if (directionInside(npD, rows, cols)) try q.enqueue(PosD{ .pos = directionToPos(npD), .dir = DOWN });
                } else {
                    var np = sumPD(p, d);
                    if (directionOutside(np, rows, cols)) continue;
                    try q.enqueue(PosD{ .pos = directionToPos(np), .dir = d });
                }
            },
            '-' => {
                if (d[1] == 0) {
                    var npR = sumPD(p, RIGHT);
                    var npL = sumPD(p, LEFT);

                    if (directionInside(npR, rows, cols)) try q.enqueue(PosD{ .pos = directionToPos(npR), .dir = RIGHT });
                    if (directionInside(npL, rows, cols)) try q.enqueue(PosD{ .pos = directionToPos(npL), .dir = LEFT });
                } else {
                    var np = sumPD(p, d);
                    if (directionOutside(np, rows, cols)) continue;
                    try q.enqueue(PosD{ .pos = directionToPos(np), .dir = d });
                }
            },
            else => {
                var np = sumPD(p, d);
                if (directionOutside(np, rows, cols)) continue;
                try q.enqueue(PosD{ .pos = directionToPos(np), .dir = d });
            },
        }
    }

    var res: usize = 0;

    var visitedP = std.AutoHashMap(Pos, void).init(allocator);
    defer visitedP.deinit();

    var it = visited.keyIterator();
    while (it.next()) |key| try visitedP.put(key.*.pos, {});

    var itp = visitedP.keyIterator();
    while (itp.next()) |_| res += 1;

    return res;
}

pub fn part1(input: Str) !usize {
    var arena = util.arena_gpa;
    defer arena.deinit();
    var allocator = arena.allocator();

    var grid = std.AutoHashMap(Pos, u8).init(allocator);
    defer grid.deinit();

    var gridBounds = try buildGrid(input, &grid);

    return try solve(&grid, gridBounds, PosD{ .pos = .{ 0, 0 }, .dir = RIGHT }, allocator);
}

pub fn part2(input: Str) !usize {
    var arena = util.arena_gpa;
    defer arena.deinit();
    var allocator = arena.allocator();

    var grid = std.AutoHashMap(Pos, u8).init(allocator);
    defer grid.deinit();

    var gridBounds = try buildGrid(input, &grid);

    var res: usize = 0;

    for (0..gridBounds.rows) |i| {
        res = @max(res, try solve(&grid, gridBounds, PosD{ .pos = .{ 0, i }, .dir = DOWN }, allocator));
        res = @max(res, try solve(&grid, gridBounds, PosD{ .pos = .{ gridBounds.rows - 1, i }, .dir = UP }, allocator));
    }
    for (0..gridBounds.cols) |i| {
        res = @max(res, try solve(&grid, gridBounds, PosD{ .pos = .{ i, 0 }, .dir = RIGHT }, allocator));
        res = @max(res, try solve(&grid, gridBounds, PosD{ .pos = .{ i, gridBounds.cols - 1 }, .dir = LEFT }, allocator));
    }

    return res;
}

pub fn main() !void {}

test "example-part1" {
    const actual = try part1(@embedFile("example1.txt"));
    const expected = @as(usize, 46);

    try util.expectEqual(expected, actual);
}

test "input-part1" {
    const actual = try part1(@embedFile("input1.txt"));
    const expected = @as(usize, 7472);

    try util.expectEqual(expected, actual);
}

test "example-part2" {
    const actual = try part2(@embedFile("example1.txt"));
    const expected = @as(usize, 51);

    try util.expectEqual(expected, actual);
}

test "input-part2" {
    const actual = try part2(@embedFile("input1.txt"));
    const expected = @as(usize, 7716);

    try util.expectEqual(expected, actual);
}
