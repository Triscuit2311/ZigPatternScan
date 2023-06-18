const std = @import("std");
const out = std.debug.print;

pub const byte_pattern = struct { byte_value: u8, wildcard: bool };

const pattern_array_size: u8 = 128;
pub const pattern_array = std.BoundedArray(byte_pattern, pattern_array_size);

pub fn parsePattern(str: []const u8, delim: u8, array: *pattern_array) !void {
    var last_delim_loc: usize = 0;
    var num_bytes: usize = 0;

    for (0..str.len) |i| {
        const is_last_byte = (i == str.len - 1);
        const char_is_delim = (str[i] == delim);

        if (char_is_delim or is_last_byte) {

            // Slice to the end or current index based on index position
            var byte_slice = if (is_last_byte) str[i - 1 ..] else str[i - 2 .. i];

            if (byte_slice.len < 2) {
                break;
            }
            // Add wildcard if wildcard byte found
            if (std.mem.eql(u8, byte_slice, "??")) {
                _ = try array.append(byte_pattern{ .byte_value = 0x00, .wildcard = true });
                num_bytes += 1;
                continue;
            }

            // Parse our value from the byte string
            // Note radix is 16 since the bytes are in hex
            const parsed = try std.fmt.parseUnsigned(u8, byte_slice, 16);

            if (@TypeOf(parsed) == u8) {
                _ = try array.append(byte_pattern{ .byte_value = parsed, .wildcard = false });
                num_bytes += 1;
            }

            // Update delim marker
            last_delim_loc = i + 1;
        }
    }
    _ = try array.resize(num_bytes);
}

// test "Pattern To Byte" {
//     const pattern_1 = "FF 08 ?? 44 24 1C";

//     var arr = pattern_array{};

//     _ = try parsePattern(pattern_1, ' ', &arr);
//     out("\n", .{});
//     var slc = arr.constSlice();
//     for (0..arr.len) |i| {
//         out("[{d}]: 0x{X} (wildcard: {s})\n", .{ i, slc[i].byte_value, if (slc[i].wildcard) "true" else "false" });
//     }
// }
