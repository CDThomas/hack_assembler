defmodule HackAssembler.Parser do
  @moduledoc """
  Parses Hack assembly (mnemonic) code into an internal representation of instructions. These instructions are later translated by `HackAssembler.Code.to_hack/1` to Hack machine (binary) code.
  """

  defmodule AInstruction do
    @type t :: %__MODULE__{address: non_neg_integer() | binary()}

    @enforce_keys [:address]
    defstruct [:address]
  end

  defmodule CInstruction do
    @type t :: %__MODULE__{
            comp: binary(),
            dest: binary() | nil,
            jump: binary() | nil
          }

    @enforce_keys [:comp]
    defstruct [:comp, :dest, :jump]
  end

  defmodule Label do
    @type t :: %__MODULE__{name: binary()}

    @enforce_keys [:name]
    defstruct [:name]
  end

  @type instruction :: AInstruction.t() | CInstruction.t()
  @type result :: instruction | Label.t() | nil

  @type error_reason :: :invalid_address
  @type parser_error :: {:error, error_reason()}

  @doc """
  Returns an internal representation of an instruction (wrapped in an `:ok` tuple) given a line of Hack assembly code.

  Returns `HackAssembler.Parser.AInstruction` or `HackAssembler.Parser.CInstruction` for A-instructions and C-instructions.

  Returns `HackAssembler.Parser.Label` for labels.

  Returns `nil` for empty instructions (e.g. whitespace and comments).

  Returns an `:error` tuple if there is an error parsing the instruction.
  """
  @spec parse(line :: binary()) :: {:ok, result()} | parser_error()
  def parse(line) do
    line
    |> trim_comment()
    |> String.trim()
    |> do_parse()
  end

  defp trim_comment(line) do
    String.replace(line, ~r/\/\/.*/, "")
  end

  defp do_parse("") do
    {:ok, nil}
  end

  defp do_parse("@" <> rest) do
    with {:ok, address} <- parse_address(rest) do
      {:ok, %AInstruction{address: address}}
    end
  end

  defp do_parse("(" <> rest) do
    name = String.trim(rest, ")")
    {:ok, %Label{name: name}}
  end

  defp do_parse(line) do
    {dest, rest} = parse_dest(line)
    {comp, jump} = parse_comp_and_jump(rest)

    {:ok, %CInstruction{comp: comp, dest: dest, jump: jump}}
  end

  defp parse_dest(line) do
    case String.split(line, "=") do
      [dest, rest] -> {dest, rest}
      [rest] -> {nil, rest}
    end
  end

  defp parse_comp_and_jump(line) do
    case String.split(line, ";") do
      [comp, jump] -> {comp, jump}
      [comp] -> {comp, nil}
    end
  end

  defp parse_address(address) do
    case Integer.parse(address) do
      {address, ""} when address >= 0 -> {:ok, address}
      :error -> {:ok, address}
      _ -> {:error, :invalid_address}
    end
  end
end
