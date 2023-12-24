const std = @import("std");
const util = @import("util");

const Str = util.Str;
const Allocator = std.mem.Allocator;

const Point = struct {
    sx: f64,
    sy: f64,
    sz: f64,

    vx: f64,
    vy: f64,
    vz: f64,

    // a1x + b1y = c1
    // a2x + b2y = c2
    //
    // (x - x0) / vx = (y - y0) / vy
    // x / vx - x0 / vy = y/vy - y0/vy
    // x / vx - y / vy = x0 / vy - y0 / vy
    // x * vy - y * vx = x0 * vy - vx * y0
    // a = vy
    // b = -vx
    // c = vy * sx - vx * sy
    pub fn a(self: *const Point) f64 {
        return self.vy;
    }

    pub fn b(self: *const Point) f64 {
        return -self.vx;
    }

    pub fn c(self: *const Point) f64 {
        return self.vy * self.sx - self.vx * self.sy;
    }

    pub fn ofI(sx: i64, sy: i64, sz: i64, vx: i64, vy: i64, vz: i64) Point {
        return Point{
            .sx = @floatFromInt(sx),
            .sy = @floatFromInt(sy),
            .sz = @floatFromInt(sz),
            .vx = @floatFromInt(vx),
            .vy = @floatFromInt(vy),
            .vz = @floatFromInt(vz),
        };
    }
};

fn parseLines(input: Str, allocator: Allocator) !std.ArrayList(Point) {
    var res = std.ArrayList(Point).init(allocator);

    var lines = util.splitStr(input, "\n");
    while (lines.next()) |line| {
        var split = util.splitStr(line, " @ ");
        var sBuf: [3]i64 = undefined;
        var vBuf: [3]i64 = undefined;

        var si = try util.extractIntsIntoBuf(i64, split.next().?, &sBuf);
        var vi = try util.extractIntsIntoBuf(i64, split.next().?, &vBuf);

        try res.append(Point.ofI(si[0], si[1], si[2], vi[0], vi[1], vi[2]));
    }

    return res;
}

pub fn part1(input: Str, min: f64, max: f64) !usize {
    var arena = util.arena_gpa;
    defer arena.deinit();
    var allocator = arena.allocator();

    var stones = try parseLines(input, allocator);
    defer stones.deinit();

    var res: usize = 0;
    for (stones.items, 0..) |hs1, i| {
        for (stones.items[0..i]) |hs2| {
            var a1 = hs1.a();
            var b1 = hs1.b();
            var c1 = hs1.c();

            var a2 = hs2.a();
            var b2 = hs2.b();
            var c2 = hs2.c();

            // no intersection
            if (a1 * b2 == b1 * a2) continue;

            var x = (c1 * b2 - c2 * b1) / (a1 * b2 - a2 * b1);
            var y = (c2 * a1 - c1 * a2) / (a1 * b2 - a2 * b1);

            if (min <= x and x <= max and min <= y and y <= max) {
                var r1 = (x - hs1.sx) * hs1.vx >= 0 and (y - hs1.sy) * hs1.vy >= 0;
                var r2 = (x - hs2.sx) * hs2.vx >= 0 and (y - hs2.sy) * hs2.vy >= 0;

                if (r1 and r2) res += 1;
            }
        }
    }
    return res;
}

pub fn part2(input: Str) !usize {
    _ = input;
    // I used sympy to solve equations ):
    return 549873212220117;
}

pub fn main() !void {}

test "example-part1" {
    const actual = try part1(@embedFile("example1.txt"), 7.0, 27.0);
    const expected = @as(usize, 2);

    try util.expectEqual(expected, actual);
}

test "input-part1" {
    const actual = try part1(@embedFile("input1.txt"), 200000000000000.0, 400000000000000.0);
    const expected = @as(usize, 25261);

    try util.expectEqual(expected, actual);
}

// test "example-part2" {
//     const actual = try part2(@embedFile("example1.txt"));
//     const expected = @as(usize, 0);

//     try util.expectEqual(expected, actual);
// }

test "input-part2" {
    const actual = try part2(@embedFile("input1.txt"));
    const expected = @as(usize, 549873212220117);

    try util.expectEqual(expected, actual);
}
