const std = @import("std");
const util = @import("util");

const Order = std.math.Order;
const Str = util.Str;
const Allocator = std.mem.Allocator;

const Direction = util.Tuple(&.{ i32, i32 });
const Pos = util.Tuple(&.{ i32, i32 });
const GridBounds = struct {
    rows: usize,
    cols: usize,
    pub fn end(self: *GridBounds) Pos {
        return .{ @as(i32, @intCast(self.rows - 1)), @as(i32, @intCast(self.cols - 1)) };
    }
};

const RCLength = util.Tuple(&.{ i32, i32 });
fn lengthInRange(tup: RCLength, max: i32) bool {
    var rl = tup[0];
    var cl = tup[1];

    return rl >= -max and rl <= max and cl >= -max and cl <= max;
}

const State = struct {
    pos: Pos, // position
    length: RCLength, // (rows, cols) length, can be negative
};

// weighted state
const WState = struct {
    state: State,
    weight: usize,

    fn lessThan(context: void, a: WState, b: WState) Order {
        _ = context;
        return std.math.order(a.weight, b.weight);
    }
};

const PQWState = std.PriorityQueue(WState, void, WState.lessThan);

// fills in the tiles map ((row, col) -> c) valies
// returns (s position, rows, cols)
fn buildGrid(input: Str, grid: *std.AutoHashMap(Pos, usize)) !GridBounds {
    var rows: usize = 0;
    var cols: usize = 0;

    var lines = util.splitStr(input, "\n");
    while (lines.next()) |line| {
        cols = @max(cols, line.len);
        for (0..cols) |c| try grid.put(.{ @as(i32, @intCast(rows)), @as(i32, @intCast(c)) }, try std.fmt.parseInt(usize, &[_]u8{line[c]}, 10));
        rows += 1;
    }

    return GridBounds{ .rows = rows, .cols = cols };
}

pub fn solve(input: Str, maxLen: i32, neighbors: *const fn (State, Allocator) anyerror!std.ArrayList(State)) !usize {
    var arena = util.arena_gpa;
    defer arena.deinit();
    var allocator = arena.allocator();

    var grid = std.AutoHashMap(Pos, usize).init(allocator);
    defer grid.deinit();

    var dist = std.AutoHashMap(State, usize).init(allocator);
    defer dist.deinit();

    var gridBounds = try buildGrid(input, &grid);

    var start = .{ 0, 0 };
    var end = gridBounds.end();
    var stateInit = WState{ .state = State{ .pos = start, .length = .{ 0, 0 } }, .weight = 0 };

    var pq = PQWState.init(allocator, {});
    defer pq.deinit();

    try pq.add(stateInit);
    try dist.put(stateInit.state, 0);

    while (pq.removeOrNull()) |x| {
        var u = x.state;

        if (!lengthInRange(u.length, maxLen)) continue;
        if (std.meta.eql(u.pos, end)) return dist.get(u).?;

        var list = try neighbors(u, allocator);
        defer list.deinit();

        for (list.items) |v| {
            if (!grid.contains(v.pos)) continue;

            var d = dist.get(u).? + grid.get(v.pos).?;
            if (dist.get(v)) |do| {
                if (d < do) {
                    try dist.put(v, d);
                    try pq.add(WState{ .state = v, .weight = d });
                }
            } else { // !dist.contains(v))
                try dist.put(v, d);
                try pq.add(WState{ .state = v, .weight = d });
            }
        }
    }

    return 0;
}

fn neighbors_part1(state: State, allocator: Allocator) !std.ArrayList(State) {
    var r = state.pos[0];
    var c = state.pos[1];
    var rl = state.length[0];
    var cl = state.length[1];

    var res = std.ArrayList(State).init(allocator);

    if (rl == 0) {
        try res.append(State{ .pos = .{ r - 1, c }, .length = .{ -1, 0 } });
        try res.append(State{ .pos = .{ r + 1, c }, .length = .{ 1, 0 } });
    }
    if (cl == 0) {
        try res.append(State{ .pos = .{ r, c - 1 }, .length = .{ 0, -1 } });
        try res.append(State{ .pos = .{ r, c + 1 }, .length = .{ 0, 1 } });
    }

    if (rl > 0) try res.append(State{ .pos = .{ r + 1, c }, .length = .{ rl + 1, 0 } });
    if (rl < 0) try res.append(State{ .pos = .{ r - 1, c }, .length = .{ rl - 1, 0 } });

    if (cl > 0) try res.append(State{ .pos = .{ r, c + 1 }, .length = .{ 0, cl + 1 } });
    if (cl < 0) try res.append(State{ .pos = .{ r, c - 1 }, .length = .{ 0, cl - 1 } });

    return res;
}

pub fn part1(input: Str) !usize {
    return solve(input, 3, neighbors_part1);
}

fn neighbors_part2(state: State, allocator: Allocator) !std.ArrayList(State) {
    var r = state.pos[0];
    var c = state.pos[1];
    var rl = state.length[0];
    var cl = state.length[1];

    var res = std.ArrayList(State).init(allocator);

    if (0 < rl and rl < 4) {
        try res.append(State{ .pos = .{ r + 1, c }, .length = .{ rl + 1, 0 } });
    } else if (-4 < rl and rl < 0) {
        try res.append(State{ .pos = .{ r - 1, c }, .length = .{ rl - 1, 0 } });
    } else if (0 < cl and cl < 4) {
        try res.append(State{ .pos = .{ r, c + 1 }, .length = .{ 0, cl + 1 } });
    } else if (-4 < cl and cl < 0) {
        try res.append(State{ .pos = .{ r, c - 1 }, .length = .{ 0, cl - 1 } });
    } else {
        var neighbors = try neighbors_part1(state, allocator);
        try res.appendSlice(neighbors.items);
    }

    return res;
}

pub fn part2(input: Str) !usize {
    return solve(input, 10, neighbors_part2);
}

pub fn main() !void {}

test "example-part1" {
    const actual = try part1(@embedFile("example1.txt"));
    const expected = @as(usize, 102);

    try util.expectEqual(expected, actual);
}

test "input-part1" {
    const actual = try part1(@embedFile("input1.txt"));
    const expected = @as(usize, 684);

    try util.expectEqual(expected, actual);
}

test "example-part2" {
    const actual = try part2(@embedFile("example1.txt"));
    const expected = @as(usize, 94);

    try util.expectEqual(expected, actual);
}

test "input-part2" {
    const actual = try part2(@embedFile("input1.txt"));
    const expected = @as(usize, 822);

    try util.expectEqual(expected, actual);
}
