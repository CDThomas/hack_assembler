defmodule HackAssembler.Code do
  alias HackAssembler.Parser
  alias HackAssembler.Parser.AInstruction
  alias HackAssembler.Parser.CInstruction

  @a_instruction_op_code "0"
  @c_instruction_op_code "1"
  @c_instruction_prefix @c_instruction_op_code <> "11"

  @destinations %{
    nil => "000",
    "M" => "001",
    "D" => "010",
    "MD" => "011",
    "A" => "100",
    "AM" => "101",
    "AD" => "110",
    "AMD" => "111"
  }

  @computations %{
    "0" => "0101010",
    "1" => "0111111",
    "-1" => "0111010",
    "D" => "0001100",
    "A" => "0110000",
    "M" => "1110000",
    "!D" => "0001101",
    "!A" => "0110001",
    "!M" => "1110001",
    "-D" => "0001111",
    "-A" => "0110011",
    "-M" => "1110011",
    "D+1" => "0011111",
    "A+1" => "0110111",
    "M+1" => "1110111",
    "D-1" => "0001110",
    "A-1" => "0110010",
    "M-1" => "1110010",
    "D+A" => "0000010",
    "D+M" => "1000010",
    "D-A" => "0010011",
    "D-M" => "1010011",
    "A-D" => "0000111",
    "M-D" => "1000111",
    "D&A" => "0000000",
    "D&M" => "1000000",
    "D|A" => "0010101",
    "D|M" => "1010101"
  }

  @jumps %{
    nil => "000",
    "JGT" => "001",
    "JEQ" => "010",
    "JGE" => "011",
    "JLT" => "100",
    "JNE" => "101",
    "JLE" => "110",
    "JMP" => "111"
  }

  @spec to_hack(instruction :: Parser.instruction()) :: binary()
  def to_hack(%AInstruction{address: address}) do
    address_in_hack =
      address
      |> Integer.to_string(2)
      |> String.pad_leading(15, "0")

    @a_instruction_op_code <> address_in_hack
  end

  def to_hack(%CInstruction{comp: comp, dest: dest, jump: jump}) do
    @c_instruction_prefix <>
      @computations[comp] <>
      @destinations[dest] <>
      @jumps[jump]
  end
end
