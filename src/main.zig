const std = @import("std");

pub fn main() !void {
    var args = std.process.args();
    _ = args.skip(); // Skip the program name argument

    var operation: enum { CountLines, CountWords, CountBytes, CountCharacters, None } = .None;
    var filename: ?[]const u8 = null; // Optional filename

    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "-c")) {
            operation = .CountBytes;
        } else if (std.mem.eql(u8, arg, "-l")) {
            operation = .CountLines;
        } else if (std.mem.eql(u8, arg, "-w")) {
            operation = .CountWords;
        } else if (std.mem.eql(u8, arg, "-m")) {
            operation = .CountCharacters;
        } else {
            // Treat as a filename if it's not an option flag
            if (filename == null) {
                filename = arg;
            } else {
                std.debug.print("Error: Unexpected argument '{s}'.\n", .{arg});
                return;
            }
        }
    }

    // Perform the operation based on the source of input (file or stdin)
    if (filename) |fname| {
        switch (operation) {
            .CountBytes => try countBytes(fname),
            .CountLines => try countLines(fname),
            .CountWords => try countWords(fname),
            .CountCharacters => try countCharacters(fname),
            .None => {
                try countBytes(fname);
                try countLines(fname);
                try countWords(fname);
            },
        }
    } else {
        // Read from stdin if no filename is provided
        const stdinReader = std.io.getStdIn().reader();
        switch (operation) {
            .CountBytes => try countBytesFromReader(stdinReader),
            .CountLines => try countLinesFromReader(stdinReader),
            .CountWords => try countWordsFromReader(stdinReader),
            .CountCharacters => try countCharactersFromReader(stdinReader),
            .None => {
                try countBytesFromReader(stdinReader);
                try countLinesFromReader(stdinReader);
                try countWordsFromReader(stdinReader);
            },
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

fn countLinesFromReader(reader: anytype) !void {
    var lineCount: usize = 0;
    var buffer: [4096]u8 = undefined;

    while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |_| {
        lineCount += 1;
    }

    std.debug.print("{d}\n", .{lineCount});
}

fn countBytesFromReader(reader: anytype) !void {
    var byteCount: usize = 0;
    var buffer: [4096]u8 = undefined;

    while (true) {
        const bytesRead = try reader.read(&buffer);
        if (bytesRead == 0) break; // End of file

        byteCount += bytesRead; // Add the number of bytes read to the byte count
    }

    std.debug.print("{d}\n", .{byteCount});
}

fn countCharactersFromReader(reader: anytype) !void {
    var characterCount: usize = 0;
    var buffer: [4096]u8 = undefined;

    while (true) {
        const bytesRead = try reader.read(&buffer);
        if (bytesRead == 0) break; // End of file

        characterCount += bytesRead; // Add the number of bytes read to the character count
    }

    std.debug.print("{d}\n", .{characterCount});
}

fn countWordsFromReader(reader: anytype) !void {
    var wordCount: usize = 0;
    var buffer: [4096]u8 = undefined;
    var inWord = false;

    while (true) {
        const bytesRead = try reader.read(&buffer);
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

    std.debug.print("{d}\n", .{wordCount});
}
