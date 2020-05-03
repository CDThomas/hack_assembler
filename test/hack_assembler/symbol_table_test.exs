defmodule HackAssembler.SymbolTableTest do
  use ExUnit.Case

  alias HackAssembler.SymbolTable

  describe "creating a new symbol table" do
    test "returns a SymbolTable with predefined symbols" do
      expected_symbols = %{
        "R0" => 0,
        "R1" => 1,
        "R2" => 2,
        "R3" => 3,
        "R4" => 4,
        "R5" => 5,
        "R6" => 6,
        "R7" => 7,
        "R8" => 8,
        "R9" => 9,
        "R10" => 10,
        "R11" => 11,
        "R12" => 12,
        "R13" => 13,
        "R14" => 14,
        "R15" => 15,
        "SCREEN" => 16_384,
        "KBD" => 24_576,
        "SP" => 0,
        "LCL" => 1,
        "ARG" => 2,
        "THIS" => 3,
        "THAT" => 4
      }

      %SymbolTable{symbols: symbols} = SymbolTable.new()

      assert symbols == expected_symbols
    end
  end

  describe "putting a new symbols in the table" do
    test "adds the symbols to the table with its value" do
      %SymbolTable{symbols: symbols} = SymbolTable.put(SymbolTable.new(), "LOOP", 10)
      assert symbols["LOOP"] == 10
    end
  end
end
