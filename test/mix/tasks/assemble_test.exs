defmodule Mix.Tasks.AssembleTest do
  use ExUnit.Case

  setup do
    tmp_filename = Base.encode16(:crypto.strong_rand_bytes(16))

    input_file = Path.join("/tmp", tmp_filename <> ".asm")
    output_file = Path.join("/tmp", tmp_filename <> ".hack")

    on_exit(fn ->
      File.rm!(input_file)
      File.rm!(output_file)
    end)

    [input_file: input_file, output_file: output_file]
  end

  test "outputs code to a .hack file given a .asm file", %{
    input_file: input_file,
    output_file: output_file
  } do
    input = """
    // Adds RAM[0] to RAM[1].
    // Puts the result in RAM[2].

    @0
    D=M
    @1
    D=D+M
    @2
    M=D
    """

    expected = """
    0000000000000000
    1111110000010000
    0000000000000001
    1111000010010000
    0000000000000010
    1110001100001000
    """

    File.write!(input_file, input)

    Mix.Tasks.Assemble.run([input_file])

    assert File.read!(output_file) == expected
  end

  test "handles symbols", %{
    input_file: input_file,
    output_file: output_file
  } do
    input = """
    // This file is part of www.nand2tetris.org
    // and the book "The Elements of Computing Systems"
    // by Nisan and Schocken, MIT Press.
    // File name: projects/06/max/Max.asm

    // Computes R2 = max(R0, R1)  (R0,R1,R2 refer to RAM[0],RAM[1],RAM[2])

      @R0
      D=M              // D = first number
      @R1
      D=D-M            // D = first number - second number
      @OUTPUT_FIRST
      D;JGT            // if D>0 (first is greater) goto output_first
      @R1
      D=M              // D = second number
      @OUTPUT_D
      0;JMP            // goto output_d
    (OUTPUT_FIRST)
      @R0
      D=M              // D = first number
    (OUTPUT_D)
      @R2
      M=D              // M[2] = D (greatest number)
    (INFINITE_LOOP)
      @INFINITE_LOOP
      0;JMP            // infinite loop
    """

    expected = """
    0000000000000000
    1111110000010000
    0000000000000001
    1111010011010000
    0000000000001010
    1110001100000001
    0000000000000001
    1111110000010000
    0000000000001100
    1110101010000111
    0000000000000000
    1111110000010000
    0000000000000010
    1110001100001000
    0000000000001110
    1110101010000111
    """

    File.write!(input_file, input)

    Mix.Tasks.Assemble.run([input_file])

    assert File.read!(output_file) == expected
  end
end
