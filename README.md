# CCWC - Custom Character Word Counter

`ccwc` is a simple command line tool written in Zig, which is inspired by the Unix `wc` command. The tool reads a specified file and outputs the number of bytes in the file when supplied with the `-c` option.

## Getting Started

These instructions will help you get a copy of the project up and running on your local machine.

### Prerequisites

- [Zig Programming Language](https://ziglang.org/download/) (version 0.10.1 or newer)

### Building

To build the `ccwc` command line tool, navigate to the project directory and run:

```bash
zig build
```

## Usage example

```bash
./zig-out/bin/ccwc -c test.txt
```

