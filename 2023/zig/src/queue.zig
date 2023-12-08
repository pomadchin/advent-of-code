// From https://ziglang.org/learn/samples/

const std = @import("std");

pub fn Queue(comptime Child: type) type {
    return struct {
        const This = @This();
        const Node = struct {
            data: Child,
            next: ?*Node,
        };
        gpa: std.mem.Allocator,
        start: ?*Node,
        end: ?*Node,
        size: usize,

        pub fn init(gpa: std.mem.Allocator) This {
            return This{ .gpa = gpa, .start = null, .end = null, .size = 0 };
        }
        pub fn enqueue(this: *This, value: Child) !void {
            const node = try this.gpa.create(Node);
            node.* = .{ .data = value, .next = null };
            if (this.end) |end| end.next = node //
            else this.start = node;
            this.end = node;
            this.size += 1;
        }
        pub fn dequeue(this: *This) ?Child {
            const start = this.start orelse return null;
            defer this.gpa.destroy(start);
            if (start.next) |next| {
                this.start = next;
                this.size -= 1;
            } else {
                this.start = null;
                this.end = null;
                this.size = 0;
            }
            return start.data;
        }
        pub fn isEmpty(this: This) bool {
            return this.start == null;
        }

        pub fn getSize(this: This) usize {
            return this.size;
        }
    };
}

test "queue" {
    var int_queue = Queue(i32).init(std.testing.allocator);

    try std.testing.expectEqual(true, int_queue.isEmpty());

    try int_queue.enqueue(25);
    try int_queue.enqueue(50);
    try int_queue.enqueue(75);
    try int_queue.enqueue(100);

    try std.testing.expectEqual(false, int_queue.isEmpty());

    try std.testing.expectEqual(int_queue.dequeue(), 25);
    try std.testing.expectEqual(int_queue.dequeue(), 50);
    try std.testing.expectEqual(int_queue.dequeue(), 75);
    try std.testing.expectEqual(int_queue.dequeue(), 100);
    try std.testing.expectEqual(int_queue.dequeue(), null);

    try std.testing.expectEqual(true, int_queue.isEmpty());

    try int_queue.enqueue(5);
    try std.testing.expectEqual(false, int_queue.isEmpty());
    try std.testing.expectEqual(int_queue.dequeue(), 5);
    try std.testing.expectEqual(int_queue.dequeue(), null);
}
