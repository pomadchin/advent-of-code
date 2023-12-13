pub const std = @import("std");
pub const Allocator = std.mem.Allocator;
pub const List = std.ArrayList;
pub const Map = std.AutoHashMap;
pub const StrMap = std.StringHashMap;
pub const BitSet = std.DynamicBitSet;
pub const Tuple = std.meta.Tuple;
pub const Str = []const u8;

pub var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
pub const gpa = gpa_impl.allocator();

pub const test_allocator = std.testing.allocator;

pub const arena_gpa = std.heap.ArenaAllocator.init(gpa);
pub const arena_test = std.heap.ArenaAllocator.init(test_allocator);

// Add utility functions here

// Useful stdlib functions
pub const tokenize = std.mem.tokenize;
pub const split = std.mem.split;
pub const indexOf = std.mem.indexOfScalar;
pub const indexOfAny = std.mem.indexOfAny;
pub const indexOfStr = std.mem.indexOfPosLinear;
pub const lastIndexOf = std.mem.lastIndexOfScalar;
pub const lastIndexOfAny = std.mem.lastIndexOfAny;
pub const lastIndexOfStr = std.mem.lastIndexOfLinear;
pub const trim = std.mem.trim;
pub const sliceMin = std.mem.min;
pub const sliceMax = std.mem.max;
pub const eql = std.mem.eql;
pub const startsWith = std.mem.startsWith;
pub const endsWith = std.mem.endsWith;

pub const parseInt = std.fmt.parseInt;
pub const parseFloat = std.fmt.parseFloat;

pub const min = std.math.min;
pub const min3 = std.math.min3;
pub const max = std.math.max;
pub const max3 = std.math.max3;

pub const print = std.debug.print;
pub const assert = std.debug.assert;

pub const sort = std.sort.sort;
pub const asc = std.sort.asc;
pub const desc = std.sort.desc;

pub const isDigit = std.ascii.isDigit;

pub const abs = std.math.absCast;

pub const SplitStringIterator = std.mem.SplitIterator(u8, std.mem.DelimiterType.sequence);

pub fn sumSlice(comptime T: type, slice: []T) T {
    var res: T = 0;
    for (slice) |e| res += e;
    return res;
}

pub fn listRangeIntersectionCount(comptime T: type, l: *std.ArrayList(T), from: T, until: T) usize {
    var res: usize = 0;

    for (l.items) |item| {
        if (item >= from and item < until) res += 1;
    }

    return res;
}

pub fn listSetIntersectionCount(comptime T: type, l: *std.ArrayList(T), r: *std.AutoHashMap(T, void)) usize {
    var res: usize = 0;

    for (l.items) |item| {
        if (r.contains(item)) res += 1;
    }

    return res;
}

pub fn listSetIntersection(comptime T: type, l: *std.ArrayList(T), r: *std.AutoHashMap(T, void), allocator: Allocator) !std.ArrayList(T) {
    var list = std.ArrayList(usize).init(allocator);

    for (l.items) |item| {
        if (r.contains(item)) try list.append(item);
    }

    return list;
}

pub fn listIntersection(comptime T: type, l: *std.ArrayList(T), r: *std.ArrayList(T), allocator: Allocator) !std.ArrayList(T) {
    var ls = try listToSet(T, l, allocator);
    var rs = try listToSet(T, r, allocator);

    var set = try setIntersection(T, &ls, &rs, allocator);
    var list = try setToList(T, &set, allocator);

    return list;
}

pub fn setIntersection(comptime T: type, ls: *std.AutoHashMap(T, void), rs: *std.AutoHashMap(T, void), allocator: Allocator) !std.AutoHashMap(T, void) {
    var set = std.AutoHashMap(T, void).init(allocator);

    var it = ls.keyIterator();
    while (it.next()) |key| {
        var k = key.*;
        if (rs.contains(k)) try set.put(k, {});
    }

    return set;
}

pub fn rangeSet(from: usize, until: usize, allocator: Allocator) !std.AutoHashMap(usize, void) {
    var set = std.AutoHashMap(usize, void).init(allocator);
    for (from..until) |idx| try set.put(idx, {});
    return set;
}

pub fn rangeList(from: usize, until: usize, allocator: Allocator) !std.ArrayList(usize) {
    var list = std.ArrayList(usize).init(allocator);
    for (from..until) |idx| try list.append(idx);
    return list;
}

pub fn setToList(comptime T: type, set: *std.AutoHashMap(T, void), allocator: Allocator) !std.ArrayList(T) {
    var list = std.ArrayList(T).init(allocator);
    var it = set.keyIterator();
    while (it.next()) |key| try list.append(key.*);
    return list;
}

pub fn listToSet2(comptime T: type, list: std.ArrayList(T), allocator: Allocator) !std.AutoHashMap(T, void) {
    var set = std.AutoHashMap(T, void).init(allocator);
    for (list.items) |item| try set.put(item, {});
    return set;
}

pub fn listToSet(comptime T: type, list: *std.ArrayList(T), allocator: Allocator) !std.AutoHashMap(T, void) {
    var set = std.AutoHashMap(T, void).init(allocator);
    for (list.items) |item| try set.put(item, {});
    return set;
}

pub fn sameElementsAs(comptime T: type, l: []T, r: []T, allocator: Allocator) !bool {
    if (l.len != r.len) return false;

    var set = std.AutoHashMap(T, void).init(allocator);
    defer set.deinit();

    for (l) |e| try set.put(e, {});
    for (r) |e| if (!set.contains(e)) return false;

    return true;
}

pub fn reverse(comptime T: type, buffer: []T, s: []const T) []T {
    for (s, 0..) |c, i| buffer[buffer.len - 1 - i] = c;
    return buffer[(buffer.len - s.len)..buffer.len];
}

pub fn forAll(comptime T: type, slice: []T, v: T) bool {
    var res = true;
    for (slice) |e| res = res and (e == v);
    return res;
}

pub fn gcd(comptime T: type, a: T, b: T) T {
    if (b == 0) return a;
    return gcd(T, b, a % b);
}

pub fn lcm(comptime T: type, a: T, b: T) T {
    return (a * b) / gcd(T, a, b);
}

pub fn lcmSlice(comptime T: type, slice: []T) T {
    var res = slice[0];

    for (1..slice.len) |i| {
        res = lcm(T, slice[i], res);
    }

    return res;
}

pub fn product(comptime T: type, k: usize, input: []const T, allocator: Allocator) !std.ArrayList(std.ArrayList(T)) {
    var res = std.ArrayList(std.ArrayList(T)).init(allocator);
    var curr = std.ArrayList(T).init(allocator);

    try enumerateProduct(T, &curr, k, input, &res);

    return res;
}

fn enumerateProduct(comptime T: type, curr: *std.ArrayList(T), k: usize, input: []const T, res: *std.ArrayList(std.ArrayList(T))) !void {
    if (curr.items.len == k) {
        var copy = try curr.clone();
        try res.append(copy);
        return;
    }

    for (input) |i| {
        try curr.append(i);
        try enumerateProduct(T, curr, k, input, res);
        _ = curr.swapRemove(curr.items.len - 1);
    }

    return;
}

pub fn combinations(comptime T: type, k: usize, input: []const T, allocator: Allocator) !std.ArrayList(std.ArrayList(T)) {
    var res = std.ArrayList(std.ArrayList(T)).init(allocator);
    var curr = std.ArrayList(T).init(allocator);

    var n: usize = input.len - 1;

    try enumerateCombinations(T, &curr, 0, k, n, input, &res);

    return res;
}

fn enumerateCombinations(comptime T: type, curr: *std.ArrayList(T), start: usize, k: usize, n: usize, input: []const T, res: *std.ArrayList(std.ArrayList(T))) !void {
    if (curr.items.len == k) {
        var copy = try curr.clone();
        try res.append(copy);
        return;
    }

    var need = k - curr.items.len;
    var remain = n - start + 1;
    var available = remain - need;

    for (start..(start + available + 1)) |i| {
        try curr.append(input[i]);
        try enumerateCombinations(T, curr, i + 1, k, n, input, res);
        _ = curr.swapRemove(curr.items.len - 1);
    }

    return;
}

pub fn copyStr(dest: []u8, source: []const u8) void {
    std.mem.copy(u8, dest, source);
}

pub fn concatStr(start: usize, input: Str, output: []u8) void {
    var i = start;
    for (input) |c| {
        output[i] = c;
        i += 1;
    }
}

pub fn splitStr(buffer: []const u8, delimiter: []const u8) SplitStringIterator {
    return std.mem.split(u8, buffer, delimiter);
}

pub fn splitStrDropFirst(buffer: []const u8, delimiter: []const u8) SplitStringIterator {
    var it = splitStr(buffer, delimiter);
    _ = it.next().?;
    return it;
}

pub fn foldSlice(
    comptime T: type,
    slice: []const T,
    initial: T,
    func: *const fn (T, T) T,
) T {
    var acc = initial;
    for (slice) |element| acc = func(acc, element);
    return acc;
}

// var acc = util.foldIteratorStrMap(usize, bag.valueIterator(), 1, struct {
//     fn func(a: usize, x: usize) usize {
//         return a * x;
//     }
// }.func);
pub fn foldIteratorStrMap(
    comptime T: type,
    iterator: StrMap(T).ValueIterator,
    initial: T,
    func: *const fn (T, T) T,
) T {
    var acc = initial;
    var it = iterator;
    while (it.next()) |element| acc = func(acc, element.*);
    return acc;
}

// ---------------------- //
// Below functions I discovered on a zig reddit, very helpful. Grabbed from the @danvk github repo.
// I will use that repo as a guide to discover a better approach to writing zig.
// ---------------------- //

// Read u32s delimited by spaces or tabs from a line of text.
pub fn readInts(comptime IntType: type, line: []const u8, nums: *std.ArrayList(IntType)) !void {
    var it = std.mem.splitAny(u8, line, ", \t");
    while (it.next()) |s| {
        if (s.len == 0) {
            continue;
        }
        const num = try std.fmt.parseInt(IntType, s, 10);
        try nums.append(num);
    }
}

fn isDigitExtract(c: u8) bool {
    return c == '-' or (c >= '0' and c <= '9');
}

pub fn extractIntsIntoBuf(comptime IntType: type, str: []const u8, buf: []IntType) ![]IntType {
    var i: usize = 0;
    var n: usize = 0;

    while (i < str.len) {
        const c = str[i];
        if (isDigitExtract(c)) {
            const start = i;
            i += 1;
            while (i < str.len) {
                const c2 = str[i];
                if (!isDigitExtract(c2)) {
                    break;
                }
                i += 1;
            }
            buf[n] = try std.fmt.parseInt(IntType, str[start..i], 10);
            n += 1;
        } else {
            i += 1;
        }
    }
    return buf[0..n];
}

pub fn splitOne(line: []const u8, delim: []const u8) ?struct { head: []const u8, rest: []const u8 } {
    const maybeIdx = std.mem.indexOf(u8, line, delim);
    // XXX is there a more idiomatic way to write this pattern?
    if (maybeIdx) |idx| {
        return .{ .head = line[0..idx], .rest = line[(idx + delim.len)..] };
    } else {
        return null;
    }
}

pub fn splitIntoArrayList(input: []const u8, delim: []const u8, array_list: *std.ArrayList([]const u8)) !void {
    array_list.clearAndFree();
    var it = std.mem.splitSequence(u8, input, delim);
    while (it.next()) |part| {
        try array_list.append(part);
    }
    // std.fmt.bufPrint(buf: []u8, comptime fmt: []const u8, args: anytype)
    // std.fmt.bufPrintIntToSlice(buf: []u8, value: anytype, base: u8, case: Case, options: FormatOptions)
}

// Split the string into a pre-allocated buffer of slices.
// The buffer must be large enough to accommodate the number of parts.
// The returned slices point into the input string.
pub fn splitIntoBuf(str: []const u8, delim: []const u8, buf: [][]const u8) [][]const u8 {
    var rest = str;
    var i: usize = 0;
    while (splitOne(rest, delim)) |s| {
        buf[i] = s.head;
        rest = s.rest;
        i += 1;
    }
    buf[i] = rest;
    i += 1;
    return buf[0..i];
}

// Split the string on any character in delims, filtering out empty values.
pub fn splitAnyIntoBuf(str: []const u8, delims: []const u8, buf: [][]const u8) [][]const u8 {
    var it = std.mem.splitAny(u8, str, delims);
    var i: usize = 0;
    while (it.next()) |part| {
        if (part.len > 0) {
            buf[i] = part;
            i += 1;
        }
    }
    return buf[0..i];
}

pub fn readInputFile(filename: []const u8, allocator: std.mem.Allocator) ![]const u8 {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();
    const stat = try file.stat();
    const fileSize = stat.size;
    return try file.reader().readAllAlloc(allocator, fileSize);
}

pub const expect = std.testing.expect;
pub const expectEqual = std.testing.expectEqual;
pub const expectEqualDeep = std.testing.expectEqualDeep;

test "splitIntoBuf" {
    var buf: [8][]const u8 = undefined;
    const parts = splitIntoBuf("abc,def,,gh12", ",", &buf);
    try expectEqual(@as(usize, 4), parts.len);
    try expectEqualDeep(@as([]const u8, "abc"), parts[0]);
    try expectEqualDeep(@as([]const u8, "def"), parts[1]);
    try expectEqualDeep(@as([]const u8, ""), parts[2]);
    try expectEqualDeep(@as([]const u8, "gh12"), parts[3]);
    // const expected = [_][]const u8{ "abc", "def", "", "gh12" };
    // expectEqualDeep(@as([][]const u8, &[_][]const u8{ "abc", "def", "", "gh12" }), parts);
}

test "extractIntsIntoBuf" {
    var buf: [8]i32 = undefined;
    var ints = try extractIntsIntoBuf(i32, "12, 38, -233", &buf);
    try expect(eql(i32, &[_]i32{ 12, 38, -233 }, ints));

    ints = try extractIntsIntoBuf(i32, "zzz343344ddkd", &buf);
    try expect(eql(i32, &[_]i32{343344}, ints));

    ints = try extractIntsIntoBuf(i32, "not a number", &buf);
    try expect(eql(i32, &[_]i32{}, ints));
}

test "splitAnyIntoBuf" {
    var buf: [5][]const u8 = undefined;
    var parts = splitAnyIntoBuf("Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53", ":|", &buf);
    try expectEqual(@as(usize, 3), parts.len);
    try expectEqualDeep(@as([]const u8, "Card 1"), parts[0]);
    try expectEqualDeep(@as([]const u8, " 41 48 83 86 17 "), parts[1]);
    try expectEqualDeep(@as([]const u8, " 83 86  6 31 17  9 48 53"), parts[2]);
}
