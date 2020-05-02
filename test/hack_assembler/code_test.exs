defmodule HackAssembler.CodeTest do
  use ExUnit.Case

  alias HackAssembler.Code
  alias HackAssembler.Parser.AInstruction
  alias HackAssembler.Parser.CInstruction

  describe "translating A-instructions" do
    test "gives the correct code given an address of 0" do
      assert Code.to_hack(%AInstruction{address: 0}) == "0000000000000000"
    end

    test "gives the correct code given an address of 1" do
      assert Code.to_hack(%AInstruction{address: 1}) == "0000000000000001"
    end

    test "gives the correct code given an address of 20,000" do
      assert Code.to_hack(%AInstruction{address: 20_000}) == "0100111000100000"
    end
  end

  describe "translating C-instructions" do
    test "sets the correct op code and filler" do
      <<op_and_filler::binary-size(3), _address::binary-size(13)>> =
        Code.to_hack(%CInstruction{
          comp: "0",
          dest: "M",
          jump: nil
        })

      assert op_and_filler == "111"
    end

    test "sets the correct destination" do
      <<_::binary-size(10), dest::binary-size(3), _::binary-size(3)>> =
        Code.to_hack(%CInstruction{
          comp: "0",
          dest: "M",
          jump: nil
        })

      assert dest == "001"
    end

    test "sets the correct computation" do
      <<_::binary-size(3), comp::binary-size(7), _::binary-size(6)>> =
        Code.to_hack(%CInstruction{
          comp: "0",
          dest: "M",
          jump: nil
        })

      assert comp == "0101010"
    end

    test "sets the correct jump" do
      <<_::binary-size(13), jump::binary-size(3)>> =
        Code.to_hack(%CInstruction{
          comp: "0",
          dest: nil,
          jump: "JMP"
        })

      assert jump == "111"
    end

    test "returns the correct code given M=D" do
      hack =
        Code.to_hack(%CInstruction{
          comp: "M",
          dest: "D"
        })

      assert hack == "1111110000010000"
    end

    test "returns the correct coce given 0;JMP" do
      hack =
        Code.to_hack(%CInstruction{
          comp: "0",
          jump: "JMP"
        })

      assert hack == "1110101010000111"
    end
  end
end
