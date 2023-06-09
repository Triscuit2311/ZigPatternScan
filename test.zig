const patterns = @import("main.zig");
const std = @import("std");

test "DOINK" {
    var p = patterns.byte_pattern{ .byte_value = 0x00, .wildcard = true };
    try std.testing.expect(@TypeOf(p) == patterns.byte_pattern);
}
