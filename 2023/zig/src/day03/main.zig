const std = @import("std");
const util = @import("util");

const Str = util.Str;

fn isSymbol(c: u8) bool {
    return !util.isDigit(c) and c != '.';
}

fn isGear(c: u8) bool {
    return c == '*';
}

pub fn part1(input: Str) !u32 {
    var list = std.ArrayList(Str).init(util.gpa);
    defer list.deinit();

    try util.splitIntoArrayList(input, "\n", &list);
    var matrix = try list.toOwnedSlice();

    var rows = matrix.len;
    var cols = matrix[0].len;

    var res: u32 = 0;
    for (0..rows) |row| {
        var numList = std.ArrayList(u8).init(util.gpa);
        defer numList.deinit();

        var adjacent = false;
        for (0..cols) |col| {
            var char = matrix[row][col];

            // skip / flush logic
            if (char == '.' or isSymbol(char)) {
                // flush
                if (adjacent and numList.items.len > 0) {
                    var items = numList.items;
                    res += try util.parseInt(u32, items, 10);
                }

                // skip
                adjacent = false;
                numList.clearAndFree();

                continue;
            }

            if (util.isDigit(char)) {
                // check neighbors
                outer: for ([_]i32{ -1, 0, 1 }) |dr| {
                    for ([_]i32{ -1, 0, 1 }) |dc| {
                        var nrowi = @as(i32, @intCast(row)) + dr;
                        var ncoli = @as(i32, @intCast(col)) + dc;

                        // outside of the matrix
                        if (nrowi < 0 or nrowi >= rows or ncoli < 0 or ncoli >= cols) continue;

                        var nrow: usize = @intCast(nrowi);
                        var ncol: usize = @intCast(ncoli);

                        var nchar = matrix[nrow][ncol];

                        if (isSymbol(nchar)) {
                            adjacent = true;

                            // no needs in checking all of the adjacent neighbors
                            break :outer;
                        }
                    }
                }

                // accumulate all, mb eventually they become adjacent
                try numList.append(char);
            }
        }

        // flush leftovers
        if (adjacent and numList.items.len > 0) {
            var items = numList.items;
            res += try util.parseInt(u32, items, 10);
        }

        adjacent = false;
        numList.clearAndFree();
    }

    return res;
}

pub fn part2(input: Str) !u32 {
    var list = std.ArrayList(Str).init(util.gpa);
    defer list.deinit();

    try util.splitIntoArrayList(input, "\n", &list);
    var matrix = try list.toOwnedSlice();

    var rows = matrix.len;
    var cols = matrix[0].len;

    // A gear is any * symbol that is adjacent to exactly two part numbers
    // gear => pn list map
    var adj = std.StringHashMap(std.ArrayList(u32)).init(util.gpa);
    defer adj.deinit();

    var res: u32 = 0;
    for (0..rows) |row| {
        var numList = std.ArrayList(u8).init(util.gpa);
        defer numList.deinit();

        var gearKey: Str = "";
        var adjacent = false;
        for (0..cols) |col| {
            var char = matrix[row][col];

            // skip / flush logic
            if (char == '.' or isSymbol(char)) {
                // flush
                if (adjacent and numList.items.len > 0) {
                    var items = numList.items;
                    var num = try util.parseInt(u32, items, 10);
                    var pnList = adj.get(gearKey).?;
                    try pnList.append(num);
                    try adj.put(gearKey, pnList);
                }

                // skip
                adjacent = false;
                gearKey = "";
                numList.clearAndFree();

                continue;
            }

            if (util.isDigit(char)) {
                // check neighbors
                outer: for ([_]i32{ -1, 0, 1 }) |dr| {
                    for ([_]i32{ -1, 0, 1 }) |dc| {
                        var nrowi = @as(i32, @intCast(row)) + dr;
                        var ncoli = @as(i32, @intCast(col)) + dc;

                        // next outside of the matrix
                        if (nrowi < 0 or nrowi >= rows or ncoli < 0 or ncoli >= cols) continue;

                        var nrow: usize = @intCast(nrowi);
                        var ncol: usize = @intCast(ncoli);

                        var nchar = matrix[nrow][ncol];

                        if (isGear(nchar)) {
                            adjacent = true;

                            // init part numbers list and gear key
                            if (gearKey.len == 0) {
                                gearKey = try std.fmt.allocPrint(util.gpa, "{d}-{d}", .{ nrow, ncol });
                                var pnList = adj.get(gearKey);
                                if (pnList == null) {
                                    pnList = std.ArrayList(u32).init(util.gpa);
                                    defer pnList.?.deinit();
                                    try adj.put(gearKey, pnList.?);
                                }
                            }

                            // no needs in checking all of the adjacent neighbors
                            break :outer;
                        }
                    }
                }

                // accumulate all, mb eventually they become adjacent to a gear
                try numList.append(char);
            }
        }

        // flush leftovers
        if (adjacent and numList.items.len > 0) {
            var items = numList.items;
            var num = try util.parseInt(u32, items, 10);
            var pnList = adj.get(gearKey).?;
            try pnList.append(num);
            try adj.put(gearKey, pnList);
        }

        adjacent = false;
        numList.clearAndFree();
    }

    var it = adj.valueIterator();
    while (it.next()) |value| {
        var pnList = value.*.items;
        if (pnList.len == 2) {
            var ratio: u32 = 1;
            for (pnList) |item| ratio *= item;
            res += ratio;
        }
    }

    return res;
}

pub fn main() !void {}

test "example-part1" {
    const actual = try part1(@embedFile("example1.txt"));
    const expected = @as(u32, 4361);

    try util.expectEqual(expected, actual);
}

test "example-part2" {
    const actual = try part2(@embedFile("example1.txt"));
    const expected = @as(u32, 467835);

    try util.expectEqual(expected, actual);
}

test "input-part1" {
    const actual = try part1(@embedFile("input1.txt"));
    const expected = @as(u32, 528819);

    try util.expectEqual(expected, actual);
}

test "input-part2" {
    const actual = try part2(@embedFile("input1.txt"));
    const expected = @as(u32, 80403602);

    try util.expectEqual(expected, actual);
}
