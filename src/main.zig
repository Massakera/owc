const std = @import("std");

pub fn main() !void {
    var args = std.process.args();
    _ = args.skip(); // Skip the program name argument and discard the return value

    var optionProvided = false;

    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "-c")) {
            optionProvided = true;
            const filename = args.next();
            try countBytes(filename.?);
        } else if (std.mem.eql(u8, arg, "-l")) {
            optionProvided = true;
            const filename = args.next();
            try countLines(filename.?);
        } else if (std.mem.eql(u8, arg, "-w")) {
            optionProvided = true;
            const filename = args.next();
            try countWords(filename.?);
        } else if (std.mem.eql(u8, arg, "-m")) {
            optionProvided = true;
            const filename = args.next();
            try countCharacters(filename.?);
        } else {
            std.debug.print("Error: Unexpected argument '{s}'.\n", .{arg});
            return;
        }
    }

    if (!optionProvided) {
        const filename: []const u8 = args.next().?;
        try countBytes(filename);
        try countLines(filename);
        try countWords(filename);
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
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var wordCount: usize = 0;
    var buffer: [4096]u8 = undefined;
    var inWord = false;

    while (true) {
        const bytesRead = try file.reader().read(&buffer);
        if (bytesRead == 0) break; // End of file

        var index: usize = 0;
        while (index < bytesRead) {
            const c = buffer[index];
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

fn countCharacters(filename: []const u8) !void {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var characterCount: usize = 0;
    var buffer: [4096]u8 = undefined;

    while (true) {
        const bytesRead = try file.reader().read(&buffer);
        if (bytesRead == 0) break; // End of file

        characterCount += bytesRead; // Add the number of bytes read to the character count
    }

    std.debug.print("{d} {s}\n", .{ characterCount, filename });
}
