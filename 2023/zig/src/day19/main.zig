const std = @import("std");
const util = @import("util");
const queue = @import("queue");

const Str = util.Str;
const Allocator = std.mem.Allocator;

const RW = util.Tuple(&.{ NRating, ?Workflow });

const NRange = struct {
    varName: Str,
    min: u64 = 1,
    max: u64 = 4000,

    pub fn len(self: *NRange) u64 {
        return self.max - self.min;
    }
};

const NRating = struct {
    x: NRange = NRange{ .varName = "x" },
    m: NRange = NRange{ .varName = "m" },
    a: NRange = NRange{ .varName = "a" },
    s: NRange = NRange{ .varName = "s" },

    pub fn combinations(self: *const NRating) u64 {
        return (self.x.max - (self.x.min - 1)) * (self.m.max - (self.m.min - 1)) * (self.a.max - (self.a.min - 1)) * (self.s.max - (self.s.min - 1));
    }

    const Out = util.Tuple(&.{ NRating, ?Str });

    pub fn split(self: *NRating, inst: Instruction, allocator: Allocator) !std.ArrayList(Out) {
        var res = std.ArrayList(Out).init(allocator);

        if (util.eqlStr(inst.varName, "x") and inst.expr == '>') {
            try res.append(.{ NRating{
                .x = NRange{ .varName = "x", .min = self.x.min, .max = @min(self.x.max, inst.value) },
                .m = self.m,
                .a = self.a,
                .s = self.s,
            }, null });
            try res.append(.{ NRating{
                .x = NRange{ .varName = "x", .min = @max(self.x.min, inst.value + 1), .max = self.x.max },
                .m = self.m,
                .a = self.a,
                .s = self.s,
            }, inst.to });
        } else if (util.eqlStr(inst.varName, "x") and inst.expr == '<') {
            try res.append(.{ NRating{
                .x = NRange{ .varName = "x", .min = self.x.min, .max = @min(self.x.max, inst.value - 1) },
                .m = self.m,
                .a = self.a,
                .s = self.s,
            }, inst.to });
            try res.append(.{ NRating{
                .x = NRange{ .varName = "x", .min = @max(self.x.min, inst.value), .max = self.x.max },
                .m = self.m,
                .a = self.a,
                .s = self.s,
            }, null });
        } else if (util.eqlStr(inst.varName, "m") and inst.expr == '>') {
            try res.append(.{ NRating{
                .x = self.x,
                .m = NRange{ .varName = "m", .min = self.m.min, .max = @min(self.m.max, inst.value) },
                .a = self.a,
                .s = self.s,
            }, null });
            try res.append(.{ NRating{
                .x = self.x,
                .m = NRange{ .varName = "m", .min = @max(self.m.min, inst.value + 1), .max = self.m.max },
                .a = self.a,
                .s = self.s,
            }, inst.to });
        } else if (util.eqlStr(inst.varName, "m") and inst.expr == '<') {
            try res.append(.{ NRating{
                .x = self.x,
                .m = NRange{ .varName = "m", .min = self.m.min, .max = @min(self.m.max, inst.value - 1) },
                .a = self.a,
                .s = self.s,
            }, inst.to });
            try res.append(.{ NRating{
                .x = self.x,
                .m = NRange{ .varName = "m", .min = @max(self.m.min, inst.value), .max = self.m.max },
                .a = self.a,
                .s = self.s,
            }, null });
        } else if (util.eqlStr(inst.varName, "a") and inst.expr == '>') {
            try res.append(.{ NRating{
                .x = self.x,
                .m = self.m,
                .a = NRange{ .varName = "a", .min = self.a.min, .max = @min(self.a.max, inst.value) },
                .s = self.s,
            }, null });
            try res.append(.{ NRating{
                .x = self.x,
                .m = self.m,
                .a = NRange{ .varName = "a", .min = @max(self.a.min, inst.value + 1), .max = self.a.max },
                .s = self.s,
            }, inst.to });
        } else if (util.eqlStr(inst.varName, "a") and inst.expr == '<') {
            try res.append(.{ NRating{
                .x = self.x,
                .m = self.m,
                .a = NRange{ .varName = "a", .min = self.a.min, .max = @min(self.a.max, inst.value - 1) },
                .s = self.s,
            }, inst.to });
            try res.append(.{ NRating{
                .x = self.x,
                .m = self.m,
                .a = NRange{ .varName = "a", .min = @max(self.a.min, inst.value), .max = self.a.max },
                .s = self.s,
            }, null });
        } else if (util.eqlStr(inst.varName, "s") and inst.expr == '>') {
            try res.append(.{ NRating{
                .x = self.x,
                .m = self.m,
                .a = self.a,
                .s = NRange{ .varName = "s", .min = self.s.min, .max = @min(self.s.max, inst.value) },
            }, null });
            try res.append(.{ NRating{
                .x = self.x,
                .m = self.m,
                .a = self.a,
                .s = NRange{ .varName = "s", .min = @max(self.s.min, inst.value + 1), .max = self.s.max },
            }, inst.to });
        } else if (util.eqlStr(inst.varName, "s") and inst.expr == '<') {
            try res.append(.{ NRating{
                .x = self.x,
                .m = self.m,
                .a = self.a,
                .s = NRange{ .varName = "s", .min = self.s.min, .max = @min(self.s.max, inst.value - 1) },
            }, inst.to });
            try res.append(.{ NRating{
                .x = self.x,
                .m = self.m,
                .a = self.a,
                .s = NRange{ .varName = "s", .min = @max(self.s.min, inst.value), .max = self.s.max },
            }, null });
        }

        return res;
    }
};

const Rating = struct {
    x: u64,
    m: u64,
    a: u64,
    s: u64,

    pub fn sum(self: *const Rating) u64 {
        return self.x + self.m + self.a + self.s;
    }
};

const Instruction = struct {
    varName: Str,
    expr: u8,
    value: u64,
    to: Str,

    fn canProcessInternal(self: *const Instruction, n: Str, v: u64) bool {
        if (util.eqlStr(self.varName, n) and self.expr == '>') return v > self.value;
        if (util.eqlStr(self.varName, n) and self.expr == '<') return v < self.value;

        return false;
    }

    pub fn canProcess(self: *const Instruction, r: Rating) bool {
        return self.canProcessInternal("x", r.x) or self.canProcessInternal("m", r.m) or self.canProcessInternal("a", r.a) or self.canProcessInternal("s", r.s);
    }
};

// name{instructions,default}
const Workflow = struct {
    name: Str,
    instructions: []Instruction,
    default: Str,

    pub fn apply(self: *Workflow, rating: Rating) Str {
        for (self.instructions) |inst| if (inst.canProcess(rating)) return inst.to;
        return self.default;
    }

    pub fn split(self: *Workflow, rating: NRating, adj: std.StringHashMap(Workflow), allocator: Allocator) !std.ArrayList(RW) {
        var res = std.ArrayList(RW).init(allocator);

        var q = queue.Queue(NRating).init(allocator);
        try q.enqueue(rating);

        for (self.instructions) |ins| {
            var size = q.getSize();
            for (0..size) |_| {
                var r: NRating = q.dequeue().?;
                var splits = try r.split(ins, allocator);
                for (splits.items) |item| {
                    var rn = item[0];
                    var to = item[1];

                    if (to != null) {
                        if (to.?[0] == 'A') {
                            try res.append(.{ rn, null });
                        } else if (to.?[0] != 'R') {
                            try res.append(.{ rn, adj.get(to.?).? });
                        }
                    } else {
                        try q.enqueue(rn);
                    }
                }
            }
        }

        if (self.default[0] == 'A') {
            while (q.nonEmpty()) {
                var x = q.dequeue().?;
                try res.append(.{ x, null });
            }
        } else if (self.default[0] != 'R') {
            while (q.nonEmpty()) {
                var x = q.dequeue().?;
                try res.append(.{ x, adj.get(self.default).? });
            }
        }

        return res;
    }
};

fn parseInstruction(input: Str, to: Str, delim: u8) !Instruction {
    var lc = util.splitStr(input, &[_]u8{delim});
    return Instruction{
        .varName = lc.next().?,
        .expr = delim,
        .value = try util.parseInt(u64, lc.next().?, 10),
        .to = to,
    };
}

fn parseWorkflows(lines: Str, allocator: Allocator) !std.StringHashMap(Workflow) {
    var res = std.StringHashMap(Workflow).init(allocator);

    var split = util.splitStr(lines, "\n");
    while (split.next()) |line| {
        var partsBuf: [2][]const u8 = undefined;
        var parts = util.splitAnyIntoBuf(line, "{}", &partsBuf);

        var instructionList = std.ArrayList(Instruction).init(allocator);
        var sit = util.splitStr(parts[1], ",");
        var default: Str = undefined;
        while (sit.next()) |rline| {
            if (std.mem.indexOf(u8, rline, ":") != null) {
                var csplit = util.splitStr(rline, ":");
                var i = csplit.next().?;
                var to = csplit.next().?;
                if (std.mem.indexOf(u8, i, "<") != null) {
                    var inst = try parseInstruction(i, to, '<');
                    try instructionList.append(inst);
                } else {
                    var inst = try parseInstruction(i, to, '>');
                    try instructionList.append(inst);
                }
            } else {
                default = rline;
            }
        }

        var w = Workflow{
            .name = parts[0],
            .instructions = instructionList.items,
            .default = default,
        };

        try res.put(w.name, w);
    }

    return res;
}

fn parseRatings(lines: Str, allocator: Allocator) !std.ArrayList(Rating) {
    var res = std.ArrayList(Rating).init(allocator);
    var split = util.splitStr(lines, "\n");
    while (split.next()) |line| {
        var it = std.mem.tokenizeAny(u8, line, "{},");
        var r = Rating{ .x = 0, .m = 0, .a = 0, .s = 0 };
        while (it.next()) |part| {
            const num = try std.fmt.parseInt(u64, part[2..], 10);
            const n = part[0];
            if (n == 'x') r.x = num;
            if (n == 'm') r.m = num;
            if (n == 'a') r.a = num;
            if (n == 's') r.s = num;
        }

        try res.append(r);
    }

    return res;
}

pub fn part1(input: Str) !u64 {
    var arena = util.arena_gpa;
    defer arena.deinit();
    var allocator = arena.allocator();

    var split = util.splitStr(input, "\n\n");
    var workflowStr = split.next().?;
    var ratingsStr = split.next().?;

    var adj = try parseWorkflows(workflowStr, allocator);
    defer adj.deinit();

    var ratings = try parseRatings(ratingsStr, allocator);
    defer ratings.deinit();

    var res: u64 = 0;
    for (ratings.items) |rating| {
        var q = queue.Queue(Workflow).init(allocator);
        try q.enqueue(adj.get("in").?);

        while (q.nonEmpty()) {
            var w: Workflow = q.dequeue().?;

            var to = w.apply(rating);

            if (to[0] == 'A') {
                res += rating.sum();
            } else if (to[0] != 'R') {
                if (adj.get(to)) |next| try q.enqueue(next);
            }
        }
    }

    return res;
}

pub fn part2(input: Str) !u64 {
    var arena = util.arena_gpa;
    defer arena.deinit();
    var allocator = arena.allocator();

    var split = util.splitStr(input, "\n\n");
    var workflowStr = split.next().?;

    var adj = try parseWorkflows(workflowStr, allocator);
    defer adj.deinit();

    var q = queue.Queue(RW).init(allocator);
    try q.enqueue(.{ NRating{}, adj.get("in") });

    var resList = std.ArrayList(NRating).init(allocator);
    defer resList.deinit();

    while (q.nonEmpty()) {
        var x = q.dequeue().?;
        var wf: Workflow = x[1].?;
        var rating: NRating = x[0];

        var splits = try wf.split(rating, adj, allocator);
        defer splits.deinit();

        for (splits.items) |branch| {
            if (branch[1] == null) try resList.append(branch[0]) else try q.enqueue(branch);
        }
    }
    var res: u64 = 0;
    for (resList.items) |item| res += item.combinations();
    return res;
}

pub fn main() !void {}

test "example-part1" {
    const actual = try part1(@embedFile("example1.txt"));
    const expected = @as(u64, 19114);

    try util.expectEqual(expected, actual);
}

test "input-part1" {
    const actual = try part1(@embedFile("input1.txt"));
    const expected = @as(u64, 325952);

    try util.expectEqual(expected, actual);
}

test "example-part2" {
    const actual = try part2(@embedFile("example1.txt"));
    const expected = @as(u64, 167409079868000);

    try util.expectEqual(expected, actual);
}

test "input-part2" {
    const actual = try part2(@embedFile("input1.txt"));
    const expected = @as(u64, 125744206494820);

    try util.expectEqual(expected, actual);
}
