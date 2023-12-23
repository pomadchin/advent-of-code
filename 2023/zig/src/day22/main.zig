const std = @import("std");
const util = @import("util");

const Str = util.Str;
const Allocator = std.mem.Allocator;
const Order = std.math.Order;

const PointsSet = std.AutoHashMap(Point, void);
const USizeSet = std.AutoHashMap(usize, void);
const PQFBricks = std.PriorityQueue(Brick, void, Brick.lessThan);

const Point = struct {
    x: i64,
    y: i64,
    z: i64,
};

const Brick = struct {
    i: usize,
    p1: Point,
    p2: Point,

    fn lessThan(context: void, s: Brick, o: Brick) Order {
        _ = context;
        var minZ = @min(s.p1.z, s.p2.z);
        var minZOther = @min(o.p1.z, o.p2.z);
        return std.math.order(minZ, minZOther);
    }

    fn contains(self: *Brick, p: Point) bool {
        return self.p1.x <= p.x and p.x <= self.p2.x and self.p1.y <= p.y and p.y <= self.p2.y and self.p1.z <= p.z and p.z <= self.p2.z;
    }

    fn points(self: *Brick, allocator: Allocator) !PointsSet {
        var res = PointsSet.init(allocator);

        var x = self.p1.x;
        while (x <= self.p2.x) : (x += 1) {
            var y = self.p1.y;
            while (y <= self.p2.y) : (y += 1) {
                try res.put(Point{ .x = x, .y = y, .z = self.p1.z }, {});
                try res.put(Point{ .x = x, .y = y, .z = self.p2.z }, {});
            }
        }

        return res;
    }

    fn canFall(self: *Brick, rpoints: PointsSet) bool {
        var x = self.p1.x;
        while (x <= self.p2.x) : (x += 1) {
            var y = self.p1.y;
            while (y <= self.p2.y) : (y += 1) {
                var zt = self.p1.z - 1;
                if (zt == 0 or rpoints.contains(Point{ .x = x, .y = y, .z = zt })) return false;
            }
        }
        return true;
    }

    fn fall(self: *Brick, rpoints: PointsSet) bool {
        var can = self.canFall(rpoints);
        if (can) {
            self.p1.z -= 1;
            self.p2.z -= 1;
        }
        return can;
    }
};

fn parsePoint(line: Str) !Point {
    var split = util.splitStr(line, ",");
    return Point{
        .x = try util.parseInt(i64, split.next().?, 10),
        .y = try util.parseInt(i64, split.next().?, 10),
        .z = try util.parseInt(i64, split.next().?, 10),
    };
}

fn parseBrick(line: Str, i: usize) !Brick {
    var split = util.splitStr(line, "~");
    return Brick{ .i = i, .p1 = try parsePoint(split.next().?), .p2 = try parsePoint(split.next().?) };
}

fn parseBricks(input: Str, allocator: Allocator) !std.ArrayList(Brick) {
    var list = std.ArrayList(Brick).init(allocator);
    var lines = util.splitStr(input, "\n");
    var i: usize = 0;
    while (lines.next()) |line| {
        try list.append(try parseBrick(line, i));
        i += 1;
    }

    return try fallBricks(list, allocator);
}

fn fallBricks(bricks: std.ArrayList(Brick), allocator: Allocator) !std.ArrayList(Brick) {
    var rbricks = std.ArrayList(Brick).init(allocator);
    var fbricks = PQFBricks.init(allocator, {});
    var rpoints = PointsSet.init(allocator);
    defer fbricks.deinit();
    defer rpoints.deinit();
    defer bricks.deinit();

    for (bricks.items) |brick| try fbricks.add(brick);

    while (fbricks.removeOrNull()) |b| {
        var brick: Brick = b;

        if (!brick.fall(rpoints)) {
            try rbricks.append(brick);
            var bpoints = try brick.points(allocator);
            defer bpoints.deinit();
            var it = bpoints.keyIterator();
            while (it.next()) |p| try rpoints.put(p.*, {});
        } else {
            try fbricks.add(brick);
        }
    }

    return rbricks;
}

pub fn part1(input: Str) !usize {
    var arena = util.arena_gpa;
    defer arena.deinit();
    var allocator = arena.allocator();

    var bricks = try parseBricks(input, allocator);
    defer bricks.deinit();

    var res: usize = 0;

    for (0..bricks.items.len) |i| {
        var fbricks = PQFBricks.init(allocator, {});
        var rpoints = PointsSet.init(allocator);
        defer fbricks.deinit();
        defer rpoints.deinit();

        for (0..bricks.items.len) |j| if (i != j) try fbricks.add(bricks.items[j]);

        var fall = false;
        while (fbricks.removeOrNull()) |b| {
            var brick: Brick = b;

            if (!brick.fall(rpoints)) {
                var bpoints = try brick.points(allocator);
                defer bpoints.deinit();
                var it = bpoints.keyIterator();
                while (it.next()) |p| try rpoints.put(p.*, {});
            } else {
                fall = true;
                break;
            }
        }

        if (!fall) res += 1;
    }

    return res;
}

pub fn part2(input: Str) !usize {
    var arena = util.arena_gpa;
    defer arena.deinit();
    var allocator = arena.allocator();

    var bricks = try parseBricks(input, allocator);
    defer bricks.deinit();

    var res: usize = 0;

    for (0..bricks.items.len) |i| {
        var fbricks = PQFBricks.init(allocator, {});
        var rpoints = PointsSet.init(allocator);
        defer fbricks.deinit();
        defer rpoints.deinit();

        for (0..bricks.items.len) |j| if (i != j) try fbricks.add(bricks.items[j]);

        var fall = USizeSet.init(allocator);
        defer fall.deinit();
        while (fbricks.removeOrNull()) |b| {
            var brick: Brick = b;

            if (!brick.fall(rpoints)) {
                var bpoints = try brick.points(allocator);
                defer bpoints.deinit();
                var it = bpoints.keyIterator();
                while (it.next()) |p| try rpoints.put(p.*, {});
            } else {
                try fall.put(brick.i, {});
                try fbricks.add(brick);
            }
        }

        res += fall.count();
    }

    return res;
}

pub fn main() !void {}

test "example-part1" {
    const actual = try part1(@embedFile("example1.txt"));
    const expected = @as(usize, 5);

    try util.expectEqual(expected, actual);
}

test "input-part1" {
    const actual = try part1(@embedFile("input1.txt"));
    const expected = @as(usize, 428);

    try util.expectEqual(expected, actual);
}

test "example-part2" {
    const actual = try part2(@embedFile("example1.txt"));
    const expected = @as(usize, 7);

    try util.expectEqual(expected, actual);
}

test "input-part2" {
    const actual = try part2(@embedFile("input1.txt"));
    const expected = @as(usize, 35654);

    try util.expectEqual(expected, actual);
}
