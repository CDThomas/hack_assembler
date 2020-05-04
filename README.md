# HackAssembler

This project is an Elixir implementation of the the assembler described in [project six](https://www.nand2tetris.org/project06) of the course [Nand2Tetris Part One](https://www.nand2tetris.org/).

## Usage

First, install deps and compile the source code:

```
mix deps.get
mix compile
```

To assemble a `.asm` file containing assembly code into a `.hack` file containing Hack machine code, run:

```
mix assemble [INPUT_FILE_PATH]
```

Note: `INPUT_FILE_PATH` must have the `.asm` extension. The output file will be written to the same directory as the input file. The output file will also have the same name as the input file, but with the `.hack` extension.

## Implementation

This project follows the general algorithm described in part six of [Nand2Tetris Part One](https://www.nand2tetris.org/).

Assembly happens in two passes of the input code. The first pass adds labels (e.g. `(LOOP)`) to the symbol table. The second pass adds variables (e.g. `@i`) to the symbol table and translates instructions to Hack machine code.

For more details on the assembly syntax for the Hack machine, see part four of [Nand2Tetris Part One](https://www.nand2tetris.org/). For more details on the assembler itself, see part six.

For details on individual modules, see the `@moduledoc`s.

## Developing

Run tests with:

```
mix test
```

Tests can also run in watch mode:

```
mix test.watch
```

To run the type checker:

```
mix dialyzer
```
