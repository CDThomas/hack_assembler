defmodule HackAssemblerTest do
  use ExUnit.Case
  doctest HackAssembler

  test "greets the world" do
    assert HackAssembler.hello() == :world
  end
end
