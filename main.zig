const std = @import("std");
const out = std.debug.print;

pub const byte_pattern = struct { byte_value: u8, wildcard: bool };

pub const pattern_array = std.BoundedArray(byte_pattern, 256);

fn byteSplit(str: []const u8, delim: u8, array: *pattern_array) !void {
    var last_delim_loc: usize = 0;
    var num_bytes: usize = 0;

    for (0..str.len) |i| {
        const last_byte = i == str.len - 1;
        const c_is_delim = str[i] == delim;

        if (c_is_delim != last_byte) {
            var slc = if (last_byte) str[last_delim_loc..] else str[last_delim_loc..i];
            if (std.mem.eql(u8, slc, "??")) {
                _ = try array.append(byte_pattern{ .byte_value = 0x00, .wildcard = true });
                num_bytes += 1;
            } else {
                const parsed = try std.fmt.parseUnsigned(u8, slc, 16);
                if (@TypeOf(parsed) == u8) {
                    _ = try array.append(byte_pattern{ .byte_value = parsed, .wildcard = false });
                    num_bytes += 1;
                }
            }
            last_delim_loc = i + 1;
        }
    }
    _ = try array.resize(num_bytes);
}

// test "Pattern To Byte" {
//     const pattern_1 = "FF 08 ?? 44 24 1C";

//     var arr = pattern_array{};

//     _ = try byteSplit(pattern_1, ' ', &arr);
//     out("\n", .{});
//     var slc = arr.constSlice();
//     for (0..arr.len) |i| {
//         out("[{d}]: 0x{X} (wildcard: {s})\n", .{ i, slc[i].byte_value, if (slc[i].wildcard) "true" else "false" });
//     }
// }
