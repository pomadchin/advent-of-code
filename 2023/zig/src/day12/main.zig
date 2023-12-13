const std = @import("std");
const util = @import("util");

const Str = util.Str;
const Allocator = std.mem.Allocator;

const MKey = util.Tuple(&.{ usize, usize, ?usize });

pub fn questionsList(slice: []const u8, allocator: Allocator) !std.ArrayList(usize) {
    var list = std.ArrayList(usize).init(allocator);
    for (slice, 0..) |c, i| if (c == '?') try list.append(i);
    return list;
}

pub fn countDamadged(slice: []const u8) usize {
    var res: usize = 0;
    for (slice) |c| {
        if (c == '#') res += 1;
    }
    return res;
}

pub fn part1(input: Str) !usize {
    var arena = util.arena_gpa;
    defer arena.deinit();
    var allocator = arena.allocator();

    var res: usize = 0;
    var lines = util.splitStr(input, "\n");
    while (lines.next()) |line| {
        var ls = util.splitStr(line, " ");
        var chars = ls.next().?;
        var numsSlice = ls.next().?;

        var numsBuf: [20]usize = undefined;
        var nums = try util.extractIntsIntoBuf(usize, numsSlice, &numsBuf);

        var questionsL = try questionsList(chars, allocator);
        var questions = questionsL.items;

        var k = util.sumSlice(usize, nums) - countDamadged(chars);

        var combinations = try util.combinations(usize, k, questions, allocator);
        for (combinations.items) |combList| {
            var comb = try util.listToSetConst(usize, combList, allocator);
            defer comb.deinit();

            var s = try allocator.alloc(u8, chars.len);
            defer allocator.free(s);

            // mk a new string
            for (chars, 0..) |c, i| {
                if (comb.contains(i)) {
                    s[i] = '#';
                } else if (c == '?') {
                    s[i] = '.';
                } else {
                    s[i] = c;
                }
            }

            var list = std.ArrayList(usize).init(allocator);
            defer list.deinit();
            var lt = util.split(u8, s, ".");
            while (lt.next()) |t| if (t.len > 0) try list.append(t.len);

            if (std.mem.eql(usize, nums, list.items)) res += 1;
        }
    }

    return res;
}

pub fn part1dp(input: Str) !usize {
    return try solve(input, 1);
}

fn getSafe(slice: []const u8, i: usize) ?u8 {
    if (i < slice.len) return slice[i];
    return null;
}

fn dp(chars: []const u8, nums: []usize, ic: usize, in: usize, curr: ?usize, memo: *std.AutoHashMap(MKey, usize)) !usize {
    var key = .{ ic, in, curr };
    if (memo.contains(key)) return memo.get(key).?;

    // no numbers left and no prev as well
    if (nums.len == in and curr == null) {
        for (ic..chars.len) |i| { // some chars left => if there is at least one damadged => 0
            if (chars[i] == '#') {
                try memo.put(key, 0);
                return 0;
            }
        }

        try memo.put(key, 1);
        return 1;
    }

    var c = getSafe(chars, ic);

    // no chars
    if (c == null) {
        if (curr == null or curr == 0) {
            // gracefully reached the end
            if (in == nums.len) {
                try memo.put(key, 1);
                return 1;
            } else { // else there is no combination
                try memo.put(key, 0);
                return 0;
            }
        } else { // not an end no combination
            try memo.put(key, 0);
            return 0;
        }
    } else if (c == '?') { // question => lets permutate
        if (curr == null) {
            // no current => there's a choice to try the current char or go to the next
            var res = try dp(chars, nums, ic + 1, in, null, memo) + try dp(chars, nums, ic, in + 1, nums[in], memo);
            try memo.put(key, res);
            return res;
        } else if (curr == 0) { // we used the entire number, the only thing we can do is move to the next char
            var res = try dp(chars, nums, ic + 1, in, null, memo);
            try memo.put(key, res);
            return res;
        } else { // we're using the current ? and substracting out of the available number of left combinations => go to the next char to get the next combination
            var res = try dp(chars, nums, ic + 1, in, curr.? - 1, memo);
            try memo.put(key, res);
            return res;
        }
    } else if (c == '#') { // broken tile
        if (curr == null) { // no numbers left => pick the next available number and try again
            var res = try dp(chars, nums, ic, in + 1, nums[in], memo);
            try memo.put(key, res);
            return res;
        } else if (curr == 0) { // tried all of the numbers but we're somehow on a tile => that's not a combination
            try memo.put(key, 0);
            return 0;
        } else { // count the tile as its already here, go to the next char
            var res = try dp(chars, nums, ic + 1, in, curr.? - 1, memo);
            try memo.put(key, res);
            return res;
        }
    } else if (c == '.') { // work tile
        if (curr == null or curr == 0) { // no current => we won't get it => skip
            var res = try dp(chars, nums, ic + 1, in, null, memo);
            try memo.put(key, res);
            return res;
        } else { // if curr != null / 0 => that's an incorrect combination
            try memo.put(key, 0);
            return 0;
        }
    }

    try memo.put(key, 0);
    return 0;
}

pub fn solve(input: Str, replication: usize) !usize {
    var arena = util.arena_gpa;
    defer arena.deinit();
    var allocator = arena.allocator();

    var res: usize = 0;
    var lines = util.splitStr(input, "\n");
    while (lines.next()) |line| {
        var ls = util.splitStr(line, " ");
        var chars = ls.next().?;
        var numsSlice = ls.next().?;

        var numsBuf: [20]usize = undefined;
        var nums = try util.extractIntsIntoBuf(usize, numsSlice, &numsBuf);

        var charsr = try allocator.alloc(u8, chars.len * replication + replication - 1);
        defer allocator.free(charsr);
        for (0..replication) |start| {
            for (chars, start..) |c, i| charsr[start * chars.len + i] = c;
            // don't add the last ?, we're adding replication - 1 question marks
            if (start * chars.len + start + chars.len >= charsr.len) continue;
            charsr[start * chars.len + start + chars.len] = '?';
        }

        var numsr = try allocator.alloc(usize, nums.len * replication);
        defer allocator.free(numsr);
        for (0..replication) |start| {
            for (nums, 0..) |n, i| numsr[start * nums.len + i] = n;
        }

        var memo = std.AutoHashMap(MKey, usize).init(allocator);
        defer memo.deinit();

        res += try dp(charsr, numsr, 0, 0, null, &memo);
    }

    return res;
}

pub fn part2(input: Str) !usize {
    return try solve(input, 5);
}

pub fn main() !void {}

test "example-part1" {
    const actual = try part1(@embedFile("example1.txt"));
    const expected = @as(usize, 21);

    try util.expectEqual(expected, actual);
}

test "input-part1" {
    const actual = try part1(@embedFile("input1.txt"));
    const expected = @as(usize, 7922);

    try util.expectEqual(expected, actual);
}

test "example-part1-dp" {
    const actual = try part1dp(@embedFile("example1.txt"));
    const expected = @as(usize, 21);

    try util.expectEqual(expected, actual);
}

test "input-part1-dp" {
    const actual = try part1dp(@embedFile("input1.txt"));
    const expected = @as(usize, 7922);

    try util.expectEqual(expected, actual);
}

test "example-part2" {
    const actual = try part2(@embedFile("example1.txt"));
    const expected = @as(usize, 525152);

    try util.expectEqual(expected, actual);
}

test "input-part2" {
    const actual = try part2(@embedFile("input1.txt"));
    const expected = @as(usize, 18093821750095);

    try util.expectEqual(expected, actual);
}
