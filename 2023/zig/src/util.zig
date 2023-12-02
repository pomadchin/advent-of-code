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

pub fn splitStr(buffer: []const u8, delimiter: []const u8) std.mem.SplitIterator(u8, std.mem.DelimiterType.sequence) {
    assert(delimiter.len != 0);
    return .{
        .index = 0,
        .buffer = buffer,
        .delimiter = delimiter,
    };
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
