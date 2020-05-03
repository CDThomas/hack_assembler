defmodule HackAssembler.ParserTest do
  use ExUnit.Case

  alias HackAssembler.Parser
  alias HackAssembler.Parser.AInstruction
  alias HackAssembler.Parser.CInstruction
  alias HackAssembler.Parser.Label

  describe "parsing A-instructions" do
    test "returns an AInstruction given a positive integer" do
      assert Parser.parse("@123") == {:ok, %AInstruction{address: 123}}
    end

    test "returns an AInstruction given zero" do
      assert Parser.parse("@0") == {:ok, %AInstruction{address: 0}}
    end

    test "returns an error given a negative integer" do
      assert Parser.parse("@-1") == {:error, :invalid_address}
    end

    # TODO: symbols
  end

  describe "parsing C-instructions" do
    test "returns a CInstruction given dest an comp" do
      {:ok, instruction} = Parser.parse("M=1")
      assert instruction == %CInstruction{comp: "1", dest: "M", jump: nil}
    end

    test "returns a CInstruction given comp and jump" do
      {:ok, instruction} = Parser.parse("0;JMP")
      assert instruction == %CInstruction{comp: "0", dest: nil, jump: "JMP"}
    end

    # TODO: symbols
  end

  describe "parsing labels" do
    test "returns a Label" do
      {:ok, label} = Parser.parse("(END)")
      assert label == %Label{name: "END"}
    end
  end

  describe "parsing comments" do
    test "returns nil" do
      assert Parser.parse("// This is a comment\n") == {:ok, nil}
    end

    test "returns nil when there is leading whitespace" do
      assert Parser.parse("  // Leading whitespace\n") == {:ok, nil}
    end

    test "returns the insctruction given an inline comment" do
      assert {:ok, %AInstruction{}} = Parser.parse("@0 // Comment\n")
    end
  end

  describe "parsing whitespace" do
    test "returns nil for newlines" do
      assert Parser.parse("\n") == {:ok, nil}
    end

    test "returns nil for tabs and spaces" do
      assert Parser.parse("\t \n") == {:ok, nil}
    end

    test "ignores leading and trailing whitespace in instructions" do
      assert {:ok, %AInstruction{}} = Parser.parse("  @123\n")
    end
  end

  # describe "parsing labels" do
  # end
end
