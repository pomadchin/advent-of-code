const std = @import("std");
const util = @import("util");
const bufIter = @import("buf-iter");
const queue = @import("queue");

const Allocator = std.mem.Allocator;

const Tuple = util.Tuple;
const Str = util.Str;

const ORDER_PART1: Str = "AKQJT98765432";
const ORDER_PART2: Str = "AKQT98765432J";

const Hand = struct { cards: Str, bid: i64 };

const HandScored = struct { score: i64, cards: [5]usize, bid: i64 };

pub fn handScoredCmp() fn (void, HandScored, HandScored) bool {
    return struct {
        pub fn inner(_: void, a: HandScored, b: HandScored) bool {
            var scoresCmp = a.score > b.score;

            if (scoresCmp) return scoresCmp;
            var cardsCmp = true;

            for (0..a.cards.len) |i| {
                var ac = a.cards[i];
                var bc = b.cards[i];
                if (ac == bc) continue;
                cardsCmp = ac > bc;
                break;
            }

            if (a.score == b.score) return cardsCmp;
            return scoresCmp and cardsCmp;
        }
    }.inner;
}

fn parseHand(line: Str) !Hand {
    var split = util.splitStr(line, " ");
    var cards = split.next().?;
    var bid = try util.parseInt(i64, split.next().?, 10);

    return Hand{ .cards = cards, .bid = bid };
}

fn singleHandScore(str: Str, bufInt: []usize, order: Str) !void {
    for (str, 0..) |c, i| {
        bufInt[i] = util.indexOf(u8, order, c).?;
    }
}

fn handScore(hand: Hand) !i64 {
    return cardsScore(hand.cards);
}

fn cardsScore(cards: Str) !i64 {
    var counts = std.AutoArrayHashMap(u8, i64).init(util.gpa);
    defer counts.deinit();

    for (cards) |card| {
        if (counts.get(card)) |value| {
            try counts.put(card, value + 1);
        } else {
            try counts.put(card, 1);
        }
    }

    var countValues = counts.values();
    std.sort.pdq(i64, countValues, {}, std.sort.desc(i64));

    if (countValues[0] == 5) { // five of a kind
        return 1;
    } else if (countValues[0] == 4) { // four of a kind
        return 2;
    } else if (countValues[0] == 3 and countValues[1] == 2) { // full house
        return 3;
    } else if (countValues[0] == 3) { // three of a kind
        return 4;
    } else if (countValues[0] == 2 and countValues[1] == 2) { // two pairs
        return 5;
    } else if (countValues[0] == 2) { // pair
        return 6;
    }
    // high card
    return 7;
}

fn countJockers(input: Str, output: []u8) Tuple(&.{ usize, usize }) {
    var count: usize = 0;
    var idx: usize = 0;
    for (input) |card| {
        if (card == 'J') {
            count += 1;
            continue;
        }

        output[idx] = card;
        idx += 1;
    }

    return .{ idx, count };
}

pub fn part1(input: Str) !i64 {
    var arena = util.arena_gpa;
    defer arena.deinit();

    var allocator = arena.allocator();

    var lines = util.splitStr(input, "\n");
    var hands = std.ArrayList(HandScored).init(allocator);
    defer hands.deinit();

    while (lines.next()) |line| {
        var hand = try parseHand(line);
        var score = try handScore(hand);

        var cardsBuf: [5]usize = undefined;
        try singleHandScore(hand.cards, &cardsBuf, ORDER_PART1);

        try hands.append(HandScored{ .score = score, .cards = cardsBuf, .bid = hand.bid });
    }

    var handsSlice = try hands.toOwnedSlice();

    std.sort.pdq(HandScored, handsSlice, {}, handScoredCmp());

    var res: i64 = 0;
    for (handsSlice, 0..) |hand, i| res += hand.bid * (@as(i64, @intCast(i)) + 1);

    return res;
}

pub fn part2(input: Str) !i64 {
    var arena = util.arena_gpa;
    defer arena.deinit();

    var allocator = arena.allocator();

    var lines = util.splitStr(input, "\n");
    var hands = std.ArrayList(HandScored).init(allocator);
    defer hands.deinit();

    while (lines.next()) |line| {
        var hand = try parseHand(line);
        var score = try handScore(hand);

        var cardsNoJocker: [5]u8 = undefined;

        var jockerCounts = countJockers(hand.cards, &cardsNoJocker);

        var idx = jockerCounts[0];
        var jCount = jockerCounts[1];

        var list = try util.product(u8, ORDER_PART2.len - 1, jCount, ORDER_PART2, allocator);

        for (list.items) |chars| {
            // chars of length that mach count of J
            // construct a new hand
            var handNew: [5]u8 = undefined;
            util.copyStr(&handNew, &cardsNoJocker);

            util.concatStr(idx, chars.items, &handNew);

            var scoreNew = try cardsScore(&handNew);

            score = @min(score, scoreNew);
        }

        var cardsBuf: [5]usize = undefined;
        try singleHandScore(hand.cards, &cardsBuf, ORDER_PART2);

        try hands.append(HandScored{ .score = score, .cards = cardsBuf, .bid = hand.bid });
    }

    var handsSlice = try hands.toOwnedSlice();

    std.sort.pdq(HandScored, handsSlice, {}, handScoredCmp());

    var res: i64 = 0;
    for (handsSlice, 0..) |hand, i| res += hand.bid * (@as(i64, @intCast(i)) + 1);

    return res;
}

pub fn main() !void {}

test "example-part1" {
    const actual = try part1(@embedFile("example1.txt"));
    const expected = @as(i64, 6440);

    try util.expectEqual(expected, actual);
}

test "input-part1" {
    const actual = try part1(@embedFile("input1.txt"));
    const expected = @as(i64, 249748283);

    try util.expectEqual(expected, actual);
}

test "example-part2" {
    // const actual = try part1(@embedFile("example2.txt"));
    const actual = try part2(@embedFile("example1.txt"));
    const expected = @as(i64, 5905);

    try util.expectEqual(expected, actual);
}

test "input-part2" {
    const actual = try part2(@embedFile("input1.txt"));
    const expected = @as(i64, 248029057);

    try util.expectEqual(expected, actual);
}
