defmodule HackAssembler.ParserTest do
  use ExUnit.Case

  alias HackAssembler.Parser
  alias HackAssembler.Parser.AInstruction

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

  # describe "parsing C-instructions" do
  #   # TODO
  # end

  # describe "parsing comments" do
  #   test "returns nil" do
  #   end

  #   test "returns nil when there is leading whitespace" do
  #   end
  # end

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
