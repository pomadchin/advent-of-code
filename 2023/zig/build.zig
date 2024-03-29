const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    setup_main(b, target, optimize);

    for (1..26) |day| {
        setup_day(b, target, optimize, day);
    }

    setup_test_all(b, target, optimize);
}

pub fn setup_main(
    b: *std.build.Builder,
    target: std.zig.CrossTarget,
    optimize: std.builtin.Mode,
) void {
    setup_module(b, target, optimize, "main", "", "src/main.zig");
}

pub fn setup_test_all(
    b: *std.build.Builder,
    target: std.zig.CrossTarget,
    optimize: std.builtin.Mode,
) void {
    setup_module(b, target, optimize, "all", "all", "src/test_all.zig");
}

pub fn setup_day(
    b: *std.build.Builder,
    target: std.zig.CrossTarget,
    optimize: std.builtin.Mode,
    day: usize,
) void {
    const path = b.fmt("day{:0>2}", .{day});
    const root_src = b.fmt("src/{s}/main.zig", .{path});

    setup_module(b, target, optimize, path, path, root_src);
}

pub fn setup_module(
    b: *std.build.Builder,
    target: std.zig.CrossTarget,
    optimize: std.builtin.Mode,
    name: []const u8,
    path: []const u8,
    root_src: []const u8,
) void {
    const exe = b.addExecutable(.{
        .name = name,
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = .{ .path = root_src },
        .target = target,
        .optimize = optimize,
    });

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    // It is also a default file used for the zig build run
    if (std.mem.eql(u8, name, "main")) {
        b.installArtifact(exe);
    }

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step_name = if (path.len == 0) "run" else b.fmt("run_{s}", .{path});
    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step(run_step_name, b.fmt("Run {s}", .{path}));
    run_step.dependOn(&run_cmd.step);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = root_src },
        .target = target,
        .optimize = optimize,
    });

    // exe.addAnonymousModule("util", .{ .source_file = .{ .path = "src/util.zig" } });
    // unit_tests.addAnonymousModule("util", .{ .source_file = .{ .path = "src/util.zig" } });

    const util_module = b.createModule(.{
        .source_file = .{ .path = "src/util.zig" },
        .dependencies = &.{},
    });

    const queue_module = b.createModule(.{
        .source_file = .{ .path = "src/queue.zig" },
        .dependencies = &.{},
    });

    const deque_module = b.createModule(.{
        .source_file = .{ .path = "src/deque.zig" },
        .dependencies = &.{},
    });

    const stack_module = b.createModule(.{
        .source_file = .{ .path = "src/stack.zig" },
        .dependencies = &.{},
    });

    const bufIter_module = b.createModule(.{
        .source_file = .{ .path = "src/buf-iter.zig" },
        .dependencies = &.{},
    });

    exe.addModule("util", util_module);
    unit_tests.addModule("util", util_module);

    exe.addModule("queue", queue_module);
    unit_tests.addModule("queue", queue_module);

    exe.addModule("deque", deque_module);
    unit_tests.addModule("deque", deque_module);

    exe.addModule("stack", stack_module);
    unit_tests.addModule("stack", stack_module);

    exe.addModule("buf-iter", bufIter_module);
    unit_tests.addModule("buf-iter", bufIter_module);

    const run_unit_tests = b.addRunArtifact(unit_tests);

    const test_step_name = if (path.len == 0) "test" else b.fmt("test_{s}", .{path});
    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step(test_step_name, b.fmt("Test {s}", .{path}));
    test_step.dependOn(&run_unit_tests.step);
}
