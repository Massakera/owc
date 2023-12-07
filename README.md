# CCWC - Custom Character Word Counter

ccwc is a simple command line tool written in Zig, which takes inspiration from the Unix wc command. This tool can read a specified file or standard input and output the number of bytes, lines, words, or characters, based on the supplied options.

## Getting Started

These instructions will help you get a copy of the project up and running on your local machine.

### Prerequisites

Zig Programming Language (version 0.10.1 or newer)

### Building

To build the ccwc command line tool, navigate to the project directory and run:

```bash
zig build-exe source/main.zig
```

This command compiles the source code and produces an executable named main.

## Usage

The ccwc tool can be used with the following options:

- -c: Count the number of bytes.
- -l: Count the number of lines.
- -w: Count the number of words.
- -m: Count the number of characters.
If no option is provided, the tool will default to counting bytes, lines, and words.

### Usage Examples

To count the number of bytes in text.txt:

```bash
./main -c text.txt
```

To count the number of lines:

```bash
./main -l text.txt
```

For counting words:

```bash
./main -w text.txt
```

To count characters:

```bash
./main -m text.txt
```

Additionally, ccwc can read from standard input (stdin), allowing it to be used in a pipeline. For example, to count lines from text.txt using cat:

```bash
cat text.txt | ./main -l
```

In this case, if no filename is provided, ccwc reads the input from stdin.