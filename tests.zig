const patterns = @import("main.zig");
const std = @import("std");
const expect = std.testing.expect;

pub const test_byte_dump = [_]u8{
    0x51, 0x75, 0x69, 0x73, 0x71, 0x75, 0x65, 0x20, 0x66, 0x61,
    0x75, 0x63, 0x69, 0x62, 0x75, 0x73, 0x20, 0x74, 0x65, 0x6c,
    0x6c, 0x75, 0x73, 0x20, 0x70, 0x75, 0x72, 0x75, 0x73, 0x2c,
    0x20, 0x61, 0x63, 0x20, 0x76, 0x65, 0x73, 0x74, 0x69, 0x62,
    0x75, 0x6c, 0x75, 0x6d, 0x20, 0x1e, 0x69, 0x62, 0x68, 0x20,
    0x66, 0x69, 0x1e, 0x69, 0x62, 0x75, 0x73, 0x20, 0x76, 0x65,
    0x6c, 0x2e, 0x20, 0x53, 0x65, 0x64, 0x20, 0x74, 0x69, 0x1e,
    0x63, 0x69, 0x64, 0x75, 0x6e, 0x74, 0x2c, 0x20, 0x6c, 0x61,
    0x63, 0x75, 0x73, 0x20, 0x73, 0x69, 0x74, 0x20, 0x61, 0x6d,
    0x65, 0x74, 0x20, 0x6c, 0x6f, 0x62, 0x6f, 0x72, 0x74, 0x69,
    0x73, 0x20, 0x66, 0x61, 0x63, 0x69, 0x6c, 0x69, 0x73, 0x69,
    0x73, 0x2c, 0x20, 0x1e, 0x69, 0x73, 0x69, 0x20, 0x1e, 0x65,
    0x71, 0x75, 0x65, 0x20, 0x62, 0x6c, 0x61, 0x1e, 0x64, 0x69,
};

test "Pattern Search No Wildcards" {
    var found = false;
    const size_to_find: usize = 3;
    const bytes_to_find = [_]u8{ 0x75, 0x6e, 0x74 };

    for (0..test_byte_dump.len - 1) |i| {
        // Find initial byte
        if (test_byte_dump[i] == bytes_to_find[0]) {
            if (std.mem.eql(u8, test_byte_dump[i .. i + size_to_find], &bytes_to_find)) {
                found = true;
                //std.debug.print("\nFound at Offset: 0x{X}\n", .{i});
            }
        }
    }
    _ = try std.testing.expect(found == true);
}

test "Pattern Search with Wildcards - Explicit" {
    var found = false;

    // Same operations as parse, just manual for tests
    var bytes_to_find = patterns.pattern_array{};
    _ = try bytes_to_find.append(patterns.byte_pattern{ .byte_value = 0x6e, .wildcard = false });
    _ = try bytes_to_find.append(patterns.byte_pattern{ .byte_value = 0x00, .wildcard = true });
    _ = try bytes_to_find.append(patterns.byte_pattern{ .byte_value = 0x2c, .wildcard = false });
    _ = try bytes_to_find.resize(3);

    const byte_array = bytes_to_find.constSlice();
    for (0..test_byte_dump.len - 1) |i| {
        // Find initial byte
        if (test_byte_dump[i] == byte_array[0].byte_value) {
            // compare byte array, skip wildcards
            compare: for (1..byte_array.len) |j| {
                if (byte_array[j].wildcard) {
                    continue :compare;
                }
                if (test_byte_dump[i + j] != byte_array[j].byte_value) {
                    break :compare;
                }
                if (j == bytes_to_find.len - 1) {
                    found = true;
                    //std.debug.print("\nFound at Offset: 0x{X}\n", .{i});
                }
            }
        }
    }
    _ = try std.testing.expect(found == true);
}

test "Pattern Search with Wildcards - Parsed" {
    var found = false;

    // Same operations as parse, just manual for tests
    var bytes_to_find = patterns.pattern_array{};
    _ = try patterns.parsePattern("6E ?? 2C", ' ', &bytes_to_find);

    const byte_array = bytes_to_find.constSlice();
    for (0..test_byte_dump.len - 1) |i| {
        // Find initial byte
        if (test_byte_dump[i] == byte_array[0].byte_value) {
            // compare byte array, skip wildcards
            compare: for (1..byte_array.len) |j| {
                if (byte_array[j].wildcard) {
                    continue :compare;
                }
                if (test_byte_dump[i + j] != byte_array[j].byte_value) {
                    break :compare;
                }
                if (j == bytes_to_find.len - 1) {
                    found = true;
                    //std.debug.print("\nFound at Offset: 0x{X}\n", .{i});
                }
            }
        }
    }
    _ = try std.testing.expect(found == true);
}
