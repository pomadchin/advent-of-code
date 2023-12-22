const std = @import("std");
const util = @import("util");

const Str = util.Str;
const Allocator = std.mem.Allocator;

const Point = struct {
    y: i64,
    x: i64,

    pub fn add(self: *Point, other: Point) Point {
        return Point{ .y = self.y + other.y, .x = self.x + other.x };
    }

    pub fn mul(self: *Point, d: i64) Point {
        return Point{ .y = self.y * d, .x = self.x * d };
    }
};
const Instruction = struct {
    direction: Point,
    dist: i64,
    color: Str,

    pub fn distc(self: *Instruction) !i64 {
        var slice = self.color[1..6];
        return try util.parseInt(i64, slice, 16);
    }

    pub fn directionc(self: *Instruction) Point {
        return direction(switch (self.color[6]) {
            '3' => 'U',
            '1' => 'D',
            '0' => 'R',
            '2' => 'L',
            else => self.color[6],
        });
    }
};

fn direction(c: u8) Point {
    return switch (c) {
        'U' => Point{ .y = -1, .x = 0 },
        'D' => Point{ .y = 1, .x = 0 },
        'R' => Point{ .y = 0, .x = 1 },
        'L' => Point{ .y = 0, .x = -1 },
        else => Point{ .y = -99, .x = -99 },
    };
}

fn shoelace(points: []Point, allocator: Allocator) !u64 {
    var res: i64 = 0;

    var y = try allocator.alloc(i64, points.len + 1);
    var x = try allocator.alloc(i64, points.len + 1);

    for (points, 0..) |p, i| {
        y[i] = p.y;
        x[i] = p.x;
    }

    y[points.len] = points[0].y;
    x[points.len] = points[0].x;

    for (0..points.len) |i| res += x[i] * y[i + 1] - y[i] * x[i + 1];

    return util.abs(res) / 2;
}

fn parse(line: Str) !Instruction {
    var split = util.splitStr(line, " ");
    var d = direction((split.next().?)[0]);
    var distStr = split.next().?;
    var dist = try util.parseInt(i64, distStr, 10);
    var colorBuf = split.next().?;
    var color = colorBuf[1 .. colorBuf.len - 1];

    return Instruction{ .direction = d, .dist = dist, .color = color };
}

pub fn part1(input: Str) !u64 {
    var arena = util.arena_gpa;
    defer arena.deinit();
    var allocator = arena.allocator();

    var current = Point{ .y = 0, .x = 0 };

    var points = std.ArrayList(Point).init(allocator);
    defer points.deinit();

    var p: u64 = 0; // border / perimiter

    var lines = util.splitStr(input, "\n");
    while (lines.next()) |line| {
        var inst = try parse(line);
        var dist = inst.dist;
        var dir = inst.direction;
        p += @as(u64, @intCast(dist));
        current = current.add(dir.mul(dist));
        try points.append(current);
    }

    return try shoelace(points.items, allocator) + (p / 2) + 1;
}

pub fn part2(input: Str) !u64 {
    var arena = util.arena_gpa;
    defer arena.deinit();
    var allocator = arena.allocator();

    var current = Point{ .y = 0, .x = 0 };

    var points = std.ArrayList(Point).init(allocator);
    defer points.deinit();

    var p: u64 = 0; // border / perimiter

    var lines = util.splitStr(input, "\n");
    while (lines.next()) |line| {
        var inst = try parse(line);
        var dist = try inst.distc();
        var dir = inst.directionc();
        p += @as(u64, @intCast(dist));
        current = current.add(dir.mul(dist));
        try points.append(current);
    }

    return try shoelace(points.items, allocator) + (p / 2) + 1;
}

pub fn main() !void {}

test "example-part1" {
    const actual = try part1(@embedFile("example1.txt"));
    const expected = @as(u64, 62);

    try util.expectEqual(expected, actual);
}

test "input-part1" {
    const actual = try part1(@embedFile("input1.txt"));
    const expected = @as(u64, 39194);

    try util.expectEqual(expected, actual);
}

test "example-part2" {
    const actual = try part2(@embedFile("example1.txt"));
    const expected = @as(u64, 952408144115);

    try util.expectEqual(expected, actual);
}

test "input-part2" {
    const actual = try part2(@embedFile("input1.txt"));
    const expected = @as(u64, 78242031808225);

    try util.expectEqual(expected, actual);
}
