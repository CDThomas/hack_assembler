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
end
