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
            try countBytes(filename.?);
        } else if (std.mem.eql(u8, arg, "-l")) {
            const filename = args.next();
            if (filename == null) {
                std.debug.print("Error: Missing filename argument. \n", .{});
                return;
            }
            try countLines(filename.?);
        } else if (std.mem.eql(u8, arg, "-w")) {
            const filename = args.next();
            if (filename == null) {
                std.debug.print("Error: Missing filename argument. \n", .{});
                return;
            }
            try countWords(filename.?);
        } else {
            std.debug.print("Error: Unexpected argument '{s}'.\n", .{arg});
            return;
        }
    }
}

fn countBytes(filename: []const u8) !void {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    const fileInfo = try file.stat();
    const fileSize = fileInfo.size;

    std.debug.print("{d} {s}\n", .{ fileSize, filename });
}

fn countLines(filename: []const u8) !void {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var lineCount: usize = 0;
    var buffer: [4096]u8 = undefined;
    while (try file.reader().readUntilDelimiterOrEof(&buffer, '\n')) |_| {
        lineCount += 1;
    }

    std.debug.print("{d} {s}\n", .{ lineCount, filename });
}

fn countWords(filename: []const u8) !void {
    const file = try std.fs.cwd().openFile(filename, .{ .read = true });
    defer file.close();

    var wordCount: usize = 0;
    var buffer: [4096]u8 = undefined;
    var inWord = false;

    while (try file.reader().read(&buffer)) |chunk| {
        var index: usize = 0;
        while (index < chunk.len) {
            const c = chunk[index];
            const isDelimiter = c == ' ' or c == '\n' or c == '\t' or c == '\r';
            if (inWord and isDelimiter) {
                wordCount += 1;
                inWord = false;
            } else if (!inWord and !isDelimiter) {
                inWord = true;
            }
            index += 1;
        }
    }

    // If the file ends while still in a word, count that word
    if (inWord) {
        wordCount += 1;
    }

    std.debug.print("{d} {s}\n", .{ wordCount, filename });
}
