const std = @import("std");
const util = @import("util");
const bufIter = @import("buf-iter");
const queue = @import("queue");

const Str = util.Str;
const assert = util.assert;

const Range = struct {
    dest: i64,
    start: i64,
    length: i64,
};

const SRange = struct {
    start: i64,
    stop: i64,
};

fn mapRanges(num: i64, ranges: []Range) i64 {
    for (ranges) |range| {
        if (num >= range.start and num < range.start + range.length) {
            return range.dest + (num - range.start);
        }
    }
    return num;
}

fn parseSeeds(line: Str, intBuf: []i64) ![]i64 {
    var buf: [2]Str = undefined;
    var parts = util.splitAnyIntoBuf(line, ":", &buf);

    var seeds = try util.extractIntsIntoBuf(i64, parts[1], intBuf);
    return seeds;
}

fn parseSRange(line: Str, intBuf: []i64) !std.ArrayList(SRange) {
    var seeds = try parseSeeds(line, intBuf);
    var res = std.ArrayList(SRange).init(util.gpa);

    var i: usize = 0;
    while (i < seeds.len) : (i += 2) {
        var start = seeds[i];
        var length = seeds[i + 1];

        try res.append(SRange{ .start = start, .stop = start + length });
    }

    return res;
}

fn parseRanges(iter: *util.SplitStringIterator) !std.ArrayList(Range) {
    var res = std.ArrayList(Range).init(util.gpa);

    var intBuf: [3]i64 = undefined;
    while (iter.next()) |line| {
        if (line.len == 0) break;

        var ints = try util.extractIntsIntoBuf(i64, line, &intBuf);
        assert(ints.len == 3);
        try res.append(Range{
            .dest = ints[0],
            .start = ints[1],
            .length = ints[2],
        });
    }
    return res;
}

pub fn part1(input: Str) !i64 {
    var lines = util.splitStr(input, "\n");

    // buf location determines scope ownership
    var seedsBuf: [20]i64 = undefined;
    var seeds = try parseSeeds(lines.next().?, &seedsBuf);

    // std.debug.print("\nseeds: {any}\n", .{seeds});

    while (lines.next()) |line| {
        // skip empty lines
        if (!util.endsWith(u8, line, "map:")) continue;

        var ranges = try parseRanges(&lines);
        defer ranges.deinit();

        // map all the seeds through.

        var j: usize = 0;
        while (j < seeds.len) : (j += 1) {
            seeds[j] = mapRanges(seeds[j], ranges.items);
        }
    }

    return util.sliceMin(i64, seeds);
}

pub fn part2(input: Str) !i64 {
    // use arena allocator to ensure that none ArrayLists are cleaned
    var arena = util.arena_gpa;
    defer arena.deinit();

    var allocator = arena.allocator();

    var lines = util.splitStr(input, "\n");

    // buf location determines scope ownership
    var seedsBuf: [20]i64 = undefined;
    var seedRangesList = try parseSRange(lines.next().?, &seedsBuf);
    defer seedRangesList.deinit();

    var seeds = seedRangesList.items;

    while (lines.next()) |line| {
        // skip empty lines
        if (!util.endsWith(u8, line, "map:")) continue;

        var ranges = try parseRanges(&lines);
        defer ranges.deinit();

        // fill in the queue
        var q = queue.Queue(SRange).init(allocator);
        for (seeds) |item| try q.enqueue(item);

        // std.debug.print("\nseeds: {any}\n", .{seeds});

        var seeds_new = std.ArrayList(SRange).init(allocator);

        while (q.nonEmpty()) {
            var r: SRange = q.dequeue().?;
            var found = false;
            for (ranges.items) |range| {
                var tr = SRange{ .start = range.dest, .stop = range.dest + range.length };
                var fr = SRange{ .start = range.start, .stop = range.start + range.length };

                var offset = tr.start - fr.start;

                // exclude ranges we're not interested in
                if ((r.stop <= fr.start) or (fr.stop <= r.start)) continue;

                // next step intersection = max start + min stop
                var ir = SRange{ .start = @max(r.start, fr.start), .stop = @min(r.stop, fr.stop) };

                // left part and right part
                var lr = SRange{ .start = r.start, .stop = ir.start };
                var rr = SRange{ .start = ir.stop, .stop = r.stop };

                // enqueue if ranges are legit to find mapping for them if possible
                // even if there is no overlap init seeds can be smaller
                if (lr.start < lr.stop) try q.enqueue(lr);
                if (rr.start < rr.stop) try q.enqueue(rr);

                // append to the list of the next step seeds
                try seeds_new.append(SRange{ .start = ir.start + offset, .stop = ir.stop + offset });

                found = true;

                // mapping found, quit
                break;
            }

            // not found => it's our seed candidate aka id mapping
            if (!found) try seeds_new.append(r);
        }

        seeds = seeds_new.items;
    }

    var res: i64 = std.math.maxInt(i64);
    for (seeds) |seed| res = @min(res, seed.start);
    return res;
}

pub fn main() !void {}

test "example-part1" {
    const actual = try part1(@embedFile("example1.txt"));
    const expected = @as(i64, 35);

    try util.expectEqual(expected, actual);
}

test "example-part2" {
    const actual = try part2(@embedFile("example1.txt"));
    const expected = @as(i64, 46);

    try util.expectEqual(expected, actual);
}

test "input-part1" {
    const actual = try part1(@embedFile("input1.txt"));
    const expected = @as(i64, 196167384);

    try util.expectEqual(expected, actual);
}

test "input-part2" {
    const actual = try part2(@embedFile("input1.txt"));
    const expected = @as(i64, 125742456);

    try util.expectEqual(expected, actual);
}
