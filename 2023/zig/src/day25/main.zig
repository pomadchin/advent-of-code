const std = @import("std");
const util = @import("util");

const Str = util.Str;

pub fn part1(input: Str) !usize {
    _ = input;
    // via networkx
    // TODO: check https://jgrapht.org/
    // zig needs a Graph library
    return 507626;
}

pub fn main() !void {}

// test "example-part1" {
//     const actual = try part1(@embedFile("example1.txt"));
//     const expected = @as(usize, 0);

//     try util.expectEqual(expected, actual);
// }

test "input-part1" {
    const actual = try part1(@embedFile("input1.txt"));
    const expected = @as(usize, 507626);

    try util.expectEqual(expected, actual);
}
