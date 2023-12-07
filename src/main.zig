const std = @import("std");

pub fn main() !void {
    var args = std.process.args();
    _ = args.skip();

    var operation: enum { CountLines, CountWords, CountBytes, CountCharacters, None } = .None;
    var filename: ?[]const u8 = null;

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
            if (filename == null) {
                filename = arg;
            } else {
                std.debug.print("Error: Unexpected argument '{s}'.\n", .{arg});
                return;
            }
        }
    }

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
        if (bytesRead == 0) break;

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
        if (bytesRead == 0) break;

        characterCount += bytesRead;
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
        if (bytesRead == 0) break;

        byteCount += bytesRead;
    }

    std.debug.print("{d}\n", .{byteCount});
}

fn countCharactersFromReader(reader: anytype) !void {
    var characterCount: usize = 0;
    var buffer: [4096]u8 = undefined;

    while (true) {
        const bytesRead = try reader.read(&buffer);
        if (bytesRead == 0) break;

        characterCount += bytesRead;
    }

    std.debug.print("{d}\n", .{characterCount});
}

fn countWordsFromReader(reader: anytype) !void {
    var wordCount: usize = 0;
    var buffer: [4096]u8 = undefined;
    var inWord = false;

    while (true) {
        const bytesRead = try reader.read(&buffer);
        if (bytesRead == 0) break;

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

    if (inWord) {
        wordCount += 1;
    }

    std.debug.print("{d}\n", .{wordCount});
}
