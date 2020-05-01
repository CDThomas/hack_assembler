defmodule HackAssembler.Parser do
  defmodule AInstruction do
    @type t :: %__MODULE__{address: non_neg_integer()}

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

  @type result :: AInstruction.t() | CInstruction.t() | nil

  @type error_reason :: :invalid_address
  @type parser_error :: {:error, error_reason()}

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
      _ -> {:error, :invalid_address}
    end
  end
end
