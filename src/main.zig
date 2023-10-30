const std = @import("std");

pub fn main() !void {
    var args = std.process.args();
    _ = args.skip(); // Skip the program name argument and discard the return value

    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "-c")) {
            const filename = args.next();
            if (filename == null) {
                std.debug.print("Error: Missing filename argument.\n", .{});
                return;
            }
            try countBytes(filename.?); // Unwrap the optional value
        } else {
            // unexpected argument
            std.debug.print("Error: Unexpected argument '{s}'.\n", .{arg}); // Corrected format specifier
            return;
        }
    }
}

fn countBytes(filename: []const u8) !void {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    const fileInfo = try file.stat();
    const fileSize = fileInfo.size;

    std.debug.print("{d} {s}\n", .{ fileSize, filename }); // Corrected format specifier
}
