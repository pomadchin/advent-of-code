const std = @import("std");
const util = @import("util");
const queue = @import("queue");

const Allocator = std.mem.Allocator;

const Str = util.Str;
const Node = [3]u8;

const Edge = struct {
    from: Node,
    toL: Node,
    toR: Node,

    fn parse(line: Str) Edge {
        var split = util.splitStr(line, " = ");
        const from = split.next().?[0..3];

        var to = util.splitStr(split.next().?, ", ");
        const toL = to.next().?[1..4];
        const toR = to.next().?[0..3];
        return Edge{ .from = from.*, .toL = toL.*, .toR = toR.* };
    }
};

const NodePath = struct { from: Node, len: usize };

fn nextInstruction(instructions: Str, step: usize) usize {
    var direction = instructions[step % instructions.len];
    if (direction == 'L') return 0;
    return 1;
}

pub fn buildG(input: Str, adj: *std.AutoHashMap(Node, std.ArrayList(Node)), allocator: Allocator) !void {
    var lines = util.splitStr(input, "\n");
    while (lines.next()) |line| {
        var edge = Edge.parse(line);

        var list = std.ArrayList(Node).init(allocator);
        try list.append(edge.toL);
        try list.append(edge.toR);
        try adj.put(edge.from, list);
    }
}

pub fn part1(instructions: Str, input: Str) !usize {
    var arena = util.arena_gpa;
    defer arena.deinit();

    var allocator = arena.allocator();

    var adj = std.AutoHashMap(Node, std.ArrayList(Node)).init(allocator);
    defer adj.deinit();

    try buildG(input, &adj, allocator);

    const start = [3]u8{ 'A', 'A', 'A' };
    const end = [3]u8{ 'Z', 'Z', 'Z' };

    var q = queue.Queue(Node).init(allocator);
    try q.enqueue(start);

    var res: usize = 0;
    var step: usize = 0;
    while (q.nonEmpty()) {
        const from = q.dequeue().?;

        if (util.eql(u8, &from, &end)) {
            res = step;
            break;
        }

        if (adj.get(from)) |next| {
            const to = next.items[nextInstruction(instructions, step)];
            try q.enqueue(to);
        }

        step += 1;
    }

    return res;
}

pub fn part2(instructions: Str, input: Str) !usize {
    var arena = util.arena_gpa;
    defer arena.deinit();

    var allocator = arena.allocator();

    var adj = std.AutoHashMap(Node, std.ArrayList(Node)).init(allocator);
    defer adj.deinit();

    try buildG(input, &adj, allocator);

    var q = queue.Queue(NodePath).init(allocator);

    var it = adj.keyIterator();
    while (it.next()) |key| {
        if (key.*[2] != 'A') continue;

        try q.enqueue(NodePath{ .from = key.*, .len = 0 });
    }

    var res = std.ArrayList(usize).init(allocator);
    defer res.deinit();

    while (q.nonEmpty()) {
        var node = q.dequeue().?;
        var from = node.from;
        var len = node.len;

        if (from[2] == 'Z') {
            try res.append(len);
            continue;
        }

        if (adj.get(from)) |next| {
            const to = next.items[nextInstruction(instructions, len)];
            try q.enqueue(NodePath{ .from = to, .len = len + 1 });
        }
    }

    var slice = try res.toOwnedSlice();
    return util.lcmSlice(usize, slice);
}

pub fn main() !void {}

test "example-part1" {
    const actual = try part1("RL", @embedFile("example1.1.txt"));
    const expected = @as(usize, 2);

    try util.expectEqual(expected, actual);
}

test "example-2-part1" {
    const actual = try part1("LLR", @embedFile("example1.2.txt"));
    const expected = @as(usize, 6);

    try util.expectEqual(expected, actual);
}

test "input-part1" {
    const instructions = "LRLRRRLRLLRRLRLRRRLRLRRLRRLLRLRRLRRLRRRLRRRLRLRRRLRLRRLRRLLRLRLLLLLRLRLRRLLRRRLLLRLLLRRLLLLLRLLLRLRRLRRLRRRLRRRLRRLRRLRRRLRLRLRRLRLRLRLRRLRRRLLRLLRRLRLRRRLRLRRRLRLRRRLRRRLRRLRLLLLRLRRRLRLRRLRLRRLRRLRRLLRRRLLLLLLRLRRRLRRLLRRRLRRLLLRLRLRLRRRLRRLRLRRRLRRLRRRLLRRLRRLLLRRRR";
    const actual = try part1(instructions, @embedFile("input1.txt"));
    const expected = @as(usize, 19099);

    try util.expectEqual(expected, actual);
}

test "example-part2" {
    const actual = try part2("LR", @embedFile("example2.1.txt"));
    const expected = @as(usize, 6);

    try util.expectEqual(expected, actual);
}

test "input-part2" {
    const instructions = "LRLRRRLRLLRRLRLRRRLRLRRLRRLLRLRRLRRLRRRLRRRLRLRRRLRLRRLRRLLRLRLLLLLRLRLRRLLRRRLLLRLLLRRLLLLLRLLLRLRRLRRLRRRLRRRLRRLRRLRRRLRLRLRRLRLRLRLRRLRRRLLRLLRRLRLRRRLRLRRRLRLRRRLRRRLRRLRLLLLRLRRRLRLRRLRLRRLRRLRRLLRRRLLLLLLRLRRRLRRLLRRRLRRLLLRLRLRLRRRLRRLRLRRRLRRLRRRLLRRLRRLLLRRRR";
    const actual = try part2(instructions, @embedFile("input1.txt"));
    const expected = @as(usize, 17099847107071);

    try util.expectEqual(expected, actual);
}
